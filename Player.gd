extends CharacterBody3D

@export var walk_speed: float = 5.0
@export var sprint_speed: float = 11.5
@export var gravity: float = 20.0
@export var touch_sensitivity: float = 0.006

# Model & Camera Nodes
@onready var model_node: Node3D = $ModelNode
@onready var cam_yaw: Node3D = $CamYaw
@onready var cam_pitch: Node3D = $CamYaw/CamPitch
@onready var camera: Camera3D = $CamYaw/CamPitch/Camera3D

# UI Joystick Nodes
@onready var joystick_area: Control = $CanvasLayer/JoystickArea
@onready var joystick_knob: ColorRect = $CanvasLayer/JoystickArea/Knob

# Animation System
var anim_player: AnimationPlayer = null
var current_anim_name: String = ""
var is_sprinting: bool = false
var sprint_btn: Button = null

# Touch Controls State
var joystick_active: bool = false
var joystick_touch_index: int = -1
var joystick_max_radius: float = 70.0
var look_touch_index: int = -1
var move_dir_2d: Vector2 = Vector2.ZERO

func _ready():
	camera.current = true
	camera.near = 0.05
	camera.far = 1000.0
	
	cam_pitch.position = Vector3(0, 1.8, 0)
	camera.position = Vector3(0, 0.6, 4.2)
	
	$CanvasLayer.visible = true
	set_process_input(true)
	_create_sprint_button()
	_setup_character_and_animations()

func _create_sprint_button():
	# Screen par Run / Sprint button dynamically banana
	sprint_btn = Button.new()
	sprint_btn.text = "RUN"
	sprint_btn.custom_minimum_size = Vector2(90, 70)
	sprint_btn.position = Vector2(get_viewport().get_visible_rect().size.x - 220, get_viewport().get_visible_rect().size.y - 100)
	
	# Button styling
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.15, 0.8)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	sprint_btn.add_theme_stylebox_override("normal", style)
	
	sprint_btn.pressed.connect(_on_sprint_toggled)
	$CanvasLayer.add_child(sprint_btn)

func _on_sprint_toggled():
	is_sprinting = !is_sprinting
	var style = sprint_btn.get_theme_stylebox("normal") as StyleBoxFlat
	if is_sprinting:
		style.bg_color = Color(0.9, 0.6, 0.1, 0.9) # Orange highlight
	else:
		style.bg_color = Color(0.15, 0.15, 0.15, 0.8)

func _setup_character_and_animations():
	var char_file = ""
	if ResourceLoader.exists("res://Chart.glb"):
		char_file = "res://Chart.glb"
	elif ResourceLoader.exists("res://chart.glb"):
		char_file = "res://chart.glb"
	else:
		return

	# 1. Base Model Spawn
	var char_res = load(char_file)
	var char_scene = char_res.instantiate()
	model_node.add_child(char_scene)

	char_scene.scale = Vector3(0.025, 0.025, 0.025)
	char_scene.position = Vector3(0, 0, 0)

	var target_skel = _find_skeleton(char_scene)
	_apply_freefire_colors(char_scene)

	# 2. Animation Player Setup
	anim_player = char_scene.find_child("AnimationPlayer", true, false)
	if not anim_player:
		anim_player = AnimationPlayer.new()
		char_scene.add_child(anim_player)

	var anim_lib = AnimationLibrary.new()

	# 3. Normal Walk/Run Animation (run.glb)
	_load_and_register_anim("res://run.glb", "walk", anim_lib, char_scene, target_skel)

	# 4. Fast Sprint Animation (Running.fbx.glb)
	_load_and_register_anim("res://Running.fbx.glb", "sprint", anim_lib, char_scene, target_skel)

	if anim_lib.get_animation_list().size() > 0:
		anim_player.add_animation_library("", anim_lib)

func _load_and_register_anim(file_path: String, anim_id: String, lib: AnimationLibrary, root: Node, skel: Skeleton3D):
	if not ResourceLoader.exists(file_path):
		return
	var res = load(file_path)
	if not res:
		return
	var scn = res.instantiate()
	var aplayer = scn.find_child("AnimationPlayer", true, false)
	if aplayer and aplayer.get_animation_list().size() > 0:
		var src: Animation = aplayer.get_animation(aplayer.get_animation_list()[0])
		var remap = _remap_and_strip_root(src, root, skel)
		remap.loop_mode = Animation.LOOP_LINEAR
		lib.add_animation(anim_id, remap)

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

		# Hips movement neutralize karna
		var low_bone = bone_name.to_lower()
		if ("hip" in low_bone or "pelvis" in low_bone or "root" in low_bone) and new_anim.track_get_type(t) == Animation.TYPE_POSITION_3D:
			for k in range(new_anim.track_get_key_count(t)):
				var pos_val = new_anim.track_get_key_value(t, k)
				if pos_val is Vector3:
					new_anim.track_set_key_value(t, k, Vector3(0, pos_val.y, 0))

	return new_anim

