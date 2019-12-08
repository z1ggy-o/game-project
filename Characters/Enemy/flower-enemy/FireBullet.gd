extends KinematicBody

var direction = Vector3()
export(float) var SPEED = 10
var damage = 0

func _ready():
	set_as_toplevel(true)
	
func _physics_process(delta):
	if is_outside_view_bounds():
		queue_free()
	
	var motion = direction * SPEED * delta
	var collision_info = move_and_collide(motion)
	if collision_info:
		queue_free()
		if collision_info.get_collider().is_in_group("Player"):
			collision_info.get_collider().take_damage(damage)

func set_damage(d):
	damage = d
	
func is_outside_view_bounds():
	pass