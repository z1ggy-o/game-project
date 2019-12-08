extends Control

onready var health_bar = $HealthBar

func _on_health_updated(health, max_health):
	health_bar.value = health
	health_bar.max_value = max_health
	#update_tween.interpolate_property(health_bar, "value", health_bar.value, health, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	#update_tween.start()

func _on_Player_health_updated(health, max_health):
	_on_health_updated(health, max_health)
	pass # Replace with function body.
