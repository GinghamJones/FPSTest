extends Node3D

#@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var player = preload("res://Player/player.tscn")

func _ready():
	var p = player.instantiate()
	p.global_transform = $PlayerStart.global_transform
