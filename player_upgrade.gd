extends Node

var player : CharacterBody3D 
var hud : Control

# Speed vars
var previous_position : float = 0
var current_position : float = 0
var distance_moved : float = 0
var distance_to_levelup : float = 5
var levelup_scalar : float = 0.1
var speed_levels_attained : int = 0

# Weapon vars
var bullets_fired : int
var bullets_to_level : int = 10
var bullet_level : int = 0

var kill_ceiling : int = 3
var enemies_killed : int = 0

var doors 


signal level_changed
signal speed_changed

func _process(delta):
	if player != null:
		current_position = player.global_position.length()
		if previous_position != current_position:
			distance_moved += abs(player.velocity.length() * delta)
			hud.distance_changed(abs(player.velocity.length() * delta))
			
		previous_position = current_position
		
		if distance_moved >= distance_to_levelup:
			distance_moved = 0
			distance_to_levelup *= 1.5
			
			speed_levels_attained += 1
			player.set_speed(speed_levels_attained * levelup_scalar)
			emit_signal("speed_changed", player.speed)

			
		if bullets_fired >= bullets_to_level:
			bullet_level += 1
			if player.weapon_holder.current_weapon.bullet_spread >= Vector2.ZERO:
				player.weapon_holder.current_weapon.bullet_spread -= Vector2(0.1, 0.05)
			print(bullet_level)
			bullets_fired = 0
			
		if enemies_killed >= kill_ceiling:
			enemies_killed = 0
			player.level += 1
			print(player.level)
			emit_signal("level_changed", player.level)
			if player.level >= 1:
				for door in doors:
					if door.DOOR_NUM == player.level:
						door.can_open = true
	

func level_loaded():
	player = get_tree().get_first_node_in_group("Player")
	hud = player.get_node("HUD")
	previous_position = player.global_position.length()
	doors = get_tree().get_nodes_in_group("Door")
	connect("level_changed", Callable(hud, "on_level_changed"))
	connect("speed_changed", Callable(hud, "on_speed_changed"))
	
	
func gun_fired():
	bullets_fired += 1
