extends RigidBody3D

const kill_timer: float = 4
var timer: float = 0
var hit_something: bool = false
var bullet_damage : int
var speed : float

@onready var raycast : RayCast3D = $RayCast3D
@onready var sparks : PackedScene = preload("res://sparks.tscn")
@onready var blood : PackedScene = preload("res://Blood/blood_particle.tscn")
@onready var bullet_hole : PackedScene = preload("res://Weapons/bullet_hole.tscn")


signal hit_enemy(position)
signal hit_wall(position)


func _ready():
	timer = 0
	
	set_as_top_level(true)
	apply_impulse(transform.basis.z * speed, transform.basis.z)
	

func _process(delta):
	apply_force(transform.basis.z * speed, transform.basis.z)
	
	timer += delta
	if timer >= kill_timer:
		queue_free()

func _on_body_entered(body):
	if hit_something == false:
		if body.is_in_group("Wall") or body.is_in_group("Floor"):
			# Do spark stuff
			var s = sparks.instantiate()
			if raycast.get_collider() != null:
				raycast.get_collider().add_child(s)
				s.global_transform.origin = $SparkRotHelper.global_transform.origin
				s.global_rotation = $SparkRotHelper.global_rotation
				s.emitting = true
		
			# Do bull hole
				var hole = bullet_hole.instantiate()
				raycast.get_collider().add_child(hole)
				hole.global_transform.origin = raycast.get_collision_point()
				if raycast.get_collider().is_in_group("Wall"):
					hole.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.UP)
				if raycast.get_collider().is_in_group("Floor"):
					hole.rotation = Vector3(77, 0, 0)
	
		if body.is_in_group("Enemy"):
			body.owie(bullet_damage)
			var blood_instance = blood.instantiate()
		
			if raycast.get_collider() != null:
				raycast.get_collider().add_child(blood_instance)
				blood_instance.global_transform.origin = $SparkRotHelper.global_transform.origin
				blood_instance.global_rotation = $SparkRotHelper.global_rotation
				blood_instance.emitting = true
		
		
	
	hit_something = true
	$Timer.start()
	$BulletMesh.visible = false
	$SmokeTrail.emitting = false
	
	


func _on_timer_timeout():
	queue_free()
