extends Weapon

@onready var anims : AnimationPlayer = $AnimationPlayer
var randomizer = RandomNumberGenerator.new()
var bullet_spread : Vector2 = Vector2(0.5, 0.2)


func fire():
	if bullets_in_mag == 0 or is_firing == true:
		can_fire = false
		#anims.connect("animation_finished")
	else:
		can_fire = true
	
	if can_fire == true:
		is_firing = true
		fire_rate.start()
		anims.play("Fire")
		spawn_bullet()
		PlayerUpgrade.gun_fired()
		
		bullets_in_mag -= 1


func reload_weapon():
	if bullets_in_mag == mag_size or is_firing == true:
		pass
	else:
		is_reloading = true
		anims.play("Reload", 0.2)
		reload_time.start()
		while bullets_in_mag < mag_size:
			bullets_in_mag += 1
			available_bullets -= 1
			if available_bullets == 0:
				break


func spawn_bullet():
	# Randomize angles of projectiles
	randomizer.randomize()
	var randomy_angle = randomizer.randf_range(-bullet_spread.x, bullet_spread.x)
	var randomx_angle = randomizer.randf_range(-bullet_spread.y, bullet_spread.y)
	
	var b : RigidBody3D = bullet.instantiate()
	b.add_collision_exception_with(get_tree().get_nodes_in_group("Player")[0])
	b.speed = bullet_speed
	b.bullet_damage = damage
	b.transform.basis = muzzle.transform.basis
	b.rotation.x += randomx_angle
	b.rotation.y += randomy_angle
	muzzle.add_child(b)


func idle(anim_speed : float):
	anims.play("Idle", 0.5, anim_speed)


func walk(anim_speed : float):
	anims.play("Walking", 0.5, anim_speed)
	

func run(anim_speed : float):
	anims.play("Run", 0.3, anim_speed)


func _on_reload_timer_timeout():
	is_reloading = false


func _on_fire_rate_timeout():
	is_firing = false
