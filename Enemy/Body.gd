extends CSGBox3D



signal ow_fuck(damage : int)

func owie(damage):
	emit_signal("ow_fuck", damage)
