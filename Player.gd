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

# Touch Controls State
var joystick_active: bool = false
var joystick_touch_index: int = -1
var joystick_max_radius: float = 70.0
var look_touch_index: int = -1
var move_dir_2d: Vector2 = Vector2.ZERO

func _ready():
	camera.current = true
	$CanvasLayer.visible = true
	set_process_input(true)
	_load_mixamo_character()

func _load_mixamo_character():
	if not ResourceLoader.exists("res://player.glb"):
		print("ERROR: player.glb nahi mili!")
		return

	var model_res = load("res://player.glb")
	if not model_res:
		print("ERROR: player.glb load fail hui!")
		return

	var model_scene = model_res.instantiate()
	model_node.add_child(model_scene)

	# Har mesh ki visibility on karna aur materials verify karna
	var meshes: Array[MeshInstance3D] = []
	_find_meshes(model_scene, meshes)

	if meshes.size() > 0:
		# Model ka real bounding size nikalna
		var aabb: AABB = meshes[0].get_aabb()
		for i in range(1, meshes.size()):
			aabb = aabb.merge(meshes[i].get_aabb())

		var model_height = aabb.size.y
		# Agar height 0 se thodi badi ho to automatically 1.8m (human size) me normalize karna
		if model_height > 0.001:
			var target_scale = 1.8 / model_height
			model_scene.scale = Vector3(target_scale, target_scale, target_scale)
		else:
			model_scene.scale = Vector3(1.0, 1.0, 1.0)

		# Ground level par align karna
		model_scene.position = Vector3(0, -aabb.position.y * model_scene.scale.y, 0)
	else:
		# Agar direct mesh na mile to standard fallback scale
		model_scene.scale = Vector3(1.0, 1.0, 1.0)
		model_scene.position = Vector3(0, 0, 0)

	print("Mixamo Model Load complete! Meshes found: ", meshes.size())

func _find_meshes(node: Node, out_list: Array[MeshInstance3D]):
	if node is MeshInstance3D:
		node.visible = true
		out_list.append(node)
	for child in node.get_children():
		_find_meshes(child, out_list)

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
			elif event.index == look_touch_index:
				look_touch_index = -1

	elif event is InputEventScreenDrag:
		if event.index == joystick_touch_index and joystick_active:
			_update_joystick(event.position)
		elif event.index == look_touch_index:
			cam_yaw.rotate_y(-event.relative.x * touch_sensitivity)
			cam_pitch.rotate_x(-event.relative.y * touch_sensitivity)
			cam_pitch.rotation.x = clamp(cam_pitch.rotation.x, deg_to_rad(-55), deg_to_rad(65))

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
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _on_fire_button_pressed():
	print("Fire Button Triggered!")
