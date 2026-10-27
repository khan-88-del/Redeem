extends Node3D

var canvas: CanvasLayer
var status_lbl: Label
var progress_bar: ProgressBar

func _ready():
	# Clean Loading Screen
	canvas = CanvasLayer.new()
	canvas.layer = 999
	add_child(canvas)

	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.04, 0.04, 0.07, 1.0)
	canvas.add_child(bg)

	var title = Label.new()
	title.text = "FREE FIRE: BERMUDA"
	title.position = Vector2(80, 100)
	title.add_theme_font_size_override("font_size", 32)
	canvas.add_child(title)

	status_lbl = Label.new()
	status_lbl.position = Vector2(80, 180)
	status_lbl.text = "Initializing Bermuda Package..."
	status_lbl.add_theme_font_size_override("font_size", 20)
	canvas.add_child(status_lbl)

	progress_bar = ProgressBar.new()
	progress_bar.position = Vector2(80, 230)
	progress_bar.size = Vector2(650, 24)
	progress_bar.value = 10
	canvas.add_child(progress_bar)

	call_deferred("mount_bermuda_pack")

func mount_bermuda_pack():
	await get_tree().create_timer(0.4).timeout

	var pck_file = "/storage/emulated/0/Android/obb/com.khan.freefire.bermuda/Bermuda.pck"
	if not FileAccess.file_exists(pck_file):
		pck_file = "/sdcard/Android/obb/com.khan.freefire.bermuda/Bermuda.pck"

	if not FileAccess.file_exists(pck_file):
		status_lbl.text = "Error: Bermuda.pck missing from OBB!"
		return

	status_lbl.text = "Mounting 1.35GB Bermuda Package..."
	progress_bar.value = 40
	await get_tree().process_frame

	# Native PCK Mount (Safe, Instant, No RAM Freeze)
	var is_mounted = ProjectSettings.load_resource_pack(pck_file)

	if is_mounted:
		progress_bar.value = 75
		status_lbl.text = "Package Mounted! Detecting 3D map scene..."
		await get_tree().create_timer(0.5).timeout

		# Pack ke andar ki possible map files check karein
		var scenes = [
			"res://BermudaMap.tscn",
			"res://Map.tscn",
			"res://Bermuda.tscn",
			"res://Bermuda Map 3D Model.glb"
		]

		var map_inst = null
		for sc in scenes:
			if ResourceLoader.exists(sc):
				var res = load(sc)
				if res is PackedScene:
					map_inst = res.instantiate()
					break
				elif res is Node:
					map_inst = res
					break

		if map_inst:
			map_inst.name = "BermudaMap"
			add_child(map_inst)
			status_lbl.text = "Map Rendered! Spawning Player..."
		else:
			status_lbl.text = "PCK Mounted! Core Assets Ready."

		progress_bar.value = 100
		if has_node("Player"):
			$Player.global_position = Vector3(0, 30, 0)

		await get_tree().create_timer(1.5).timeout
		canvas.queue_free()
	else:
		status_lbl.text = "PCK Mount Error: Header mismatch!"
