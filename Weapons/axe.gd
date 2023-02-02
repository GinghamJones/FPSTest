extends Weapon

@onready var anims : AnimationPlayer = $AnimationPlayer


func fire():
	if is_firing == true:
		pass
	else:
		anims.play("Fire")
		is_firing = true
		fire_rate.start()
	

func reload_weapon():
	pass
	
	
func walk(speed):
	anims.play("Walk", 0.3, speed)
	

func run(speed):
	anims.play("Walk", 0.3, speed)
	
	
func idle(_speed):
	pass


func _on_fire_rate_timeout():
	is_firing = false
