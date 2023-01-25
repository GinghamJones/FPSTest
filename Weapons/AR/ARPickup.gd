extends WeaponPickup

var gun_instance 

func _on_area_3d_body_entered(body):
	if body.has_method("pickup_available"):
		body.pickup_available(weapon)	


func _on_area_3d_body_exited(body):
	if body.has_method("pickup_not_available"):
		body.pickup_not_available()


