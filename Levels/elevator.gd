extends Node3D
var moved : bool = false

func use():
	if not moved:
		$ElevatorMove.play("move_up")
		moved = true
	else:
		$ElevatorMove.play_backwards("move_up")
		moved = false
