extends AnimatableBody3D

@onready var anims : AnimationPlayer = $AnimationPlayer
var is_open : bool = false

func choose_action():
	if is_open:
		close()
	else:
		open()

func open():
	if anims.is_playing() == false:
		anims.play("Open")
		is_open = true
	
func close():
	if anims.is_playing() == false:
		anims.play_backwards("Open")
		is_open = false
