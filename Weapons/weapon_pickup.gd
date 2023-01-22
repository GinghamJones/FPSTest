extends RigidBody3D
class_name WeaponPickup

@export var weapon_name : String
@export var ammo : int
@export var weapon : PackedScene


var on_ground = true

func throw_me():
	apply_impulse(transform.basis.z * 20, transform.basis.z)


func weapon_picked_up(this_weapon_name):
	if this_weapon_name == weapon_name:
		queue_free()
