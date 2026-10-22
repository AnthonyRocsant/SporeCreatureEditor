class_name ProceduralGait
extends Node

## Controlador Interativo de Locomoção Terrestre (WASD) e Voo (Segurar ESPAÇO + WASD) no Modo Sandbox.
## - Apoia automaticamente os pés da criatura no solo (y = 0.0) ao iniciar o Test Drive (sem flutuar!)
## - Só anima a passada das pernas quando o jogador move a criatura com WASD
## - Permite voar segurando ESPAÇO e controlar a direção no ar com WASD, batendo as asas proceduralmente
## - Respeita a Trava de Validação de Locomoção Terrestre (Pilar 2.2) para caminhada no solo

@export var creature_root: Node3D
@export var creature_data: CreatureData
@export var camera: OrbitCamera

@export var step_frequency: float = 5.5
@export var step_swing_angle: float = 0.52
@export var step_lift: float = 0.12
@export var is_moving: bool = false ## Em Sandbox, indica que o modo interativo Sandbox está ativo

# Transforms originais no Editor para restaurar ao sair do Sandbox
var _editor_root_transform: Transform3D = Transform3D(Basis.IDENTITY, Vector3(0.0, 1.0, 0.0))
var _leg_initial_transforms: Dictionary = {}  # { Node3D: Transform3D }
var _wing_initial_transforms: Dictionary = {} # { Node3D: Transform3D }
var _tail_initial_transforms: Dictionary = {} # { Node3D: Transform3D }

# Estado físico de Sandbox
var _ground_root_y: float = 0.76
var _vertical_velocity: float = 0.0
var _current_yaw: float = 0.0
var _walk_phase: float = 0.0
var _flight_phase: float = 0.0
var _idle_phase: float = 0.0
var _skill_anim_timer: float = 0.0
var _skill_anim_offset: Vector3 = Vector3.ZERO

const GRAVITY: float = 14.0
const GLIDE_GRAVITY: float = 5.5
const MAX_FLIGHT_ALTITUDE: float = 14.0
const ARENA_LIMIT: float = 28.0

func _ready() -> void:
	if creature_root:
		_editor_root_transform = creature_root.transform

## Chamado ao entrar no Modo Sandbox (Test Drive)
func register_limbs() -> void:
	_leg_initial_transforms.clear()
	_wing_initial_transforms.clear()
	_tail_initial_transforms.clear()

	if not creature_root or not creature_data:
		return

	_editor_root_transform = creature_root.transform
	_current_yaw = 0.0
	_vertical_velocity = 0.0
	_walk_phase = 0.0
	_flight_phase = 0.0

	var lowest_local_foot_y: float = -0.42
	var found_leg: bool = false

	for part_info in creature_data.attached_parts:
		var node = part_info.get("node") as Node3D
		if not is_instance_valid(node):
			continue
		var part_type = str(part_info.get("type", "")).to_lower()
		var part_cat = str(part_info.get("category", part_type)).to_lower()
		var scale_f = float(part_info.get("scale_factor", 1.0))

		if part_type == "leg" or part_cat == "leg":
			_leg_initial_transforms[node] = node.transform
			# A sola do pé em LegClaw fica em -0.76 * scale abaixo do quadril da perna
			var foot_local_y = node.position.y - (0.76 * scale_f)
			if not found_leg or foot_local_y < lowest_local_foot_y:
				lowest_local_foot_y = foot_local_y
				found_leg = true
		elif part_type == "wing" or part_cat == "wing":
			_wing_initial_transforms[node] = node.transform
		elif part_type == "tail" or part_cat == "tail":
			_tail_initial_transforms[node] = node.transform

	# Calcula a altura exata do CreatureRoot para que a sola dos pés encoste exatamente no chão (y = 0.0)
	_ground_root_y = maxf(0.35, -lowest_local_foot_y)

	# Posiciona a criatura pousada no chão imediatamente ao iniciar o Test Drive!
	creature_root.position = Vector3(0.0, _ground_root_y, 0.0)
	creature_root.rotation = Vector3.ZERO

