extends Node3D

var weapons : Array[Weapon] = []
var current_weapon : Weapon = null
var is_holstered : bool = true
var state = MOVING
var anim_speed : float = 1.0

const MIN_WEAPON_ROTATION : Vector3 = Vector3(deg_to_rad(-5.0), deg_to_rad(-10), 0)
const MAX_WEAPON_ROTATION : Vector3 = Vector3(deg_to_rad(5.0), deg_to_rad(10.0), 0)

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


func weapon_sway(mouseDelta):
	# Rotate weapon_holder 
	
	if mouseDelta.x > 0:
		#weapon_holder.rotation.y = lerp(weapon_holder.rotation.y, deg_to_rad(-10.0), 0.009)
		rotation.y = lerp(rotation.y, -mouseDelta.x / 50, 0.009)
	
	elif mouseDelta.x < 0:
		#weapon_holder.rotation.y = lerp(weapon_holder.rotation.y, deg_to_rad(10), 0.009)
		rotation.y = lerp(rotation.y, -mouseDelta.x / 50, 0.009)
	
	if mouseDelta.y > 0:
		rotation.x = lerp(rotation.x, deg_to_rad(-5.0), 0.009)
	
	elif mouseDelta.y < 0:
		rotation.x = lerp(rotation.x, deg_to_rad(5.0), 0.009)
		

	if mouseDelta == Vector2(0,0):
		rotation.y = lerp(rotation.y, 0.0, 0.1)
		rotation.x = lerp(rotation.x, 0.0, 0.1)
		

	rotation = clamp(rotation, MIN_WEAPON_ROTATION, MAX_WEAPON_ROTATION)
	#weapon_holder.rotation.y = clamp(weapon_holder.rotation.y, deg_to_rad(-10.0), deg_to_rad(10.0))


func holster_weapon():
	current_weapon.hide()


func get_weapon():
	return current_weapon
