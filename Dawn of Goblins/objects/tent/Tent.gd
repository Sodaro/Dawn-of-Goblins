extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(int) var health_max = 50
var health_current: float = health_max
signal health_changed

signal tent_destroyed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func take_damage(var amount: int, var knockbackForce):
	health_current -= amount
	emit_signal("health_changed", health_current)
	print(health_current)
	if health_current <= 0:
		emit_signal("tent_destroyed")
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
