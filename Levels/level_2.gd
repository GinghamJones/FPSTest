extends Node3D

@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var enemy : PackedScene = preload("res://Enemy/enemy.tscn")
var start_positions : Array 
var enemies_killed : int = 0
var enemies : Array

func _ready():
	randomize()
	
	get_tree().paused = false
	
	# Use 'tree entered' to tell upgrade script level was loaded
	connect("tree_entered", Callable(PlayerUpgrade, "level2_loaded"))
	#emit_signal("tree_entered")
	
	# Place player in world
	player.global_transform = $PlayerStart.global_transform
	
	# Connect player signal to pickups
	var pickups = get_tree().get_nodes_in_group("Pickup")
	for p in pickups:
		player.weapon_holder.picked_up.connect(Callable(p, "weapon_picked_up"))

	# Populate array of start/nav positions for enemy 
	for i in $StartPositions.get_children():
		start_positions.push_back(i)
	
	
	enemies.push_back(ObjectManager.spawn_a_bitch(get_start_pos(), self, "Melee")) 
	for enemy in enemies:
		set_enemy_nav_points(enemy)
	#$L2Song.play()


func _on_l_2_song_finished():
	$L2Song.play()


func get_start_pos() -> Vector3:
	var randomizer = randi_range(0, 3)
	var start_pos = start_positions[randomizer]
	return start_pos.global_position
	
	
#func spawn_a_bitch():
#	var new_enemy = enemy.instantiate()
#	add_child(new_enemy)
#
#	new_enemy.global_position = start_pos.global_position
#
#	set_enemy_nav_points(new_enemy)
#
#	new_enemy.connect("im_dead_af", Callable(self, "enemy_death"))
 

func enemy_death(enemy):
	if enemies_killed >= 3:
		$frame/door.can_open = true
	if enemies_killed < 3:
		enemies.push_back(ObjectManager.spawn_a_bitch(get_start_pos(), self, "Melee"))
	PlayerUpgrade.enemies_killed += 1
	enemies_killed += 1
	for bitch in enemies:
		if bitch == enemy:
			enemies.erase(enemy)
		
	

	
func set_enemy_nav_points(new_enemy):
	#var new_nav_points = [$Marker3D, $Marker3D2, $Marker3D3, $Marker3D4]
	new_enemy.set_nav_points(start_positions)
	
