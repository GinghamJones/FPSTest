extends Node

var bullets : Array[RigidBody3D]
#var ar_pickups : Array[RigidBody3D]
#var shotgun_pickups : Array[RigidBody3D]
#var enemies : Array[CharacterBody3D]

@onready var bullet : PackedScene = preload("res://Weapons/bullet.tscn")
#@onready var enemy : PackedScene = preload("res://Enemy/enemy.tscn")
#@onready var ar_pickup : PackedScene = preload("res://Weapons/AR/ar_pickup.tscn")
#@onready var shotgun_pickup : PackedScene = preload("res://Weapons/Shotgun/shotgun_pickup.tscn")
#@onready var ar : PackedScene = preload("res://Weapons/AR/ar.tscn")
#@onready var shotgun : PackedScene = preload("res://Weapons/Shotgun/shotgun_2.tscn")

var bullet_iter : int = 0


func _ready():
	for i in 200:
		var b = bullet.instantiate()
		b.set_physics_process(false)
		bullets.push_back(b)
		
		#b.hide()


#	for i in 5:
#		var e = enemy.instantiate()
#		enemies.push_back(e)
#	print(enemies.size())


func get_bullet():
	var b = bullets[0]
	#b.reset()
	bullets.pop_front()
	return b

func return_bullet(cur_gun, cur_bullet):
	cur_bullet.set_physics_process(false)
	cur_gun.muzzle.remove_child(cur_bullet)
	get_tree().root.add_child(cur_bullet)
	cur_bullet.rotation = Vector3.ZERO
	bullets.push_back(cur_bullet)
	

	
	

