extends Node3D

@onready var player = $Player

func _ready():
	print("Game started. Loading directly from Recordings folder...")
	call_deferred("load_direct_bermuda_map")

func load_direct_bermuda_map():
	# Screen par dikh rahe Recordings path ki direct file
	var direct_paths = [
		"/storage/emulated/0/Recordings/Bermuda Map 3D Model.glb",
		"/sdcard/Recordings/Bermuda Map 3D Model.glb"
	]
	
	var valid_path = ""
	for p in direct_paths:
		if FileAccess.file_exists(p):
			valid_path = p
			break
			
	if valid_path != "":
		print("Direct GLB map found: ", valid_path)
		var gltf_doc = GLTFDocument.new()
		var gltf_state = GLTFState.new()
		var err = gltf_doc.append_from_file(valid_path, gltf_state)
		
		if err == OK:
			var map_node = gltf_doc.generate_scene(gltf_state)
			map_node.name = "BermudaMap"
			add_child(map_node)
			
			# View distance LOD taaki game smooth chale aur lag na kare
			apply_render_distance(map_node)
			
			# Player ko ground se thoda upar spawn karein
			if has_node("Player"):
				$Player.global_position = Vector3(0, 15, 0)
			print("Bermuda Map loaded successfully from Recordings!")
		else:
			print("GLTF loading error: ", err)
	else:
		print("Map file not found in Recordings folder!")

func apply_render_distance(parent: Node):
	for child in parent.get_children():
		if child is GeometryInstance3D:
			child.visibility_range_end = 150.0
			child.visibility_range_begin_margin = 15.0
			child.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
		apply_render_distance(child)
