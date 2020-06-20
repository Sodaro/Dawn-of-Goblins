extends KinematicBody

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
signal death
signal entered_combat
signal left_combat

var corpse

var heldWeapon: Node

var isInCombat: bool = false
var isCaptured: bool = false

#var currentWeapon = Globals.WeaponType.None

var currentStatus: int = Globals.StatusEffects.None

var isAttacking : bool = false

func _ready():
	if get_signal_connection_list("death").size() == 0:
		connect("death", self, "_on_Death")
	if enemyClass == enemyType.Goblin:
		enemy = load("res://characters/Goblin/Goblin.gd")
		corpse = load("res://characters/Human/Human_Corpse.tscn")
	elif enemyClass == enemyType.Human:
		enemy = load("res://characters/Human/Human.gd")
		corpse = load("res://characters/Goblin/Goblin_Corpse.tscn")


func _physics_process(delta):
	if currentStatus != Globals.StatusEffects.Stunned:
		if !isCaptured:
			if HasThreats():
				if !isInCombat:
					emit_signal("entered_combat")
					isInCombat = true
				if heldWeapon:
					KillEnemy(delta)
			elif isInCombat:
				emit_signal("left_combat")
				isInCombat = false
			elif friendlyTarget:
				FollowFriendly(delta)
		elif isCaptured:
			if !HasThreats() && friendlyTarget:
				isCaptured = false
	else:
		velocity.x *= 0.9
		velocity.z *= 0.9
			
	if is_on_floor():
		gravity = 0
		currentStatus = Globals.StatusEffects.None
	else:
		gravity += gravityForce * delta
		velocity.y -= gravity

		

		
	
	if velocity != Vector3.ZERO:
		if $body/AnimationPlayer.current_animation != "Walk":
			$body/AnimationPlayer.play("Walk")
		move_and_slide(velocity, Vector3.UP, false)
	else:
		if $body/AnimationPlayer.current_animation != "Idle":
			$body/AnimationPlayer.play("Idle")
#	isAttacking = $sword/AnimationPlayer.is_playing()
#	if isAttacking: return
	
	#if !enemyTargets.empty() && hasWeapon:

func HasThreats() -> bool:
	if enemyTargets.size() > 0:
		for entity in enemyTargets:
			var wr = weakref(entity)
			if !wr.get_ref():
				enemyTargets.erase(entity)
			elif entity.heldWeapon:
				return true
	return false


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
	

	var targetPos: Vector3 = friendlyTarget.get_translation()
	var offset = friendlyTarget.get("lastDirection") * -16
	targetPos += offset
	#print("pos: " + String(position) + " targetPos:" + String(targetPos))
	
	#targetPos = targetPos + offset
	targetPos.y = position.y
	#print(offset)

	#var facingDirection: Vector3 = (targetPos - position).normalized()
	
	LookAtPosition(targetPos)
	
	var distance: float = position.distance_to(targetPos)
	
	velocity = (targetPos - position).normalized() * targetSpeed
	#velocity = (targetPos - position).normalized() * delta * moveSpeed
	if distance < 8 && targetVelocity == Vector3.ZERO:
		velocity = Vector3.ZERO
			
		#print(velocity)
#	else:
#		LookAtPosition(friendlyTarget.get_translation())
	#MoveTowardsFriendly(position, targetPos, targetVelocity)

		 #enemy not a prisoner and self not prisoner



func MoveTowardsPosition(var position, var target_position, var delta):
	var facingDirection: Vector3 = (target_position - position).normalized()
	facingDirection.y = 0
	velocity += facingDirection * speed
	velocity = Globals.ClampedVector3(velocity, -speed, speed)
	#move_and_slide(velocity, Vector3.UP, false)
	if facingDirection:
		lastDirection = facingDirection
	LookAtPosition(target_position)
	
func MoveTowardsFriendly(var position, var target_position, var targetVelocity):
	var facingDirection: Vector3 = (target_position - position).normalized()
	
	#velocity += facingDirection * target_speed
	if targetVelocity != Vector3.ZERO:
		velocity = facingDirection * targetVelocity.length()
	else:
		velocity += facingDirection * speed
		
	
	#move_and_slide(velocity, Vector3.UP, false)
	if facingDirection:
		lastDirection = facingDirection
	


func take_damage(var amount: int, var knockback: Vector3):
	health_current -= amount
	emit_signal("health_changed", health_current)
	if health_current <= 0:
		emit_signal("friendly_died")
		emit_signal("death")
	else:
		velocity += knockback

func _on_Death():
	var corpseInstance = corpse.instance()
	get_parent().add_child(corpseInstance)
	corpseInstance.transform.origin = transform.origin
	corpseInstance.rotate_y(deg2rad(90))
	
	queue_free()
	

func _on_AggroArea_body_entered(body: Entity):
	if body is enemy:
		enemyTargets.append(body)
#		isInCombat = true
#		emit_signal("entered_combat")

func LookAtPosition(var position: Vector3) -> void:
	if position == get_translation():
		return
	else:
		look_at(position, Vector3.UP)
