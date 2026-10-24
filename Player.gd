extends CharacterBody3D

@export var speed: float = 7.5
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
	
	cam_pitch.position = Vector3(0, 1.4, 0)
	camera.position = Vector3(0, 0.5, 3.5)
	
	$CanvasLayer.visible = true
	set_process_input(true)
	_setup_player_and_animations()

func _setup_player_and_animations():
	var model_path = ""
	if ResourceLoader.exists("res://Chart.glb"):
		model_path = "res://Chart.glb"
	elif ResourceLoader.exists("res://chart.glb"):
		model_path = "res://chart.glb"
	else:
		return

	# 1. Base Model Instantiate
	var model_res = load(model_path)
	var model_scene = model_res.instantiate()
	model_node.add_child(model_scene)

	model_scene.scale = Vector3(0.015, 0.015, 0.015)
	model_scene.position = Vector3(0, 0, 0)

	var target_skel = _find_skeleton(model_scene)
	_fix_mesh_and_materials(model_scene)

	# 2. Base Model me AnimationPlayer confirm karna
	anim_player = model_scene.find_child("AnimationPlayer", true, false)
	if not anim_player:
		anim_player = AnimationPlayer.new()
		model_scene.add_child(anim_player)

	# 3. run.glb se animation import karke skeleton se connect karna
	var run_path = ""
	if ResourceLoader.exists("res://run.glb"):
		run_path = "res://run.glb"
	elif ResourceLoader.exists("res://Run.glb"):
		run_path = "res://Run.glb"

	if run_path != "" and target_skel:
		var run_res = load(run_path)
		if run_res:
			var run_scene = run_res.instantiate()
			var run_anim_player = run_scene.find_child("AnimationPlayer", true, false)
			if run_anim_player:
				var anim_names = run_anim_player.get_animation_list()
				if anim_names.size() > 0:
					var src_anim: Animation = run_anim_player.get_animation(anim_names[0])
					var fixed_anim = _remap_tracks(src_anim, model_scene, target_skel)
					fixed_anim.loop_mode = Animation.LOOP_LINEAR
					
					var anim_lib = AnimationLibrary.new()
					anim_lib.add_animation("run", fixed_anim)
					anim_player.add_animation_library("", anim_lib)
					current_anim_name = "run"
					anim_player.play("run")
					anim_player.speed_scale = 0.0

func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node
	for child in node.get_children():
		var res = _find_skeleton(child)
		if res:
			return res
	return null

func _remap_tracks(source_anim: Animation, model_root: Node, skel: Skeleton3D) -> Animation:
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
		
	return new_anim

func _fix_mesh_and_materials(node: Node):
	if node is MeshInstance3D:
		node.extra_cull_margin = 16384.0
		node.ignore_occlusion_culling = true
		node.set_surface_override_material(0, null)
	for child in node.get_children():
		_fix_mesh_and_materials(child)

func _input(event: InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed:
			var joy_rect = joystick_area.get_global_rect()
			if joy_rect.has_point(event.position) and not joystick_active:
				joystick_active = true
				joystick_touch_index = event.index
				_update_joystick(event.position)
			elif event.position.x > get_viewport().get_visible_rect().size.x / 2.0 and look_touch_index == -1:
				if not $CanvasLayer/FireButton.get_global_rect().has_point(event.position):
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

	if move_direction != Vector3.ZERO:
		velocity.x = move_direction.x * speed * move_dir_2d.length()
		velocity.z = move_direction.z * speed * move_dir_2d.length()

		var target_rotation_y = atan2(move_direction.x, move_direction.z)
		model_node.rotation.y = lerp_angle(model_node.rotation.y, target_rotation_y, 0.25)

		if anim_player and current_anim_name != "":
			anim_player.speed_scale = 1.0
			if not anim_player.is_playing():
				anim_player.play(current_anim_name)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

		if anim_player and current_anim_name != "":
			anim_player.speed_scale = 0.0

	move_and_slide()

func _on_fire_button_pressed():
	print("Fire Button Triggered")
