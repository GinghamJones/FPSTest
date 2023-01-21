extends Node3D

@onready var player : CharacterBody3D = get_tree().get_nodes_in_group("Player")[0]
@onready var player_start : Marker3D = $PlayerSpawn
@onready var start_positions : Array
@onready var enemy : PackedScene = preload("res://Enemy/enemy.tscn")
@onready var win_text : Label = $WinText

var enemies_killed : int = 0

signal level1_complete

func _ready():
	randomize()
	win_text.hide()
	
	connect("level1_complete", Callable(LevelManager, "level1_complete"))

	player.global_transform = player_start.global_transform
	
	# Connect player signal to pickups
	var pickups = get_tree().get_nodes_in_group("Pickup")
	for p in pickups:
		player.weapon_holder.picked_up.connect(Callable(p, "weapon_picked_up"))
	
	for i in $StartPositions.get_children():
		start_positions.push_back(i)
		
	spawn_a_bitch()
	#$L2Song.play()


func spawn_a_bitch():
	var new_enemy = enemy.instantiate()
	add_child(new_enemy)
	var randomizer = randi_range(0, 3)
	var start_pos = start_positions[randomizer]
	new_enemy.global_position = start_pos.global_position
	
	set_enemy_nav_points(new_enemy)
	
	new_enemy.connect("im_dead_af", Callable(self, "enemy_death"))


func set_enemy_nav_points(new_enemy):
	var new_nav_points = [$StartPositions/Point1, $StartPositions/Point2, $StartPositions/Point3, $StartPositions/Point4]
	new_enemy.set_nav_points(new_nav_points)
	
	
func enemy_death():
	spawn_a_bitch()
	PlayerUpgrade.enemies_killed += 1
	enemies_killed += 1
	if enemies_killed > 1:
		level_complete()
		
func level_complete():
	win_text.show()
	$Timer.start()
	get_tree().paused = true
	await $Timer.timeout
	emit_signal("level1_complete")
	
