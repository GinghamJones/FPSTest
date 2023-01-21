extends CharacterBody3D

@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var h_text = $HealthText
@onready var timer = $RespawnTimer
@onready var idle_timer = $IdleTimer
@onready var fire_timer = $FireTimer
@onready var eye = $Form/Head/Eye
@onready var bitch_finder = $Form/Head/BitchFinder
@onready var detection_area : Area3D = $Form/Head/DetectionCone
@onready var nav_agent = $NavigationAgent3D
@onready var shotgun : PackedScene = preload("res://Weapons/Shotgun/shotgun_2.tscn")
@onready var anims : AnimationPlayer = $AnimationPlayer
@onready var weapon_equipper : Node3D = $Form/RightArmRotator/RightArm/WeaponEquip

@onready var bullet = preload("res://Weapons/bullet.tscn")

var current_nav_point : int = 0
var nav_points : Array = []
var target

@export var search_speed = 2.0
@export var follow_speed = 3.0
@export var jump_velocity = 4.5
@export var turn_speed = 2

var health : int = 100
var max_health : int = 100
var start_pos 
var random_spread = RandomNumberGenerator.new()
var bullet_speed = 2
var bullet_damage = 1
var weapon_equipped : bool = false
var current_weapon
var player_in_view : bool = false

enum EnemyState {
	IDLE,
	SEARCHING,
	FOLLOWING,
	ATTACKING,
	PICKUP_FOUND,
	DEAD,
}

var enemy_state = EnemyState.SEARCHING

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

signal im_dead_af

func _ready():
	update_health(health)
	start_pos = global_transform
	#im_dead_af.connect(get_tree().root.get_node("Level2").enemy_death())
	

func _physics_process(delta):
	match enemy_state:
		EnemyState.IDLE:
			velocity = Vector3.ZERO
			if idle_timer.is_stopped() == true:
				idle_timer.start()
			rotation.y += 2 * delta
		
#			if is_player_spotted():
#				enemy_state = EnemyState.FOLLOWING
				
		EnemyState.SEARCHING:
#			if is_player_spotted():
#				enemy_state = EnemyState.FOLLOWING
			
			if target_reached() == true:
				enemy_state = EnemyState.IDLE
			
			set_movement_target(nav_points[current_nav_point].global_transform.origin)
			var current_agent_position: Vector3 = global_transform.origin
			var next_path_position : Vector3 = nav_agent.get_next_location()
			var new_velocity : Vector3 = (next_path_position - current_agent_position).normalized() * search_speed
			set_velocity(new_velocity)
			
			# Make enemy look at current direction
			look_somewhere(nav_points[current_nav_point].global_transform.origin)
			
		EnemyState.FOLLOWING:
			var current_agent_position: Vector3 = global_transform.origin
			
			if current_agent_position.distance_to(player.global_transform.origin) > 10:
				enemy_state = EnemyState.SEARCHING
			elif current_agent_position.distance_to(player.global_transform.origin) < 3:
				enemy_state = EnemyState.ATTACKING
			
			set_movement_target(player.global_transform.origin)
			var next_path_position: Vector3 = nav_agent.get_next_location()
			var new_velocity : Vector3 = (next_path_position - current_agent_position).normalized() * follow_speed
			set_velocity(new_velocity)
			
			look_somewhere(player.global_transform.origin)
			
		EnemyState.ATTACKING:
			if global_transform.origin.distance_to(player.global_transform.origin) > 3:
				if player_in_view == false:
					enemy_state = EnemyState.SEARCHING
				else:
					enemy_state = EnemyState.FOLLOWING
			velocity = Vector3.ZERO
			
			look_somewhere(player.global_transform.origin)
			
			if weapon_equipped:
				if current_weapon.bullets_in_mag == 0:
					current_weapon.reload_weapon()
				else:	
					if fire_timer.is_stopped() == true and bitch_finder.get_collider() == player:
						fire_timer.start()
						current_weapon.fire()
		
		EnemyState.PICKUP_FOUND:
			if target_reached():
				velocity = Vector3.ZERO
			if weapon_equipped == true:
				enemy_state = EnemyState.SEARCHING
		
		EnemyState.DEAD:
			die()
	
	if enemy_state != EnemyState.DEAD:
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Handle Jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = jump_velocity

		if velocity != Vector3.ZERO:
			if not weapon_equipped:
				anims.play("walk")
			else:
				anims.play("walk_equipped")
		else:
			anims.play("RESET")
		
		move_and_slide()


func die():
#	timer.start()
	anims.play("Die")
	set_physics_process(false)
	set_collision_layer_value(5, false)
	await anims.animation_finished
	emit_signal("im_dead_af")
	


func update_health(new_health : int):
	h_text.set_text("My owwie meter: " + str(new_health))
	if health <= 0:
		enemy_state = EnemyState.DEAD
	
	
func set_movement_target(movement_target : Vector3):
	nav_agent.set_target_location(movement_target)
	


func look_somewhere(pos : Vector3):
		eye.look_at(pos, Vector3.UP)
		rotate_y(deg_to_rad(eye.rotation.y * turn_speed))
		weapon_equipper.rotate_z(deg_to_rad(eye.rotation.z * turn_speed))
		

func target_reached() -> bool:
	if nav_agent.is_target_reached():
		current_nav_point += 1
		if current_nav_point > 3:
			current_nav_point = 0
		return true
	return false	


func pickup_available(weapon):
	weapon_equipper.add_child(weapon)
	anims.play("Equip")
	weapon_equipped = true
	current_weapon = weapon


func set_nav_points(new_nav_points : Array):
	nav_points = new_nav_points


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
		player_in_view = true
		enemy_state = EnemyState.FOLLOWING


func _on_detection_cone_body_exited(body):
	if body.is_in_group("Player"):
		player_in_view = false
		enemy_state = EnemyState.SEARCHING


func _on_detection_cone_area_entered(area):
	if area.is_in_group("pickup"):
		enemy_state = EnemyState.PICKUP_FOUND
		set_movement_target(area.global_position)


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
