extends Node3D

var map_node: Node3D = null

func _ready():
	call_deferred("deferred_load_map")

func deferred_load_map():
	# Map ko frame-by-frame background me load karein
	if ResourceLoader.exists("res://bermuda_map.glb"):
		var map_res = load("res://bermuda_map.glb")
		if map_res:
			map_node = map_res.instantiate()
			add_child(map_node)
			optimize_map_nodes(map_node)

func optimize_map_nodes(node: Node):
	if node is MeshInstance3D:
		# Door ke visual lods aur collision set karein
		if not node.has_node("StaticBody3D"):
			node.create_trimesh_collision()
	for child in node.get_children():
		optimize_map_nodes(child)
