extends Node

@onready var level1 : PackedScene = preload("res://Levels/level.tscn")
@onready var level2 : PackedScene = preload("res://Levels/level_2.tscn")
@onready var player_ps : PackedScene = preload("res://Player/player.tscn")

var player : CharacterBody3D 

# Called when the node enters the scene tree for the first time.
func _ready():
	player = player_ps.instantiate()
	player.set_physics_process(false)
	

func level_1_pressed():
	get_tree().change_scene_to_packed(level1)
	get_tree().root.add_child(player)
	PlayerUpgrade.game_loaded()
	
	
func level1_complete():
	get_tree().change_scene_to_packed(level2)

