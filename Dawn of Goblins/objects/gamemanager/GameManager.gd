extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var tents: Array = []
var destroyedTents: int = 0
var totalTents

signal check_win

# Called when the node enters the scene tree for the first time.
func _ready():
	tents = get_tree().get_nodes_in_group("Tents")
	for tent in tents:
		tent.connect("tent_destroyed", self, "_on_Tent_Destroyed")
	
	totalTents = tents.size()
	connect("check_win", self, "_on_Check_Win")

func _on_Tent_Destroyed():
	destroyedTents += 1
	emit_signal("check_win")
	
	
func _on_Check_Win():
	if destroyedTents >= totalTents:
		print("You Win!")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
