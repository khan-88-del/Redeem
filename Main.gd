extends Node3D

func _ready():
	# Purana green floor agar ho to use hide ya remove karein
	for child in get_children():
		var c_name = child.name.to_lower()
		if "floor" in c_name or "ground" in c_name or "plane" in c_name:
			child.visible = false

	# Bermuda map load karna
	var map_path = ""
	if ResourceLoader.exists("res://bermuda.glb"):
		map_path = "res://bermuda.glb"
	elif ResourceLoader.exists("res://Bermuda.glb"):
		map_path = "res://Bermuda.glb"

	if map_path != "":
		var map_res = load(map_path)
		if map_res:
			var map_inst = map_res.instantiate()
			map_inst.name = "BermudaMap"
			# Bermuda map ka scale aur position
			map_inst.scale = Vector3(1.0, 1.0, 1.0)
			map_inst.position = Vector3(0, 0, 0)
			add_child(map_inst)
			
			# Map ke har mesh par automatic collision generate karna
			_generate_collisions_recursively(map_inst)

func _generate_collisions_recursively(node: Node):
	if node is MeshInstance3D and node.mesh:
		# Static body aur trimesh collision create karna
		node.create_trimesh_collision()

	for child in node.get_children():
		_generate_collisions_recursively(child)
