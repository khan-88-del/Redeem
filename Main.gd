extends Node3D

@onready var player = $Player
var map_loaded: bool = false

func _ready():
	print("Checking storage permissions...")
	# Android se permission popup maangein
	if OS.get_name() == "Android":
		OS.request_permissions()
	
	# Thoda wait karke map check karein
	await get_tree().create_timer(1.0).timeout
	load_map_from_recordings()

func _notification(what):
	# Jab user permission allow karke wapas game par aaye
	if what == NOTIFICATION_APPLICATION_RESUMED and not map_loaded:
		load_map_from_recordings()

func load_map_from_recordings():
	if map_loaded:
		return
		
	var path = "/sdcard/Recordings/Bermuda Map 3D Model.glb"
	if not FileAccess.file_exists(path):
		path = "/storage/emulated/0/Recordings/Bermuda Map 3D Model.glb"
		
	if FileAccess.file_exists(path):
		var gltf = GLTFDocument.new()
		var state = GLTFState.new()
		var err = gltf.append_from_file(path, state)
		
		if err == OK:
			var scene = gltf.generate_scene(state)
			scene.name = "BermudaMap"
			add_child(scene)
			map_loaded = true
			if has_node("Player"):
				$Player.global_position = Vector3(0, 20, 0)
			print("Map successfully loaded after permission!")
		else:
			print("GLTF loading error: ", err)
	else:
		print("File still not accessible. Waiting for permission grant...")
