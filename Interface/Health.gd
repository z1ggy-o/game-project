extends HBoxContainer



func _on_Interface_health_changed(health):
	$Bar.value = health
