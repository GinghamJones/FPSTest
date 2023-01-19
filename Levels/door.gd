extends AnimatableBody3D

@onready var anims : AnimationPlayer = $AnimationPlayer
@onready var bullet : PackedScene = preload("res://Weapons/bullet.tscn")
var is_open : bool = false
var can_open : bool = false
var randomizer = RandomNumberGenerator.new()
const DOOR_NUM : int = 1

func choose_action():
	if can_open:
		if is_open:
			close()
		else:
			open()
	else:
		for i in 100:
			randomizer.randomize()
			var randomy_angle = randomizer.randf_range(-1, 1)
			var randomx_angle = randomizer.randf_range(-0.1, 0.1)
			var b = bullet.instantiate()
			b.speed = 30
			b.bullet_damage = 1
			b.global_position = $door2/handle.global_position
			b.rotation.x += randomx_angle
			b.rotation.y += randomy_angle
			$door2/handle.add_child(b)
		
	
	
func open():
	if anims.is_playing() == false:
		anims.play("Open")
		is_open = true
	
func close():
	if anims.is_playing() == false:
		anims.play_backwards("Open")
		is_open = false
