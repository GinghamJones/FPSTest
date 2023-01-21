extends Control

@onready var use_prompt : Label = $UsePrompt
@onready var health : Label = $StatsContainer/Health
@onready var ammo : Label = $StatsContainer/Ammo
@onready var bullets_left : Label = $StatsContainer/BulletsLeft

@onready var speed_label : Label = $UpgradeVarsContainer/Speed
@onready var level_label : Label = $UpgradeVarsContainer/Level
@onready var distance_label : Label = $UpgradeVarsContainer/DistanceTraveled

var distance_traveled : float = 0

func _ready():
	health.show()
	ammo.show()


func display_use_prompt(text):
	use_prompt.set_text("Press E to " + text)
	use_prompt.show()


func update_health(cur_health):
	health.set_text("Health: " + str(cur_health))
	
	
func update_ammo():
	pass


func _on_weapon_holder_weapon_changed(weapon_stats):
	ammo.set_text("Ammo: " + str(weapon_stats.bullets_in_mag) + " / " + str(weapon_stats.mag_size))
	bullets_left.set_text("Bullets Left: " + str(weapon_stats.available_bullets))


func _on_player_health_changed(cur_health):
	health.set_text("Health: " + str(cur_health) + " / " + "100")
	

func on_level_changed(new_level):
	level_label.set_text("Level: " + str(new_level))
	
	
func on_speed_changed(new_speed):
	speed_label.set_text("Speed: " + str(new_speed))
	

func distance_changed(distance):
	distance_traveled += distance
	distance_label.set_text("Distance: " + str(distance_traveled))

