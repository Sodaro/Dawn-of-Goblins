extends Entity

class_name Goblin
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#const Enemy = preload("res://Enemy.gd")

func _ready():
	._ready()
	#$sword/AnimationPlayer.playback_speed = attackSpeed


func _on_RecruitArea_body_entered(body):
	if body.get_name() == "Player":
		body.AddGoblin(self)
		friendlyTarget = body.GetFriendlyFollowTarget(self)
		#print(target)
		$RecruitArea.disconnect("body_entered", self, "_on_RecruitArea_body_entered")
