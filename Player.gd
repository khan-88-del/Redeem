extends CharacterBody3D

@export var speed: float = 7.0
@export var gravity: float = 20.0
@export var touch_sensitivity: float = 0.005

# Model & Limb Nodes
@onready var model: Node3D = $Model
@onready var torso: MeshInstance3D = $Model/Torso
@onready var left_arm: Node3D = $Model/Torso/LeftArmPivot
@onready var right_arm: Node3D = $Model/Torso/RightArmPivot
@onready var left_leg: Node3D = $Model/LeftLegPivot
@onready var right_leg: Node3D = $Model/RightLegPivot

# Free Look 360 Camera Nodes
@onready var cam_yaw: Node3D = $CamYaw
@onready var cam_pitch: Node3D = $CamYaw/Pitch
@onready var camera: Camera3D = $CamYaw/Pitch/Camera3D

# Touch Controls State
var joystick_active: bool = false
var joystick_touch_index: int = -1
var joystick_center: Vector2 = Vector2.ZERO
var joystick_max_radius: float = 120.0
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

	# Touch Start
	if event is InputEventScreenTouch:
		if event.pressed:
			var viewport_width = get_viewport().get_visible_rect().size.x
			# Left Screen: Joystick Touch
			if event.position.x < viewport_width / 2.0 and not joystick_active:
				joystick_active = true
				joystick_touch_index = event.index
				joystick_center = event.position
				$CanvasLayer/JoystickBase.visible = true
				$CanvasLayer/JoystickBase.position = joystick_center
				$CanvasLayer/JoystickBase/Knob.position = Vector2.ZERO
			# Right Screen: 360 Orbit Camera Swipe
			elif event.position.x >= viewport_width / 2.0 and look_touch_index == -1:
				if not $CanvasLayer/FireButton.get_global_rect().has_point(event.position):
					look_touch_index = event.index
		else:
			# Touch Release
			if event.index == joystick_touch_index:
				joystick_active = false
				joystick_touch_index = -1
				move_dir_2d = Vector2.ZERO
				$CanvasLayer/JoystickBase.visible = false
			elif event.index == look_touch_index:
				look_touch_index = -1

	# Touch Drag (Motion)
	elif event is InputEventScreenDrag:
		if event.index == joystick_touch_index and joystick_active:
			var offset = event.position - joystick_center
			if offset.length() > joystick_max_radius:
				offset = offset.normalized() * joystick_max_radius
			$CanvasLayer/JoystickBase/Knob.position = offset
			move_dir_2d = offset / joystick_max_radius

		elif event.index == look_touch_index:
			# Pure 360 Free-Look: CamYaw horizontal 360 ghoomega, player nahi ghoomega
			cam_yaw.rotate_y(-event.relative.x * touch_sensitivity)
			cam_pitch.rotate_x(-event.relative.y * touch_sensitivity)
			cam_pitch.rotation.x = clamp(cam_pitch.rotation.x, deg_to_rad(-50), deg_to_rad(65))

func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if camera.current:
		# Joystick input ko Camera ke view angle ke relative calculate karna
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

			# Player ka model movement ki direction me face karega
			var target_rotation_y = atan2(-move_direction.x, -move_direction.z)
			model.rotation.y = lerp_angle(model.rotation.y, target_rotation_y, 0.18)
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	_handle_animations(delta)

func _handle_animations(delta: float):
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()

	if horizontal_speed > 0.5:
		# Running Animation: Arms & Legs swinging
		walk_cycle += delta * horizontal_speed * 2.2
		var leg_angle = sin(walk_cycle) * 0.75
		var arm_angle = sin(walk_cycle) * 0.65

		left_leg.rotation.x = leg_angle
		right_leg.rotation.x = -leg_angle
		left_arm.rotation.x = -arm_angle
		right_arm.rotation.x = arm_angle

		# Run karte waqt normal position
		torso.position.y = torso_initial_y
	else:
		# Idle / Breathing Animation: Khade rahne par saans lena
		walk_cycle = 0.0
		breath_cycle += delta * 2.5
		
		# Chest up-down & shoulders subtle expansion (saans lene ka effect)
		var breath_offset = sin(breath_cycle) * 0.015
		torso.position.y = torso_initial_y + breath_offset
		torso.scale = Vector3(1.0 + breath_offset * 0.5, 1.0 + breath_offset, 1.0 + breath_offset * 0.5)

		# Limbs smoothly neutral pose me aana
		left_leg.rotation.x = lerp(left_leg.rotation.x, 0.0, 0.15)
		right_leg.rotation.x = lerp(right_leg.rotation.x, 0.0, 0.15)
		left_arm.rotation.x = lerp(left_arm.rotation.x, 0.0, 0.15)
		right_arm.rotation.x = lerp(right_arm.rotation.x, 0.0, 0.15)

func _on_fire_button_pressed():
	print("Player Shot Fired!")
