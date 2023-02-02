extends Node


func save_game():
	var save_data = FileAccess.open("user://save_game.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
#		if node.filename.empty():
#			print("FUCK YOU!!!! %s not instanced" % node.name)
#			continue
			
		if not node.has_method("save"):
			print("%s has no fucking save method, dummy" % node.name)
			continue
			
		var node_data = node.call("save")
		
		var json_string = JSON.stringify(node_data)
		
		save_data.store_line(json_string)
		
	save_data = null
	
	
func load_game():
	var save_game = FileAccess.open("user://save_game.save", FileAccess.READ)
	
#	if not save_game.file_exists("user://save_game.save"):
#		print("That ain't right, dingus. no save file")
#		return
		
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	
	while save_game.get_position() < save_game.get_length():
		var json = JSON.new()
		
		var node_data = json.get_data()
		#var parse_result = json.parse(node_data)
#		if not parse_result == OK:
#			print("error error i r stpid n rding json")
#			continue
			
		print(node_data)
