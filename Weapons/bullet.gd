extends RigidBody3D

const kill_timer: float = 4
var timer: float = 0
var hit_something: bool = false
var bullet_damage : int
var speed : float
var what_fired_me : Weapon
var collision_exception 

@onready var raycast : RayCast3D = $RayCast3D
@onready var sparks : PackedScene = preload("res://Weapons/sparks.tscn")
@onready var blood : PackedScene = preload("res://Blood/blood_particle.tscn")
@onready var bullet_hole : PackedScene = preload("res://Weapons/bullet_hole.tscn")


signal hit_enemy(position)
signal hit_wall(position)


func _ready():
	set_as_top_level(true)
	#apply_impulse(transform.basis.z * speed, transform.basis.z)


func _physics_process(delta):
	apply_force(transform.basis.z * speed, transform.basis.z)
	
	timer += delta
	if timer >= kill_timer:
		#return_home()
		queue_free()

func _on_body_entered(body):
	if hit_something == false:
		if body.is_in_group("Wall"):
			if raycast.get_collider() != null:
				do_sparks()
				do_bull_hole()

		if body.is_in_group("Floor"):
			if raycast.get_collider() != null:
				do_sparks()
				
		if body.is_in_group("Enemy"):
			if raycast.get_collider() != null:
				do_blood_stuff(body)
		
		if body.is_in_group("Player"):
			if raycast.get_collider() != null:
				body.take_damage(bullet_damage)

		hit_something = true
		$Timer.start()
		$BulletMesh.visible = false
		$SmokeTrail.emitting = false


func set_what_fired_me(weapon : Weapon):
	what_fired_me = weapon


func do_sparks():
	var s = sparks.instantiate()
	raycast.get_collider().add_child(s)
	s.global_transform.origin = $SparkRotHelper.global_transform.origin
	s.global_rotation = $SparkRotHelper.global_rotation
	s.emitting = true


func do_bull_hole():
	var hole = bullet_hole.instantiate()
	raycast.get_collider().add_child(hole)
	hole.global_transform.origin = raycast.get_collision_point()
	if raycast.get_collision_normal() == Vector3.DOWN:
		hole.rotation_degrees.x = 90
	elif raycast.get_collision_normal() != Vector3.UP:
		hole.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.UP)


func do_blood_stuff(body):
	body.owie(bullet_damage)
	var blood_instance = blood.instantiate()
	raycast.get_collider().add_child(blood_instance)
	blood_instance.global_transform.origin = $SparkRotHelper.global_transform.origin
	blood_instance.global_rotation = $SparkRotHelper.global_rotation
	blood_instance.emitting = true

	
func reset():
	hit_something = false
	timer = 0
	bullet_damage = what_fired_me.damage
	speed = what_fired_me.bullet_speed
	
	if what_fired_me.gun_owner == null:
		printerr("the fuck?")
	collision_exception = what_fired_me.gun_owner
	add_collision_exception_with(collision_exception)
	#set_physics_process(true)
	show()
	$BulletMesh.visible = true
	$SmokeTrail.emitting = true
	apply_impulse(transform.basis.z * speed, transform.basis.z)
	

func return_home():
	remove_collision_exception_with(collision_exception)
	hide()
	ResourcePool.return_bullet(what_fired_me, self)
	
	
func _on_timer_timeout():
	#return_home()
	queue_free()
	


