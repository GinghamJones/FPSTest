extends Node3D

func _ready():
	print("I've been instantiated!")

func _process(delta):
	if !self.emitting:
		queue_free()
		
