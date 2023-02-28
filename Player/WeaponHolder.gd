extends Node3D

var weapons : Array[Weapon] = []
var current_weapon : Weapon = null
var is_holstered : bool = true
var state = MOVEMENT
var is_sprinting : bool = false
var anim_speed : float = 1.0
var weapon_rotation : Vector3 = Vector3.ZERO
var already_got_weapon : bool = false

const MIN_WEAPON_ROTATION : Vector3 = Vector3(deg_to_rad(-5.0), deg_to_rad(-10), 0)
const MAX_WEAPON_ROTATION : Vector3 = Vector3(deg_to_rad(5.0), deg_to_rad(10.0), 0)

enum {
	FIRING,
	RELOADING,
	MOVEMENT,
	THROWN,
}

signal weapon_changed(current_weapon)
signal picked_up


func _unhandled_input(event):
	if is_holstered:
		pass
	else:
		if event.is_action_pressed("throw_weapon"):
			ObjectManager.spawn_weapon_pickup(current_weapon.gun_name, current_weapon.global_transform)
			state = THROWN

			
		if state != RELOADING:
			if current_weapon.single_fire:
				if event.is_action_pressed("fire"):
					state = FIRING
			else:
				if Input.is_action_pressed("fire"):
					state = FIRING
			if event.is_action_released("fire"):
				state = MOVEMENT
		
		if state != FIRING:
			if event.is_action_pressed("reload"):
				state = RELOADING
			
		if event.is_action_pressed("weapon_1"):
			if weapons.size() > 1:
				switch_weapon(weapons[0])
		
		if event.is_action_pressed("weapon_2"):
			if weapons.size() > 1:
				switch_weapon(weapons[1])


func _physics_process(_delta):
	if not is_holstered:
		animate_weapon()
		

func switch_weapon(weapon):
	if weapon == current_weapon:
		return
	# Hide current weapon and show new one
	for i in weapons:
		if i == current_weapon:
			i.hide()
		if i == weapon:
			i.show()
	
	current_weapon = weapon
	is_holstered = false
	emit_signal("weapon_changed", current_weapon)
	print(current_weapon.gun_owner)


func pickup_weapon(new_weapon):
	for w in weapons:
		if w.gun_name == new_weapon.gun_name:
			return

	var g = new_weapon
	g.gun_owner = get_parent().get_parent()
	add_child(g)
	weapons.push_back(g)
	switch_weapon(g)
	emit_signal("picked_up", g.gun_name)
		

func animate_weapon():
	#if not is_holstered:
	match(state):
		THROWN:
			weapons.erase(current_weapon)
			current_weapon.queue_free()
			if weapons.size() > 0:
				switch_weapon(weapons[0])
			else:
				current_weapon = null
				is_holstered = true
			
			state = MOVEMENT
		FIRING:
			current_weapon.fire()
			if not current_weapon.is_firing:
				state = MOVEMENT
			emit_signal("weapon_changed", current_weapon)
		RELOADING:
			current_weapon.reload_weapon()
			if not current_weapon.is_reloading:
				state = MOVEMENT
			emit_signal("weapon_changed", current_weapon)
		MOVEMENT:
			if is_sprinting == true:
				current_weapon.run(anim_speed)
			if anim_speed > 0.3:
				current_weapon.walk(anim_speed)
			else:
				#anim_speed = 1.0
				current_weapon.idle(1.0)
		


func weapon_sway(mouseDelta):
	# Rotate weapon_holder 
	if mouseDelta.x > 0:
		weapon_rotation.y = lerp(weapon_rotation.y, deg_to_rad(-10), 0.01)
	
	elif mouseDelta.x < 0:
		weapon_rotation.y = lerp(weapon_rotation.y, deg_to_rad(10), 0.01)
	
	if mouseDelta.y > 0:
		weapon_rotation.x = lerp(weapon_rotation.x, deg_to_rad(-5.0), 0.02)
	
	elif mouseDelta.y < 0:
		weapon_rotation.x = lerp(weapon_rotation.x, deg_to_rad(5.0), 0.02)

	if mouseDelta == Vector2(0,0):
		weapon_rotation.y = lerp(weapon_rotation.y, 0.0, 0.1)
		weapon_rotation.x = lerp(weapon_rotation.x, 0.0, 0.1)
	
	weapon_rotation.clamp(MIN_WEAPON_ROTATION, MAX_WEAPON_ROTATION)
	rotation = weapon_rotation


func holster_weapon():
	current_weapon.hide()


func get_weapon():
	return current_weapon
