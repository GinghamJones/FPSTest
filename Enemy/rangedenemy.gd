extends CharacterBody3D

@onready var shotgun : Weapon = $Form/RightArmRotator/RightArm/Shotgun2
@onready var raycast : RayCast3D = $Form/Head/BitchFinder
# Load limbs for death destruction
@onready var head_limb : PackedScene = preload("res://Enemy/head_limb.tscn")
@onready var arm_limb : PackedScene = preload("res://Enemy/arm_limb.tscn")
@onready var leg_limb : PackedScene = preload("res://Enemy/leg_limb.tscn")
@onready var body_limb : PackedScene = preload("res://Enemy/head_limb.tscn")
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

var target : CharacterBody3D = null
var rotate_speed : float = 5.0
var health : int = 100
var can_fire : bool = true

var state = AIMING
enum {
	AIMING, 
	FIRING,
	RELOADING,
	DEAD,
}

signal im_dead_af

func _ready() -> void:
	shotgun.gun_owner = self
	print(shotgun.gun_owner)


func _physics_process(delta: float) -> void:
	match state:
		AIMING: 
			aiming()
		FIRING:
			firing()
		RELOADING: 
			reloading()
		DEAD:
			die()
			
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	velocity.x = 0
	velocity.z = 0

	move_and_slide()
	

func aiming():
	if target != null:
		var new_velocity = target.global_position - global_position
		new_velocity = new_velocity.normalized() 
		new_velocity *= 20
		var target_rotation = atan2(-new_velocity.x, new_velocity.z)
	
		rotation.y = lerp(rotation.y, -target_rotation + deg_to_rad(5), 0.1)
		if raycast.is_colliding() and raycast.get_collider() == target:
			state = FIRING
			
			
func firing():
	if shotgun.bullets_in_mag > 0 and can_fire:
		shotgun.fire()
		state = AIMING
	elif shotgun.bullets_in_mag <= 0:
		state = RELOADING
	else:
		state = AIMING
		

func reloading():
	shotgun.reload_weapon()
	can_fire = false
	$FireTimer.start()
	state = AIMING
	
	
func die():
	var head : RigidBody3D = head_limb.instantiate()
	head.global_transform = $Form/Head.global_transform
	get_tree().root.add_child(head)
	head.apply_impulse(-transform.basis.z * 2, transform.basis.z)
	
	var body : RigidBody3D = body_limb.instantiate()
	body.global_transform = $Form/Body.global_transform
	get_tree().root.add_child(body)
	body.apply_impulse(transform.basis.z * 8, transform.basis.z)
	
	var left_arm : RigidBody3D = arm_limb.instantiate()
	left_arm.global_transform = $Form/LeftArmRotator/LeftArm.global_transform
	get_tree().root.add_child(left_arm)
	left_arm.apply_impulse(-transform.basis.z * 4, transform.basis.z)
	
	var right_arm : RigidBody3D = arm_limb.instantiate()
	right_arm.global_transform = $Form/RightArmRotator/RightArm.global_transform
	get_tree().root.add_child(right_arm)
	right_arm.apply_impulse(transform.basis.z * 4, transform.basis.z)
	
	var right_leg : RigidBody3D = leg_limb.instantiate()
	right_leg.global_transform = $Form/RightLegRotator/RightLeg.global_transform
	get_tree().root.add_child(right_leg)
	right_leg.apply_impulse(-transform.basis.z * 5, transform.basis.z)
	
	var left_leg : RigidBody3D = leg_limb.instantiate()
	left_leg.global_transform = $Form/LeftLegRotator/LeftLeg.global_transform
	get_tree().root.add_child(left_leg)
	left_leg.apply_impulse(transform.basis.z * 5, transform.basis.z)
	
	emit_signal("im_dead_af")
	queue_free()
	

func update_health(damage):
	health -= damage
	#update_health(health)
		
	if health <= 0:
		state = DEAD
		

func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		target = body


func _on_head_ow_fuck(damage) -> void:
	update_health(damage)


func _on_body_ow_fuck(damage) -> void:
	update_health(damage)


func _on_left_leg_ow_fuck(damage) -> void:
	update_health(damage)


func _on_right_leg_ow_fuck(damage) -> void:
	update_health(damage)


func _on_right_arm_ow_fuck(damage) -> void:
	update_health(damage)


func _on_left_arm_ow_fuck(damage) -> void:
	update_health(damage)


func _on_fire_timer_timeout() -> void:
	can_fire = true
