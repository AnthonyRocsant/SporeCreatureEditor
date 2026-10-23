class_name OrbitCamera
extends Camera3D

@export var target: Node3D
@export var distance: float = 4.0
@export var min_distance: float = 1.5
@export var max_distance: float = 12.0
@export var rotate_speed: float = 0.005
@export var zoom_speed: float = 0.5

var _yaw: float = 0.0
var _pitch: float = 0.25
var _is_rotating: bool = false

func _ready() -> void:
	_update_position()

func _process(_delta: float) -> void:
	if target:
		_update_position()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_is_rotating = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			distance = clampf(distance - zoom_speed, min_distance, max_distance)
			_update_position()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			distance = clampf(distance + zoom_speed, min_distance, max_distance)
			_update_position()

	elif event is InputEventMouseMotion and _is_rotating:
		_yaw -= event.relative.x * rotate_speed
		_pitch = clampf(_pitch - event.relative.y * rotate_speed, -1.45, 1.45)
		_update_position()

func _update_position() -> void:
	if not is_inside_tree():
		return
	var target_pos = target.global_position if (target and target.is_inside_tree()) else Vector3.ZERO
	var offset = Vector3(
		sin(_yaw) * cos(_pitch),
		sin(_pitch),
		cos(_yaw) * cos(_pitch)
	) * distance
	global_position = target_pos + offset

	var up_vec = Vector3.UP
	if absf(cos(_pitch)) < 0.01:
		up_vec = Vector3.FORWARD if _pitch > 0.0 else Vector3.BACK
	look_at(target_pos, up_vec)

## Retorna o vetor "Frente" horizontal da câmera (no plano XZ) para controle WASD
func get_flat_forward() -> Vector3:
	var fwd = -global_transform.basis.z
	fwd.y = 0.0
	if fwd.length_squared() < 0.0001:
		return Vector3.FORWARD
	return fwd.normalized()

## Retorna o vetor "Direita" horizontal da câmera (no plano XZ) para controle WASD
func get_flat_right() -> Vector3:
	var r = global_transform.basis.x
	r.y = 0.0
	if r.length_squared() < 0.0001:
		return Vector3.RIGHT
	return r.normalized()
