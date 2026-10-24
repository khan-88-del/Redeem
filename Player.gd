extends CharacterBody3D

@export var walk_speed: float = 4.5
@export var sprint_speed: float = 10.5
@export var gravity: float = 20.0
@export var touch_sensitivity: float = 0.006

# Model & Camera Nodes
@onready var model_node: Node3D = $ModelNode
@onready var cam_yaw: Node3D = $CamYaw
@onready var cam_pitch: Node3D = $CamYaw/CamPitch
@onready var camera: Camera3D = $CamYaw/CamPitch/Camera3D

# UI Nodes
@onready var joystick_area: Control = $CanvasLayer/JoystickArea
@onready var joystick_knob: ColorRect = $CanvasLayer/JoystickArea/Knob

# Animation System
var anim_player: AnimationPlayer = null
var current_anim: String = ""
var is_transitioning: bool = false
var auto_sprint: bool = false
var sprint_btn: Button = null

# Touch State
var joystick_active: bool = false
var joystick_touch_index: int = -1
var joystick_max_radius: float = 70.0
var look_touch_index: int = -1
var move_dir_2d: Vector2 = Vector2.ZERO

func _ready():
	camera.current = true
	camera.near = 0.05
	camera.far = 1000.0
	
	cam_pitch.position = Vector3(0, 1.6, 0)
	camera.position = Vector3(0, 0.4, 3.8)
	
	$CanvasLayer.visible = true
	set_process_input(true)
	
	_create_run_button()
	_setup_character_and_all_animations()

func _create_run_button():
	# Screen par Free Fire style RUN button
	sprint_btn = Button.new()
	sprint_btn.text = "RUN"
	sprint_btn.custom_minimum_size = Vector2(90, 70)
	sprint_btn.position = Vector2(get_viewport().get_visible_rect().size.x - 220, get_viewport().get_visible_rect().size.y - 100)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.12, 0.85)
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	sprint_btn.add_theme_stylebox_override("normal", style)
	
	sprint_btn.pressed.connect(_on_sprint_pressed)
	$CanvasLayer.add_child(sprint_btn)

func _on_sprint_pressed():
	# Auto-run toggle bina joystick ke
	auto_sprint = !auto_sprint
	var style = sprint_btn.get_theme_stylebox("normal") as StyleBoxFlat
	if auto_sprint:
		style.bg_color = Color(0.95, 0.45, 0.05, 0.95) # Glowing Orange
	else:
		style.bg_color = Color(0.12, 0.12, 0.12, 0.85)
		if move_dir_2d == Vector2.ZERO:
			_trigger_stop_transition()

func _setup_character_and_all_animations():
	var char_file = ""
	if ResourceLoader.exists("res://Chart.glb"):
		char_file = "res://Chart.glb"
	elif ResourceLoader.exists("res://chart.glb"):
		char_file = "res://chart.glb"
	else:
		return

	# 1. Spawn character model
	var char_res = load(char_file)
	var char_scene = char_res.instantiate()
	model_node.add_child(char_scene)

	char_scene.scale = Vector3(0.025, 0.025, 0.025)
	char_scene.position = Vector3(0, 0, 0)

	var target_skel = _find_skeleton(char_scene)
	_apply_clean_colors(char_scene)

	# 2. Setup Animation Player
	anim_player = char_scene.find_child("AnimationPlayer", true, false)
	if not anim_player:
		anim_player = AnimationPlayer.new()
		char_scene.add_child(anim_player)

	anim_player.animation_finished.connect(_on_animation_finished)

	var anim_lib = AnimationLibrary.new()

	# 3. Load all animations cleanly
	_register_anim(["res://stop.glb", "res://Stop.glb"], "idle", anim_lib, char_scene, target_skel, true)
	_register_anim(["res://run.glb", "res://Run.glb"], "walk", anim_lib, char_scene, target_skel, true)
	_register_anim(["res://Running.fbx.glb", "res://running.fbx.glb"], "sprint", anim_lib, char_scene, target_skel, true)
	_register_anim(["res://Run To Stop.glb", "res://run to stop.glb", "res://Run_To_Stop.glb"], "run_to_stop", anim_lib, char_scene, target_skel, false)

	if anim_lib.get_animation_list().size() > 0:
		anim_player.add_animation_library("", anim_lib)

	# Shuru hote hi Idle pose play karna taaki haath upar na tangein
	if anim_player.has_animation("idle"):
		_play_anim("idle")
	elif anim_player.has_animation("walk"):
		_play_anim("walk")
		anim_player.speed_scale = 0.0

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
		var src: Animation = ap.get_animation(aplayer_first_anim(ap))
		var remap = _remap_and_strip_root(src, root, skel)
		remap.loop_mode = Animation.LOOP_LINEAR if is_loop else Animation.LOOP_NONE
		lib.add_animation(anim_name, remap)

