extends weapon

var randomizer = RandomNumberGenerator.new()
@onready var anims = $Shotgunrig/AnimationPlayer

func fire():
	if anims.is_playing or bullets_in_mag <= 0:
		can_fire = false
	else:
		can_fire = true
		
	if can_fire:
		fire_sound.play()
		anims.play("Shotgun_Fire")

		for i in 10:
			randomizer.randomize()
			var randomy_angle = randomizer.randf_range(-1, 1)
			var randomx_angle = randomizer.randf_range(-0.1, 0.1)
		
			var b = bullet.instantiate()
			b.speed = bullet_speed
			b.bullet_damage = damage
			b.transform.basis = muzzle.transform.basis 
			b.rotation.x += randomx_angle
			b.rotation.y += randomy_angle
			muzzle.add_child(b)
	
		bullets_in_mag -= 1
	
func reload_weapon():
	if bullets_in_mag == mag_size:
		pass
	else:
		reload_time.start()
		while bullets_in_mag < mag_size:
			bullets_in_mag += 1
			if available_bullets == 0:
				break
