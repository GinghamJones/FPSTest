extends RigidBody3D


func save():
	var save_dict = {
		"pos_x" : position.x,
		"pos_y" : position.y,
		"pos_z" : position.z
	}
	
	return save_dict
