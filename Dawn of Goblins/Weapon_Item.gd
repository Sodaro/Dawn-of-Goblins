extends Weapon

func init(var p_type, var p_damage, var p_knockbackForce, var p_excludearray):
	weaponType = p_type
	damage = p_damage
	p_knockbackForce = knockbackForce
	excludeArray = p_excludearray

func Attack():
	if !$AnimationPlayer.is_playing():
		$AnimationPlayer.play("MeleeSwing")

func _process(delta):
	$Cube/Hitbox.monitoring = $AnimationPlayer.is_playing()

func _on_Hitbox_body_entered(body):
	for exclusion in excludeArray:
		if body is exclusion:
			return
	var position: Vector3 = get_parent().get_translation()
	var enemyPos: Vector3 = body.get_translation()
	var hitDirection: Vector3 = (enemyPos - position).normalized()
	var hitForce: Vector3 = hitDirection * knockbackForce
	if body.has_method("take_damage"):
		body.take_damage(damage, hitForce)
