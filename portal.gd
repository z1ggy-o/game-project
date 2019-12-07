extends Spatial

const LEVEL_PATH = ["res://levels/Level1.tscn",
					"res://levels/Level2.tscn",
					"res://levels/Level3.tscn",
					"res://levels/Level4.tscn",
					"res://levels/Level5.tscn"]
					
# Called when the node enters the scene tree for the first time.
func _ready():
	$Entry.connect("body_entered", self, "to_next_scene")

func to_next_scene(body):
	# need check if enemies are all died
	print("called to_next_scene")

	if body.has_method("to_next_scene"):
		print("to next scene") #
		var cur_level = get_node("/root/Globals").CURRENT_LEVEL
		print("current level ", cur_level) #
		
		if cur_level == 5:
			get_tree().change_scene("res://Main_Menu.tscn")
		else:
			get_node("/root/Globals").CURRENT_LEVEL += 1
			print(LEVEL_PATH[cur_level]) #
			get_node("/root/Globals").load_new_scene(LEVEL_PATH[cur_level])
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
