extends RigidBody3D


func use():
	var hinge : HingeJoint3D = $RightDoorHinge
	
	if rotation.y < deg_to_rad(1):
		
