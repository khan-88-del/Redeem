extends CharacterBody3D

@export var speed: float = 7.5
@export var gravity: float = 20.0
@export var touch_sensitivity: float = 0.006

# Model & Limb Nodes
@onready var model: Node3D = $Model
@onready var torso: MeshInstance3D = $Model/Torso
@onready var left_arm: Node3D = $Model/Torso/LeftArmPivot
@onready var right_arm: Node3D = $Model/Torso/RightArmPivot
@onready var left_leg: Node3D = $Model/LeftLegPivot
@onready var right_leg: Node3D = $Model/RightLegPivot

# Free Look 360 Camera Nodes
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

# Animation Timers
var walk_cycle: float = 0.0
var breath_cycle: float = 0.0
var torso_initial_y: float = 1.05

func _ready():
	var is_local_player = (name == str(multiplayer.get_unique_id())) or not multiplayer.has_multiplayer_peer()
	camera.current = is_local_player
	$CanvasLayer.visible = is_local_player
	set_process_input(is_local_player)
	torso_initial_y = torso.position.y

func _input(event: InputEvent):
	if not camera.current:
		return

	# Touch Press
	if event is InputEventScreenTouch:
		if event.pressed:
			# Check if touching Joystick Area (Left Bottom)
			var joy_rect = joystick_area.get_global_rect()
			if joy_rect.has_point(event.position) and not joystick_active:
				joystick_active = true
				joystick_touch_index = event.index
				_update_joystick(event.position)
			# Right Screen Side for 360 Free-Look Camera
			elif event.position.x > get_viewport().get_visible_rect().size.x / 2.0 and look_touch_index == -1:
				if not $CanvasLayer/FireButton.get_global_rect().has_point(event.position):
					look_touch_index = event.index
		else:
			# Touch Release
			if event.index == joystick_touch_index:
				joystick_active = false
				joystick_touch_index = -1
				move_dir_2d = Vector2.ZERO
				joystick_knob.position = joystick_area.size / 2.0 - joystick_knob.size / 2.0
			elif event.index == look_touch_index:
				look_touch_index = -1

	# Touch Drag (Motion)
	elif event is InputEventScreenDrag:
		if event.index == joystick_touch_index and joystick_active:
			_update_joystick(event.position)
		elif event.index == look_touch_index:
			# Full 360 Orbit Camera Rotation
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

	if camera.current:
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

			# Player turns smoothly to face the moving direction
			var target_rotation_y = atan2(-move_direction.x, -move_direction.z)
			model.rotation.y = lerp_angle(model.rotation.y, target_rotation_y, 0.2)
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	_handle_animations(delta)

func _handle_animations(delta: float):
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()

	if horizontal_speed > 0.5:
		# Run Motion
		walk_cycle += delta * horizontal_speed * 2.3
		var leg_angle = sin(walk_cycle) * 0.75
		var arm_angle = sin(walk_cycle) * 0.65

		left_leg.rotation.x = leg_angle
		right_leg.rotation.x = -leg_angle
		left_arm.rotation.x = -arm_angle
		right_arm.rotation.x = arm_angle
		torso.position.y = torso_initial_y
	else:
		# Idle Breathing Motion
		walk_cycle = 0.0
		breath_cycle += delta * 2.5
		var breath_offset = sin(breath_cycle) * 0.012
		torso.position.y = torso_initial_y + breath_offset

		left_leg.rotation.x = lerp(left_leg.rotation.x, 0.0, 0.15)
		right_leg.rotation.x = lerp(right_leg.rotation.x, 0.0, 0.15)
		left_arm.rotation.x = lerp(left_arm.rotation.x, 0.0, 0.15)
		right_arm.rotation.x = lerp(right_arm.rotation.x, 0.0, 0.15)

func _on_fire_button_pressed():
	print("Fire Button Triggered!")
