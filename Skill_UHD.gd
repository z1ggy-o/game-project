extends Control

func _ready():
	pass # Replace with function body.


func _process(delta):
	$Attack_Power.text = "Attack Up: " + str(get_node("/root/Globals").ABIL_POWER)
	$HP_Power.text = "HP Up: " + str(get_node("/root/Globals").ABIL_HP)
	$Shooting_Power.text = "Shooting Up: " + str(get_node("/root/Globals").ABIL_SHOOT)