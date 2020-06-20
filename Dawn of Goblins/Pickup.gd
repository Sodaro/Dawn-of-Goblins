extends Weapon


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var weaponScene = preload("res://objects/sword/sword_weapon.tscn")

func _on_PickupArea_body_entered(body):
	if body.has_method("PickUpWeapon"):
		
		var weaponInstance = weaponScene.instance()
		if body is Player || body is Goblin:
			excludeArray = [Player, Goblin]
			
		if body is Human:
			excludeArray = [Human]
			
		weaponInstance.init(weaponType, damage, knockbackForce, excludeArray)
		body.PickUpWeapon(weaponInstance)
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
