extends Node3D

@onready var player = get_tree().get_nodes_in_group("Player")[0]

func _ready():
	var p = player.instantiate()
	p.global_transform = $PlayerStart.global_transform
