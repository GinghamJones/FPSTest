extends WeaponPickup

#@onready var shotgun : PackedScene = preload("res://Weapons/Shotgun/shotgun_2.tscn")



func _on_area_3d_body_entered(body):
	if body.has_method("pickup_available"):
		#var gun_instance = weapon.instantiate()
		#var gun_instance = shotgun.instantiate()
		body.pickup_available(weapon)


func _on_area_3d_body_exited(body):
	if body.has_method("pickup_not_available"):
		body.pickup_not_available()

