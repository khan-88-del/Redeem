extends CharacterBody3D

@export var speed: float = 7.0
@export var gravity: float = 20.0
@export var mouse_sensitivity: float = 0.005

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

# Body Pivots
@onready var left_arm: Node3D = $Model/LeftArmPivot
@onready var right_arm: Node3D = $Model/RightArmPivot
@onready var left_leg: Node3D = $Model/LeftLegPivot
@onready var right_leg: Node3D = $Model/RightLegPivot

# Touch Controls
var joystick_active: bool = false
var joystick_touch_index: int = -1
var joystick_center: Vector2 = Vector2.ZERO
var joystick_max_radius: float = 120.0
var look_touch_index: int = -1
var move_dir_2d: Vector2 = Vector2.ZERO

# Animation Timer
var walk_cycle: float = 0.0

func _ready():
	var is_local_player = (name == str(multiplayer.get_unique_id())) or not multiplayer.has_multiplayer_peer()
	camera.current = is_local_player
	$CanvasLayer.visible = is_local_player
	set_process_input(is_local_player)

func _input(event: InputEvent):
	if not camera.current:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			var viewport_width = get_viewport().get_visible_rect().size.x
			if event.position.x < viewport_width / 2.0 and not joystick_active:
				joystick_active = true
				joystick_touch_index = event.index
				joystick_center = event.position
				$CanvasLayer/JoystickBase.visible = true
				$CanvasLayer/JoystickBase.position = joystick_center
				$CanvasLayer/JoystickBase/Knob.position = Vector2.ZERO
			elif event.position.x >= viewport_width / 2.0 and look_touch_index == -1:
				if not $CanvasLayer/FireButton.get_global_rect().has_point(event.position):
					look_touch_index = event.index
		else:
			if event.index == joystick_touch_index:
				joystick_active = false
				joystick_touch_index = -1
				move_dir_2d = Vector2.ZERO
				$CanvasLayer/JoystickBase.visible = false
			elif event.index == look_touch_index:
				look_touch_index = -1

	elif event is InputEventScreenDrag:
		if event.index == joystick_touch_index and joystick_active:
			var offset = event.position - joystick_center
			if offset.length() > joystick_max_radius:
				offset = offset.normalized() * joystick_max_radius
			$CanvasLayer/JoystickBase/Knob.position = offset
			move_dir_2d = offset / joystick_max_radius

		elif event.index == look_touch_index:
			rotate_y(-event.relative.x * mouse_sensitivity)
			camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
			camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if camera.current:
		var forward = -transform.basis.z
		var right = transform.basis.x
		var input_vec = Vector3(move_dir_2d.x, 0, move_dir_2d.y)
		var direction = (right * input_vec.x + forward * -input_vec.z).normalized()

		if direction != Vector3.ZERO:
			velocity.x = direction.x * speed * move_dir_2d.length()
			velocity.z = direction.z * speed * move_dir_2d.length()
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	_animate_character(delta)

func _animate_character(delta: float):
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()

	if horizontal_speed > 0.5:
		walk_cycle += delta * horizontal_speed * 2.2
		var leg_angle = sin(walk_cycle) * 0.75
		var arm_angle = sin(walk_cycle) * 0.65

		# Legs swing opposite to each other
		left_leg.rotation.x = leg_angle
		right_leg.rotation.x = -leg_angle

		# Arms swing opposite to legs (Natural running movement)
		left_arm.rotation.x = -arm_angle
		right_arm.rotation.x = arm_angle
	else:
		# Idle pose me limbs smooth wapas neutral par aayenge
		walk_cycle = 0.0
		left_leg.rotation.x = lerp(left_leg.rotation.x, 0.0, 0.15)
		right_leg.rotation.x = lerp(right_leg.rotation.x, 0.0, 0.15)
		left_arm.rotation.x = lerp(left_arm.rotation.x, 0.0, 0.15)
		right_arm.rotation.x = lerp(right_arm.rotation.x, 0.0, 0.15)

func _on_fire_button_pressed():
	print("Player Shot!")
