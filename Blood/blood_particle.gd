extends GPUParticles3D


func _physics_process(_delta):
	if emitting == false:
		queue_free()
		$Timer.start()


func _on_timer_timeout():
	print("I'm here!")
