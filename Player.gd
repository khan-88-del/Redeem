extends CharacterBody3D

const SPEED = 7.0
const SPRINT_SPEED = 11.0
const GRAVITY = 9.8

@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D
@onready var raycast = $CameraPivot/Camera3D/RayCast3D

@export var health: int = 100

var look_rotation = Vector2.ZERO
var is_sprinting = false

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority():
		camera.current = false
		$UI.visible = false
	else:
		camera.current = true
		$UI.visible = true

func _input(event):
	if not is_multiplayer_authority(): return
	
	# Mobile Right-Screen Touch Swipe for Camera Rotation
	if event is InputEventScreenDrag:
		if event.position.x > get_viewport().size.x / 2.0:
			rotate_y(-event.relative.x * 0.005)
			camera_pivot.rotate_x(-event.relative.y * 0.005)
			camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-45), deg_to_rad(55))

func _physics_process(delta):
	if not is_multiplayer_authority(): return

	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	var input_dir = Vector2.ZERO
	# On-Screen Touch Joystick or Keyboard Fallback
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	input_dir.y = Input.get_axis("ui_up", "ui_down")

	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var current_speed = SPRINT_SPEED if is_sprinting else SPEED

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

# Shoot Gun Function (Linked to UI Fire Button)
func fire_weapon():
	if not is_multiplayer_authority(): return
	
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if target and target.has_method("take_damage"):
			target.take_damage.rpc(25)

@rpc("any_peer", "call_local")
func take_damage(damage: int):
	health -= damage
	if health <= 0:
		queue_free()
