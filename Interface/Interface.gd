extends Control

signal health_changed(health)

func _on_Player_health_updated(health, Max_health):
	emit_signal("health_changed", health, Max_health)


func _on_Player_Abilup(abil):
	$Abil.get_text(abil)
	pass # Replace with function body.
