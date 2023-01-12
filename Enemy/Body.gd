extends CSGBox3D



signal ow_fuck(damage : int)

func owie(damage):
	print(self)
	
	emit_signal("ow_fuck", damage)
