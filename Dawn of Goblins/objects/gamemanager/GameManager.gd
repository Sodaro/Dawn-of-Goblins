extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var tents: Array = []
var destroyedTents: int = 0
var totalTents

var goblinsInCombat: Array = []

signal check_win

var peaceMusic = load("res://audio/Cosmin Mirza - 04 Bygone.ogg")
var battleMusic = load("res://audio/Cosmin Mirza - 05 Flesh & Bones.ogg")

# Called when the node enters the scene tree for the first time.
func _ready():
	var goblins = get_tree().get_nodes_in_group("Goblins")
	for goblin in goblins:
		goblin.connect("entered_combat", self, "_on_Goblin_Entered_Combat", [goblin])
		goblin.connect("left_combat", self, "_on_Goblin_Left_Combat", [goblin])
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
		
		
func _on_Goblin_Entered_Combat(goblin):
	goblinsInCombat.append(goblin)
	print(goblin.name + " entered combat")
	if $MusicPlayer.stream != battleMusic:
		$MusicPlayer.stop()
		$MusicPlayer.stream = battleMusic
		$MusicPlayer.play()
	
	
func _on_Goblin_Left_Combat(goblin):
	goblinsInCombat.erase(goblin)
	if $MusicPlayer.stream != peaceMusic && goblinsInCombat.size() == 0:
		$MusicPlayer.stop()
		$MusicPlayer.stream = peaceMusic
		$MusicPlayer.play()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
