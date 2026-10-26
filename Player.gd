extends CharacterBody3D

@export var walk_speed: float = 2.4
@export var sprint_speed: float = 4.8
@export var gravity: float = 24.0
@export var touch_sensitivity: float = 0.004

@onready var model_node: Node3D = $ModelNode
@onready var cam_yaw: Node3D = $CamYaw
@onready var cam_pitch: Node3D = $CamYaw/CamPitch
@onready var camera: Camera3D = $CamYaw/CamPitch/Camera3D

@onready var joystick_area: Control = $CanvasLayer/JoystickArea
@onready var joystick_knob: ColorRect = $CanvasLayer/JoystickArea/Knob

var anim_player: AnimationPlayer = null
var current_anim: String = ""
var is_transitioning: bool = false
var auto_sprint: bool = false
var has_gun_equipped: bool = false

var sprint_btn: Button = null
var gun_switch_btn: Button = null
var gun_instance: Node3D = null
var bone_attachment: BoneAttachment3D = null

const GUN_SCALE: Vector3 = Vector3(56.0, 56.0, 56.0)
const GUN_ROT: Vector3 = Vector3(990.0, 390.0, 255.0)
const GUN_POS: Vector3 = Vector3(-1.76, 22.45, 1.62)

var joystick_active: bool = false
var joystick_touch_index: int = -1
var joystick_max_radius: float = 70.0
var look_touch_index: int = -1
var move_dir_2d: Vector2 = Vector2.ZERO

var cull_timer: float = 0.0
var all_map_meshes: Array[MeshInstance3D] = []
var texture_cache: Dictionary = {}

func _ready():
	Engine.max_fps = 120
	# Darwaze ki chaukhat aur pull par smoothly chadhne ke liye
	floor_snap_length = 0.6
	floor_constant_speed = true
	floor_max_angle = deg_to_rad(65.0)
	
	camera.current = true
	camera.near = 0.05
	camera.far = 130.0
	
	cam_yaw.position = Vector3(0, 0, 0)
	cam_yaw.rotation = Vector3.ZERO
	cam_pitch.position = Vector3(0, 0.65, 0)
	cam_pitch.rotation = Vector3.ZERO
	camera.position = Vector3(0.3, 0.15, 1.35)
	camera.rotation_degrees = Vector3(-5, 0, 0)
	
	_fix_player_collision_shape()
	$CanvasLayer.visible = true
	set_process_input(true)
	
	_create_ui_buttons()
	_setup_character_and_all_animations()
	call_deferred("_launch_free_fire_pipeline")

func _fix_player_collision_shape():
	var col_shape: CollisionShape3D = find_child("CollisionShape3D", true, false)
	if col_shape:
		# Darwaze se bina fase nikalne ke liye capsule ko ultra-slim kiya
		var capsule = CapsuleShape3D.new()
		capsule.radius = 0.18
		capsule.height = 1.3
		col_shape.shape = capsule
		col_shape.position = Vector3(0, 0.65, 0)

func _load_tex(filename: String) -> Texture2D:
	if texture_cache.has(filename):
		return texture_cache[filename]
	var base_path = "res://textures/" + filename
	var tex: Texture2D = null
	if ResourceLoader.exists(base_path + ".png"):
		tex = load(base_path + ".png")
	elif ResourceLoader.exists(base_path + ".jpg"):
		tex = load(base_path + ".jpg")
	elif ResourceLoader.exists(base_path + ".tga"):
		tex = load(base_path + ".tga")
	texture_cache[filename] = tex
	return tex

