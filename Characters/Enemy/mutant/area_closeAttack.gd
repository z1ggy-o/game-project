extends Area



func _on_area_closeAttack_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			print(get_parent().DAMAGE)
			body.take_damage(get_parent().DAMAGE)
