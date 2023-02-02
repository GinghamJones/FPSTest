extends CSGBox3D

signal ow_fuck(damage : int)

func owie(damage):
	print(self)
	damage *= 0.5

	emit_signal("ow_fuck", damage)


