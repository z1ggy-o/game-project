extends Area


func _on_Area_body_entered(body):
	if body.is_in_group("Enemy"):
		#print(body)
		if body.has_method("take_damage"):
			body.take_damage(get_parent().DAMAGE)
