extends CharacterBody3D

@onready var player : CharacterBody3D
@onready var h_text = $HealthText
@onready var timer = $RespawnTimer
@onready var idle_timer = $IdleTimer
@onready var fire_timer = $FireTimer
@onready var eye = $Form/Head/Eye
@onready var bitch_finder = $Form/Head/BitchFinder
@onready var detection_area : Area3D = $Form/Head/DetectionCone
@onready var nav_agent = $NavigationAgent3D
@onready var anims : AnimationPlayer = $AnimationPlayer

# Load limbs for death destruction
@onready var head_limb : PackedScene = preload("res://Enemy/head_limb.tscn")
@onready var arm_limb : PackedScene = preload("res://Enemy/arm_limb.tscn")
@onready var leg_limb : PackedScene = preload("res://Enemy/leg_limb.tscn")
@onready var body_limb : PackedScene = preload("res://Enemy/head_limb.tscn")

var current_nav_point : int = 0
var nav_points : Array = []
var target

@export var search_speed = 2.0
@export var follow_speed = 6.0
@export var jump_velocity = 4.5
@export var turn_speed = 2

var health : int = 100
var max_health : int = 100
var start_pos 
#var player_in_view : bool = false

enum EnemyState {
	IDLE,
	SEARCHING,
	FOLLOWING,
	ATTACKING,
	DEAD,
}

var enemy_state = EnemyState.SEARCHING

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

signal im_dead_af

func _ready():
	update_health(health)
	start_pos = global_transform


func _physics_process(delta):
	match enemy_state:
		EnemyState.IDLE:
			velocity = Vector3.ZERO
			if idle_timer.is_stopped() == true:
				idle_timer.start()
			rotation.y += 2 * delta
				
		EnemyState.SEARCHING:
			if target_reached() == true:
				enemy_state = EnemyState.IDLE
			
			nav_agent.set_target_position(nav_points[current_nav_point].global_position)
			#set_movement_target(nav_points[current_nav_point].global_transform.origin)
			var current_agent_position: Vector3 = global_position
			var next_path_position : Vector3 = nav_agent.get_next_path_position()
			var new_velocity : Vector3 = (next_path_position - current_agent_position).normalized() * search_speed
			set_velocity(new_velocity)
			
			# Make enemy look at current direction
			look_somewhere(next_path_position)
			
		EnemyState.FOLLOWING:
			var current_agent_position: Vector3 = global_position
			
			if current_agent_position.distance_to(player.global_position) > 10:
				enemy_state = EnemyState.SEARCHING
			elif current_agent_position.distance_to(player.global_position) < 2:
				enemy_state = EnemyState.ATTACKING
			
			nav_agent.set_target_position(player.global_position)
			var next_path_position: Vector3 = nav_agent.get_next_path_position()
			var new_velocity : Vector3 = (next_path_position - current_agent_position).normalized() * follow_speed
			set_velocity(new_velocity)
			
			look_somewhere(player.global_position)
			
		EnemyState.ATTACKING:
			if global_position.distance_to(player.global_position) > 3:
				if player != null:
					enemy_state = EnemyState.SEARCHING
				else:
					enemy_state = EnemyState.FOLLOWING
			velocity = Vector3.ZERO
			
			if anims.current_animation != "Attack":
				anims.play("Attack")

			look_somewhere(player.global_position)

		EnemyState.DEAD:
			die()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	if velocity != Vector3.ZERO:
		anims.play("walk")
	else:
		if enemy_state != EnemyState.ATTACKING:
			anims.play("RESET")
	
	move_and_slide()


func new_rotation() -> float:
	if velocity.length() > 0:
		return atan2(velocity.x, -velocity.z)
	else:
		return rotation.y


func update_health(new_health : int):
	h_text.set_text("My owwie meter: " + str(new_health))
	if health <= 0:
		enemy_state = EnemyState.DEAD


# Unnecessary function for pitiful one liner. Delete if not needed
func set_movement_target(movement_target : Vector3):
	nav_agent.set_target_position(movement_target)


func look_somewhere(pos : Vector3):
		eye.look_at(pos, Vector3.UP)
		rotate_y(deg_to_rad(eye.rotation.y * turn_speed))


func target_reached() -> bool:
	if nav_agent.is_target_reached():
		current_nav_point += 1
		if current_nav_point > 3:
			current_nav_point = 0
		return true
	return false	


func save():
	var save_dict = {
		"filename" : "res://Enemy/enemy.tscn",
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"pos_z" : position.z,
		"current_health" : health,
		"target_position" : nav_agent.get_final_position()
	}
	
	return save_dict


func set_nav_points(new_nav_points : Array):
	nav_points = new_nav_points
	
	
func smack_a_bitch():
	if ($Form/RightArmRotator/RightArm.global_transform.origin.length() - player.global_transform.origin.length() < 2):
		player.take_damage(5.0)


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


func _on_idle_timer_timeout():
	enemy_state = EnemyState.SEARCHING


func _on_navigation_agent_3d_path_changed():
	if enemy_state != EnemyState.DEAD:
		target = nav_points[current_nav_point]


func _on_form_ow_fuck(damage):
	health -= damage
	update_health(health)
		
	if health <= 0:
		enemy_state = EnemyState.DEAD


func _on_detection_cone_body_entered(body):
	if body.is_in_group("Player"):
		#player_in_view = true
		print("player entered")
		player = body
		enemy_state = EnemyState.FOLLOWING


func _on_detection_cone_body_exited(body):
	if body.is_in_group("Player"):
		player = null
		print("player exited")
		#player_in_view = false
		enemy_state = EnemyState.SEARCHING


func _on_head_ow_fuck(damage):
	health -= damage
	update_health(health)


func _on_body_ow_fuck(damage):
	health -= damage
	update_health(health)


func _on_left_leg_ow_fuck(damage):
	health -= damage
	update_health(health)


func _on_right_leg_ow_fuck(damage):
	health -= damage
	update_health(health)


func _on_right_arm_ow_fuck(damage):
	health -= damage
	update_health(health)


func _on_left_arm_ow_fuck(damage):
	health -= damage
	update_health(health)
