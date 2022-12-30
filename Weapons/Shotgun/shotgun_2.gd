extends weapon


var randomizer = RandomNumberGenerator.new()
@onready var anims = $Player_Shotgun/AnimationPlayer
@onready var reload_sound = $Reload
var current_anim : String = ""
var does_anim_loop : bool = false

func fire():
	if bullets_in_mag <= 0 || fire_sound.playing == true:
		can_fire = false
		anims.connect("animation_finished")
	else:
		can_fire = true
		
	if can_fire:
		fire_sound.play()
		set_anim("Fire")

		for i in 10:
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
	
		bullets_in_mag -= 1
	
func reload_weapon():
	if bullets_in_mag == mag_size || can_fire == false:
		pass
	else:
		anims.connect("animation_finished", get_parent().finished_reloading())
		set_anim("Reload")
		reload_sound.play()
		while bullets_in_mag < mag_size:
			bullets_in_mag += 1
			if available_bullets == 0:
				break
				
func idle():
	set_anim("Idle")
	
func walk():
	set_anim("Walk")
	
func run():
	set_anim("Run")
	
func set_anim(anim_name: String, anim_speed := 1.0, xfade_time := 0.2):
	var last_anim : String = anims.current_animation
	
	if last_anim != anim_name:
		if anims.has_animation(anim_name):
			anims.play(anim_name)
			current_anim = anim_name
		else:
			print("no anim of that name")
		
		#does_anim_loop = bool(anims.get_animation(anim_name).loop_mode)
		
		anims.playback_speed = anim_speed
		anims.playback_default_blend_time = xfade_time

