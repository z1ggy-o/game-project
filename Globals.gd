extends Node

# ------------------
# zgy: TEST
const FAILED_MENU_PATH = "res://FailedMenu.tscn"
#-----------------------
# The path to the title screen scene
const MAIN_MENU_PATH = "res://Main_Menu.tscn"

# Current level for level transition
var CURRENT_LEVEL = 1

# ------------------------------------
# All of the GUI/UI related variables

# The popup scene, and a variable to hold the popup
const POPUP_SCENE = preload("res://Pause_Popup.tscn")
var popup = null

# A canvas layer node so our GUI/UI is always drawn on top
var canvas_layer = null

# ------------------------------------


# A variable to hold all of the respawn points in a level
var respawn_points = null

# A variable to hold the mouse sensitivity (so Player.gd can load it)
var mouse_sensitivity = 0.08
# A variable to hold the joypad sensitivity (so Player.gd can load it)
var joypad_sensitivity = 2


# ------------------------------------
# All of the audio files.

# You will need to provide your own sound files.
# One site I'd recommend is GameSounds.xyz. I'm using Sonniss' GDC Game Audio bundle for 2017.
# The tracks I've used (with some minor editing) are as follows:
#

var audio_clips = {
	"punch":preload("res://sounds/sound_punch.wav"),
	"fireball":preload("res://sounds/sound_fireball.wav"),
	"menu":preload("res://sounds/sound_menu.wav"),
	"battle":preload("res://sounds/sound_battle.wav")
}

# The simple audio player scene
const SIMPLE_AUDIO_PLAYER_SCENE = preload("res://Simple_Audio_Player.tscn")

# A list to hold all of the created audio nodes
var created_audio = []


# ------------------------------------


func _ready():
	# Randomize the random number generator, so we get random values
	randomize()
	read_power()  # zgy: Read power up from file
	CURRENT_LEVEL = 1 # for level scene choosing
	# Make a new canvas layer.
	# This is so our popup always appears on top of everything else
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)

# -------------------
# zgy: Power Up
var HP_LEVEL = 0
var ATTACK_LEVEL = 0
var SPEED_LEVEL = 0
var SOULS = 0
var POWER_UP_COST = 5

func read_power():
	var file = File.new()
	if not file.file_exists("user://powers.txt"):
		return
	
	file.open("user://powers.txt", File.READ)
	while not file.eof_reached():
		var current_line = file.get_line()
		var power = current_line.split(":", false)
		
		if power.size() == 0:
			break
			
		var name = power[0]
		var value = int(power[1])
		
		if name == "hp":
			HP_LEVEL = value
		elif name == "attack":
			ATTACK_LEVEL = value
		elif name == "speed":
			SPEED_LEVEL = value
		elif name == "souls":
			SOULS = value
		elif name == "cost":
			POWER_UP_COST = value

	file.close()
	
func write_power():
	var file = File.new()
	file.open("user://powers.txt", File.WRITE)
	
	file.store_string("souls:" + str(SOULS) +"\n")
	file.store_string("cost:" + str(POWER_UP_COST) +"\n")
	file.store_string("hp:" + str(HP_LEVEL) +"\n")
	file.store_string("attack:" + str(ATTACK_LEVEL) +"\n")
	file.store_string("speed:" + str(SPEED_LEVEL) +"\n")
	
	file.close()
#------------------------

"""
func get_respawn_position():
	# If we do not have any respawn points, return origin
	if respawn_points == null:
		return Vector3(0, 0, 0)
	# If we have respawn points, get a random one and return it's global position
	else:
		var respawn_point = rand_range(0, respawn_points.size()-1)
		return respawn_points[respawn_point].global_transform.origin
"""

func load_new_scene(new_scene_path):
	# Set respawn points to null so when/if we get to a level with no respawn points,
	# we do not respawn at the respawn points in the level prior.
	respawn_points = null
	
	# Delete all of the sounds
	for sound in created_audio:
		if (sound != null):
			sound.queue_free()
	created_audio.clear()
	
	# Change scenes
	get_tree().change_scene(new_scene_path)


func _process(delta):
	# If ui_cancel is pressed, we want to open a popup if one is not already open
	if Input.is_action_just_pressed("ui_cancel"):
		if popup == null:
			# Make a new popup scene
			popup = POPUP_SCENE.instance()
			
			# Connect the signals
			popup.get_node("Button_quit").connect("pressed", self, "popup_quit")
			popup.connect("popup_hide", self, "popup_closed")
			popup.get_node("Button_resume").connect("pressed", self, "popup_closed")
			
			# Add it as a child, and make it pop up in the center of the screen
			canvas_layer.add_child(popup)
			popup.popup_centered()
			
			# Make sure the mouse is visible
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			
			# Pause the game
			get_tree().paused = true
	
	# ---------------------
	# zgy: TEST
	if Input.is_action_just_pressed("test_failed"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		load_new_scene(FAILED_MENU_PATH)


func popup_closed():
	# Unpause the game
	get_tree().paused = false
	
	# If we have a popup, destoy it
	if popup != null:
		popup.queue_free()
		popup = null

func popup_quit():
	get_tree().paused = false
	
	# Make sure the mouse is visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# If we have a popup, destoy it
	if popup != null:
		popup.queue_free()
		popup = null
	
	# Go back to the title screen scene
	load_new_scene(MAIN_MENU_PATH)

# --------------
# zgy: sounds
func play_sound(sound_name, loop_sound=false, sound_position=null):
	# If we have a audio clip with with the name sound_name
	if audio_clips.has(sound_name):
		# Make a new simple audio player and set it's looping variable to the loop_sound
		var new_audio = SIMPLE_AUDIO_PLAYER_SCENE.instance()
		new_audio.should_loop = loop_sound
		
		# Add it as a child and add it to created_audio
		add_child(new_audio)
		created_audio.append(new_audio)
		
		# Send the newly created simple audio player the audio stream and sound position
		new_audio.play_sound(audio_clips[sound_name], sound_position)
	
	# If we do not have an audio clip with the name sound_name, print a error message
	else:
		print ("ERROR: cannot play sound that does not exist in audio_clips!")

# -------------------
# skill popup
const SKILL_POPUP_SCENE = preload("res://Skill_Popup.tscn")
var skill_popup = null
	
func skill_popup():
	if skill_popup == null:
		# Make a new popup scene
		skill_popup = SKILL_POPUP_SCENE.instance()
		
		# Connect the signals
		skill_popup.get_ok().connect("pressed", self, "get_skill")
		skill_popup.get_cancel().connect("pressed", self, "skill_popup_closed")
		
		# Add it as a child, and make it pop up in the center of the screen
		get_node("/root/Globals").canvas_layer.add_child(skill_popup)
			
		skill_popup.popup_centered()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func skill_popup_closed():
	
	# If we have a popup, destoy it
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if skill_popup != null:
		skill_popup.queue_free()
		skill_popup = null

func get_skill():
	print("OK, get this skill")
	skill_popup_closed()
