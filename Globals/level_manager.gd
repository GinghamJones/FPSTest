extends Node

@onready var level1 : PackedScene = preload("res://Levels/level.tscn")
@onready var level2 : PackedScene = preload("res://Levels/level_2.tscn")
@onready var level3 : PackedScene = preload("res://Levels/level_3.tscn")
@onready var player_ps : PackedScene = preload("res://Player/player.tscn")

var player : CharacterBody3D 

# Called when the node enters the scene tree for the first time.
func _ready():
	player = player_ps.instantiate()
	player.set_physics_process(false)
	

func level_1_pressed():
	level1.instantiate()
	get_tree().change_scene_to_file("res://Levels/level.tscn")
	#get_tree().change_scene_to_packed(level1)
	get_tree().root.add_child(player)
	PlayerUpgrade.game_loaded()
	
	
func level1_complete():
	remove_limbs()
	get_tree().change_scene_to_packed(level2)
	
	
func level2_complete():
	remove_limbs()
	get_tree().change_scene_to_packed(level3)
	

func level_2_pressed():
	get_tree().change_scene_to_packed(level2)
	get_tree().root.add_child(player)
	PlayerUpgrade.game_loaded()
	

func level_3_pressed():
	get_tree().change_scene_to_packed(level3)
	get_tree().root.add_child(player)
	PlayerUpgrade.game_loaded()


func remove_limbs():
	var gored_limbs : Array = get_tree().get_nodes_in_group("Limb")
	for limb in gored_limbs:
		limb.queue_free()
