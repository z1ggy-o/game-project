extends KinematicBody

var active = true
var move_vec = Vector3()

var MOVE_SPEED = 2
var target

# MOVEMENT SPEED
const GRAVITY = -0.98
const ACCEL= 4.5
const DEACCEL= 16

# MOVEMENT VAR
var vel = Vector3()
var dir = Vector3()

# etc
const MAX_SLOPE_ANGLE = 40

# enemy status
var MAX_HEALTH = 100
var HEALTH = 100
var DAMAGE = 20
var SOUL = 10

# flags
var attack_flag = false
var walk_flag = false
var sprint_flag = false
var is_shoot = false
var dead = false

onready var animation_manager = $Graphics/AnimationPlayer

var y_velo = 0
var t = 0

var animations = {
	"Attack": "Attack-loop",
	"Death": "Death",
	"Hit": "Hit",
	"Idle": "Idle-loop",
	"Walk": "Walk-loop",
	"Sprint": "Run-loop"
}

func _ready():
	var target_array = get_tree().get_nodes_in_group("Player")
	target = target_array[0]
	vel = Vector3()
	dir = Vector3()
	
	add_to_group("Enemy")
	
	get_node("BulletSpawn").set_damage(DAMAGE)
		
	
func _physics_process(delta):
	if !dead:
		
		
		#global_transform = global_transform.looking_at(target.global_transform.origin, Vector3(0,1,0))
		#var forwards: Vector3 = -global_transform.basis.z * 1
		#var right: Vector3 = global_transform.basis.x * 1
		#dir = (forwards + right).normalized()
		#test_dir()
		move_with_navigate(target.get_translation())
		
		var anim = ai()
		process_animation(delta, animations["Attack"])
		if $stoptime.is_stopped():
			movement_loop()
			aim()
		get_node("BulletSpawn").fire(global_transform.basis.z)
		#process_movement(delta)
		pass
		

# ---------- basic movements ---------- #

func test_dir():
	if t % 50 < 25:
		dir = Vector3(1, 0, 0)
	else:
		dir = Vector3(-1, 0, 0)
	
	t += 1
	
func movement_loop():
	
	var motion = dir.normalized() * MOVE_SPEED
	motion.y = y_velo
	motion.x = -motion.x
	motion.z = -motion.z
	
	y_velo += GRAVITY
	
	if is_on_floor() and y_velo <= 0:
		y_velo = -0.1
	
	motion = move_and_slide(motion, Vector3(0, 1, 0))
	
func aim():
	var rayPos = target.global_transform.origin
	rayPos.y = global_transform.origin.y
	var desired_rotation = global_transform.looking_at(rayPos, Vector3(0,1,0))
	desired_rotation.basis.y = -desired_rotation.basis.y 
	var a = Quat(global_transform.basis.get_rotation_quat()).slerp(desired_rotation.basis.get_rotation_quat(), 0.2)
	global_transform.basis = Basis(a)
	
func move_with_navigate(end):
	
	var Nav = owner.get_node("Navigation")

	var path = Nav.get_simple_path(get_translation(), end)
	
	#var begin = get_translation()
	#var path = owner.get_node("Navigation").get_Navigation_path(begin, end)
	
	if path.size() < 2:
		return
	var nextPos = path[1]
	dir = (nextPos - get_translation())
	if (dir.x < 0.1) and (dir.z) < 0.1 && path.size() > 3:
		nextPos = path[2]
		dir = nextPos - get_translation()

# ---------- basic movements finish ---------- #


# ---------- basic animations ---------- #

func play_anim(name):
	if animation_manager.current_animation == name:
		return
	animation_manager.set_animation(name)

func process_animation(delta, anim):
	if anim:
		play_anim(anim)
		
		
# ---------- basic animations finish ---------- #
	

# ---------- basic status change ----------#
func take_damage(amount):
	set_health(HEALTH - amount)


func kill():
	play_anim("Death")
	dead = true
	abilup()
	get_node("/root/Globals").updateSoul(SOUL)
	pass
	

func abilup():
	var rn = randi() % 100
	if rn > 0:
		get_node("/root/Globals").ABIL_SHOOT += 3

func set_health(value):
	var prev_health = HEALTH
	HEALTH = clamp(value, 0 , MAX_HEALTH)
	if HEALTH != prev_health:
		#emit_signal("health_updated", HEALTH)
		if HEALTH <= 0:
			kill()

# ---------- basic status change end ----------#

# ---------- basic ai ---------- #
func ai():
	if !is_shoot:
		return animations["Attack"]
	if attack_flag:
		dir = Vector3(0,0,0)
		return animations["Attack"]
	
	elif walk_flag:
		return animations["Walk"]
		
		
	return null

	

func _on_AnimationPlayer_animation_finished(anim_name):
	is_shoot = false


func _on_CooldownTimer_timeout():
	$shoot.start()
	pass # Replace with function body.
