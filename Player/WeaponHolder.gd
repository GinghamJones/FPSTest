extends Node3D

var weapons : Array[Weapon] = []
var current_weapon : Weapon = null
var is_holstered : bool = true
var shotgun : PackedScene = preload("res://Weapons/Shotgun/shotgun_2.tscn")
var state = MOVING
var anim_speed : float = 1.0

enum {
	FIRING,
	RELOADING,
	MOVING,
}

signal weapon_changed(current_weapon)

func _unhandled_input(event):
	if is_holstered:
		pass
	else:
		if event.is_action_pressed("fire"):
			change_state(FIRING)
			emit_signal("weapon_changed", current_weapon)
		
		if event.is_action_pressed("reload"):
			change_state(RELOADING)
			emit_signal("weapon_changed", current_weapon)


func switch_weapon(weapon):
	for i in weapons:
		if i == current_weapon:
			i.hide()
		if i == weapon:
			i.show()
	
	current_weapon = weapon
	is_holstered = false
	emit_signal("weapon_changed", current_weapon)
	

func pickup_weapon(new_weapon):
	if weapons.has(new_weapon):
		pass
	else:
		add_child(new_weapon)
		weapons.push_back(new_weapon)
		switch_weapon(weapons[0])
		

func animate_weapon():
	if not is_holstered:
		print(anim_speed)
		match(state):
			FIRING:
				if not current_weapon.is_firing:
					current_weapon.fire()
			RELOADING:
				if not current_weapon.is_reloading:
					current_weapon.reload_weapon()
			MOVING:
				# First param in set_anim corresponds to enum state values in weapon
				if anim_speed > 2.5:
					current_weapon.run(anim_speed)
					#current_weapon.set_anim(4, anim_speed)
				elif anim_speed > 0.3:
					current_weapon.walk(anim_speed)
					#current_weapon.set_anim(3, anim_speed)
				else:
					anim_speed = 1.0
					current_weapon.idle(anim_speed)
					#current_weapon.set_anim(2, anim_speed)


func change_state(wanted_state):
	if not is_holstered:
		if current_weapon.is_firing or current_weapon.is_reloading:
			pass
		else:
			state = wanted_state
	
	animate_weapon()


func holster_weapon():
	current_weapon.hide()


func get_weapon():
	return current_weapon
