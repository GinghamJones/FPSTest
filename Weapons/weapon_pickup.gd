extends Node3D

@export var weapon_name : String
@export var ammo : int
var on_ground = true


func _process(delta):
	if on_ground:
		self.global_rotation.y += 1 * delta

func _on_player_picked_up():
	queue_free()


func _on_area_3d_body_entered(body):
	if body.has_method("pickup_available"):
		body.pickup_available(weapon_name)	


func _on_area_3d_body_exited(body):
	if body.has_method("pickup_not_available"):
		body.pickup_not_available()
