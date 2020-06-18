extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


enum StatusEffects {None, Stunned}

static func ClampedVector3(var vector: Vector3, var minFloat: float, var maxFloat: float) -> Vector3:
	vector.x = clamp(vector.x, minFloat, maxFloat)
	vector.y = clamp(vector.y, minFloat, maxFloat)
	vector.z = clamp(vector.z, minFloat, maxFloat)
	return vector
	
	


func CreateWeapon(var type):
#	match type:
#		WeaponType.Sword:
#			pass
# Called when the node enters the scene tree for the first time.
#func _ready():
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
