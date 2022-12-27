extends weapon

func fire():

	if !fire_rate.is_stopped() or bullets_in_mag <= 0:
		can_fire = false
	else:
		can_fire = true
		
	if can_fire:
		fire_sound.play()
		fire_rate.start()
		
		var b = bullet.instantiate()
		b.speed = bullet_speed
		b.bullet_damage = damage
		b.transform.basis = muzzle.transform.basis
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
