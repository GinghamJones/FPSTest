extends Weapon


var randomizer = RandomNumberGenerator.new()
@onready var anims = $Player_Shotgun/AnimationPlayer
@onready var reload_sound = $Reload
@onready var muzzle_flash : GPUParticles3D = $MuzzleFlash
@onready var smoke : GPUParticles3D = $Smoke
var current_anim : String = ""
var does_anim_loop : bool = false


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
		#anims.connect("animation_finished")
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

		bullets_in_mag -= 1


func reload_weapon():
	if bullets_in_mag == mag_size or is_firing == true:
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
	var randomy_angle = randomizer.randf_range(-1, 1)
	var randomx_angle = randomizer.randf_range(-0.1, 0.1)
		
	# Spawn bullet and set transformation
	var b = bullet.instantiate()
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
	
	
## Antiquated code; states moved to weapon_holder. Delete me if new code works for a while ##

#func set_anim(state, anim_speed := 1.0):
#	if can_i_move() == true:
#		anim_state = state
#
#	anims.playback_speed = anim_speed
#
#	match(anim_state):
#		FIRING:
#			anims.play("Player_Shotgun_Fire")
#		RELOADING:
#			anims.play("Player_Shotgun_Reload")
#		IDLE:
#			anims.play("Player_Shotgun_Idle")
#		WALKING:
#			anims.play("Player_Shotgun_Walk")
#		RUNNING:
#			anims.play("Player_Shotgun_Run")
			

			

#func set_anim(anim_name: String, anim_speed := 1.0, xfade_time := 0.2):
#	var last_anim : String = anims.current_animation
#
#	var anim_to_play = get_animation(anim_name)
#
#	if can_i_move() == true:
#		if last_anim != anim_name:
#			if anims.has_animation(anim_to_play): #and current_anim != anim_name:
#				anims.play(anim_to_play)
#				current_anim = anim_to_play
#			else:
#				print("no anim of that name")
#	else:
#		if is_reloading or is_firing:
#			pass
#		else:	
#			anims.play(anim_name)
#		#does_anim_loop = bool(anims.get_animation(anim_name).loop_mode)
#
#		anims.playback_speed = anim_speed
#		anims.playback_default_blend_time = xfade_time


#func get_animation(anim_name) -> String:
#	if anim_name == "run":
#		return "Player_Shotgun_Run"
#	elif anim_name == "walk":
#		return "Player_Shotgun_Walk"
#	elif anim_name == "idle":
#		return "Player_Shotgun_Idle"
#	else:
#		print("error getting anim name")
#		return ""
		



