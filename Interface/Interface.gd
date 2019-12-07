extends Control

signal health_changed(health)

func _on_Player_health_updated(health):
	emit_signal("health_changed", health)
