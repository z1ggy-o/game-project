extends Control

const MAIN_MENU_PATH = "res://Main_Menu.tscn"

# -------
# for confirm pop up window
const POPUP_SCENE = preload("res://Power_Popup.tscn")
var popup = null
var canvas = null
# -------------

var SOULS
var HP
var ATTACK
var SPEED
var POWER_UP_COST

# Called when the node enters the scene tree for the first time.
func _ready():
	$BackBtn.connect("pressed", self, "back_pressed")
	
	$Bottons/HPBtn.connect("pressed", self, "confirm_popup", ["hp"])
	$Bottons/AttackBtn.connect("pressed", self, "confirm_popup", ["attack"])
	$Bottons/SpeedBtn.connect("pressed", self, "confirm_popup", ["speed"])
	
	canvas = get_node("/root/Globals").canvas_layer
	
	get_value()	
	update_labels()  # zgy: Update all the power and soul values

func back_pressed():
	get_node("/root/Globals").load_new_scene(MAIN_MENU_PATH)
	
func update_labels():	
	$Labels/HP.text = "HP Level:        " + str(HP)
	$Labels/Attack.text = "Attack Level: " + str(ATTACK)
	$Labels/Speed.text = "Speed Level: " + str(SPEED)
	$Souls.text = "Souls: " + str(SOULS)
	
func get_value():
	SOULS = get_node("/root/Globals").SOULS
	HP = get_node("/root/Globals").HP_LEVEL
	ATTACK = get_node("/root/Globals").ATTACK_LEVEL
	SPEED = get_node("/root/Globals").SPEED_LEVEL
	POWER_UP_COST = get_node("/root/Globals").POWER_UP_COST
	
func update_value():
	get_node("/root/Globals").SOULS = SOULS
	get_node("/root/Globals").HP_LEVEL = HP
	get_node("/root/Globals").ATTACK_LEVEL = ATTACK
	get_node("/root/Globals").SPEED_LEVEL = SPEED
	get_node("/root/Globals").POWER_UP_COST = POWER_UP_COST

func power_up(power):
	if SOULS >= POWER_UP_COST:
		# Power Up
		if power == "hp":
			HP += 1
		elif power == "attack":
			ATTACK += 1
		elif power == "speed":
			SPEED += 1
		
		# Update data
		SOULS -= POWER_UP_COST
		POWER_UP_COST *= 2
		update_value()
	update_labels()
	popup_closed()
	
func confirm_popup(power):
	if popup == null:
		# Make a new popup scene
		popup = POPUP_SCENE.instance()
		
		# Connect the signals
		popup.get_ok().connect("pressed", self, "power_up", [power])
		popup.get_cancel().connect("pressed", self, "popup_closed")
		
		# Add it as a child, and make it pop up in the center of the screen
		canvas.add_child(popup)
	
		var label = popup.get_label()
		if label == null:
			print("can not get Popup label")
		else:
			label.text = "\n           Costs " + str(POWER_UP_COST) + " souls.\n               Upgrade?"
			
		if SOULS < POWER_UP_COST:
			popup.get_ok().set_disabled(true)
			
		popup.popup_centered()
	
func popup_closed():
	
	# If we have a popup, destoy it
	if popup != null:
		popup.queue_free()
		popup = null
	