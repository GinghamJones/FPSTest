extends Node3D

signal weapon_changed(new_weapon)
signal bullet_fired(ammo)

@onready var shotgun : PackedScene = preload("res://Weapons/Shotgun/shotgun_2.tscn")
@onready var unarmed : PackedScene = preload("res://Weapons/unarmed.tscn")



var weapon_equipped : bool = false

var weapons: Array = [null, null, null]
var current_weapon 

func _ready():
#	var x = unarmed.instantiate()
#	weapons.push_back(x)
#	switch_weapon(x)
	pass
	
func switch_weapon(weapon):
	if weapon == current_weapon:
		return
	
	if weapon_equipped:
		current_weapon.hide()
	
	weapon.show()
	current_weapon = weapon	
	
	if !weapon_equipped:
		weapon_equipped = true
	if current_weapon == shotgun:
		emit_signal("weapon_changed", current_weapon)
	
#func pickup_weapon():
#	var w = get_child(0)
#	weapons.push_back(w)
#	switch_weapon(w)

func pickup_weapon(thing):
	if thing == "Shotgun":
		var s = shotgun.instantiate()
		self.add_child(s)
		weapons.push_back(s)
		switch_weapon(s)

func _input(event):
	if weapon_equipped:
		if event.is_action_pressed("fire"):
			current_weapon.fire()
			emit_signal("weapon_changed", current_weapon)
		
		if Input.is_action_just_pressed("reload"):
			current_weapon.reload_weapon()
			emit_signal("weapon_changed", current_weapon)
		
		if event is InputEventKey:
			var walk_or_idle = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
			var is_idle : bool = false
			
			if walk_or_idle == Vector2(0,0):
				is_idle = true
				
			if Input.is_action_pressed("sprint") and is_idle == false:
				current_weapon.determine_move_anim("Player_Shotgun_Run")
			else:
				if is_idle == true:
					current_weapon.determine_move_anim("Player_Shotgun_Idle")
				else:
					current_weapon.determine_move_anim("Player_Shotgun_Walk")
			
			
	
	if Input.is_action_just_pressed("weapon_1"):
		switch_weapon(weapons[0])
	if Input.is_action_just_pressed("weapon_2"):
		if weapons.size() > 1:
			switch_weapon(weapons[1])

func fire_weapon(event):
	if current_weapon.single_fire == false:
		current_weapon.fire()
	else:
		if event.is_action_released("fire"):
			current_weapon.fire()
