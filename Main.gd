extends Node3D

@onready var player = $Player

var canvas: CanvasLayer
var progress_bar: ProgressBar
var status_label: Label
var loading_panel: Panel
var map_loaded: bool = false

func _ready():
	# Game controls ko loading ke doran hide karein
	hide_gameplay_ui(true)
	
	# Free Fire Style Fullscreen Loading UI setup
	create_loading_ui()
	
	# Background me loading flow chalayein
	start_game_loading_sequence()

func create_loading_ui():
	canvas = CanvasLayer.new()
	canvas.layer = 999
	add_child(canvas)

	loading_panel = Panel.new()
	loading_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Black background theme
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.08, 1.0)
	loading_panel.add_theme_stylebox_override("panel", style)
	canvas.add_child(loading_panel)

	# Title Label
	var title = Label.new()
	title.text = "FREE FIRE BERMUDA"
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.position = Vector2(100, 80)
	title.add_theme_font_size_override("font_size", 36)
	loading_panel.add_child(title)

	# Status Label
	status_label = Label.new()
	status_label.text = "Checking game assets..."
	status_label.position = Vector2(100, 260)
	status_label.add_theme_font_size_override("font_size", 20)
	loading_panel.add_child(status_label)

	# Progress Bar
	progress_bar = ProgressBar.new()
	progress_bar.position = Vector2(100, 310)
	progress_bar.size = Vector2(700, 30)
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.value = 5.0
	loading_panel.add_child(progress_bar)

func update_progress(val: float, msg: String):
	if progress_bar:
		progress_bar.value = val
	if status_label:
		status_label.text = msg
	await get_tree().process_frame

func hide_gameplay_ui(state: bool):
	# Agar UI nodes hain to hide/unhide karein
	for c in get_children():
		if c is CanvasLayer and c != canvas:
			c.visible = !state
		elif c.name in ["TouchScreenButton", "Joystick", "Control"]:
			c.visible = !state

func start_game_loading_sequence():
	await update_progress(10.0, "Locating Bermuda OBB & Data packages...")
	await get_tree().create_timer(1.0).timeout

	var target_paths = [
		"/sdcard/Android/obb/com.khan.freefire.bermuda/Bermuda Map 3D Model.glb",
		"/storage/emulated/0/Android/obb/com.khan.freefire.bermuda/Bermuda Map 3D Model.glb",
		"/sdcard/Android/obb/com.khan.freefire.bermuda/My project (22)/Bermuda Map 3D Model.glb",
		"/storage/emulated/0/Android/obb/com.khan.freefire.bermuda/My project (22)/Bermuda Map 3D Model.glb",
		OS.get_user_data_dir() + "/Bermuda Map 3D Model.glb",
		"user://Bermuda Map 3D Model.glb"
	]

	var valid_path = ""
	for p in target_paths:
		if FileAccess.file_exists(p):
			valid_path = p
			break

	if valid_path == "":
		await update_progress(15.0, "ERROR: Bermuda GLB File not found in OBB or Data!")
		return

	await update_progress(30.0, "Package Found! Reading 3D Geometry (" + valid_path.get_file() + ")...")
	await get_tree().create_timer(1.5).timeout

	var gltf = GLTFDocument.new()
	var state = GLTFState.new()

	await update_progress(50.0, "Decompressing Meshes & Textures...")
	await get_tree().create_timer(1.0).timeout
	
	var err = gltf.append_from_file(valid_path, state)
	if err != OK:
		await update_progress(50.0, "Corrupt File: GLTF Parse Failed code " + str(err))
		return

	await update_progress(75.0, "Building Collision & Physics World...")
	await get_tree().create_timer(1.5).timeout

	var map_node = gltf.generate_scene(state)
	map_node.name = "BermudaMap"
	add_child(map_node)
	map_loaded = true

	await update_progress(90.0, "Spawning Player Character...")
	await get_tree().create_timer(1.0).timeout

	if has_node("Player"):
		$Player.global_position = Vector3(0, 30, 0)

	await update_progress(100.0, "Welcome to Bermuda!")
	await get_tree().create_timer(1.2).timeout

	# Loading Screen remove karein aur gameplay enable karein
	loading_panel.visible = false
	canvas.queue_free()
	hide_gameplay_ui(false)
