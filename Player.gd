extends CharacterBody3D

@export var speed: float = 7.0
@export var gravity: float = 20.0
@export var mouse_sensitivity: float = 0.005

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var sync_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

# Touch & Joystick State
var joystick_active: bool = false
var joystick_touch_index: int = -1
var joystick_center: Vector2 = Vector2.ZERO
var joystick_current_pos: Vector2 = Vector2.ZERO
var joystick_max_radius: float = 120.0

var look_touch_index: int = -1
var move_dir_2d: Vector2 = Vector2.ZERO

func _ready():
	# Sirf local player ke liye camera aur control active rakhein
	var is_local_player = (name == str(multiplayer.get_unique_id())) or not multiplayer.has_multiplayer_peer()
	camera.current = is_local_player
	$CanvasLayer.visible = is_local_player
	set_process_input(is_local_player)

func _input(event: InputEvent):
	if not camera.current:
		return

	# Touch Down
	if event is InputEventScreenTouch:
		if event.pressed:
			var viewport_width = get_viewport().get_visible_rect().size.x
			# Left screen half: Joystick
			if event.position.x < viewport_width / 2.0 and not joystick_active:
				joystick_active = true
				joystick_touch_index = event.index
				joystick_center = event.position
				joystick_current_pos = event.position
				$CanvasLayer/JoystickBase.visible = true
				$CanvasLayer/JoystickBase.position = joystick_center
				$CanvasLayer/JoystickBase/Knob.position = Vector2.ZERO
			# Right screen half: Look / Aim swipe
			elif event.position.x >= viewport_width / 2.0 and look_touch_index == -1:
				# Check if fire button not pressed
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
			joystick_current_pos = joystick_center + offset
			$CanvasLayer/JoystickBase/Knob.position = offset
			# Normalize for movement (-1 to 1)
			move_dir_2d = offset / joystick_max_radius

		elif event.index == look_touch_index:
			# Smooth Camera Rotation
			rotate_y(-event.relative.x * mouse_sensitivity)
			camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
			# Vertical clamp taaki camera ulta na ghume
			camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if camera.current:
		# Calculate 3D movement relative to camera direction
		var direction = Vector3.ZERO
		var forward = -transform.basis.z
		var right = transform.basis.x

		# Joystick input to 3D world space
		var input_vec = Vector3(move_dir_2d.x, 0, move_dir_2d.y)
		direction = (right * input_vec.x + forward * -input_vec.z).normalized()

		if direction != Vector3.ZERO:
			velocity.x = direction.x * speed * move_dir_2d.length()
			velocity.z = direction.z * speed * move_dir_2d.length()
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _on_fire_button_pressed():
	# Gun shoot simulation / animation call
	print("Player Fired Weapon!")
