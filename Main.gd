extends Node3D

func _ready():
	# 1. Screen par testing message
	var canvas = CanvasLayer.new()
	canvas.layer = 999
	add_child(canvas)

	var label = Label.new()
	label.position = Vector2(80, 80)
	label.text = "TEST SUCCESSFUL: Main.gd is running properly!"
	label.add_theme_font_size_override("font_size", 24)
	canvas.add_child(label)

	# 2. Ek chhota green test platform spawn karein
	var mesh_instance = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(20, 1, 20)
	mesh_instance.mesh = box

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.8, 0.2)
	mesh_instance.material_override = mat

	mesh_instance.position = Vector3(0, -1, 0)
	add_child(mesh_instance)

	if has_node("Player"):
		$Player.global_position = Vector3(0, 5, 0)
