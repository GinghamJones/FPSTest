extends CharacterBody3D

@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var h_text = $HealthText
@onready var timer = $RespawnTimer
@onready var idle_timer = $IdleTimer
@onready var fire_timer = $FireTimer1
@onready var fire_timer_2 = $FireTimer2
@onready var raycast = $BitchFinder
@onready var nav_agent = $NavigationAgent3D
@onready var eyes : Node3D = $Eyes
@onready var nipple1 : MeshInstance3D = $Nipple1
@onready var nipple2 : MeshInstance3D = $Nipple2
@onready var bullet = preload("res://Weapons/bullet.tscn")

var current_nav_point : int = 0
var nav_points : Array = []
var target

const SEARCH_SPEED = 2.0
const FOLLOW_SPEED = 3.0
const JUMP_VELOCITY = 4.5
const TURN_SPEED = 3

var health : int = 100
var max_health : int = 100
var start_pos 
var random_spread = RandomNumberGenerator.new()
var bullet_speed = 2
var bullet_damage = 1

enum EnemyState {
	IDLE,
	SEARCHING,
	FOLLOWING,
	ATTACKING,
	DEAD
}

var enemy_state = EnemyState.SEARCHING

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	update_health(health)
	start_pos = global_transform

func owie(damage):
	health -= damage
	update_health(health)
	if health <= 0:
		die()

func die():
	timer.start()
	velocity = Vector3(-200, 30, 0)
	health = 100
	update_health(health)
	enemy_state = EnemyState.DEAD
	
func update_health(new_health : int):
	h_text.set_text("My owwie meter: " + str(new_health))
	
func get_nav_points(new_nav_points : Array):
	nav_points = new_nav_points
	
	
func is_player_spotted() -> bool:
	if raycast.is_colliding():
		if raycast.get_collider().is_in_group("Player"):
			return true
	return false
	
func set_movement_target(movement_target : Vector3):
	nav_agent.set_target_location(movement_target)
	
func look_somewhere(pos : Vector3):
		eyes.look_at(pos, Vector3.UP)
		rotate_y(deg_to_rad(eyes.rotation.y * TURN_SPEED))
	
func target_reached() -> bool:
	if nav_agent.is_target_reached():
		current_nav_point += 1
		if current_nav_point > 3:
			current_nav_point = 0
		return true
	return false	

func _physics_process(delta):
	match enemy_state:
		EnemyState.IDLE:
			velocity = Vector3.ZERO
			if idle_timer.is_stopped() == true:
				idle_timer.start()
			rotation.y += 2 * delta
		
			if is_player_spotted():
				enemy_state = EnemyState.FOLLOWING
				
		EnemyState.SEARCHING:
			if is_player_spotted():
				enemy_state = EnemyState.FOLLOWING
			
			if target_reached() == true:
				enemy_state = EnemyState.IDLE
	
			set_movement_target(nav_points[current_nav_point].global_transform.origin)
			var current_agent_position: Vector3 = global_transform.origin
			var next_path_position : Vector3 = nav_agent.get_next_location()
			var new_velocity : Vector3 = (next_path_position - current_agent_position).normalized() * SEARCH_SPEED
			set_velocity(new_velocity)
			
			# Make enemy look at current direction
			look_somewhere(nav_points[current_nav_point].global_transform.origin)
			
		EnemyState.FOLLOWING:
			var current_agent_position: Vector3 = global_transform.origin
			if current_agent_position.distance_to(player.global_transform.origin) > 10:
				enemy_state = EnemyState.SEARCHING
			elif current_agent_position.distance_to(player.global_transform.origin) < 3:
				enemy_state = EnemyState.ATTACKING
			
			print(current_agent_position.distance_to(player.global_transform.origin))
			set_movement_target(player.global_transform.origin)
			var next_path_position: Vector3 = nav_agent.get_next_location()
			var new_velocity : Vector3 = (next_path_position - current_agent_position).normalized() * FOLLOW_SPEED
			set_velocity(new_velocity)
			#print(nav_agent.get_final_location())
			
			eyes.look_at(player.global_transform.origin, Vector3.UP)
			rotate_y(deg_to_rad(eyes.rotation.y * TURN_SPEED))
			
		EnemyState.ATTACKING:
			fire_timer_2.start()
			if global_transform.origin.distance_to(player.global_transform.origin) > 3:
				enemy_state = EnemyState.SEARCHING
			velocity = Vector3.ZERO
			
			look_somewhere(player.global_transform.origin)
			print(rad_to_deg(nipple1.rotation.y))
			print(rad_to_deg(global_rotation.y))
			
			
			print(fire_timer_2.is_stopped())
			if fire_timer.is_stopped() == true:
				fire_nipple1()
			if fire_timer_2.is_stopped() == true:
				fire_nipple2()
		
		EnemyState.DEAD:
			move_and_collide(velocity)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()

func fire_nipple1():
	random_spread.randomize()
	var randomy_angle = random_spread.randf_range(-0.1, 0.1)
	var randomx_angle = random_spread.randf_range(-0.1, 0.1)
			
	fire_timer.start()
	var b = bullet.instantiate()
	b.speed = bullet_speed
	b.bullet_damage = bullet_damage
	b.transform.basis = nipple1.transform.basis 
	b.rotation.x += randomx_angle
	b.rotation.y += randomy_angle
	b.add_collision_exception_with(self)
	nipple1.add_child(b)

func fire_nipple2():
	random_spread.randomize()
	var randomy_angle = random_spread.randf_range(-0.1, 0.1)
	var randomx_angle = random_spread.randf_range(-0.1, 0.1)
			
	fire_timer_2.start()
	var b = bullet.instantiate()
	b.speed = bullet_speed
	b.bullet_damage = bullet_damage
	b.transform.basis = nipple2.transform.basis 
	b.rotation.x += randomx_angle
	b.rotation.y += randomy_angle
	b.add_collision_exception_with(self)
	nipple2.add_child(b)

func _on_timer_timeout():
	global_transform = start_pos
	enemy_state = EnemyState.SEARCHING
	current_nav_point = 0


func _on_idle_timer_timeout():
	enemy_state = EnemyState.SEARCHING

