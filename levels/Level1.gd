extends Spatial

var counter
# Called when the node enters the scene tree for the first time.
func _ready():
	counter = $Soul_Counter
	var global = get_node("/root/Globals")
	global.play_sound("battle", true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("score_test"):
		counter.update()