extends Area

func _ready():
	self.connect("body_entered", self, "get_skill")

func get_skill(body):
	print("get_skill")
	# If the body has the add_health function, then call it,
	# set the respawn timer (so we have to wait for the health to respawn),
	# and make the nodes for the current size disabled.
	# if body.has_method("set_health"):

	if body.has_method("fetch_skill"):
		get_node("/root/Globals").skill_popup()