extends CharacterBody3D

@onready var camera : Camera3D = $PlayerCamera
@onready var use_text: Label = $HUD/UsePrompt
@onready var look_anim : AnimationTree = $AnimationTree
@onready var anims : AnimationPlayer = $PlayerAnims
@onready var raycast : RayCast3D = $PlayerCamera/InteractableFinder

# Vars for mouse look
var mouseDelta : Vector2 = Vector2()
const LOOK_SENS : float = 0.8
const MIN_LOOK_ANGLE : int = -90
const MAX_LOOK_ANGLE : int = 90
var look_anim_pos : Vector2 = Vector2()


var current_weapon = null
var changing_weapon = false
var can_pickup = false
var what_to_pickup : String
var aim_down_sights : bool = false
var is_crouching : bool = false
@onready var weapon_manager = $PlayerCamera/WeaponManager

# Vars for physics
const SPEED : float = 3.5
const ADS_SPEED : float = 2
const MAX_SPEED: float = 5
const JUMP_VELOCITY: float = 4.5
const FRICTION: float = 10
const ACCEL: float = 4
const MAX_SPRINT_SPEED: float = 10
const SPRINT_ACCEL : float = 6
var is_sprinting : bool = false

@onready var flashlight = $PlayerCamera/Flashlight

var cur_health : int
var max_health : int = 100

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

signal picked_up()
signal health_changed(health)

func _ready():
	use_text.hide()
	cur_health = max_health
	anims.play("RESET")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	emit_signal("health_changed", cur_health)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.MOUSE_MODE_CAPTURED:
		mouseDelta = event.relative
	
	if Input.is_action_just_pressed("ADS"):
		aim_down_sights = true
		anims.play("ADS")
	if Input.is_action_just_released("ADS"):
		aim_down_sights = false
		anims.play("NoADS")
		
	if event.is_action_pressed("crouch"):
		anims.play("Crouch")
		is_crouching = true
	if event.is_action_released("crouch"):
		anims.play_backwards("Crouch")
		is_crouching = false
	
func toggle_cursor():
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
		
	
func _process(delta):
	#Toggle mouse cursor
	if Input.is_action_just_pressed("toggle_cursor"):
		toggle_cursor()
	
	#Rotate camera
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera.rotation -= Vector3(mouseDelta.y, 0, 0) * LOOK_SENS * delta
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(MIN_LOOK_ANGLE), deg_to_rad(MAX_LOOK_ANGLE))
		rotation -= Vector3(0, mouseDelta.x, 0) * LOOK_SENS * delta
	
	#------------------------------------------------------------------------
	
	#Handle mouse rotation anim
	if mouseDelta.x > 0:
		look_anim_pos.x = lerp(look_anim_pos.x, 1.0, 0.009)
	
	elif mouseDelta.x < 0:
		look_anim_pos.x = lerp(look_anim_pos.x, -1.0, 0.009)
	
	if mouseDelta.y > 0:
		look_anim_pos.y = lerp(look_anim_pos.y, -1.0, 0.009)
	
	elif mouseDelta.y < 0:
		look_anim_pos.y = lerp(look_anim_pos.y, 1.0, 0.009)

	if mouseDelta == Vector2(0,0):
		look_anim_pos.x = lerp(look_anim_pos.x, 0.0, 0.05)
		look_anim_pos.y = lerp(look_anim_pos.y, 0.0, 0.05)
		

	look_anim.set("parameters/blend_position", look_anim_pos)
	
	#-------------------------------------------------------------------------
	
	mouseDelta = Vector2()

	#Quit game
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("use"):
		if can_pickup:
			weapon_manager.pickup_weapon(what_to_pickup)
			emit_signal("picked_up")
		do_raycast()


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	#Sprint when pressed
	if Input.is_action_pressed("sprint"):
		is_sprinting = true
	else:
		is_sprinting = false
		
	#Toggle flashlight
	if Input.is_action_just_pressed("flashlight"):
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()
			
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
#	if direction:
	var target = direction
	
	# Determine how fast to move
	if is_sprinting:
		target *= MAX_SPRINT_SPEED
	elif aim_down_sights || is_crouching:
		target *= ADS_SPEED
	else:	
		target *= MAX_SPEED
	
	var hvel = velocity
	hvel.y = 0
	var accel
	
	#Change accel based on sprint bool
	if direction.dot(hvel) > 0:
		if is_sprinting:
			accel = SPRINT_ACCEL
		else:	
			accel = ACCEL
	else:
		accel = FRICTION
	
	
	hvel = hvel.lerp(target, accel * delta)
	velocity.x = hvel.x
	velocity.z = hvel.z

	move_and_slide()

func pickup_available(pickup_type):
	use_text.text = "Press E to pick up " + pickup_type
	use_text.show()
	can_pickup = true
	what_to_pickup = pickup_type

func pickup_not_available():
	use_text.text = ""
	use_text.hide()
	can_pickup = false
	what_to_pickup = "shit"

func do_raycast():
	if raycast.is_colliding():
		if raycast.get_collider().is_in_group("Door"):
			raycast.get_collider().choose_action()
	
