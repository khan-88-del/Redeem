extends Node3D

@onready var player = $Player

func _ready():
	print("Game initialized. Searching for Bermuda Map Expansion Pack...")
	load_expansion_obb()

func load_expansion_obb():
	var package_name = "com.khan.freefire.bermuda"
	
	# Potential OBB paths on Android storage
	var paths_to_check = [
		"/sdcard/Android/obb/" + package_name + "/main.1." + package_name + ".obb",
		"user://main.1." + package_name + ".obb",
		"user://bermuda.pck",
		"res://bermuda_map.glb" # Fallback if compiled directly
	]
	
	var mounted = false
	
	for path in paths_to_check:
		if FileAccess.file_exists(path):
			if path.ends_with(".obb") or path.ends_with(".pck"):
				# Godot's built-in virtual file system mount
				var success = ProjectSettings.load_resource_pack(path)
				if success:
					print("Successfully mounted OBB/PCK from: ", path)
					mounted = true
					break
			elif path.ends_with(".glb"):
				mounted = true
				break
				
	if mounted or ResourceLoader.exists("res://bermuda_map.glb"):
		spawn_bermuda_map()
	else:
		show_missing_obb_ui()

func spawn_bermuda_map():
	print("Spawning Bermuda Map into scene...")
	var map_resource = load("res://bermuda_map.glb")
	if map_resource:
		var map_instance = map_resource.instantiate()
		map_instance.name = "BermudaMap"
		add_child(map_instance)
		print("Bermuda Map Loaded Successfully!")

func show_missing_obb_ui():
	var canvas = CanvasLayer.new()
	var label = Label.new()
	label.text = "OBB Data Missing!\nPlease place 'main.1.com.khan.freefire.bermuda.obb' in:\nAndroid/obb/com.khan.freefire.bermuda/"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(label)
	add_child(canvas)