func _launch_free_fire_pipeline():
	var nodes = get_tree().root.find_children("*", "MeshInstance3D", true, false)
	
	var tex_ground = _load_tex("Terrain_Ground_01_D")
	var tex_road = _load_tex("Terrain_Ground_02_D")
	var tex_dirt = _load_tex("Terrain_Ground_03_D")
	
	# Ultra Low Shading Presets
	var mat_ground = StandardMaterial3D.new()
	if tex_ground:
		mat_ground.albedo_texture = tex_ground
		mat_ground.uv1_scale = Vector3(100, 100, 100)
	else:
		mat_ground.albedo_color = Color(0.35, 0.48, 0.25)
	mat_ground.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_ground.cull_mode = BaseMaterial3D.CULL_BACK

	var mat_road = StandardMaterial3D.new()
	if tex_road:
		mat_road.albedo_texture = tex_road
		mat_road.uv1_scale = Vector3(50, 50, 50)
	else:
		mat_road.albedo_color = Color(0.25, 0.25, 0.25)
	mat_road.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_road.cull_mode = BaseMaterial3D.CULL_BACK

	var mat_dirt = StandardMaterial3D.new()
	if tex_dirt:
		mat_dirt.albedo_texture = tex_dirt
		mat_dirt.uv1_scale = Vector3(60, 60, 60)
	else:
		mat_dirt.albedo_color = Color(0.45, 0.38, 0.3)
	mat_dirt.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_dirt.cull_mode = BaseMaterial3D.CULL_BACK

	var mat_metal = StandardMaterial3D.new()
	mat_metal.albedo_color = Color(0.38, 0.38, 0.38)
	mat_metal.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_metal.cull_mode = BaseMaterial3D.CULL_BACK

	for m in nodes:
		if model_node.is_ancestor_of(m):
			continue
		var low_name = m.name.to_lower()
		var is_terrain = ("terrain" in low_name or "ground" in low_name or "landscape" in low_name)
		var is_bridge = ("bridge" in low_name or "pull" in low_name or "road" in low_name)
		var is_house = ("house" in low_name or "building" in low_name or "room" in low_name or "wall" in low_name)
		
		if "stair" in low_name or "step" in low_name or "ladder" in low_name:
			m.material_override = mat_metal
		elif is_bridge:
			m.material_override = mat_road
		elif "rock" in low_name or "mountain" in low_name or "cliff" in low_name:
			m.material_override = mat_dirt
		elif is_terrain:
			m.material_override = mat_ground
		else:
			m.visibility_range_end = 100.0
			m.visibility_range_end_margin = 10.0
			all_map_meshes.append(m)

		# Pull ke andar girne aur ghar ke darwaze block hone ka permanent solution
		if not m.has_node("StaticBody3D"):
			if "tree" in low_name or "leaf" in low_name or "grass" in low_name or "fence" in low_name or "prop" in low_name:
				continue
			# Bridge aur House ke liye exact Trimesh collision taaki darwaze khule rahein aur pull solid bane
			m.create_trimesh_collision()

func _create_ui_buttons():
	var vp_size = get_viewport().get_visible_rect().size
	var fire_btn = $CanvasLayer.find_child("FireButton", true, false)
	var base_x = vp_size.x - 210
	var base_y = vp_size.y - 120
	if fire_btn:
		base_x = fire_btn.position.x - 95
		base_y = fire_btn.position.y
	sprint_btn = Button.new()
	sprint_btn.text = "RUN"
	sprint_btn.custom_minimum_size = Vector2(80, 55)
	sprint_btn.position = Vector2(base_x, base_y + 10)
	var style_run = StyleBoxFlat.new()
	style_run.bg_color = Color(0.12, 0.12, 0.12, 0.85)
	style_run.corner_radius_top_left = 10
	style_run.corner_radius_top_right = 10
	style_run.corner_radius_bottom_left = 10
	style_run.corner_radius_bottom_right = 10
	sprint_btn.add_theme_stylebox_override("normal", style_run)
	sprint_btn.pressed.connect(_on_sprint_pressed)
	$CanvasLayer.add_child(sprint_btn)

	gun_switch_btn = Button.new()
	gun_switch_btn.text = "MP40"
	gun_switch_btn.custom_minimum_size = Vector2(80, 55)
	gun_switch_btn.position = Vector2(base_x, base_y - 70)
	var style_gun = StyleBoxFlat.new()
	style_gun.bg_color = Color(0.15, 0.15, 0.2, 0.85)
	style_gun.corner_radius_top_left = 10
	style_gun.corner_radius_top_right = 10
	style_gun.corner_radius_bottom_left = 10
	style_gun.corner_radius_bottom_right = 10
	gun_switch_btn.add_theme_stylebox_override("normal", style_gun)
	gun_switch_btn.pressed.connect(_on_gun_switch_pressed)
	$CanvasLayer.add_child(gun_switch_btn)

