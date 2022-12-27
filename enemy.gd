extends CharacterBody3D

@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var h_text = $HealthText
@onready var timer = $RespawnTimer
@onready var idle_timer = $IdleTimer
@onready var raycast = $BitchFinder
@onready var nav_agent = $NavigationAgent3D
@onready var eyes : Node3D = $Eyes

var current_nav_point : int = 0
var nav_points : Array = []
var target

const SPEED = 2.0
const JUMP_VELOCITY = 4.5
const TURN_SPEED = 2

var health : int = 100
var max_health : int = 100
var start_pos 

enum EnemyState {
	IDLE,
	SEARCHING,
	FOLLOWING,
	ATTACKING
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
	
func update_health(new_health : int):
	h_text.set_text("My owwie meter: " + str(new_health))
	
func get_nav_points(new_nav_points : Array):
	nav_points = new_nav_points
	
#func get_navigation_point() -> Marker3D:
#	return nav_points[current_nav_point]
	
func is_player_spotted() -> bool:
	if raycast.is_colliding():
		if raycast.get_collider().is_in_group("Player"):
			return true
	return false
	
func set_movement_target(movement_target : Vector3):
	nav_agent.set_target_location(movement_target)
	
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
			var new_velocity : Vector3 = (next_path_position - current_agent_position).normalized() * SPEED
			#look_at(next_path_position, Vector3.UP)
			#new_velocity = new_velocity.normalized()
			#new_velocity = new_velocity * SPEED
			set_velocity(new_velocity)
			eyes.look_at(nav_points[current_nav_point].global_transform.origin, Vector3.UP)
			rotate_y(deg_to_rad(eyes.rotation.y * TURN_SPEED))
			
			
		EnemyState.FOLLOWING:
			pass
			
		EnemyState.ATTACKING:
			pass
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()


func _on_timer_timeout():
	global_transform = start_pos


func _on_idle_timer_timeout():
	enemy_state = EnemyState.SEARCHING


func _on_navigation_agent_3d_path_changed():
	target = nav_points[current_nav_point]
