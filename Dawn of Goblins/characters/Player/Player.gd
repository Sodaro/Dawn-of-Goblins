extends KinematicBody

class_name Player

var speed : float = 10.0
var velocity: Vector3

var facingDirection = Vector3.ZERO
var lastDirection = Vector3.ZERO

var goblins: Array = []
export(NodePath) var cameraSpatial
var camera

var meleeDamage: int = 5

var heldWeapon: Node

func _ready():
	goblins.append(self)
	camera = get_node(cameraSpatial).GetCamera()


func _process(delta):

	var position = get_translation()
	velocity = Vector3.ZERO
	
	var horizontal = (Input.get_action_strength("right") - Input.get_action_strength("left"))
	var forward = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	var moveDirection = Vector3(horizontal, 0, forward).normalized()

	
	if Input.is_action_just_pressed("attack"):
		if heldWeapon:
			heldWeapon.Attack()
	
	
	velocity = moveDirection.rotated(Vector3.UP, rotation.y) * speed
	if velocity != Vector3.ZERO:
		move_and_slide(velocity, Vector3.UP, false)
	

	
func _physics_process(delta):
	var mousePos = get_viewport().get_mouse_position()
	var space_state = get_world().get_direct_space_state()
	var from = camera.project_ray_origin(mousePos)
	var to = from + camera.project_ray_normal(mousePos) * 1000
	var result = space_state.intersect_ray(from, to, [self])
	if result:
		var lookPos = Vector3(result.position.x, get_translation().y, result.position.z)
		facingDirection = lookPos.normalized()
		LookAtPosition(lookPos)
		if (facingDirection):
			lastDirection = facingDirection


func AddGoblin(var goblin):
	goblin.connect("friendly_died", self, "_on_Goblin_friendly_died", [goblin])
	goblins.append(goblin)


func _on_Goblin_friendly_died(goblin):
	print(goblin.get_name() + " has died")
	var index = goblins.find(goblin)
	if index != goblins.size() -1:
		goblins[index+1].friendlyTarget = goblins[index-1]
	goblins.erase(goblin)
	

	
func GetFriendlyFollowTarget(var callerObject):
	var index = goblins.find(callerObject)
	return goblins[index-1]

func PickUpWeapon(var weapon):
	if heldWeapon:
		for goblin in goblins:
			if goblin.heldWeapon == null:
				goblin.PickUpWeapon(weapon)
				break
	else:
		heldWeapon = weapon
		$Weapon.add_child(heldWeapon)

func LookAtPosition(var position: Vector3) -> void:
	if position == get_translation():
		return
	else:
		look_at(position, Vector3.UP)
