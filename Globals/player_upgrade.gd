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

signal level_changed
signal speed_changed

func _process(delta):
	if player != null:
		var current_velocity : float = player.velocity.length() / 3
		if current_velocity > 0.5:
			distance_moved += abs(current_velocity * delta)
			hud.distance_changed(abs(current_velocity * delta))

		if distance_moved >= distance_to_levelup:
			distance_moved = 0
			distance_to_levelup *= 1.5

			speed_levels_attained += 1
			player.set_speed(speed_levels_attained * levelup_scalar)
			emit_signal("speed_changed", player.speed)


		if bullets_fired >= bullets_to_level:
			bullet_level += 1
			if player.weapon_holder.current_weapon.bullet_spread >= Vector2.ZERO:
				player.weapon_holder.current_weapon.bullet_spread -= Vector2(0.02, 0.01)
			print(bullet_level)
			bullets_fired = 0

		if enemies_killed >= kill_ceiling:
			enemies_killed = 0
			player.level += 1
			emit_signal("level_changed", player.level)

	

func game_loaded():
	player = get_tree().get_nodes_in_group("Player")[0]
	hud = player.get_node("HUD")
	
	connect("level_changed", Callable(hud, "on_level_changed"))
	connect("speed_changed", Callable(hud, "on_speed_changed"))

	
func gun_fired():
	bullets_fired += 1
