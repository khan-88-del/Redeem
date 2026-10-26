extends Node3D

var map_instance: Node3D = null
var textures_cache = {}
var all_mesh_instances = []
var stream_index = 0
const BATCH_SIZE = 15

func _ready():
	load_textures_cache("res://textures/")
	load_bermuda_map()

func load_textures_cache(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and not file_name.begins_with("."):
				load_textures_cache(path + file_name + "/")
			elif file_name.ends_with(".png") or file_name.ends_with(".jpg"):
				var pure_name = file_name.get_basename().to_lower().replace(" ", "_")
				var tex = load(path + file_name)
				if tex:
					textures_cache[pure_name] = tex
			file_name = dir.get_next()

func load_bermuda_map():
	if ResourceLoader.exists("res://bermuda_map.glb"):
		var map_res = load("res://bermuda_map.glb")
		if map_res:
			map_instance = map_res.instantiate()
			add_child(map_instance)
			collect_all_meshes(map_instance)
			apply_missing_textures(map_instance)

func collect_all_meshes(node: Node):
	if node is MeshInstance3D:
		all_mesh_instances.append(node)
		# Shuru me door ke objects ko visually light rakhein
		node.visible = false
	for child in node.get_children():
		collect_all_meshes(child)

func apply_missing_textures(node: Node):
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			for i in range(mesh.get_surface_count()):
				var mat = node.get_active_material(i)
				if mat is StandardMaterial3D and mat.albedo_texture == null:
					var m_name = mat.resource_name.to_lower().replace(" ", "_")
					for k in textures_cache.keys():
						if k in m_name or m_name in k:
							var new_mat = mat.duplicate()
							new_mat.albedo_texture = textures_cache[k]
							node.set_surface_override_material(i, new_mat)
							break
	for child in node.get_children():
		apply_missing_textures(child)

func _process(_delta):
	# Dheere dheere map objects ko background me reveal/stream karein (Lag khatam)
	if stream_index < all_mesh_instances.size():
		var limit = min(stream_index + BATCH_SIZE, all_mesh_instances.size())
		for j in range(stream_index, limit):
			var mesh_node = all_mesh_instances[j]
			if is_instance_valid(mesh_node):
				mesh_node.visible = true
				if not mesh_node.has_node("StaticBody3D"):
					mesh_node.create_trimesh_collision()
		stream_index = limit
