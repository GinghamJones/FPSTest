extends Node3D

@onready var blades : Node3D = $Blades

@export var speed : float = 10
var running : bool = true

func _ready():
	$FanSound.play()

func _physics_process(delta):
	if running:
		blades.rotation.z += speed * delta
