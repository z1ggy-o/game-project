extends Control

const MAIN_MENU_PATH = "res://Main_Menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Button.connect("pressed", self, "retry_pressed")

func retry_pressed():
	get_node("/root/Globals").load_new_scene(MAIN_MENU_PATH)
