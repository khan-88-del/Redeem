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

# Animation & Skeleton Controllers
var anim_player: AnimationPlayer = null
var skeleton: Skeleton3D = null
var default_run_anim_name: String = ""

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
	_load_azri_character()

func _load_azri_character():
	if ResourceLoader.exists("res://azrirun.glb"):
		var model_res = load("res://azrirun.glb")
		if model_res:
			var model_scene = model_res.instantiate()
			model_node.add_child(model_scene)
			
			# मॉडल का सही साइज़ (100 गुना छोटा) सेट करना
			model_scene.scale = Vector3(0.01, 0.01, 0.01)
			model_scene.position = Vector3(0, 0, 0)

			skeleton = model_scene.find_child("Skeleton3D", true, false)
			anim_player = model_scene.find_child("AnimationPlayer", true, false)
			
			if anim_player:
				var anim_list = anim_player.get_animation_list()
				if anim_list.size() > 0:
					default_run_anim_name = anim_list[0]
					var anim = anim_player.get_animation(default_run_anim_name)
					if anim:
						anim.loop_mode = Animation.LOOP_LINEAR
			
			# गेम स्टार्ट होते ही कैरेक्टर को सीधा खड़ा करना
			_set_idle_pose()

func _set_idle_pose():
	if anim_player:
		anim_player.stop()
	if skeleton:
		# हड्डियों को दौड़ने की स्थिति से हटाकर नॉर्मल सीधी स्थिति में लाना
		for i in range(skeleton.get_bone_count()):
			skeleton.set_bone_pose_position(i, skeleton.get_bone_rest(i).origin)
			skeleton.set_bone_pose_rotation(i, skeleton.get_bone_rest(i).basis.get_rotation_quaternion())
			skeleton.set_bone_pose_scale(i, skeleton.get_bone_rest(i).basis.get_scale())

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
				_set_idle_pose()
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

		# मुँह चलने की दिशा में सीधा रखना
		var target_rotation_y = atan2(move_direction.x, move_direction.z)
		model_node.rotation.y = lerp_angle(model_node.rotation.y, target_rotation_y, 0.25)

		# रनिंग एनिमेशन शुरू करना
		if anim_player and default_run_anim_name != "":
			if not anim_player.is_playing() or anim_player.current_animation != default_run_anim_name:
				anim_player.play(default_run_anim_name)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

		# रुकने पर सीधा खड़ा करना
		if anim_player and anim_player.is_playing():
			_set_idle_pose()

	move_and_slide()

func _on_fire_button_pressed():
	print("Fire Button Triggered!")
