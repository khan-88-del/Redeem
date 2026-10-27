extends Node3D

@onready var player = $Player

func _ready():
	# Sabse upar dikhne wala Canvas Layer
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	add_child(canvas)

	var bg = ColorRect.new()
	bg.size = Vector2(800, 120)
	bg.position = Vector2(20, 20)
	bg.color = Color(0, 0, 0, 0.75)
	canvas.add_child(bg)

	var lbl = Label.new()
	lbl.name = "StatusLabel"
	lbl.position = Vector2(30, 30)
	lbl.text = "Checking map paths..."
	lbl.add_theme_font_size_override("font_size", 20)
	canvas.add_child(lbl)

	call_deferred("start_loading_flow", lbl)

func start_loading_flow(lbl: Label):
	await get_tree().create_timer(0.5).timeout

	var user_data_path = OS.get_user_data_dir()
	print("User data dir: ", user_data_path)

	# Har possible path scan karein (OBB aur Android/data dono)
	var targets = [
		"/sdcard/Android/obb/com.khan.freefire.bermuda/Bermuda Map 3D Model.glb",
		"/storage/emulated/0/Android/obb/com.khan.freefire.bermuda/Bermuda Map 3D Model.glb",
		"/sdcard/Android/obb/com.khan.freefire.bermuda/My project (22)/Bermuda Map 3D Model.glb",
		"/storage/emulated/0/Android/obb/com.khan.freefire.bermuda/My project (22)/Bermuda Map 3D Model.glb",
		user_data_path + "/Bermuda Map 3D Model.glb",
		"user://Bermuda Map 3D Model.glb"
	]

	var selected_path = ""
	for p in targets:
		if FileAccess.file_exists(p):
			selected_path = p
			break

	if selected_path == "":
		lbl.text = "Error: File nahi mili!\nPath checked in OBB & data folders."
		return

	lbl.text = "Found file at:\n" + selected_path + "\nLoading GLB..."
	await get_tree().process_frame

	var gltf = GLTFDocument.new()
	var state = GLTFState.new()
	var err = gltf.append_from_file(selected_path, state)

	if err == OK:
		lbl.text = "Generating 3D Bermuda scene..."
		await get_tree().process_frame
		var map_node = gltf.generate_scene(state)
		map_node.name = "BermudaMap"
		add_child(map_node)

		if has_node("Player"):
			$Player.global_position = Vector3(0, 35, 0)

		lbl.text = "Bermuda Map Loaded Successfully!"
		await get_tree().create_timer(4.0).timeout
		lbl.get_parent().queue_free()
	else:
		lbl.text = "GLTF Load Failed. Error Code: " + str(err)
