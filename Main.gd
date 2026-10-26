extends Node3D

@onready var player = $Player

func _ready():
	print("Game active. Loading Bermuda directly from storage...")
	call_deferred("load_direct_bermuda_map")

func load_direct_bermuda_map():
	# Direct mobile storage paths jahan map rakha hai
	var possible_paths = [
		"/sdcard/Recordings/Bermuda Map 3D Model.glb",
		"/storage/emulated/0/Recordings/Bermuda Map 3D Model.glb",
		"/sdcard/Android/obb/com.khan.freefire.bermuda/Bermuda Map 3D Model.glb"
	]
	
	var found_path = ""
	for p in possible_paths:
		if FileAccess.file_exists(p):
			found_path = p
			break
			
	if found_path != "":
		print("Found Bermuda Map at: ", found_path)
		var gltf_doc = GLTFDocument.new()
		var gltf_state = GLTFState.new()
		var error = gltf_doc.append_from_file(found_path, gltf_state)
		
		if error == OK:
			var map_node = gltf_doc.generate_scene(gltf_state)
			map_node.name = "BermudaMap"
			add_child(map_node)
			# Player ko ground ke upar set karein
			if has_node("Player"):
				$Player.global_position = Vector3(0, 15, 0)
			print("Map successfully spawned!")
		else:
			print("GLTF load error code: ", error)
	else:
		print("Map file not found on storage paths")