func _process(delta: float) -> void:
	if not is_moving or not creature_root:
		return

	_idle_phase += delta * 2.5

	# 1. Leitura de Input do Jogador: WASD + Espaço para Voo
	var input_vec = Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_vec.y += 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_vec.y -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_vec.x += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_vec.x -= 1.0

	if input_vec.length_squared() > 1.0:
		input_vec = input_vec.normalized()

	var holding_space = Input.is_key_pressed(KEY_SPACE)
	var has_wings = not _wing_initial_transforms.is_empty()

	# Direção de movimento no mundo relativa à câmera orbital
	var move_dir = Vector3.ZERO
	if camera:
		var fwd = camera.get_flat_forward()
		var right = camera.get_flat_right()
		move_dir = (fwd * input_vec.y + right * input_vec.x)
	else:
		move_dir = Vector3(-input_vec.x, 0.0, input_vec.y)

	if move_dir.length_squared() > 0.001:
		move_dir = move_dir.normalized()

	# 2. Física Vertical: Voo (Segurar ESPAÇO SOMENTE SE TIVER ASAS) vs Gravidade e Pouso no Solo
	var current_y = creature_root.position.y
	if holding_space and has_wings:
		var climb_rate = 6.2 + (creature_data.agility * 0.12 if creature_data else 0.0)
		_vertical_velocity = lerpf(_vertical_velocity, climb_rate, delta * 6.0)
	elif holding_space and not has_wings:
		# Sem asas: no máximo um pulinho inicial se estiver no chão, mas sem sustentação de voo
		if current_y <= _ground_root_y + 0.04 and _vertical_velocity <= 0.0:
			_vertical_velocity = 4.0
		_vertical_velocity -= GRAVITY * delta
	else:
		var grav = GLIDE_GRAVITY if (has_wings and current_y > _ground_root_y + 0.1) else GRAVITY
		_vertical_velocity -= grav * delta

	current_y += _vertical_velocity * delta
	if current_y <= _ground_root_y:
		current_y = _ground_root_y
		if _vertical_velocity < 0.0:
			_vertical_velocity = 0.0
	elif current_y > MAX_FLIGHT_ALTITUDE:
		current_y = MAX_FLIGHT_ALTITUDE
		if _vertical_velocity > 0.0:
			_vertical_velocity = 0.0

	var is_airborne = (current_y > _ground_root_y + 0.08)

	# 3. Movimentação Horizontal (WASD no Solo ou no Ar)
	var can_move_on_ground = (creature_data == null) or creature_data.locomotion_valid
	var can_translate = is_airborne or can_move_on_ground
	var is_walking_now = false

	if move_dir.length_squared() > 0.001 and can_translate:
		var move_speed: float = 5.0
		if creature_data:
			if is_airborne:
				move_speed = maxf(6.2, creature_data.speed * 0.65 + creature_data.agility * 0.12 + 3.5)
			else:
				move_speed = maxf(4.2, creature_data.speed * 0.55 + 2.0)

		creature_root.position.x = clampf(creature_root.position.x + move_dir.x * move_speed * delta, -ARENA_LIMIT, ARENA_LIMIT)
		creature_root.position.z = clampf(creature_root.position.z + move_dir.z * move_speed * delta, -ARENA_LIMIT, ARENA_LIMIT)

		# Rotaciona suavemente a criatura para olhar na direção do movimento (+Z é a cabeça)
		var target_yaw = atan2(move_dir.x, move_dir.z)
		_current_yaw = lerp_angle(_current_yaw, target_yaw, delta * 9.0)
		is_walking_now = not is_airborne

	# Inclinação dinâmica de voo (pitch leve ao voar para frente)
	var target_pitch = 0.0
	if is_airborne and move_dir.length_squared() > 0.01:
		target_pitch = 0.18
	creature_root.rotation = Vector3(
		lerpf(creature_root.rotation.x, target_pitch, delta * 6.0),
		_current_yaw,
		0.0
	)

	# 4. Animação de Habilidade (Lunge / Salto)
	var skill_offset_world = Vector3.ZERO
	if _skill_anim_timer > 0.0:
		_skill_anim_timer = maxf(0.0, _skill_anim_timer - delta)
		skill_offset_world = creature_root.global_transform.basis * (_skill_anim_offset * (_skill_anim_timer / 0.35))

	# Oscilação vertical sutil (passo ao caminhar ou respiração em repouso)
	var bob_y = 0.0
	if is_walking_now:
		bob_y = abs(cos(_walk_phase)) * 0.045
	elif not is_airborne:
		bob_y = sin(_idle_phase) * 0.012

	creature_root.position.y = current_y + bob_y + skill_offset_world.y

	# 5. Animação Procedural das PATAS (apenas ao caminhar com WASD ou recolhidas no voo)
	_animate_legs(delta, is_walking_now, is_airborne)

	# 6. Animação Procedural das ASAS (batida intensa no voo ou repouso respiratório no solo)
	_animate_wings(delta, is_airborne, holding_space)

	# 7. Animação Procedural da CAUDA (balanço natural)
	_animate_tails(delta, is_walking_now or is_airborne)

