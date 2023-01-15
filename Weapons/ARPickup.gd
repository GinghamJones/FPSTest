extends WeaponPickup

#@onready var ar : PackedScene = preload("res://Weapons/ar.tscn")
var gun_instance 

func _on_area_3d_body_entered(body):
	if body.has_method("pickup_available"):
		#gun_instance = ar.instantiate()
		body.pickup_available(weapon)	


func _on_area_3d_body_exited(body):
	if body.has_method("pickup_not_available"):
		body.pickup_not_available()
		#gun_instance.queue_free()


