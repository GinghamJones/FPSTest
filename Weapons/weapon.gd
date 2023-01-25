extends Node3D
class_name Weapon


@export var gun_name : String = "gun"
@export var gun_type : String = "type"
@export var mag_size : int 
@export var damage : int 
@export var single_fire : bool 
@export var bullet_speed : float
@export var bullet_spread : Vector2

@onready var reload_time : Timer = $ReloadTimer
@onready var fire_rate : Timer = $FireRate
@onready var fire_sound : AudioStreamPlayer3D = $FireSound

var bullets_in_mag : int
var available_bullets : int
var gun_owner : String
var spread_randomizer = RandomNumberGenerator.new()

var can_fire : bool = true
var outta_bullets : bool = false
var is_firing : bool = false
var is_reloading : bool = false


signal outta_rounds()
signal bullet_fired()


func _ready():
	bullets_in_mag = mag_size


