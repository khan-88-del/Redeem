extends CharacterBody3D

@export var walk_speed: float = 6.0
@export var sprint_speed: float = 11.5
@export var jump_velocity: float = 5.5
@export var gravity: float = 14.0

var is_sprinting: bool = false
var touch_dir: Vector2 = Vector2.ZERO

@onready var camera = $Camera3D
@onready var weapon = $Camera3D/WeaponSlot if has_node("Camera3D/WeaponSlot") else null

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var current_speed = sprint_speed if is_sprinting else walk_speed
	var direction = Vector3.ZERO

	# Touch input & smooth movement
	if touch_dir != Vector2.ZERO:
		var cam_basis = camera.global_transform.basis
		var forward = -cam_basis.z
		forward.y = 0
		forward = forward.normalized()
		var right = cam_basis.x
		right.y = 0
		right = right.normalized()
		direction = (forward * -touch_dir.y + right * touch_dir.x).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	# MP-40 Sway & Run animation smoothing (Glitch avoid karein)
	if weapon:
		var target_z = -0.45 if is_sprinting else -0.35
		var target_rot_x = 0.2 if is_sprinting else 0.0
		weapon.position.z = lerp(weapon.position.z, target_z, 10.0 * delta)
		weapon.rotation.x = lerp(weapon.rotation.x, target_rot_x, 10.0 * delta)

	move_and_slide()

# UI Run Button Trigger
func set_run_state(active: bool):
	is_sprinting = active
