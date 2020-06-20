extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var health_max
var health_current: float

var initial_scale: Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent()
	parent.connect("health_changed", self, "_on_Health_Changed")
	health_max = parent.get("health_max")
	health_current = parent.get("health_current")
	initial_scale = $Fill.get_scale()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_Health_Changed(var new_value):
	if visible == false:
		visible = true
	health_current = new_value
	$Fill.set_scale(Vector3(float(health_current/health_max * initial_scale.x), initial_scale.y, initial_scale.z))
