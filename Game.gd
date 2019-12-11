extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var enemy = preload("res://Characters/Enemy/EnemySample/Enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(enemy.instance())

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
