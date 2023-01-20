extends Node3D

@onready var player : CharacterBody3D = get_tree().get_nodes_in_group("Player")[0]
@onready var player_start : Marker3D = $PlayerSpawn

func _ready():
	connect("tree_entered", Callable(PlayerUpgrade, "level1_loaded"))
	emit_signal("tree_entered")
	player.global_transform = player_start.global_transform
	player.set_physics_process(true)
