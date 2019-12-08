extends AnimationPlayer

var states = {
	"Attack":["Death", "Hit", "Idle-loop", "Jump", "Run-loop", "Walk"],
	"Death":[],
	"Gunplay":["Death", "Hit", "Idle-loop", "Jump", "Run-loop", "Walk"],
	"Hit":["Attack", "Death", "Hit", "Idle-loop", "Jump", "Run-loop", "Walk"],
	"Idle-loop":["Attack", "Death", "Gunplay", "Hit", "Idle-loop", "Jump", "Run-loop", "Walk"],
	"Jump":["Attack", "Death", "Idle-loop", "Walk", "Run-loop"],
	"Run-loop":["Attack", "Death", "Idle-loop", "Gunplay","Walk","Jump","Death"],
	"Walk":["Attack", "Death", "Gunplay", "Hit", "Idle-loop", "Jump", "Run-loop"],
	
	"default":["Death", "Idle-loop", "Walk", "Run-loop"]
}

var animation_speeds = {
	"Attack" : 1.5,
	"Death" : 1,
	"Gunplay" : 3,
	"Hit" : 1,
	"Idle-loop": 1,
	"Jump" : 1,
	"Run-loop": 1,
	"Walk" : 1,
	"default": 1
}

var current_state = null
var callback_function = null

func _ready():
	set_animation("Idle-loop")
	get_animation("Walk").set_loop(true)
	connect("animation_finished", self, "animation_ended")
	#get_animation('Jump').length = 1.1
	
func reset():
	set_animation("Idle-loop")
	
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

func animation_callback():
	if callback_function == null:
		pass
	else:
		callback_function.call_func()