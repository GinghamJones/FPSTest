extends Node3D

signal weapon_changed(new_weapon)
signal bullet_fired(ammo)

@onready var shotgun : PackedScene = preload("res://Weapons/Shotgun/shotgun_2.tscn")
@onready var pistol : PackedScene = preload("res://Weapons/Walther/pistol.tscn")


var weapon_equipped : bool = false

var weapons: Array = []
var current_weapon 

enum {
	IDLE,
	WALKING,
	RUNNING,
	FIRING,
	RELOADING
}

var state = IDLE

func _ready():
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
	emit_signal("weapon_changed", current_weapon)
	
func pickup_weapon(thing):
	if thing == "shotgun":
		var s = shotgun.instantiate()
		self.add_child(s)
		weapons.push_back(s)
		#s.rotation = rotation
		switch_weapon(s)
		
	if thing == "pistol":
		var p = pistol.instantiate()
		add_child(p)
		weapons.push_back(p)
		switch_weapon(p)

func _input(event):
	if weapon_equipped:
		if current_weapon.single_fire and Input.is_action_just_pressed("fire"):
			current_weapon.fire()
			emit_signal("weapon_changed", current_weapon)
			
		if !current_weapon.single_fire and Input.is_action_pressed("fire"):
			current_weapon.fire()
		
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

