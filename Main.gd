extends Node3D

@onready var player = $Player
var status_lbl: Label
var map_loaded: bool = false

func _ready():
	# Screen par status text box banana
	status_lbl = Label.new()
	status_lbl.position = Vector2(50, 50)
	status_lbl.text = "Initializing storage checks..."
	status_lbl.add_theme_font_size_override("font_size", 24)
	add_child(status_lbl)
	
	if OS.get_name() == "Android":
		status_lbl.text = "Requesting Android Storage Permission..."
		OS.request_permissions()
	
	# 1 second wait karein fir file scan shuru karein
	await get_tree().create_timer(1.2).timeout
	check_and_load_map()

func _notification(what):
	# User permission allow karke app me wapas aaye
	if what == NOTIFICATION_APPLICATION_RESUMED and not map_loaded:
		check_and_load_map()

func check_and_load_map():
	if map_loaded:
		return
		
	var path = "/sdcard/Recordings/Bermuda Map 3D Model.glb"
	if not FileAccess.file_exists(path):
		path = "/storage/emulated/0/Recordings/Bermuda Map 3D Model.glb"
		
	if not FileAccess.file_exists(path):
		status_lbl.text = "File access blocked! Go to Settings > Apps > FreeFire > Permissions > Allow Storage"
		print("Storage path inaccessible")
		return
		
	status_lbl.text = "Map file found! Reading GLB mesh..."
	var gltf = GLTFDocument.new()
	var state = GLTFState.new()
	var err = gltf.append_from_file(path, state)
	
	if err == OK:
		status_lbl.text = "Generating 3D Scene..."
		var map_node = gltf.generate_scene(state)
		map_node.name = "BermudaMap"
		add_child(map_node)
		map_loaded = true
		
		# Ground collision ensure karne ke liye
		if has_node("Player"):
			$Player.global_position = Vector3(0, 25, 0)
			
		status_lbl.text = "Bermuda Map Spawned Successfully!"
		await get_tree().create_timer(3.0).timeout
		status_lbl.visible = false
	else:
		status_lbl.text = "GLTF Load Error code: " + str(err)
