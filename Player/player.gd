extends CharacterBody3D

@onready var camera : Camera3D = $PlayerCamera
@onready var use_text: Label = $HUD/UsePrompt
@onready var anims : AnimationPlayer = $PlayerAnims
@onready var raycast : RayCast3D = $PlayerCamera/InteractableFinder
@onready var flashlight = $PlayerCamera/Flashlight
@onready var weapon_holder = $PlayerCamera/WeaponHolder

# Vars for mouse look
var mouseDelta : Vector2 = Vector2()
const LOOK_SENS : float = 0.8
const MIN_LOOK_ANGLE : int = -90
const MAX_LOOK_ANGLE : int = 90
const MIN_WEAPON_ROTATION : Vector3 = Vector3(deg_to_rad(-5.0), deg_to_rad(-10), 0)
const MAX_WEAPON_ROTATION : Vector3 = Vector3(deg_to_rad(5.0), deg_to_rad(10.0), 0)

var kills: int = 0 :
	get:
		return kills
	set(amount):
		if amount != 0:
			kills += amount
		else:
			kills = amount
var xp : int = 0
var level : int = 0
var no_clip : bool = false

var did_i_pickup : bool = false
var can_pickup = false
var gun_instance : Weapon
var aiming : bool = false
var is_crouching : bool = false


# Vars for physics
@export var speed : float = 3.0 :
	set = set_speed, get = get_speed
@export var reduced_speed : float = 2
@export var max_speed: float = 4.5
@export var jump_velocity: float = 4.5
@export var friction: float = 10
@export var accel: float = 3.5
@export_category("Sprinting")
@export var max_sprint_speed: float = 7.5
@export var sprint_accel : float = 7
var is_sprinting : bool = false
var animation_speed_modifier : float = 0.4



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
	emit_signal("health_changed", cur_health)
	
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
			
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	if event.is_action_pressed("use"):
		if can_pickup:
			weapon_holder.pickup_weapon(gun_instance)
			did_i_pickup = true
			#emit_signal("picked_up", self)
		do_raycast()
	
	if event.is_action_pressed("aim"):
		$ADSAnim.play("ADS")
		aiming = true

	if event.is_action_released("aim"):
		$ADSAnim.play_backwards("ADS")
		aiming = false
		
	if event.is_action_pressed("toggle_cursor"):
		toggle_cursor()
		
	if event.is_action_pressed("no_clip"):
		if no_clip:
			no_clip = false
			set_collision_mask_value(1, true)
			set_collision_mask_value(5, true)
		if not no_clip:
			no_clip = true
			set_collision_mask_value(1, false)
			set_collision_mask_value(5, false)


func _process(delta):
	#Rotate camera
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera.rotation -= Vector3(mouseDelta.y, 0, 0) * LOOK_SENS * delta
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(MIN_LOOK_ANGLE), deg_to_rad(MAX_LOOK_ANGLE))
		rotation -= Vector3(0, mouseDelta.x, 0) * LOOK_SENS * delta
		

	
	mouseDelta = Vector2()


func _physics_process(delta):
	# Add the gravity.
	if not no_clip:
		if not is_on_floor():
			velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
			
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var target = direction
	
	# Determine how fast to move
	if is_sprinting and not aiming:
		target *= max_sprint_speed
	elif aiming or is_crouching:
		target *= reduced_speed
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
	
	#if velocity != old_velocity:
	if not aiming:
		set_anims(input_dir)
	else:
		weapon_holder.anim_speed = 0

	gun_rotation_anim()

	move_and_slide()



func mouse_look(delta):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera.rotation -= Vector3(mouseDelta.y, 0, 0) * LOOK_SENS * delta
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(MIN_LOOK_ANGLE), deg_to_rad(MAX_LOOK_ANGLE))
		rotation -= Vector3(0, mouseDelta.x, 0) * LOOK_SENS * delta


func gun_rotation_anim():
	# Rotate weapon_holder 
	
	if mouseDelta.x > 0:
		#weapon_holder.rotation.y = lerp(weapon_holder.rotation.y, deg_to_rad(-10.0), 0.009)
		weapon_holder.rotation.y = lerp(weapon_holder.rotation.y, -mouseDelta.x / 50, 0.009)
	
	elif mouseDelta.x < 0:
		#weapon_holder.rotation.y = lerp(weapon_holder.rotation.y, deg_to_rad(10), 0.009)
		weapon_holder.rotation.y = lerp(weapon_holder.rotation.y, -mouseDelta.x / 50, 0.009)
	
	if mouseDelta.y > 0:
		weapon_holder.rotation.x = lerp(weapon_holder.rotation.x, deg_to_rad(-5.0), 0.009)
	
	elif mouseDelta.y < 0:
		weapon_holder.rotation.x = lerp(weapon_holder.rotation.x, deg_to_rad(5.0), 0.009)
		

	if mouseDelta == Vector2(0,0):
		weapon_holder.rotation.y = lerp(weapon_holder.rotation.y, 0.0, 0.1)
		weapon_holder.rotation.x = lerp(weapon_holder.rotation.x, 0.0, 0.1)
		

	weapon_holder.rotation = clamp(weapon_holder.rotation, MIN_WEAPON_ROTATION, MAX_WEAPON_ROTATION)
	#weapon_holder.rotation.y = clamp(weapon_holder.rotation.y, deg_to_rad(-10.0), deg_to_rad(10.0))



func set_anims(am_i_moving):
	var anim_speed = velocity.length() * animation_speed_modifier
	if not weapon_holder.is_holstered and anim_speed > 0.2:
		weapon_holder.anim_speed = anim_speed
		
	if am_i_moving != Vector2.ZERO:
		anims.play("Walk")
		anims.playback_speed = anim_speed

	else:
		anims.stop()


func toggle_cursor():
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func pickup_available(weapon : PackedScene):
	did_i_pickup = false
	gun_instance = weapon.instantiate()
	use_text.text = "Press E to pick up " + gun_instance.gun_name
	use_text.show()
	can_pickup = true
	#what_to_pickup = gun_instance


func pickup_not_available():
	use_text.text = ""
	use_text.hide()
	can_pickup = false
	if did_i_pickup == false:
		gun_instance.queue_free()
	gun_instance = null


func do_raycast():
	if raycast.is_colliding():
		if raycast.get_collider().is_in_group("Door"):
			raycast.get_collider().choose_action()
			

func set_speed(increase):
	speed += increase
	max_speed += increase
	max_sprint_speed += increase
	reduced_speed += increase
	
	
func get_speed():
	return speed
