tool
extends Control

var sceneToSpawnPath: String
var parent: Node
var sceneToSpawn

var parentNewChild = false
var file_dialog : FileDialog

var count = 1

signal open_dialog

#func CreateFileDialog():
#	file_dialog = FileDialog.new()
#	file_dialog.mode = FileDialog.MODE_OPEN_FILE
#	file_dialog.access = FileDialog.ACCESS_RESOURCES
#	file_dialog.add_filter("*.tscn ; Scenes")
#	file_dialog.connect("file_selected", self, "_on_FileDialog_file_selected")
#	add_child(file_dialog)

func _ready():
	var floatInputs: Array = get_tree().get_nodes_in_group("FloatInputs")
	for member in floatInputs:
		member.connect("focus_exited", self, "ValidateFloatInput", [member])
		member.connect("text_entered", self, "ValidateFloatInput2", [member])
	parentNewChild = $HBoxContainer/VBoxContainer/ParentCheckbox.is_pressed()

func _on_ObjectButton_button_down():
	emit_signal("open_dialog")
	#file_dialog.popup_centered(Vector2(400, 200))
	
func _on_FileDialog_file_selected(path):
	sceneToSpawnPath = path
	#print("node: " + path + " will have parent:" + parent)


#func _on_ParentButton_button_down():
#	get_all_children(get_tree().get_root())
#	$TreeList.show()


#func get_all_children(var node: Node):
#	for child in node.get_children():
#		var childName: String = child.get_path()
#		if childName.count("@") <= 0:
#			$TreeList.add_item(childName)
#		if child.get_child_count() > 0:
#			get_all_children(child)

#func _on_CloseTreeButton_button_down():
#	CloseTreeList()
	

func ChangeParent(var p_parent):
	parent = p_parent

#func _on_TreeList_item_activated(index):
#	var selectedPath = $TreeList.get_item_text(index)
#	parent = get_node(selectedPath)
#	print(parent.name)
#	CloseTreeList()

#func CloseTreeList():
#	$TreeList.hide()
#	$TreeList.clear()
func SetSceneToSpawn(var path: String):
	sceneToSpawnPath = path
	sceneToSpawn = load(sceneToSpawnPath)
	var shortenedPath: String = path.substr(path.find_last("/"))
	shortenedPath = shortenedPath.replace("/", "")
	$HBoxContainer/VBoxContainer/ObjectSelectCont/NameLabel.text = shortenedPath

func CreateNodes():
	if parent != null && sceneToSpawnPath != null:
		parentNewChild = $HBoxContainer/VBoxContainer/ParentCheckbox.is_pressed()
		
	var offset: Vector3 = GetOffset()
	var initialOffset: Vector3 = GetInitialOffset()
	var rotation: Vector3 = GetRotation()
	for i in range (1, count+1):
		var sceneInstance: Node = sceneToSpawn.instance()
		UnRotateNode(sceneInstance)
		sceneInstance.rotate_x(deg2rad(rotation.x))
		sceneInstance.rotate_y(deg2rad(rotation.y))
		sceneInstance.rotate_z(deg2rad(rotation.z))
		var instanceOffset
		if initialOffset != Vector3.ZERO:
			instanceOffset = initialOffset + (offset * (i-1))
		else:
			instanceOffset = offset * i
			
		if parentNewChild:
			parent.add_child(sceneInstance)
			sceneInstance.set_owner(get_tree().get_edited_scene_root())
		else:
			sceneInstance.set_owner(get_tree().get_edited_scene_root()) #parent of leveleditor
		
		sceneInstance.transform.origin = instanceOffset


func UnRotateNode(var node):
	var nodeRotation = node.get_rotation()
	
	if nodeRotation == Vector3.ZERO: return
	
	node.rotate_z(-nodeRotation.z)
	node.rotate_y(-nodeRotation.y)
	node.rotate_x(-nodeRotation.x)
	print(nodeRotation + " -> " + node.get_rotation())


func ValidateFloatInput(node):
	var nodeText: String = node.text
	if !nodeText.is_valid_float():
		nodeText = "0"
		node.text = nodeText
	

func ValidateFloatInput2(text, node):
	var nodeText: String = text
	if !nodeText.is_valid_float():
		nodeText = "0"
		node.text = nodeText

func _on_CreateButton_button_down():
	CreateNodes()


func SetParent(var p_parent):
	parent = p_parent
	print("new parent: " + parent.name)

func GetOffset() -> Vector3:
	var offset: Vector3
	offset.x = float(get_node("HBoxContainer/OffsetContainer/HBoxContainer/X").text)
	offset.y = float(get_node("HBoxContainer/OffsetContainer/HBoxContainer/Y").text)
	offset.z = float(get_node("HBoxContainer/OffsetContainer/HBoxContainer/Z").text)
	return offset
	
	
func GetInitialOffset() -> Vector3:
	var initialOffset: Vector3
	initialOffset.x = float(get_node("HBoxContainer/OffsetContainer/HBoxContainer2/InitialX").text)
	initialOffset.y = float(get_node("HBoxContainer/OffsetContainer/HBoxContainer2/InitialY").text)
	initialOffset.z = float(get_node("HBoxContainer/OffsetContainer/HBoxContainer2/InitialZ").text)
	return initialOffset

func GetRotation() -> Vector3:
	var rotation: Vector3
	rotation.x = float(get_node("HBoxContainer/OffsetContainer/RotationContainer/RotX").text)
	rotation.y = float(get_node("HBoxContainer/OffsetContainer/RotationContainer/RotY").text)
	rotation.z = float(get_node("HBoxContainer/OffsetContainer/RotationContainer/RotZ").text)
	return rotation

