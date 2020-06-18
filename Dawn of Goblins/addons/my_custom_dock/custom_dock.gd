tool
extends EditorPlugin

var dock
var eds = get_editor_interface().get_selection()

var file_dialog

var undo_redo = get_undo_redo()

func _enter_tree():
	eds.connect("selection_changed", self, "_on_Selection_Changed")
	CreateDock()


func CreateFileDialog():
	file_dialog = FileDialog.new()
	file_dialog.mode = FileDialog.MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	file_dialog.add_filter("*.tscn ; Scenes")
	file_dialog.connect("file_selected", self, "_on_FileDialog_file_selected")
	add_child(file_dialog)
	
func CreateDock():
	dock = preload("res://LevelEditor.tscn").instance()
	dock.connect("open_dialog", self, "_on_Open_Dialog")
	add_control_to_dock(DOCK_SLOT_LEFT_UL, dock)

func _exit_tree():
	remove_control_from_docks(dock)
	if dock:
		dock.free()
	
func _on_Selection_Changed():
	if !dock:
		CreateDock()
	var selected = eds.get_selected_nodes()
	if !selected.empty():
		for obj in selected:
			print(obj.name)
		dock.ChangeParent(selected[0])

func _on_Open_Dialog():
	print("received signal")
	if !file_dialog:
		CreateFileDialog()
	file_dialog.popup_centered(Vector2(400, 200))


func _on_FileDialog_file_selected(var path):
	if !dock:
		CreateDock()
	dock.SetSceneToSpawn(path)
