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
var _view_tween: Tween

func _ready() -> void:
	_update_position()

func _process(_delta: float) -> void:
	if target:
		_update_position()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_is_rotating = event.pressed
			if _is_rotating and _view_tween and _view_tween.is_valid():
				_view_tween.kill()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			distance = clampf(distance - zoom_speed, min_distance, max_distance)
			_update_position()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			distance = clampf(distance + zoom_speed, min_distance, max_distance)
			_update_position()

	elif event is InputEventMouseMotion and _is_rotating:
		_yaw -= event.relative.x * rotate_speed
		_pitch = clampf(_pitch - event.relative.y * rotate_speed, -1.50, 1.50)
		_update_position()

	elif event is InputEventKey and event.pressed and not event.is_echo():
		var focus_owner = get_viewport().gui_get_focus_owner()
		if focus_owner is LineEdit or focus_owner is TextEdit:
			return
		if event.keycode == KEY_KP_1 or event.keycode == KEY_1:
			set_preset_view("lateral")
		elif event.keycode == KEY_KP_7 or event.keycode == KEY_2:
			set_preset_view("topo")
		elif event.keycode == KEY_KP_3 or event.keycode == KEY_3:
			set_preset_view("frontal")
		elif event.keycode == KEY_KP_5 or event.keycode == KEY_4:
			set_preset_view("perspectiva")

## Ajusta a câmera para um ângulo de visualização pré-definido (Lateral/Perfil, Topo/Vertical, Frontal, Perspectiva)
func set_preset_view(view_name: String, smooth: bool = true) -> void:
	var target_yaw: float = _yaw
	var target_pitch: float = _pitch

	match view_name.to_lower():
		"side", "lateral", "perfil":
			target_yaw = -PI * 0.5
			target_pitch = 0.0
		"top", "topo", "vertical", "superior":
			target_yaw = 0.0
			target_pitch = 1.48
		"front", "frontal":
			target_yaw = 0.0
			target_pitch = 0.0
		"back", "traseira":
			target_yaw = PI
			target_pitch = 0.0
		"perspective", "perspectiva", "free", "isometric", "livre":
			target_yaw = 0.785
			target_pitch = 0.35

	if _view_tween and _view_tween.is_valid():
		_view_tween.kill()

	if smooth and is_inside_tree():
		_view_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_view_tween.tween_property(self, "_yaw", target_yaw, 0.28)
		_view_tween.tween_property(self, "_pitch", target_pitch, 0.28)
	else:
		_yaw = target_yaw
		_pitch = target_pitch
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