#
#func _on_X_focus_exited(var isInitialOffset: bool):
#	var node
#	if isInitialOffset:
#		node = get_node("HBoxContainer/OffsetContainer/HBoxContainer2/InitialX")
#	else:
#		node = get_node("HBoxContainer/OffsetContainer/HBoxContainer/X")
#
#	#offset.x = float(nodeText)
#
#
#func _on_Y_focus_exited(var isInitialOffset: bool):
#	var node
#	if isInitialOffset:
#		node = get_node("HBoxContainer/OffsetContainer/HBoxContainer2/InitialY")
#	else:
#		node = get_node("HBoxContainer/OffsetContainer/HBoxContainer/Y")
#	var nodeText: String = node.text
#	if !nodeText.is_valid_float():
#		nodeText = "0"
#		node.text = nodeText
#	#offset.y = float(nodeText)
#
#
#func _on_Z_focus_exited(var isInitialOffset: bool):
#	var node
#	if isInitialOffset:
#		node = get_node("HBoxContainer/OffsetContainer/HBoxContainer2/InitialZ")
#	else:
#		node = get_node("HBoxContainer/OffsetContainer/HBoxContainer/Z")
#	var nodeText: String = node.text
#	if !nodeText.is_valid_float():
#		nodeText = "0"
#		node.text = nodeText
#	#offset.z = float(nodeText)


func _on_CountLine_focus_exited():
	var nodeText: String = get_node("HBoxContainer/OffsetContainer/CountLine").text
	if !nodeText.is_valid_integer():
		nodeText = "1"
		get_node("HBoxContainer/OffsetContainer/CountLine").text = nodeText
	count = int(nodeText)
#
#
#
#func _on_X_text_entered(new_text):
#	var nodeText: String = get_node("HBoxContainer/OffsetContainer/HBoxContainer/X").text
#	if !nodeText.is_valid_float():
#		nodeText = "0"
#		get_node("HBoxContainer/OffsetContainer/HBoxContainer/X").text = nodeText
#	#offset.z = float(nodeText)
#	get_node("HBoxContainer/OffsetContainer/HBoxContainer/Y").grab_focus()
#
#
#func _on_Y_text_entered(new_text):
#	var nodeText: String = new_text
#	if !nodeText.is_valid_float():
#		nodeText = "0"
#		get_node("HBoxContainer/OffsetContainer/HBoxContainer/Y").text = nodeText
#	#offset.z = float(nodeText)
#	get_node("HBoxContainer/OffsetContainer/HBoxContainer/Z").grab_focus()
#
#func _on_Z_text_entered(new_text):
#	var nodeText: String = new_text
#	if !nodeText.is_valid_float():
#		nodeText = "0"
#		get_node("HBoxContainer/OffsetContainer/HBoxContainer/Z").text = nodeText
#	#offset.z = float(nodeText)
#	get_node("HBoxContainer/OffsetContainer/RotationContainer/RotX").grab_focus()


func _on_CountLine_text_entered(new_text):
	var nodeText: String = new_text
	if !nodeText.is_valid_integer():
		nodeText = "1"
		get_node("HBoxContainer/OffsetContainer/CountLine").text = nodeText
	#count = int(nodeText)
	get_node("HBoxContainer/VBoxContainer/CreateButton").grab_focus()

#
#func _on_RotX_text_entered(new_text):
#	var nodeText: String = new_text
#	if !nodeText.is_valid_float():
#		nodeText = "0"
#		get_node("HBoxContainer/OffsetContainer/RotationContainer/RotX").text = nodeText
#	get_node("HBoxContainer/OffsetContainer/RotationContainer/RotY").grab_focus()
#
#func _on_RotY_text_entered(new_text):
#	var nodeText: String = new_text
#	if !nodeText.is_valid_float():
#		nodeText = "0"
#		get_node("HBoxContainer/OffsetContainer/RotationContainer/RotY").text = nodeText
#	get_node("HBoxContainer/OffsetContainer/RotationContainer/RotZ").grab_focus()
#
#func _on_RotZ_text_entered(new_text):
#	var nodeText: String = new_text
#	if !nodeText.is_valid_float():
#		nodeText = "0"
#		get_node("HBoxContainer/OffsetContainer/RotationContainer/RotZ").text = nodeText
#	#offset.z = float(nodeText)
#	get_node("HBoxContainer/OffsetContainer/CountLine").grab_focus()
#
#
#func _on_RotX_focus_exited():
#	var nodeText: String = get_node("HBoxContainer/OffsetContainer/RotationContainer/RotX").text
#	if !nodeText.is_valid_float():
#		nodeText = "0"
#		get_node("HBoxContainer/OffsetContainer/RotationContainer/RotX").text = nodeText
#
#
#func _on_RotY_focus_exited():
#	var nodeText: String = get_node("HBoxContainer/OffsetContainer/RotationContainer/RotY").text
#	if !nodeText.is_valid_float():
#		nodeText = "0"
#		get_node("HBoxContainer/OffsetContainer/RotationContainer/RotY").text = nodeText
#
#
#func _on_RotZ_focus_exited():
#	var nodeText: String = get_node("HBoxContainer/OffsetContainer/RotationContainer/RotZ").text
#	if !nodeText.is_valid_float():
#		nodeText = "0"
#		get_node("HBoxContainer/OffsetContainer/RotationContainer/RotZ").text = nodeText
