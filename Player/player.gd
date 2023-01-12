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
var what_to_pickup : Weapon
var aim_down_sights : bool = false
var is_crouching : bool = false
@onready var weapon_holder = $PlayerCamera/WeaponHolder

# Vars for physics
@export var speed : float = 3.0
@export var ads_speed : float = 2
@export var max_speed: float = 4.5
@export var jump_velocity: float = 4.5
@export var friction: float = 10
@export var accel: float = 3.5
@export var max_sprint_speed: float = 7.5
@export var sprint_accel : float = 7
var is_sprinting : bool = false
var animation_speed_modifier : float = 0.4

@onready var flashlight = $PlayerCamera/Flashlight

var cur_health : int
var max_health : int = 100

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

signal picked_up(player)
signal health_changed(health)

func _ready():
	use_text.hide()
	cur_health = max_health
	anims.play("RESET")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
	#emit_signal("health_changed", cur_health)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.MOUSE_MODE_CAPTURED:
		mouseDelta = event.relative
	
	if event.is_action_pressed("sprint"):
		is_sprinting = true
	if event.is_action_released("sprint"):
		is_sprinting = false
		
	if event.is_action_pressed("crouch"):
		anims.play("Crouch")
		is_crouching = true
	if event.is_action_released("crouch"):
		anims.play_backwards("Crouch")
		is_crouching = false
		
	if event.is_action_pressed("flashlight"):
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()
	
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
#		look_anim_pos.x = lerp(look_anim_pos.x, 1.0, 0.009)
		weapon_holder.rotation.y = lerp(weapon_holder.rotation.y, deg_to_rad(-15.0), 0.009)
		#clamp(weapon_manager.rotation.y, 0, deg_to_rad(10.0))
	
	elif mouseDelta.x < 0:
		#look_anim_pos.x = lerp(look_anim_pos.x, -1.0, 0.009)
		weapon_holder.rotation.y = lerp(weapon_holder.rotation.y, deg_to_rad(15.0), 0.009)
	
	if mouseDelta.y > 0:
		#look_anim_pos.y = lerp(look_anim_pos.y, -1.0, 0.009)
		weapon_holder.rotation.x = lerp(weapon_holder.rotation.x, deg_to_rad(-5.0), 0.009)
	
	elif mouseDelta.y < 0:
		#look_anim_pos.y = lerp(look_anim_pos.y, 1.0, 0.009)
		weapon_holder.rotation.x = lerp(weapon_holder.rotation.x, deg_to_rad(5.0), 0.009)

	if mouseDelta == Vector2(0,0):
		#look_anim_pos.x = lerp(look_anim_pos.x, 0.0, 0.05)
		#look_anim_pos.y = lerp(look_anim_pos.y, 0.0, 0.05)
		weapon_holder.rotation.y = lerp(weapon_holder.rotation.y, 0.0, 0.1)
		weapon_holder.rotation.x = lerp(weapon_holder.rotation.x, 0.0, 0.1)
		

	#look_anim.set("parameters/blend_position", look_anim_pos)
	
	#-------------------------------------------------------------------------
	
	mouseDelta = Vector2()

	#Quit game
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("use"):
		if can_pickup:
			weapon_holder.pickup_weapon(what_to_pickup)
			#emit_signal("picked_up", self)
		do_raycast()


func _physics_process(delta):
	var old_velocity = velocity
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
			
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
#	if direction:
	var target = direction
	
	# Determine how fast to move
	if is_sprinting:
		target *= max_sprint_speed
	elif aim_down_sights or is_crouching:
		target *= ads_speed
	else:	
		target *= max_speed
	
	var hvel = velocity
	hvel.y = 0
	var new_accel
	
	#Change accel based on sprint bool
	if direction.dot(hvel) > 0:
		if is_sprinting:
			new_accel = sprint_accel
		else:	
			new_accel = accel
	else:
		if is_sprinting:
			new_accel = friction + 2
		else:
			new_accel = friction
	
	
	hvel = hvel.lerp(target, new_accel * delta)
	velocity.x = hvel.x
	velocity.z = hvel.z
	
	if velocity != old_velocity:
		set_anims()
		
#	if input_dir != Vector2.ZERO:
#		anims.play("Walk")
#		if is_sprinting:
#			anims.playback_speed = 1.5
#		else:
#			anims.playback_speed = 1
		
	move_and_slide()


func set_anims():
	if velocity != Vector3.ZERO:
		anims.play("Walk")
		var anim_speed = velocity.length() * animation_speed_modifier
		#print(anim_speed)
		anims.playback_speed = anim_speed
		weapon_holder.anim_speed = anim_speed
		# 2 corresponds to enum value "MOVING" in weapon_holder
		weapon_holder.change_state(2)
		#weapon_holder.animate_weapon(anim_speed)
	else:
		anims.play("RESET")


func pickup_available(weapon : Weapon):
	use_text.text = "Press E to pick up " + weapon.gun_name
	use_text.show()
	print(weapon)
	can_pickup = true
	what_to_pickup = weapon


func pickup_not_available():
	use_text.text = ""
	use_text.hide()
	can_pickup = false
	what_to_pickup = null


func do_raycast():
	if raycast.is_colliding():
		if raycast.get_collider().is_in_group("Door"):
			raycast.get_collider().choose_action()
	
