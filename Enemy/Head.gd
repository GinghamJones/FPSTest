extends CSGBox3D



signal ow_fuck(damage : int)

func owie(damage):
	damage *= 2
	
	emit_signal("ow_fuck", damage)
