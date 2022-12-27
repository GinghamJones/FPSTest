extends Node3D


func _process(delta):
	if !self.emitting:
		queue_free()
		
