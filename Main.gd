extends Node3D

@onready var player = $Player
var status_lbl: Label
var map_loaded: bool = false

func _ready():
	# Screen par live text dikhane ke liye
	status_lbl = Label.new()
	status_lbl.position = Vector2(40, 40)
	status_lbl.text = "OBB directory scan shuru..."
	status_lbl.add_theme_font_size_override("font_size", 22)
	add_child(status_lbl)

	call_deferred("load_map_from_obb")

func load_map_from_obb():
	if map_loaded:
		return

	# Dono targets (seedha OBB root aur My project folder)
	var possible_paths = [
		"/sdcard/Android/obb/com.khan.freefire.bermuda/Bermuda Map 3D Model.glb",
		"/storage/emulated/0/Android/obb/com.khan.freefire.bermuda/Bermuda Map 3D Model.glb",
		"/sdcard/Android/obb/com.khan.freefire.bermuda/My project (22)/Bermuda Map 3D Model.glb",
		"/storage/emulated/0/Android/obb/com.khan.freefire.bermuda/My project (22)/Bermuda Map 3D Model.glb"
	]

	var found_path = ""
	for p in possible_paths:
		if FileAccess.file_exists(p):
			found_path = p
			break

	if found_path == "":
		status_lbl.text = "Error: Bermuda GLB OBB me nahi mila!"
		print("File missing in OBB targets")
		return

	status_lbl.text = "Map mil gaya! Mesh compile ho raha hai..."
	await get_tree().process_frame

	var gltf = GLTFDocument.new()
	var state = GLTFState.new()
	var err = gltf.append_from_file(found_path, state)

	if err == OK:
		status_lbl.text = "3D world render ho raha hai..."
		var map_node = gltf.generate_scene(state)
		map_node.name = "BermudaMap"
		add_child(map_node)
		map_loaded = true

		if has_node("Player"):
			$Player.global_position = Vector3(0, 30, 0)

		status_lbl.text = "Bermuda Map successfully load ho gaya!"
		await get_tree().create_timer(3.0).timeout
		status_lbl.visible = false
	else:
		status_lbl.text = "GLTF Load Error code: " + str(err)