func _on_sprint_pressed():
	auto_sprint = !auto_sprint
	var style = sprint_btn.get_theme_stylebox("normal") as StyleBoxFlat
	if auto_sprint:
		style.bg_color = Color(0.95, 0.45, 0.05, 0.95)
	else:
		style.bg_color = Color(0.12, 0.12, 0.12, 0.85)
		if move_dir_2d == Vector2.ZERO:
			_trigger_stop_transition()

func _on_gun_switch_pressed():
	has_gun_equipped = !has_gun_equipped
	var style = gun_switch_btn.get_theme_stylebox("normal") as StyleBoxFlat
	if has_gun_equipped:
		style.bg_color = Color(0.1, 0.6, 0.95, 0.95)
		if gun_instance:
			gun_instance.visible = true
		if move_dir_2d == Vector2.ZERO and not auto_sprint:
			_play_anim("gun_idle")
	else:
		style.bg_color = Color(0.15, 0.15, 0.2, 0.85)
		if gun_instance:
			gun_instance.visible = false
		if move_dir_2d == Vector2.ZERO and not auto_sprint:
			_play_anim("idle")

func _setup_character_and_all_animations():
	var char_file = ""
	if ResourceLoader.exists("res://Chart.glb"):
		char_file = "res://Chart.glb"
	elif ResourceLoader.exists("res://chart.glb"):
		char_file = "res://chart.glb"
	else:
		return
	var char_res = load(char_file)
	var char_scene = char_res.instantiate()
	model_node.add_child(char_scene)
	char_scene.scale = Vector3(0.0055, 0.0055, 0.0055)
	char_scene.position = Vector3(0, 0, 0)
	var target_skel = _find_skeleton(char_scene)
	_apply_clean_colors(char_scene)
	if target_skel:
		_attach_mp40_to_skeleton(target_skel)
	anim_player = char_scene.find_child("AnimationPlayer", true, false)
	if not anim_player:
		anim_player = AnimationPlayer.new()
		char_scene.add_child(anim_player)
	anim_player.animation_finished.connect(_on_animation_finished)
	var anim_lib = AnimationLibrary.new()
	_register_anim(["res://stop.glb", "res://Stop.glb"], "idle", anim_lib, char_scene, target_skel, true)
	_register_anim(["res://run.glb", "res://Run.glb"], "walk", anim_lib, char_scene, target_skel, true)
	_register_anim(["res://Running.fbx.glb", "res://running.fbx.glb"], "sprint", anim_lib, char_scene, target_skel, true)
	_register_anim(["res://Run To Stop.glb", "res://run to stop.glb"], "run_to_stop", anim_lib, char_scene, target_skel, false)
	_register_anim(["res://takewepon.glb", "res://Takewepon.glb", "res://TakeWepon.glb"], "gun_idle", anim_lib, char_scene, target_skel, true)
	_register_anim(["res://runwithrifel.glb", "res://Runwithrifel.glb", "res://RunWithRifel.glb"], "gun_run", anim_lib, char_scene, target_skel, true)
	if anim_lib.get_animation_list().size() > 0:
		anim_player.add_animation_library("", anim_lib)
	if anim_player.has_animation("idle"):
		_play_anim("idle")

func _attach_mp40_to_skeleton(skel: Skeleton3D):
	var hand_bone_name = ""
	for b in range(skel.get_bone_count()):
		var b_low = skel.get_bone_name(b).to_lower()
		if ("righthand" in b_low or "right_hand" in b_low or "hand.r" in b_low or "hand_r" in b_low) and not "arm" in b_low:
			hand_bone_name = skel.get_bone_name(b)
			break
	if hand_bone_name == "":
		for b in range(skel.get_bone_count()):
			var b_low = skel.get_bone_name(b).to_lower()
			if "hand" in b_low and not "arm" in b_low:
				hand_bone_name = skel.get_bone_name(b)
				break
	if hand_bone_name == "" and skel.get_bone_count() > 0:
		hand_bone_name = skel.get_bone_name(skel.get_bone_count() - 1)
	bone_attachment = BoneAttachment3D.new()
	bone_attachment.bone_name = hand_bone_name
	skel.add_child(bone_attachment)
	var gun_path = ""
	if ResourceLoader.exists("res://mp40.glb"):
		gun_path = "res://mp40.glb"
	elif ResourceLoader.exists("res://MP40.glb"):
		gun_path = "res://MP40.glb"
	if gun_path != "":
		var g_res = load(gun_path)
		if g_res:
			gun_instance = g_res.instantiate()
			gun_instance.scale = GUN_SCALE
			gun_instance.rotation_degrees = GUN_ROT
			gun_instance.position = GUN_POS
			gun_instance.visible = false
			bone_attachment.add_child(gun_instance)