func aplayer_first_anim(ap: AnimationPlayer) -> String:
	return ap.get_animation_list()[0]

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

		# Root/Hips translation lock taaki player screen se aage na bhaage
		var low = bone_name.to_lower()
		if ("hip" in low or "pelvis" in low or "root" in low) and new_anim.track_get_type(t) == Animation.TYPE_POSITION_3D:
			for k in range(new_anim.track_get_key_count(t)):
				var val = new_anim.track_get_key_value(t, k)
				if val is Vector3:
					new_anim.track_set_key_value(t, k, Vector3(0, val.y, 0))

	return new_anim

# Colours: White Shirt, Matte Black Pants, Blue Shoes
func _apply_clean_colors(node: Node):
	if node is MeshInstance3D:
		node.extra_cull_margin = 16384.0
		node.ignore_occlusion_culling = true
		
		var count = node.get_surface_override_material_count()
		if count == 0 and node.mesh:
			count = node.mesh.get_surface_count()

		for s in range(max(1, count)):
			var mat = StandardMaterial3D.new()
			var n_name = (node.name + "_" + str(s)).to_lower()

			if "shoe" in n_name or "foot" in n_name or "boot" in n_name or s == 3:
				mat.albedo_color = Color("#0088ff") # Bright Blue Shoes
				mat.roughness = 0.3
			elif "leg" in n_name or "pant" in n_name or "bottom" in n_name or s == 2:
				mat.albedo_color = Color("#151515") # Jet Black Pants
				mat.roughness = 0.8
			elif "hair" in n_name or "head" in n_name:
				mat.albedo_color = Color("#222222") # Hair
				mat.roughness = 0.8
			else:
				mat.albedo_color = Color("#f0f0f0") # Pure White Hoodie / Body
				mat.roughness = 0.5

			mat.cull_mode = BaseMaterial3D.CULL_DISABLED
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
	if anim_player and anim_player.has_animation("run_to_stop"):
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
				auto_sprint = false # Manual control lene par auto-sprint off
				_update_sprint_btn_style()
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
			cam_pitch.rotation.x = clamp(cam_pitch.rotation.x, deg_to_rad(-45), deg_to_rad(65))

func _update_sprint_btn_style():
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

	# RUN button active: camera jidhar ghoomega, player usi taraf daudega
	if auto_sprint:
		move_direction = cam_forward
		current_speed = sprint_speed
		if not is_transitioning:
			_play_anim("sprint", 1.0)
	elif move_dir_2d != Vector2.ZERO:
		var input_vec = Vector3(move_dir_2d.x, 0, move_dir_2d.y)
		move_direction = (cam_right * input_vec.x + cam_forward * -input_vec.z).normalized()
		current_speed = walk_speed
		if not is_transitioning:
			_play_anim("walk", 1.0)
	else:
		if not is_transitioning and current_anim != "idle":
			_play_anim("idle", 1.0)

	if move_direction != Vector3.ZERO:
		is_transitioning = false
		velocity.x = move_direction.x * current_speed
		velocity.z = move_direction.z * current_speed

		var target_rot = atan2(move_direction.x, move_direction.z)
		model_node.rotation.y = lerp_angle(model_node.rotation.y, target_rot, 0.25)
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)

	move_and_slide()

func _on_fire_button_pressed():
	print("Fire Button Triggered")
