extends Node3D

@export var weapon_name : String
@export var ammo : int
@onready var shotgun : PackedScene = preload("res://Weapons/Shotgun/shotgun_2.tscn")

var on_ground = true


func _process(delta):
	if on_ground:
		self.global_rotation.y += 1 * delta

func _on_area_3d_body_entered(body):
	if body.has_method("pickup_available"):
		var s = shotgun.instantiate()
		body.pickup_available(s)	


func _on_area_3d_body_exited(body):
	if body.has_method("pickup_not_available"):
		body.pickup_not_available()


#func _on_player_picked_up(player):
#	var s = shotgun.instantiate()
#	player.get_node("PlayerCamera/WeaponManager").add_child(s)
#	queue_free()
