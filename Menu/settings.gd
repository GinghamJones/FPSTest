extends Control

func _on_qhd_pressed():
	get_tree().get_root().size = Vector2i(2560, 1440)
	get_tree().get_root().position = Vector2i(20, 20)

func _on_fhd_pressed():
	get_tree().get_root().size = Vector2i(1920, 1080)
	get_tree().get_root().position = Vector2i(20, 20)

func _on_hd_pressed():
	get_tree().get_root().size = Vector2i(1280, 720)
	get_tree().get_root().position = Vector2i(20, 20)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Menu/main_menu.tscn")
	
func _on_fs_pressed():
	get_tree().get_root().mode = Window.MODE_FULLSCREEN

func _on_windowed_pressed():
	get_tree().get_root().mode = Window.MODE_WINDOWED

func _exit_tree():
	queue_free()