func _register_anim(paths: Array, anim_name: String, lib: AnimationLibrary, root: Node, skel: Skeleton3D, is_loop: bool):
	var found_path = ""
	for p in paths:
		if ResourceLoader.exists(p):
			found_path = p
			break
	if found_path == "":
		return
	var res = load(found_path)
	if not res:
		return
	var scn = res.instantiate()
	var ap = scn.find_child("AnimationPlayer", true, false)
	if ap and ap.get_animation_list().size() > 0:
		var src: Animation = ap.get_animation(ap.get_animation_list()[0])
		var remap = _remap_and_strip_root(src, root, skel)
		remap.loop_mode = Animation.LOOP_LINEAR if is_loop else Animation.LOOP_NONE
		lib.add_animation(anim_name, remap)

func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node
	for child in node.get_children():
		var res = _find_skeleton(child)
		if res:
			return res
	return null

func _remap_and_strip_root(source_anim: Animation, model_root: Node, skel: Skeleton3D) -> Animation:
	var new_anim: Animation = source_anim.duplicate()
	var skel_path = str(model_root.get_path_to(skel))
	for t in range(new_anim.get_track_count()):
		var track_p = String(new_anim.track_get_path(t))
		var bone_name = ""
		if ":" in track_p:
			bone_name = track_p.split(":")[-1]
		elif "/" in track_p:
			bone_name = track_p.split("/")[-1]
		new_anim.track_set_path(t, skel_path + ":" + bone_name)
		var low = bone_name.to_lower()
		if ("hip" in low or "pelvis" in low or "root" in low) and new_anim.track_get_type(t) == Animation.TYPE_POSITION_3D:
			for k in range(new_anim.track_get_key_count(t)):
				var val = new_anim.track_get_key_value(t, k)
				if val is Vector3:
					new_anim.track_set_key_value(t, k, Vector3(0, val.y, 0))
	return new_anim

func _apply_clean_colors(node: Node):
	if node is MeshInstance3D:
		var count = node.get_surface_override_material_count()
		if count == 0 and node.mesh:
			count = node.mesh.get_surface_count()
		for s in range(max(1, count)):
			var mat = StandardMaterial3D.new()
			var n_name = (node.name + "_" + str(s)).to_lower()
			if "shoe" in n_name or "foot" in n_name or "boot" in n_name or s == 3:
				mat.albedo_color = Color("#0099ff")
				mat.roughness = 0.35
			elif "leg" in n_name or "pant" in n_name or "bottom" in n_name or s == 1:
				mat.albedo_color = Color("#111111")
				mat.roughness = 0.85
			elif "hair" in n_name or "head" in n_name:
				mat.albedo_color = Color("#1e1e1e")
				mat.roughness = 0.8
			else:
				mat.albedo_color = Color("#f4f4f4")
				mat.roughness = 0.5
			mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			node.set_surface_override_material(s, mat)
	for child in node.get_children():
		_apply_clean_colors(child)

func _play_anim(name: String, speed_val: float = 1.0):
	if not anim_player or not anim_player.has_animation(name):
		return
	if current_anim != name or not anim_player.is_playing():
		anim_player.play(name)
		current_anim = name
	anim_player.speed_scale = speed_val

func _trigger_stop_transition():
	if has_gun_equipped:
		_play_anim("gun_idle")
	elif anim_player and anim_player.has_animation("run_to_stop"):
		is_transitioning = true
		_play_anim("run_to_stop", 1.2)
	else:
		_play_anim("idle")

func _on_animation_finished(anim_name: String):
	if anim_name == "run_to_stop":
		is_transitioning = false
		_play_anim("idle")

