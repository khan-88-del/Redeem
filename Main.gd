extends Node3D

var canvas: CanvasLayer
var status_label: Label
var load_thread: Thread
var map_loaded: bool = false
var loaded_scene: Node = null

func _ready():
	# Simple safe black loading UI
	canvas = CanvasLayer.new()
	canvas.layer = 999
	add_child(canvas)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.08, 0.08, 0.1, 1.0)
	canvas.add_child(bg)

	status_label = Label.new()
	status_label.text = "Free Fire Bermuda: Checking files safely..."
	status_label.position = Vector2(80, 150)
	status_label.add_theme_font_size_override("font_size", 22)
	canvas.add_child(status_label)

	# Main thread ko block kiye bina alag thread me load karein
	load_thread = Thread.new()
	load_thread.start(_background_loader)

func _background_loader():
	var valid_path = ""
	var paths = [
		"/sdcard/Android/obb/com.khan.freefire.bermuda/Bermuda Map 3D Model.glb",
		"/storage/emulated/0/Android/obb/com.khan.freefire.bermuda/Bermuda Map 3D Model.glb",
		"/sdcard/Android/obb/com.khan.freefire.bermuda/My project (22)/Bermuda Map 3D Model.glb",
		"/storage/emulated/0/Android/obb/com.khan.freefire.bermuda/My project (22)/Bermuda Map 3D Model.glb"
	]

	for p in paths:
		if FileAccess.file_exists(p):
			valid_path = p
			break

	if valid_path == "":
		call_deferred("_update_status", "Error: Bermuda GLB OBB me nahi mila!")
		return

	call_deferred("_update_status", "Map mil gaya! RAM safe loading shuru...")

	var gltf = GLTFDocument.new()
	var state = GLTFState.new()

	# Safe parsing
	var err = gltf.append_from_file(valid_path, state)
	if err == OK:
		call_deferred("_update_status", "Compiling 3D world meshes...")
		var scene = gltf.generate_scene(state)
		call_deferred("_on_load_complete", scene)
	else:
		call_deferred("_update_status", "Load Error: " + str(err))

func _update_status(msg: String):
	if status_label:
		status_label.text = msg

func _on_load_complete(scene_node: Node):
	if scene_node:
		scene_node.name = "BermudaMap"
		add_child(scene_node)
		map_loaded = true

		if has_node("Player"):
			$Player.global_position = Vector3(0, 30, 0)

		status_label.text = "Bermuda Map Successfully Loaded!"
		await get_tree().create_timer(2.0).timeout
		canvas.queue_free()

func _exit_tree():
	if load_thread and load_thread.is_started():
		load_thread.wait_to_finish()
