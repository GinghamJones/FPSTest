extends Node3D

#@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var player = preload("res://Player/player.tscn")
@onready var enemy = preload("res://Enemy/enemy.tscn")
var already_done : bool = false

func _ready():
	var p = player.instantiate()
	p.global_transform = $PlayerStart.global_transform
	
func _physics_process(delta: float) -> void:
	pass


func _on_box_start_col_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and already_done == false:
		$Geometry/Box/Cube/Floor/CollisionShape3D.call_deferred("set_disabled", false)
		spawn_a_bitch()
		$ShotgunPickup2.freeze = false
		already_done = true


func spawn_a_bitch():
	var new_enemy = enemy.instantiate()
	var new_enemy2 = enemy.instantiate()
	var point : Array = [$Geometry/Box/NavPoint]
	new_enemy.set_nav_points(point)
	new_enemy.set_nav_points(point)
	add_child(new_enemy)
	add_child(new_enemy2)

	new_enemy.global_position = $Geometry/Box/Marker3D.global_position
	new_enemy2.global_position = $Geometry/Box/Marker3D2.global_position



	new_enemy.connect("im_dead_af", Callable(self, "enemy_death"))
	new_enemy2.connect("im_dead_af", Callable(self, "enemy_death"))
	
	
func enemy_death():
	pass
