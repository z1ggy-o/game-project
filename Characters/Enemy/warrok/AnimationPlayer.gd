extends AnimationPlayer

var states = {
	"Attack": ["Attack", "Death", "Idle", "Run-loop", "Walk"],
	"Death": [],
	"Hit": ["Attack", "Death", "Idle", "Run-loop", "Walk"],
	"Idle":["Attack", "Death", "Idle", "Run-loop", "Walk"],
	"Walk":["Attack", "Idle", "Death", "Run-loop"],
	"default":["Idle", "Walk", "Death", "Run-loop"],
}

var animation_speeds = {
	"Attack": 1,
	"Death": 1,
	"Hit": 1,
	"Idle": 1,
	"Walk": 1,
	"default": 1
}

var t_firstDelay = get_parent().get_parent().get_node("timer_firstDelay")
var firstDelay = 0.8

var t_attackFinish = get_parent().get_parent().get_node("timer_attackFinish")
var attackFinish = 1.15

var t_closeAttack = get_parent().get_parent().get_node("timer_closeAttack")

var current_state = null
var callback_function = null

func _ready():
	set_animation("Idle-loop")
	get_animation("Walk").set_loop(true)
	#connect("animation_finished", self, "animation_ended")
	
	t_firstDelay.set_wait_time(firstDelay)
	t_attackFinish.set_wait_time(attackFinish)
	t_closeAttack.stop()

	
func set_animation(animation_name):
	if animation_name == current_state:
		return true
		
	if has_animation(animation_name) == true:
		if current_state != null:
			var possible_animations = states[current_state]
			if animation_name in possible_animations:
				current_state = animation_name
				t_closeAttack.start()
				t_firstDelay.start()
				t_attackFinish.start()
				play(animation_name, -1, animation_speeds[animation_name])
				return true
			else:
				print ("AnimationPlayer_Manager.gd -- WARNING: Cannot change to ", animation_name, " from ", current_state)
				return false
		else:
			current_state = animation_name
			t_closeAttack.start()
			t_firstDelay.start()
			t_attackFinish.start()
			play(animation_name, -1, animation_speeds[animation_name])
			return true
	return false