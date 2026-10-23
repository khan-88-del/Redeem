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

# Animation Controller
var anim_player: AnimationPlayer = null

# Touch Controls State
var joystick_active: bool = false
var joystick_touch_index: int = -1
var joystick_max_radius: float = 70.0
var look_touch_index: int = -1
var move_dir_2d: Vector2 = Vector2.ZERO

func _ready():
	var is_local_player = (name == str(multiplayer.get_unique_id())) or not multiplayer.has_multiplayer_peer()
	camera.current = is_local_player
	$CanvasLayer.visible = is_local_player
	set_process_input(is_local_player)

	_load_character_model()

func _load_character_model():
	# 1. Naya player.glb 3D Model load karna
	if ResourceLoader.exists("res://player.glb"):
		var model_res = load("res://player.glb")
		if model_res:
			var model_scene = model_res.instantiate()
			model_node.add_child(model_scene)
			
			model_scene.scale = Vector3(1.0, 1.0, 1.0)
			model_scene.position = Vector3(0, 0, 0)
			
			anim_player = model_scene.find_child("AnimationPlayer", true, false)

	# 2. Jogging.glb se running animation track import karna
	if ResourceLoader.exists("res://Jogging.glb") and anim_player != null:
		var jog_res = load("res://Jogging.glb")
		if jog_res:
			var jog_scene = jog_res.instantiate()
			var jog_anim_player: AnimationPlayer = jog_scene.find_child("AnimationPlayer", true, false)
			if jog_anim_player:
				for anim_name in jog_anim_player.get_animation_list():
					var anim = jog_anim_player.get_animation(anim_name)
					anim.loop_mode = Animation.LOOP_LINEAR
					if not anim_player.has_animation("run"):
						anim_player.get_animation_library("").add_animation("run", anim)
			jog_scene.queue_free()

func _input(event: InputEvent):
	if not camera.current:
		return

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
			# 360 Free-Look Camera
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

			# Model movement ki direction me ghumega
			var target_rotation_y = atan2(-move_direction.x, -move_direction.z)
			model_node.rotation.y = lerp_angle(model_node.rotation.y, target_rotation_y, 0.2)

			# Run animation play karna
			if anim_player and anim_player.has_animation("run") and anim_player.current_animation != "run":
				anim_player.play("run")
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)

			# Khada hone par animation stop
			if anim_player and anim_player.current_animation == "run":
				anim_player.stop()

	move_and_slide()

func _on_fire_button_pressed():
	print("Fire Button Triggered!")
