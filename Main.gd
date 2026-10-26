extends Node3D

@onready var player = $Player

func _ready():
	print("Loading Bermuda directly from storage...")
	call_deferred("load_map_direct")

func load_map_direct():
	var glb_path = "/storage/emulated/0/Recordings/Bermuda Map 3D Model.glb"
	
	if not FileAccess.file_exists(glb_path):
		glb_path = "/sdcard/Recordings/Bermuda Map 3D Model.glb"
		
	if FileAccess.file_exists(glb_path):
		print("File found at: ", glb_path)
		var gltf = GLTFDocument.new()
		var state = GLTFState.new()
		var err = gltf.append_from_file(glb_path, state)
		if err == OK:
			var scene = gltf.generate_scene(state)
			scene.name = "BermudaMap"
			add_child(scene)
			if has_node("Player"):
				$Player.global_position = Vector3(0, 30, 0)
			print("Map successfully spawned!")
		else:
			print("GLTF Parse Error: ", err)
	else:
		print("Map GLB not found at path")
