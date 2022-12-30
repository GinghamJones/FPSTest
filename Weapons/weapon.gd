extends Node3D
class_name weapon


@export var gun_name : String = "gun"
@export var gun_type : String = "type"
@export var mag_size : int 
var bullets_in_mag : int
var available_bullets : int
@export var reload_time : Timer 
@export var fire_rate : Timer 
@export var damage : int 
@export var single_fire : bool 
@export var bullet_speed : float 
@onready var bullet = preload("res://Weapons/bullet.tscn")
@onready var muzzle: MeshInstance3D = $Muzzle
@onready var fire_sound : AudioStreamPlayer3D = $FireSound
var can_fire : bool = true
var is_firing : bool = false
var is_reloading : bool = false


signal outta_rounds()
signal bullet_fired()



func _ready():
	bullets_in_mag = mag_size
	available_bullets = 30	
	


func get_damage():
	return damage



	
