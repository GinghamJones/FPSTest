extends Node3D

@onready var upgrade_script = get_node("/root/PlayerUpgrade")
@onready var player = $Player
@onready var enemy : PackedScene = preload("res://Enemy/enemy.tscn")
var start_positions : Array 

func _ready():
	randomize()
	
	connect("tree_entered", Callable(upgrade_script, "level_loaded"))
	
	for i in $StartPositions.get_children():
		start_positions.push_back(i)
		
	spawn_a_bitch()
	set_enemy_nav_points()
	#$L2Song.play()
	emit_signal("tree_entered")

func _on_timer_timeout():
	Window.print_orphan_nodes()


func _on_l_2_song_finished():
	$L2Song.play()


func spawn_a_bitch():
	var new_enemy = enemy.instantiate()
	add_child(new_enemy)
	var randomizer = randi_range(0, 3)
	var start_pos = start_positions[randomizer]
	new_enemy.global_position = start_pos.global_position
	
	set_enemy_nav_points()
	
	#new_enemy.connect("im_dead_af", self.enemy_death())
	#new_enemy.connect(new_enemy.im_dead_af, enemy_death())
	await new_enemy.im_dead_af
	enemy_death()


func enemy_death():
	spawn_a_bitch()
	PlayerUpgrade.enemies_killed += 1

	
func set_enemy_nav_points():
	var new_nav_points = [$Marker3D, $Marker3D2, $Marker3D3, $Marker3D4]
	get_tree().call_group("EnemyNav", "get_nav_points", new_nav_points)
