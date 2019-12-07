extends Control

onready var health_bar = $HeatlhBar

func _on_health_updated(health):
	health_bar.value = health
	#update_tween.interpolate_property(health_bar, "value", health_bar.value, health, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	#update_tween.start()
	
func _on_max_health_updated(max_health):
	health_bar.max_value = max_health

func _on_Player_health_updated(health):
	_on_health_updated(health)
	pass # Replace with function body.
