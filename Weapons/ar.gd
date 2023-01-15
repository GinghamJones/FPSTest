extends Weapon

@onready var anims : AnimationPlayer = $AnimationPlayer


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
		var b = bullet.instantiate()
		b.speed = bullet_speed
		b.bullet_damage = damage
		b.transform.basis = muzzle.transform.basis
		muzzle.add_child(b)
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
