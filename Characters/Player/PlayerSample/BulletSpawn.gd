extends Node

var bullet = preload("res://Characters/Player/PlayerSample/Bullet.tscn")

var damage = 0

func _input(event):
	if event.is_action_pressed("fire") and get_parent().SHOOT > 0:
		fire(get_parent().global_transform.basis.z)

func set_damage(d):
	damage = d
		
func fire(direction):
	if not $CooldownTimer.is_stopped():
		return
	print(direction)
	$CooldownTimer.start()
	var new_bullet = bullet.instance()
	new_bullet.direction = direction
	new_bullet.global_transform.origin = get_parent().get_node("bulletStart").global_transform.origin
	new_bullet.set_damage(damage)
	add_child(new_bullet)
	
