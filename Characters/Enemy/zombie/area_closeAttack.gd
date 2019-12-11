extends Area



func _on_area_closeAttack_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage(get_parent().DAMAGE)