# Kapde: White shirt, Black cargo pants, Blue shoes
func _apply_freefire_colors(node: Node):
	if node is MeshInstance3D:
		node.extra_cull_margin = 16384.0
		node.ignore_occlusion_culling = true
		
		var count = node.get_surface_override_material_count()
		if count == 0 and node.mesh:
			count = node.mesh.get_surface_count()

		for s in range(max(1, count)):
			var mat = StandardMaterial3D.new()
			var n_name = (node.name + "_" + str(s)).to_lower()

			if "shoe" in n_name or "boot" in n_name or "foot" in n_name or s == 3:
				# Bright Electric Blue Shoes
				mat.albedo_color = Color("#0077ff")
				mat.roughness = 0.4
			elif "leg" in n_name or "pant" in n_name or "bottom" in n_name or s == 2:
				# Matte Tactical Black Cargo
				mat.albedo_color = Color("#181818")
				mat.roughness = 0.8
			elif "head" in n_name or "hair" in n_name:
				# Dark Hair / Skin
				mat.albedo_color = Color("#202020")
				mat.roughness = 0.7
			else:
				# Clean White Hoodie / T-shirt
				mat.albedo_color = Color("#f5f5f5")
				mat.roughness = 0.5

			mat.cull_mode = BaseMaterial3D.CULL_DISABLED
			node.set_surface_override_material(s, mat)

	for child in node.get_children():
		_apply_freefire_colors(child)

func _input(event: InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed:
			var joy_rect = joystick_area.get_global_rect()
			if joy_rect.has_point(event.position) and not joystick_active:
				joystick_active = true
				joystick_touch_index = event.index
				_update_joystick(event.position)
			elif event.position.x > get_viewport().get_visible_rect().size.x / 2.0 and look_touch_index == -1:
				if not $CanvasLayer/FireButton.get_global_rect().has_point(event.position) and not sprint_btn.get_global_rect().has_point(event.position):
					look_touch_index = event.index
		else:
			if event.index == joystick_touch_index:
				joystick_active = false
				joystick_touch_index = -1
				move_dir_2d = Vector2.ZERO
				joystick_knob.position = joystick_area.size / 2.0 - joystick_knob.size / 2.0
				if anim_player and current_anim_name != "":
					anim_player.speed_scale = 0.0
			elif event.index == look_touch_index:
				look_touch_index = -1

	elif event is InputEventScreenDrag:
		if event.index == joystick_touch_index and joystick_active:
			_update_joystick(event.position)
		elif event.index == look_touch_index:
			cam_yaw.rotate_y(-event.relative.x * touch_sensitivity)
			cam_pitch.rotate_x(-event.relative.y * touch_sensitivity)
			cam_pitch.rotation.x = clamp(cam_pitch.rotation.x, deg_to_rad(-45), deg_to_rad(65))

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

	var input_vec = Vector3(move_dir_2d.x, 0, move_dir_2d.y)
	var move_direction = (cam_right * input_vec.x + cam_forward * -input_vec.z).normalized()

	var current_speed = sprint_speed if is_sprinting else walk_speed
	var target_anim = "sprint" if is_sprinting else "walk"

	if move_direction != Vector3.ZERO:
		velocity.x = move_direction.x * current_speed * move_dir_2d.length()
		velocity.z = move_direction.z * current_speed * move_dir_2d.length()

		var target_rotation_y = atan2(move_direction.x, move_direction.z)
		model_node.rotation.y = lerp_angle(model_node.rotation.y, target_rotation_y, 0.25)

		if anim_player and anim_player.has_animation(target_anim):
			if current_anim_name != target_anim or not anim_player.is_playing():
				anim_player.play(target_anim)
				current_anim_name = target_anim
			anim_player.speed_scale = 1.0
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

		if anim_player and current_anim_name != "":
			anim_player.speed_scale = 0.0

	move_and_slide()

func _on_fire_button_pressed():
	print("Fire Button Triggered")
