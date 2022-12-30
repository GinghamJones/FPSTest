extends Node3D

@onready var player = $Player

func _ready():
	var new_nav_points = [$Marker3D, $Marker3D2, $Marker3D3, $Marker3D4]
	get_tree().call_group("EnemyNav", "get_nav_points", new_nav_points)

func _physics_process(delta):
	#get_tree().call_group("Enemy", "set_movement_target", player.global_transform.origin)
	pass
