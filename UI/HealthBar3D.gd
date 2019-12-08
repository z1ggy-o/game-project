extends Sprite3D

func _ready():
	texture = $Viewport.get_texture()
	
func update(health, MAX_HEALTH):
	$Viewport/HealthBar._on_health_updated(health,MAX_HEALTH)