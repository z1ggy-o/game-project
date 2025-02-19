extends KinematicBody
class_name Player

signal health_updated(HEALTH, MAXHEALTH)
signal Abilup(abil)
signal killed()


# MOUSE SENSITIVE
const H_LOOK_SENS = 0.2
const V_LOOK_SENS = 0.2


# MOVEMENT SPEED
const SPEED = 8
const SPRINT_SPEED = 12
const JUMP_SPEED = 15
const MAX_FALL_SPEED = 30
const GRAVITY = -38.8
const ACCEL= 4.5
const DEACCEL= 16

# MOVEMENT VAR
var vel = Vector3()
var dir = Vector3()

# is_bool
var is_sprinting
var is_moving
var is_shoot
var is_attack
var is_hit

var attack_finish = true

# etc
const MAX_SLOPE_ANGLE = 40
onready var invulnerability_timer = $InvulnerableTimer

# STATUS
var MIN_HEALTH = 100
var DAMAGE = 30
var MIN_DAMAGE = 30
var MAX_HEALTH = 100
onready var HEALTH = 100 setget set_health
var SHOOT = 0


#onready var cam = $CamBase
onready var animation_manager = $Graphics/AnimationPlayer

var camera: Camera

# on ready
func _ready():
	camera = get_tree().root.find_node("Camera", true, false)
	assert(camera)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	emit_signal("health_updated", MAX_HEALTH, MAX_HEALTH)
	
	add_to_group("Player")
	$Area/CollisionShape.disabled = true
	first_status_update()
	
# when dead
func kill():
	play_anim("Death")
	$DeadDelay.start()
	pass
	
# get status from Global

func first_status_update():
	DAMAGE = MIN_DAMAGE + 5 * get_node("/root/Globals").ATTACK_LEVEL + get_node("/root/Globals").ABIL_POWER
	MAX_HEALTH = MIN_HEALTH + 15 * get_node("/root/Globals").HP_LEVEL + get_node("/root/Globals").ABIL_HP
	#HEALTH = set_health(HEALTH + get_node("/root/Globals").HEALTH_UP)
	get_node("/root/Globals").HEALTH_UP = 0
	SHOOT = get_node("/root/Globals").ABIL_SHOOT
	get_node("BulletSpawn").set_damage(SHOOT + DAMAGE)
	
	emit_signal("Abilup", "update")

func status_update():
	var before_damage = DAMAGE
	var before_max_health = MAX_HEALTH
	var before_shoot = SHOOT
	DAMAGE = MIN_DAMAGE + 5 * get_node("/root/Globals").ATTACK_LEVEL + get_node("/root/Globals").ABIL_POWER
	MAX_HEALTH = MIN_HEALTH + 15 * get_node("/root/Globals").HP_LEVEL + get_node("/root/Globals").ABIL_HP
	set_health(HEALTH + get_node("/root/Globals").HEALTH_UP)
	get_node("/root/Globals").HEALTH_UP = 0
	SHOOT = get_node("/root/Globals").ABIL_SHOOT
	get_node("BulletSpawn").set_damage(SHOOT + DAMAGE)
	
	if before_damage < DAMAGE:
		emit_signal("Abilup", "DAMAGE")
	if before_max_health < MAX_HEALTH:
		emit_signal("Abilup", "MAX_HEALTH")		
	if before_shoot < SHOOT:
		emit_signal("Abilup", "SHOOT")
		
	
	
func _input(event):
	pass
	
static func lerp_angle(from, to, weight):
	return from + _short_angle_dist(from, to) * weight

static func _short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference

func _physics_process(delta):
			
	status_update()
	# if dead
	if HEALTH <= 0:
		if $DeadDelay.is_stopped():
			kill()
		return
		
	var anim = process_input(delta)
	if !is_attack:
		process_movement(delta)
	process_animation(delta, anim)
	
	
	
func process_input(delta):
	
	dir = Vector3()
	
	is_moving = false
	
	
	var input_movement_vector = Vector3()
	if Input.is_action_pressed("move_forwards"):
		input_movement_vector.z += 1
		is_moving = true
	if Input.is_action_pressed("move_backwards"):
		input_movement_vector.z -= 1
		is_moving = true
	if Input.is_action_pressed("move_right"):
		input_movement_vector.x += 1
		is_moving = true
	if Input.is_action_pressed("move_left"):
		input_movement_vector.x -= 1
		is_moving = true
		
	if Input.is_action_pressed("sprint"):
    	is_sprinting = true
	else:
    	is_sprinting = false
	
	
	if Input.is_action_pressed("attack") and attack_finish and is_on_floor():
		is_attack = true
		is_moving = true
		get_node("/root/Globals").play_sound("punch")

	
		
	
	input_movement_vector = input_movement_vector.normalized()
	
	if Input.is_action_pressed("fire") and SHOOT > 0 and !is_attack:
		is_moving = false
		dir = Vector3(0,0,0)
		return play_anim("Gunplay") #zgy
	
	var forwards: Vector3 = -camera.global_transform.basis.z * input_movement_vector.z
	var right: Vector3 = camera.global_transform.basis.x * input_movement_vector.x
	dir = (forwards + right).normalized()

	
	var is_jumped = false
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			vel.y = JUMP_SPEED
			is_jumped = true
	
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#auto_rotate(move_vec)

	if is_jumped:
		return "Jump"
	elif is_on_floor():
		if is_attack:
			if attack_finish:
				$Area/CollisionShape.disabled = false
				attack_finish = false
				return "Idle-loop"
			is_moving = false
			return "Attack"
		if is_shoot:
			return "Gunplay"
		if dir.x == 0 and dir.z == 0:
			return "Idle-loop"
		if is_sprinting:
			return "Run-loop"
		else:
			return "Walk"
			
	return null
	
func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta*GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	
	if is_sprinting:
    	target *= SPRINT_SPEED
	else:
    	target *= SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel*delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel,Vector3(0,1,0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
 
func process_animation(delta, anim):

	if is_moving:
		var angle = atan2(dir.x, dir.z)
		
		var char_rot = get_rotation()

		
		if abs(fmod(char_rot.y - angle, PI)) > 0.1 :
			char_rot.y = lerp_angle(char_rot.y, angle, 0.2)
		else :
			char_rot.y = angle
		
		set_rotation(char_rot)

	
	if anim:
		#print(anim)
		play_anim(anim)
	
func play_anim(name):
	if animation_manager.current_animation == name:
		return
	animation_manager.set_animation(name)
	
	
func take_damage(amount):
	if invulnerability_timer.is_stopped():
		invulnerability_timer.start()
		set_health(HEALTH - amount)


	
func set_health(value):
	var prev_health = HEALTH
	HEALTH = clamp(value, 0 , MAX_HEALTH)
	if HEALTH != prev_health:
		emit_signal("health_updated", HEALTH, MAX_HEALTH)
		if HEALTH <= 0:
			kill()
			emit_signal("killed")
			
# Empty method for Player determination
func to_next_scene():
	pass

func fetch_skill():
	pass




func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Attack":
		is_attack = false
		attack_finish = true
		$Area/CollisionShape.disabled = true
	if anim_name == "Gunplay":
		get_node("BulletSpawn").fire(global_transform.basis.z)




func _on_Attack_timeout():
	$Area/CollisionShape.disabled = false
	 # Replace with function body.


func _on_DeadDelay_timeout():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_node("/root/Globals").reset_abil()
	get_tree().change_scene("res://FailedMenu.tscn")
