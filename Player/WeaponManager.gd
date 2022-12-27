extends Node3D

signal weapon_changed(new_weapon)
signal bullet_fired(ammo)

@onready var shotgun : PackedScene = preload("res://Weapons/Shotgun/shotgun_2.tscn")
@onready var pistol : PackedScene = preload("res://Weapons/Walther/pistol.tscn")


var weapon_equipped : bool = false

var weapons: Array = []
var current_weapon 

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
			current_weapon.fire()
			emit_signal("bullet_fired", current_weapon)
		if Input.is_action_just_pressed("reload"):
			current_weapon.reload_weapon()
	if Input.is_action_just_pressed("weapon_1"):
		switch_weapon(weapons[0])
	if Input.is_action_just_pressed("weapon_2"):
		if weapons.size() > 1:
			switch_weapon(weapons[1])
