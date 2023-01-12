extends Node3D


var sounds = []

func _ready():
	var sound1 : AudioStreamPlayer3D = $Step1
	var sound2 : AudioStreamPlayer3D = $Step2
	var sound3 : AudioStreamPlayer3D = $Step3
	var sound4 : AudioStreamPlayer3D = $Step4
	sounds = [sound1, sound2, sound3, sound4]

func play_random_sound():
	var i = (randi() % 4) - 1
	sounds[i].play()