func _animate_legs(delta: float, is_walking: bool, is_airborne: bool) -> void:
	if _leg_initial_transforms.is_empty():
		return

	if is_walking:
		var spd_factor = clampf((creature_data.speed / 8.0) if creature_data else 1.2, 0.85, 2.4)
		_walk_phase += delta * step_frequency * spd_factor

	var index = 0
	for leg in _leg_initial_transforms.keys():
		if not is_instance_valid(leg):
			continue
		var init_t: Transform3D = _leg_initial_transforms[leg]

		if is_airborne:
			# No voo, as pernas ficam levemente recolhidas para trás
			var air_t = init_t
			air_t.basis = init_t.basis.rotated(Vector3.RIGHT, 0.35)
			air_t.origin = init_t.origin + Vector3(0.0, 0.06, -0.05)
			leg.transform = leg.transform.interpolate_with(air_t, delta * 8.0)
		elif is_walking:
			var is_right_side = init_t.origin.x > 0.0
			var side_offset = 0.0 if is_right_side else PI
			var leg_phase = _walk_phase + side_offset + (int(index / 2) * 0.8)

			var swing = sin(leg_phase) * step_swing_angle
			var lift = maxf(0.0, cos(leg_phase)) * step_lift

			var walk_t = init_t
			walk_t.basis = init_t.basis.rotated(Vector3.RIGHT, swing)
			walk_t.origin = init_t.origin + Vector3(0.0, lift, -sin(leg_phase) * 0.09)
			leg.transform = walk_t
		else:
			# Parado no chão: retorna suavemente para a pose firme de apoio
			leg.transform = leg.transform.interpolate_with(init_t, delta * 10.0)

		index += 1

func _animate_wings(delta: float, is_airborne: bool, holding_space: bool) -> void:
	if _wing_initial_transforms.is_empty():
		return

	var flap_speed = 14.0 if holding_space else (8.5 if is_airborne else 2.2)
	var flap_amp = 0.65 if is_airborne else 0.08
	_flight_phase += delta * flap_speed

	for wing in _wing_initial_transforms.keys():
		if not is_instance_valid(wing):
			continue
		var init_t: Transform3D = _wing_initial_transforms[wing]
		var flap_angle = sin(_flight_phase) * flap_amp
		var new_t = init_t
		new_t.basis = init_t.basis.rotated(Vector3.FORWARD, flap_angle)
		wing.transform = new_t

func _animate_tails(_delta: float, is_active: bool) -> void:
	if _tail_initial_transforms.is_empty():
		return
	var sway_amp = 0.22 if is_active else 0.07
	var sway = sin(_idle_phase * (2.2 if is_active else 1.0)) * sway_amp
	for tail in _tail_initial_transforms.keys():
		if not is_instance_valid(tail):
			continue
		var init_t: Transform3D = _tail_initial_transforms[tail]
		var new_t = init_t
		new_t.basis = init_t.basis.rotated(Vector3.UP, sway)
		tail.transform = new_t

## Feedback visual de execução de Habilidade (Q, E, R, F, V) no Modo Sandbox
func play_skill_motion(effect_type: String) -> void:
	if not creature_root:
		return
	_skill_anim_timer = 0.35
	match effect_type:
		"linear_knockback", "lifesteal_melee", "fast_combo":
			_skill_anim_offset = Vector3(0.0, 0.08, 0.45)
		"aerial_dash":
			_vertical_velocity = 8.5
			_skill_anim_offset = Vector3(0.0, 0.45, 0.55)
		"ground_shockwave":
			_vertical_velocity = 5.0
			_skill_anim_offset = Vector3(0.0, 0.30, 0.0)
		_:
			_skill_anim_offset = Vector3(0.0, 0.12, -0.25)

func reset_limbs_pose() -> void:
	for leg in _leg_initial_transforms.keys():
		if is_instance_valid(leg):
			leg.transform = _leg_initial_transforms[leg]
	for wing in _wing_initial_transforms.keys():
		if is_instance_valid(wing):
			wing.transform = _wing_initial_transforms[wing]
	for tail in _tail_initial_transforms.keys():
		if is_instance_valid(tail):
			tail.transform = _tail_initial_transforms[tail]
	if creature_root:
		creature_root.transform = _editor_root_transform
	_walk_phase = 0.0
	_flight_phase = 0.0
	_vertical_velocity = 0.0
	_skill_anim_timer = 0.0