func _input(event: InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed:
			var joy_rect = joystick_area.get_global_rect()
			if joy_rect.has_point(event.position) and not joystick_active:
				joystick_active = true
				joystick_touch_index = event.index
				auto_sprint = false
				_update_sprint_btn_style()
				_update_joystick(event.position)
			elif event.position.x > get_viewport().get_visible_rect().size.x / 2.0 and look_touch_index == -1:
				var is_btn = false
				if $CanvasLayer.has_node("FireButton") and $CanvasLayer/FireButton.get_global_rect().has_point(event.position):
					is_btn = true
				if sprint_btn and sprint_btn.get_global_rect().has_point(event.position):
					is_btn = true
				if gun_switch_btn and gun_switch_btn.get_global_rect().has_point(event.position):
					is_btn = true
				if not is_btn:
					look_touch_index = event.index
		else:
			if event.index == joystick_touch_index:
				joystick_active = false
				joystick_touch_index = -1
				move_dir_2d = Vector2.ZERO
				joystick_knob.position = joystick_area.size / 2.0 - joystick_knob.size / 2.0
				if not auto_sprint:
					_trigger_stop_transition()
			elif event.index == look_touch_index:
				look_touch_index = -1
	elif event is InputEventScreenDrag:
		if event.index == joystick_touch_index and joystick_active:
			_update_joystick(event.position)
		elif event.index == look_touch_index:
			cam_yaw.rotate_y(-event.relative.x * touch_sensitivity)
			cam_pitch.rotate_x(-event.relative.y * touch_sensitivity)
			cam_pitch.rotation.x = clamp(cam_pitch.rotation.x, deg_to_rad(-35), deg_to_rad(35))

func _update_sprint_btn_style():
	if sprint_btn:
		var style = sprint_btn.get_theme_stylebox("normal") as StyleBoxFlat
		style.bg_color = Color(0.12, 0.12, 0.12, 0.85)

func _update_joystick(touch_pos: Vector2):
	var center = joystick_area.global_position + (joystick_area.size / 2.0)
	var offset = touch_pos - center
	if offset.length() > joystick_max_radius:
		offset = offset.normalized() * joystick_max_radius
	joystick_knob.position = (joystick_area.size / 2.0) + offset - (joystick_knob.size / 2.0)
	move_dir_2d = offset / joystick_max_radius

func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y -= gravity * delta
	var cam_forward = -cam_yaw.global_transform.basis.z
	cam_forward.y = 0.0
	cam_forward = cam_forward.normalized()
	var cam_right = cam_yaw.global_transform.basis.x
	cam_right.y = 0.0
	cam_right = cam_right.normalized()
	var move_direction = Vector3.ZERO
	var current_speed = 0.0
	if auto_sprint:
		move_direction = cam_forward
		current_speed = sprint_speed
	elif move_dir_2d != Vector2.ZERO:
		var input_vec = Vector3(move_dir_2d.x, 0, move_dir_2d.y)
		move_direction = (cam_right * input_vec.x + cam_forward * -input_vec.z).normalized()
		current_speed = walk_speed
	if move_direction != Vector3.ZERO:
		is_transitioning = false
		velocity.x = move_direction.x * current_speed
		velocity.z = move_direction.z * current_speed
		var target_rot = atan2(move_direction.x, move_direction.z)
		model_node.rotation.y = lerp_angle(model_node.rotation.y, target_rot, 0.25)
		if has_gun_equipped and anim_player.has_animation("gun_run"):
			_play_anim("gun_run", 0.9)
		elif auto_sprint and anim_player.has_animation("sprint"):
			_play_anim("sprint", 1.0)
		elif anim_player.has_animation("walk"):
			_play_anim("walk", 0.95)
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)
		if not is_transitioning:
			if has_gun_equipped and anim_player.has_animation("gun_idle"):
				_play_anim("gun_idle", 1.0)
			elif current_anim != "idle":
				_play_anim("idle", 1.0)
	move_and_slide()
	cull_timer += delta
	if cull_timer >= 0.3:
		cull_timer = 0.0
		var p_pos = global_position
		for obj in all_map_meshes:
			if is_instance_valid(obj):
				var dist_sq = p_pos.distance_squared_to(obj.global_position)
				obj.visible = (dist_sq <= 10000.0)

func _on_fire_button_pressed():
	print("Fire Button Triggered")
