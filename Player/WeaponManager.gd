extends Node3D

signal weapon_changed(new_weapon)
signal bullet_fired(ammo)

@onready var shotgun : PackedScene = preload("res://Weapons/Shotgun/shotgun_2.tscn")
@onready var pistol : PackedScene = preload("res://Weapons/Walther/pistol.tscn")

var weapon_equipped : bool = false

var weapons: Array = []
var current_weapon 
var vel : Vector3 = Vector3.ZERO

signal gimme_vel

enum {
	FIRING,
	RELOADING,
	MOVING
}

var state = MOVING

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

func _input(_event):
	if weapon_equipped:
		if current_weapon.single_fire and Input.is_action_just_pressed("fire"):
			current_weapon.fire()
			emit_signal("bullet_fired", current_weapon)
		if !current_weapon.single_fire and Input.is_action_pressed("fire"):
			state = FIRING
			current_weapon.fire()
			emit_signal("bullet_fired", current_weapon)
		if Input.is_action_just_pressed("reload"):
			state = RELOADING
			current_weapon.reload_weapon()
	if Input.is_action_just_pressed("weapon_1"):
		switch_weapon(weapons[0])
	if Input.is_action_just_pressed("weapon_2"):
		if weapons.size() > 1:
			switch_weapon(weapons[1])
			
func set_animation():
	
	match(state):
		MOVING:
			emit_signal("gimme_vel")
			if vel == Vector3.ZERO:
				current_weapon.idle()
			else:
				current_weapon.walk()
		FIRING:
			pass
		RELOADING:
			pass

func _physics_process(delta):
	if weapon_equipped:
		print(current_weapon.anims.get_current_animation())
		if current_weapon.anims.get_current_animation() != "Player_Shotgun_Reload" or current_weapon.anims.get_current_animation() == "Player_Shotgun_Fire":
			state = MOVING
		
		set_animation()

#		if current_weapon.anims.get_current_animation() == "Player_Shotgun_Reload" or current_weapon.anims.get_current_animation() == "Player_Shotgun_Fire":
#			pass
#		else:
#			state = MOVING
			
			


