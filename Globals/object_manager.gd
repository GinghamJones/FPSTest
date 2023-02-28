extends Node

var player : CharacterBody3D
@onready var melee_enemy : PackedScene = preload("res://Enemy/enemy.tscn")
@onready var ranged_enemy : PackedScene = preload("res://Enemy/rangedenemy.tscn")
@onready var shotgun_pickup : PackedScene = preload("res://Weapons/Shotgun/shotgun_pickup.tscn")
@onready var ar_pickup : PackedScene = preload("res://Weapons/AR/ar_pickup.tscn")


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	
	
func spawn_a_bitch(spawn_point : Vector3, requester, bitch_type : String) -> CharacterBody3D:
	var new_enemy
	if bitch_type == "Melee":
		new_enemy = melee_enemy.instantiate()
	elif bitch_type == "Ranged":
		new_enemy = ranged_enemy.instantiate()
	requester.add_child(new_enemy)
	new_enemy.global_position = spawn_point
	#set_enemy_nav_points(new_enemy)
	new_enemy.connect("im_dead_af", Callable(requester, "enemy_death"))

	return new_enemy


func spawn_weapon_pickup(weapon : String, spawn_point : Transform3D):
	var pickup_to_spawn : WeaponPickup
	match(weapon):
		"Shotgun":
			pickup_to_spawn = shotgun_pickup.instantiate()
		"AR":
			pickup_to_spawn = ar_pickup.instantiate()
	
	player.weapon_holder.picked_up.connect(Callable(pickup_to_spawn, "weapon_picked_up"))
	
	get_tree().current_scene.add_child(pickup_to_spawn)
	pickup_to_spawn.global_transform = spawn_point
	pickup_to_spawn.throw_me()
