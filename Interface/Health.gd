extends HBoxContainer



func _on_Interface_health_changed(health, Max_health):
	$Bar.value = health
	$Bar.max_value = Max_health
