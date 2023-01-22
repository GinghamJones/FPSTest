extends Weapon


var randomizer = RandomNumberGenerator.new()
@onready var anims = $Player_Shotgun/AnimationPlayer
@onready var reload_sound = $Reload
@onready var muzzle_flash : GPUParticles3D = $MuzzleFlash
@onready var smoke : GPUParticles3D = $Smoke
var current_anim : String = ""
var does_anim_loop : bool = false
var bullet_spread : Vector2 = Vector2(1, 0.1)


## States moved to weapon_holder ## 
#enum {
#	FIRING,
#	RELOADING,
#	IDLE,
#	WALKING,
#	RUNNING,
#}

#var anim_state = IDLE

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
		
		#set_anim(FIRING, 1.0)
		fire_sound.play()
		fire_rate.start()
		#set_anim("Player_Shotgun_Fire")
		for i in 10:
			spawn_bullet()
		
		PlayerUpgrade.gun_fired()
		bullets_in_mag -= 1


func reload_weapon():
	if bullets_in_mag == mag_size:
		pass
	else:
		anims.play("Player_Shotgun_Reload", 0.1, 1.0)
		#set_anim(RELOADING, 1.0)
		is_reloading = true
		reload_time.start()
		#set_anim("Player_Shotgun_Reload")
		#reload_sound.play()
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
	randomizer.randomize()
	var randomy_angle = randomizer.randf_range(-bullet_spread.x, bullet_spread.x)
	var randomx_angle = randomizer.randf_range(-bullet_spread.y, bullet_spread.y)
		
	# Spawn bullet and set transformation
#	var b = bullet.instantiate()
	var b = ResourcePool.get_bullet()
	b.set_who_fired_me(self)
	b.add_collision_exception_with(get_tree().get_nodes_in_group("Player")[0])
	b.speed = bullet_speed
	b.bullet_damage = damage
	b.transform.basis = muzzle.transform.basis
	b.rotation.x += randomx_angle
	b.rotation.y += randomy_angle
	muzzle.add_child(b)


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
