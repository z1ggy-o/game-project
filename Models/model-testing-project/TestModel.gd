extends KinematicBody

const MOVE_SPEED = 12
 
const H_LOOK_SENS = 1.0
const V_LOOK_SENS = 1.0
 
onready var cam = $CameraBase
#onready var anim = $Graphics/AnimationPlayer
onready var anim = $Graphics/AnimationPlayer
 
var y_velo = 0
 
func _ready():
    #anim.get_animation("walk").set_loop(true)
	anim.get_animation("Walk-loop").set_loop(true)
    #Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
 
func _input(event):
    if event is InputEventMouseMotion:
        cam.rotation_degrees.x -= event.relative.y * V_LOOK_SENS
        cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)
        rotation_degrees.y -= event.relative.x * H_LOOK_SENS
 
func _physics_process(delta):
    var move_vec = Vector3()
    if Input.is_action_pressed("move_forwards"):
        move_vec.z -= 1
    if Input.is_action_pressed("move_backwards"):
        move_vec.z += 1
    if Input.is_action_pressed("move_right"):
        move_vec.x += 1
    if Input.is_action_pressed("move_left"):
        move_vec.x -= 1
    move_vec = move_vec.normalized()
    move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
    move_vec *= MOVE_SPEED
    move_vec.y = y_velo
    move_and_slide(move_vec, Vector3(0, 1, 0))
   

    var just_acctacted = false
    if not just_acctacted and Input.is_action_just_pressed("hit"):
        just_acctacted = true
        play_anim("Attack-loop")
    
    if move_vec.x == 0 and move_vec.z == 0:
        play_anim("Idle-loop")
    else:
        play_anim("Walk-loop")
 
func play_anim(name):
    if anim.current_animation == name:
        return
    anim.play(name)