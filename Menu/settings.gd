extends Control
@onready var res_menu : OptionButton = $VBoxContainer/ResolutionsMenu


var Resolutions : Dictionary = {"2560 x 1440" : Vector2(2560, 1440),
								"1920 x 1080" : Vector2(1920, 1080),
								"1280 x 720" : Vector2(1280, 720),
								"1024 x 600" : Vector2(1024, 600),}

func _ready():
	add_resolutions()
	

func add_resolutions():
	for r in Resolutions:
		res_menu.add_item(r)


func _on_back_pressed():
	get_tree().change_scene_to_file("res://Menu/main_menu.tscn")


func _on_fs_pressed():
	get_tree().get_root().mode = Window.MODE_FULLSCREEN


func _on_windowed_pressed():
	get_tree().get_root().mode = Window.MODE_WINDOWED


func _exit_tree():
	queue_free()


func _on_resolutions_menu_item_selected(index):
	var window_size = Resolutions.get(res_menu.get_item_text(index))
	DisplayServer.window_set_size(window_size)
	


func _on_msaa_slider_value_changed(value):
	get_viewport().msaa_3d = value
	print($VBoxContainer/MSAASlider.value)
	print(get_viewport().msaa_3d)



func _on_taa_box_toggled(button_pressed):
	get_viewport().use_taa = button_pressed


func _on_shadow_quality_value_changed(value):
	RenderingServer.positional_soft_shadow_filter_set_quality(value)


func _on_check_box_pressed():
	if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_DISABLED:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
