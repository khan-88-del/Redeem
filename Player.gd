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

# Animation & Movement System
var anim_player: AnimationPlayer = null
var skeleton: Skeleton3D = null
var step_time: float = 0.0

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
	
	# Camera ko standard third-person angle par set karna
	cam_pitch.position = Vector3(0, 1.4, 0)
	camera.position = Vector3(0, 0.5, 3.5)
	
	$CanvasLayer.visible = true
	set_process_input(true)
	_load_player_model()

func _load_player_model():
	var model_path = ""
	if ResourceLoader.exists("res://Chart.glb"):
		model_path = "res://Chart.glb"
	elif ResourceLoader.exists("res://chart.glb"):
		model_path = "res://chart.glb"
	else:
		return

	var model_res = load(model_path)
	var model_scene = model_res.instantiate()
	model_node.add_child(model_scene)

	# Zameen ke andar dhansne se rokne ke liye simple normal scale
	model_scene.scale = Vector3(0.015, 0.015, 0.015)
	model_scene.position = Vector3(0, 0, 0)

	# Skeleton dhoondh kar pose reset karna
	skeleton = _find_skeleton(model_scene)
	if skeleton:
		skeleton.reset_bone_poses()

	# Mesh materials ko preserve rakhna taaki color/texture na ude
	_fix_mesh_and_materials(model_scene)

	# Animation Player setup
	anim_player = model_scene.find_child("AnimationPlayer", true, false)
	if anim_player:
		var anims = anim_player.get_animation_list()
		if anims.size() > 0:
			# Agar animation file ke sath aaya ho to use chalana
			anim_player.play(anims[0])
			anim_player.speed_scale = 0.0

func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node
	for child in node.get_children():
		var res = _find_skeleton(child)
		if res:
			return res
	return null

func _fix_mesh_and_materials(node: Node):
	if node is MeshInstance3D:
		node.extra_cull_margin = 16384.0
		node.ignore_occlusion_culling = true
		# Purane override ko clean karna taaki model ke original textures load hon
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
				if anim_player and anim_player.is_playing():
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
		step_time += delta * 12.0
		velocity.x = move_direction.x * speed * move_dir_2d.length()
		velocity.z = move_direction.z * speed * move_dir_2d.length()

		var target_rotation_y = atan2(move_direction.x, move_direction.z)
		model_node.rotation.y = lerp_angle(model_node.rotation.y, target_rotation_y, 0.25)

		if anim_player and anim_player.get_animation_list().size() > 0:
			anim_player.speed_scale = 1.0
			if not anim_player.is_playing():
				anim_player.play(anim_player.get_animation_list()[0])
		else:
			# Procedural run sway
			model_node.position.y = abs(sin(step_time)) * 0.06
			model_node.rotation.z = sin(step_time * 0.5) * 0.04
	else:
		step_time += delta * 2.0
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

		if anim_player and anim_player.is_playing():
			anim_player.speed_scale = 0.0

		model_node.position.y = lerp(model_node.position.y, 0.0, 0.2)
		model_node.rotation.z = lerp(model_node.rotation.z, 0.0, 0.2)

	move_and_slide()

func _on_fire_button_pressed():
	print("Fire Button")
