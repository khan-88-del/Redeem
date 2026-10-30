extends Node3D

var canvas: CanvasLayer
var status_lbl: Label
var load_thread: Thread

func _ready():
	# Clean Progress Overlay
	canvas = CanvasLayer.new()
	canvas.layer = 999
	add_child(canvas)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.04, 0.06, 1.0)
	canvas.add_child(bg)

	var title = Label.new()
	title.text = "FREE FIRE: BERMUDA 3D"
	title.position = Vector2(80, 80)
	title.add_theme_font_size_override("font_size", 30)
	canvas.add_child(title)

	status_lbl = Label.new()
	status_lbl.position = Vector2(80, 160)
	status_lbl.text = "Optimized Bermuda Mesh load ho raha hai..."
	status_lbl.add_theme_font_size_override("font_size", 20)
	canvas.add_child(status_lbl)

	load_thread = Thread.new()
	load_thread.start(_load_map_mesh)

func _load_map_mesh():
	var map_path = "res://Bermuda_Mesh.glb"

	if not ResourceLoader.exists(map_path):
		call_deferred("_update_status", "Error: Bermuda_Mesh.glb res:// me nahi mila!")
		return

	call_deferred("_update_status", "3D Island generate ho raha hai...")
	var packed_scene = load(map_path)

	if packed_scene is PackedScene:
		var scene_node = packed_scene.instantiate()
		call_deferred("_finish_loading", scene_node)
	else:
		call_deferred("_update_status", "Error: Model file format invalid!")

func _update_status(msg: String):
	if status_lbl:
		status_lbl.text = msg

func _finish_loading(map_node: Node):
	if map_node:
		map_node.name = "BermudaIsland"
		add_child(map_node)

		if has_node("Player"):
			$Player.global_position = Vector3(0, 35, 0)

		status_lbl.text = "Bermuda 3D Island Ready!"
		await get_tree().create_timer(1.2).timeout
		canvas.queue_free()

func _exit_tree():
	if load_thread and load_thread.is_started():
		load_thread.wait_to_finish()
