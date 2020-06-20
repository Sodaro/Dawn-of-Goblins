extends Entity

class_name Human

var swordScene = preload("res://objects/sword/sword_weapon.tscn")
var weaponScript = preload("res://globalscripts/Weapon.gd")

func _ready():
	._ready()
	#$sword/AnimationPlayer.playback_speed = attackSpeed
	
