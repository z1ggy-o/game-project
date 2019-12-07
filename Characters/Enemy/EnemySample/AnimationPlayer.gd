extends AnimationPlayer

var states = {
	"Attack": ["Attack", "Death", "Idle-loop", "Run-loop", "Walk-loop"],
	"Death": [],
	"Hit": ["Attack", "Death", "Idle-loop", "Run-loop", "Walk-loop"],
	"Idle-loop":["Attack", "Death", "Idle-loop", "Run-loop", "Walk-loop"],
	"Walk-loop":["Idle-loop", "Death", "Run-loop"],
	"Run-loop":["Idle-loop","Walk-loop","Death"],
	"default":["Idle-loop", "Walk-loop", "Death", "Run-loop"],
}

var animation_speeds = {
	"Attack": 1,
	"Death": 1,
	"Hit": 1,
	"Idle-loop": 1,
	"Run-loop": 1,
	"Walk-loop": 2,
	"default": 1
}


var current_state = null
var callback_function = null

func _ready():
	set_animation("Idle-loop")
	get_animation("Walk-loop").set_loop(true)
	connect("animation_finished", self, "animation_ended")
	
func set_animation(animation_name):
	if animation_name == current_state:
		return true
		
	if has_animation(animation_name) == true:
		if current_state != null:
			var possible_animations = states[current_state]
			if animation_name in possible_animations:
				current_state = animation_name
				play(animation_name, -1, animation_speeds[animation_name])
				return true
			else:
				print ("AnimationPlayer_Manager.gd -- WARNING: Cannot change to ", animation_name, " from ", current_state)
				return false
		else:
			current_state = animation_name
			play(animation_name, -1, animation_speeds[animation_name])
			return true
	return false
	
func animation_ended(anim_name):
	# UNARMED transitions
	if current_state == "Idle-loop":
		return
	# KNIFE transitions
	elif current_state == "Walk":
		pass
	elif current_state == "default":
		pass

func firstDelayFinished(string):
	print("test")
	owner.firstDelayFinished()
	
func attackFinished():
	owner.attackFinished()
	
func asdfasdf():
	print("ttt")