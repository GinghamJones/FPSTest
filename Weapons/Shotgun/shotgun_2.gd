extends Weapon


@onready var anims = $Player_Shotgun/AnimationPlayer
@onready var reload_sound = $Reload
@onready var muzzle_flash : GPUParticles3D = $MuzzleFlash
@onready var smoke : GPUParticles3D = $Smoke
@onready var muzzle : Marker3D = $Player_Shotgun/Muzzle
@onready var bullet : PackedScene = preload("res://Weapons/bullet.tscn")


func fire():
	if bullets_in_mag == 0 or is_firing == true:
		can_fire = false
	else:
		can_fire = true

	if can_fire:
		is_firing = true
		anims.play("Player_Shotgun_Fire", 0, 1.0)
		muzzle_flash.emitting = true
		smoke.emitting = true
		
		fire_sound.play()
		fire_rate.start()
		
		for i in 10:
			spawn_bullet()

		PlayerUpgrade.gun_fired()
		bullets_in_mag -= 1


func reload_weapon():
	if bullets_in_mag == mag_size:
		pass
	else:
		anims.play("Player_Shotgun_Reload", 0.1, 1.0)
		is_reloading = true
		reload_time.start()
		while bullets_in_mag < mag_size:
			bullets_in_mag += 1
			available_bullets -= 1
			if available_bullets == 0:
				break


func idle(anim_speed : float):
	anims.play("Player_Shotgun_Idle", 0.5, anim_speed)
	

func walk(anim_speed : float):
	anims.play("Player_Shotgun_Walk", 0.5, anim_speed)
	
	
func run(anim_speed : float):
	anims.play("Player_Shotgun_Run", 0.3, anim_speed)


func spawn_bullet():
	# Randomize angles of projectiles
	spread_randomizer.randomize()
	var randomy_angle = spread_randomizer.randf_range(-bullet_spread.x, bullet_spread.x)
	var randomx_angle = spread_randomizer.randf_range(-bullet_spread.y, bullet_spread.y)
		
	# Spawn bullet and set transformation
	var b : RigidBody3D = bullet.instantiate()
	#var b : RigidBody3D = ResourcePool.get_bullet()
	
	#b.set_what_fired_me(self)
	b.transform = muzzle.transform
	b.position += Vector3(0, -1.63, 0)
	b.rotation.x += randomx_angle
	b.rotation.y += randomy_angle
	muzzle.add_child(b)
	b.prepare(self)
	



func can_i_move():
	if not is_firing and not is_reloading:
		return true
		
	return false


func _on_fire_rate_timeout():
	is_firing = false
	#anim_state = IDLE


func _on_reload_timer_timeout():
	is_reloading = false
	#anim_state = IDLE
