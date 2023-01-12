extends Node3D

signal ow_fuck(damage : int)

func owie(damage, body_part):
	print(body_part)
	if body_part == $LeftArm or body_part == $RightArm or body_part == $LeftLeg or body_part == $RightLeg:
		damage *= 0.5
	elif body_part == $Head:
		damage *= 2
		
	emit_signal("ow_fuck", damage)
		
#	health -= damage
#	update_health(health)
#	if health <= 0:
#		die()
