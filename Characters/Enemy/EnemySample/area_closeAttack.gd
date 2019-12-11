extends Area



func _on_area_closeAttack_body_entered(body):
	if body.is_group_of("Player"):
		if body.has_method("take_damage"):
			body.take_damage(20)
