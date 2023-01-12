extends Node3D

@onready var player = $Player

func _ready():
	var new_nav_points = [$Marker3D, $Marker3D2, $Marker3D3, $Marker3D4]
	get_tree().call_group("EnemyNav", "get_nav_points", new_nav_points)
	#$L2Song.play()


func _on_timer_timeout():
	Window.print_orphan_nodes()


func _on_l_2_song_finished():
	$L2Song.play()
