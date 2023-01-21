extends Control
#@onready var player : PackedScene = preload("res://Player/player.tscn")

signal level1_start

func _ready():
	connect("level1_start", Callable(LevelManager, "level_1_pressed"))


func _on_start_button_pressed():
	$Level1.visible = true
	$Level2.visible = true

func _on_settings_button_pressed():
	get_tree().change_scene_to_file("res://Menu/settings.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

func _exit_tree():
	queue_free()

func _on_level_1_pressed():
	#var p : CharacterBody3D = player.instantiate()
	emit_signal("level1_start")
	


func _on_level_2_pressed():
	get_tree().change_scene_to_file("res://Levels/level_2.tscn")
