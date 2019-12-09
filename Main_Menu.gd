extends Control

var start_menu
var options_menu

export (String, FILE) var testing_area_scene

const POWER_UP_PATH = "res://PowerUp.tscn"

func _ready():
	start_menu = $Start_Menu
	options_menu = $Options_Menu

	
	$Start_Menu/Button_Start.connect("pressed", self, "start_menu_button_pressed", ["start"])
	$Start_Menu/Button_Options.connect("pressed", self, "start_menu_button_pressed", ["options"])
	$Start_Menu/Button_Quit.connect("pressed", self, "start_menu_button_pressed", ["quit"])
	$Start_Menu/Button_PowerUp.connect("pressed", self, "start_menu_button_pressed", ["powers"])

	$Options_Menu/VBoxContainer/Button_Back.connect("pressed", self, "options_menu_button_pressed", ["back"])

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var globals = get_node("/root/Globals")
	$Options_Menu/VBoxContainer/HSlider_Mouse_Sensitivity.value = globals.mouse_sensitivity
	$Options_Menu/VBoxContainer/HSlider_Joypad_Sensitivity.value = globals.joypad_sensitivity
	
	# zgy: play music
	globals.play_sound("menu", true)
	
	get_node("/root/Globals").ABIL_HP = 0
	get_node("/root/Globals").ABIL_POWER = 0
	get_node("/root/Globals").ABIL_SHOOT = 0

func start_menu_button_pressed(button_name):
	if button_name == "start":
		start_menu.visible = false
		# Load scene
		set_mouse_and_joypad_sensitivity()
		get_node("/root/Globals").load_new_scene(testing_area_scene)
		get_node("/root/Globals").play_sound("battle")
		get_node("/root/Globals").CURRENT_LEVEL = 1
	elif button_name == "powers":
		get_tree().change_scene(POWER_UP_PATH)
	elif button_name == "options":
		options_menu.visible = true
		start_menu.visible = false
	elif button_name == "quit":
		# Write power when before quit
		var globals = get_node("/root/Globals")
		globals.write_power()
		
		get_tree().quit()


func options_menu_button_pressed(button_name):
	if button_name == "back":
		start_menu.visible = true
		options_menu.visible = false


func set_mouse_and_joypad_sensitivity():
	var globals = get_node("/root/Globals")
	globals.mouse_sensitivity = $Options_Menu/VBoxContainer/HSlider_Mouse_Sensitivity.value
	globals.joypad_sensitivity = $Options_Menu/VBoxContainer/HSlider_Joypad_Sensitivity.value