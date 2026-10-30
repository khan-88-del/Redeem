extends Node3D

var canvas: CanvasLayer
var status_lbl: Label

func _ready():
	canvas = CanvasLayer.new()
	canvas.layer = 999
	add_child(canvas)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.04, 0.07, 1.0)
	canvas.add_child(bg)

	status_lbl = Label.new()
	status_lbl.position = Vector2(80, 160)
	status_lbl.text = "Loading Bermuda World Scene..."
	status_lbl.add_theme_font_size_override("font_size", 22)
	canvas.add_child(status_lbl)

	call_deferred("_load_scene")

func _load_scene():
	await get_tree().process_frame
	var scene_path = "res://BermudaMap.tscn"

	if ResourceLoader.exists(scene_path):
		var packed = load(scene_path)
		if packed is PackedScene:
			var map_inst = packed.instantiate()
			map_inst.name = "BermudaIsland"
			add_child(map_inst)
			status_lbl.text = "Bermuda 3D Map Loaded!"
			if has_node("Player"):
				$Player.global_position = Vector3(0, 35, 0)
			await get_tree().create_timer(1.2).timeout
			canvas.queue_free()
			return

	# Fallback agar direct GLB check karna ho
	if ResourceLoader.exists("res://Bermuda_Mesh.glb"):
		var glb_packed = load("res://Bermuda_Mesh.glb")
		if glb_packed is PackedScene:
			var map_inst = glb_packed.instantiate()
			map_inst.name = "BermudaIsland"
			add_child(map_inst)
			status_lbl.text = "Bermuda GLB Loaded!"
			if has_node("Player"):
				$Player.global_position = Vector3(0, 35, 0)
			await get_tree().create_timer(1.2).timeout
			canvas.queue_free()
			return

	status_lbl.text = "Error: Map assets missing inside package!"
