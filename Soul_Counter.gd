extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

	
func update():
	$Label.text = "Souls: " + str(get_node("/root/Globals").SOULS)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Label.text = "Souls: " + str(get_node("/root/Globals").SOULS)
#	pass
