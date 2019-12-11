extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

var text = ""
	
func update():
	$Timer.start()
	$Label.text = text
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
#	pass

func get_text(abil):
	if abil == "DAMAGE":
		text = "DAMAGE UP"
	if abil == "MAX_HEALTH":
		text = "MAX HEALTH UP"
	if abil == "SHOOT":
		text = "SHOOTING UP"
	
	update()

func _on_Timer_timeout():
	$Label.text = ""
