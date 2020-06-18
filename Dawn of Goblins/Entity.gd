extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

class_name Entity

enum enemyType {Goblin, Human}
var enemy
var canBeRecruited: bool = false

export(enemyType) var enemyClass


var gravity: float = 0

export(float) var gravityForce = 5


export(float) var speed = 5.0
export(float) var attackSpeed = 4

export(int) var health_max = 10
var health_current:float = health_max
signal health_changed

var friendlyTarget: Node
var enemyTargets: Array = []
var velocity = Vector3.ZERO
var lastDirection = Vector3.ZERO

signal friendly_died

var heldWeapon: Node
#var currentWeapon = Globals.WeaponType.None

var currentStatus: int = Globals.StatusEffects.None

var isAttacking : bool = false

func _ready():
	if enemyClass == enemyType.Goblin:
		enemy = load("res://Goblin.gd")
	elif enemyClass == enemyType.Human:
		enemy = load("res://Human.gd")


func _physics_process(delta):
	
	if currentStatus != Globals.StatusEffects.Stunned:
		if enemyTargets.size() > 0 && heldWeapon:
			KillEnemy(delta)
		elif friendlyTarget:
			FollowFriendly(delta)
			
	if is_on_floor():
		gravity = 0
	else:
		gravity += gravityForce * delta
		
	velocity.x -= velocity.x * delta
	velocity.z -= velocity.z * delta
		
	velocity.y -= gravity
	move_and_slide(velocity, Vector3.UP, false)
#	isAttacking = $sword/AnimationPlayer.is_playing()
#	if isAttacking: return
	
	#if !enemyTargets.empty() && hasWeapon:



func PickUpWeapon(var weapon):
	heldWeapon = weapon
	$Weapon.add_child(heldWeapon)


func KillEnemy(delta):
	var position: Vector3 = get_translation()
	var nearestEnemy: Node
	for enemy in enemyTargets:
		var wr = weakref(enemy)
		if !wr.get_ref():
			enemyTargets.erase(enemy)
		else:
			if nearestEnemy == null:
				nearestEnemy = enemy
			elif position.distance_to(enemy.get_translation()) < position.distance_to(nearestEnemy.get_translation()):
				nearestEnemy = enemy
			
	var wr = weakref(nearestEnemy)
	if !wr.get_ref(): return
	var nearestEnemyPos: Vector3 = nearestEnemy.get_translation()
	nearestEnemyPos.y = position.y
	var targetPos: Vector3 = (nearestEnemyPos - ((position + nearestEnemyPos).normalized() * 2))
	var distance: float = position.distance_to(targetPos)
	if distance > 4:
		MoveTowardsPosition(position, targetPos, delta)
	else:
		LookAtPosition(nearestEnemyPos)
		velocity = Vector3.ZERO
		if heldWeapon:
			heldWeapon.Attack()
			#$sword.Swing()


func FollowFriendly(delta):
	var position: Vector3 = get_translation()
	var targetSpeed: float = friendlyTarget.get("speed")
	var targetVelocity = friendlyTarget.get("velocity")

	var targetPos: Vector3 = friendlyTarget.get_translation() - (friendlyTarget.get("lastDirection") * 4)
	targetPos.y = position.y
	var facingDirection: Vector3 = (targetPos - position).normalized()
	
	var distance: float = position.distance_to(targetPos)
	if distance > 4:
		MoveTowardsFriendly(position, targetPos, targetSpeed)
	else:
		LookAtPosition(friendlyTarget.get_translation())
		
	if targetVelocity == Vector3.ZERO:
		velocity = Vector3.ZERO


func MoveTowardsPosition(var position, var target_position, var delta):
	var facingDirection: Vector3 = (target_position - position).normalized()
	facingDirection.y = 0
	velocity += facingDirection * speed
	velocity = Globals.ClampedVector3(velocity, -speed, speed)
	#move_and_slide(velocity, Vector3.UP, false)
	if facingDirection:
		lastDirection = facingDirection
	LookAtPosition(target_position)
	
func MoveTowardsFriendly(var position, var target_position, var target_speed):
	var facingDirection: Vector3 = (target_position - position).normalized()
	
	velocity += facingDirection * speed
	if target_speed != 0:
		velocity = Globals.ClampedVector3(velocity, -target_speed, target_speed)
	else:
		velocity = Globals.ClampedVector3(velocity, -speed, speed)
	#move_and_slide(velocity, Vector3.UP, false)
	if facingDirection:
		lastDirection = facingDirection
	


func take_damage(var amount: int, var knockback: Vector3):
	health_current -= amount
	emit_signal("health_changed", health_current)
	if health_current <= 0:
		emit_signal("friendly_died")
		queue_free()
	else:
		velocity += knockback


func _on_AggroArea_body_entered(body: Entity):
	if body is enemy:
		enemyTargets.append(body)

func LookAtPosition(var position: Vector3) -> void:
	if position == get_translation():
		return
	else:
		look_at(position, Vector3.UP)
