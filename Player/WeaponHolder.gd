extends Node3D

var weapons : Array[Weapon] = []
var current_weapon : Weapon = null
var is_holstered : bool = true
var state = MOVING
var anim_speed : float = 1.0

enum {
	FIRING,
	RELOADING,
	MOVING,
}

signal weapon_changed(current_weapon)
signal picked_up


func _ready():
	var pickups = get_tree().get_nodes_in_group("Pickup")
	for p in pickups:
		picked_up.connect(p.weapon_picked_up)


func _unhandled_input(event):
	if is_holstered:
		pass
	else:
		if current_weapon.single_fire:
			if event.is_action_pressed("fire"):
				state = FIRING
		else:
			if Input.is_action_pressed("fire"):
				state = FIRING
		if event.is_action_released("fire"):
			state = MOVING
		
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


func pickup_weapon(new_weapon):
	if weapons.has(new_weapon):
		pass
	else:
		var g = new_weapon
		add_child(g)
		weapons.push_back(g)
		switch_weapon(g)
		emit_signal("picked_up", g.gun_name)
		

func animate_weapon():
	#if not is_holstered:
	match(state):
		FIRING:
			current_weapon.fire()
			if not current_weapon.is_firing:
				state = MOVING
			emit_signal("weapon_changed", current_weapon)
		RELOADING:
			current_weapon.reload_weapon()
			if not current_weapon.is_reloading:
				state = MOVING
			emit_signal("weapon_changed", current_weapon)
		MOVING:
			if anim_speed > 2.5:
				current_weapon.run(anim_speed)
			elif anim_speed > 0.3:
				current_weapon.walk(anim_speed)
			else:
				#anim_speed = 1.0
				current_weapon.idle(1.0)


func holster_weapon():
	current_weapon.hide()


func get_weapon():
	return current_weapon
