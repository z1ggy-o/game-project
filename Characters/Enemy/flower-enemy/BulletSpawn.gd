extends Node

var damage
var bullet = preload("FireBullet.tscn")

func fire(direction):
	if not $CooldownTimer.is_stopped():
		return
	#print(direction)
	$CooldownTimer.start()
	var new_bullet = bullet.instance()
	new_bullet.direction = direction
	new_bullet.global_transform.origin = get_parent().get_node("bulletStart").global_transform.origin
	new_bullet.set_damage(damage)
	add_child(new_bullet)

func set_damage(d):
	damage = d