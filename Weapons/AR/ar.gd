extends Weapon

@onready var anims : AnimationPlayer = $AnimationPlayer
@onready var muzzle : MeshInstance3D = $GunModel/Muzzle
@onready var bullet : PackedScene = preload("res://Weapons/bullet.tscn")


func fire():
	if bullets_in_mag == 0 or is_firing == true:
		can_fire = false
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
	spread_randomizer.randomize()
	var randomy_angle = spread_randomizer.randf_range(-bullet_spread.x, bullet_spread.x)
	var randomx_angle = spread_randomizer.randf_range(-bullet_spread.y, bullet_spread.y)
	
	var b : RigidBody3D = bullet.instantiate()
	#var b : RigidBody3D = ResourcePool.get_bullet()
	b.set_what_fired_me(self)
	b.position = muzzle.position
	b.rotation.x += randomx_angle
	b.rotation.y += randomy_angle
	muzzle.add_child(b)
	b.reset()


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
