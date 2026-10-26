extends Node3D

var map_instance: Node3D = null
var is_obb_mounted: bool = false
var target_map_path: String = ""

func _ready():
	print("Game initialized. Searching for Bermuda OBB...")
	call_deferred("initialize_game_obb")

func initialize_game_obb():
	var package_name = "com.khan.freefire.bermuda"
	var possible_obb_paths = [
		"/sdcard/Android/obb/" + package_name + "/main.1." + package_name + ".obb",
		"/storage/emulated/0/Android/obb/" + package_name + "/main.1." + package_name + ".obb",
		"user://main.1." + package_name + ".obb"
	]
	
	for path in possible_obb_paths:
		if FileAccess.file_exists(path):
			var mounted = ProjectSettings.load_resource_pack(path)
			if mounted:
				print("OBB successfully mounted from: ", path)
				is_obb_mounted = true
				break
	
	# Map GLB file identify karein
	var potential_maps = [
		"res://Bermuda Map 3D Model.glb",
		"res://bermuda_map.glb"
	]
	
	for map_p in potential_maps:
		if ResourceLoader.exists(map_p):
			target_map_path = map_p
			break
			
	if target_map_path != "":
		print("Starting background streaming for: ", target_map_path)
		ResourceLoader.load_threaded_request(target_map_path)
		set_process(true)
	else:
		show_missing_obb_ui()

func _process(_delta):
	if target_map_path == "" or map_instance != null:
		set_process(false)
		return
		
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(target_map_path, progress)
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var packed_scene = ResourceLoader.load_threaded_get(target_map_path)
		if packed_scene:
			map_instance = packed_scene.instantiate()
			map_instance.name = "BermudaMap"
			add_child(map_instance)
			apply_view_distance_optimization(map_instance)
			print("Bermuda Map successfully spawned with chunk optimization!")
		set_process(false)

func apply_view_distance_optimization(node: Node):
	if node is GeometryInstance3D:
		# Distance LOD optimization: door ke parts frame rate drop nahi karenge
		node.visibility_range_end = 160.0
		node.visibility_range_begin_margin = 15.0
		node.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF
	for child in node.get_children():
		apply_view_distance_optimization(child)

func show_missing_obb_ui():
	var canvas = CanvasLayer.new()
	var label = Label.new()
	label.text = "OBB Not Found!\nPlease place 'main.1.com.khan.freefire.bermuda.obb' in:\nAndroid/obb/com.khan.freefire.bermuda/"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(label)
	add_child(canvas)
