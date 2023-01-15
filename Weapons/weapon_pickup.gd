extends Node3D
class_name WeaponPickup

@export var weapon_name : String
@export var ammo : int
@export var weapon : PackedScene


var on_ground = true


func weapon_picked_up(this_weapon_name):
	if this_weapon_name == weapon_name:
		queue_free()
