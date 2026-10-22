class_name SpineManager
extends Node3D

## PILAR 1: Gerenciador Procedural da Espinha Dorsal (Spine & Body Sculpting).
## - Cadeia de vértebras (mín: 3, máx: 16, padrão: 5)
## - Raio ajustável entre 0.15m e 2.50m (passos de 0.05m no Scroll)
## - Curva Catmull-Rom 3D com geração de malha contínua via SurfaceTool / ArrayMesh
## - Extrusão no final via Shift + Clique e remoção via Delete
## - Atualização dinâmica do CollisionShape3D e vínculo (skinning) de apêndices

signal spine_modified()
signal vertebra_selected(index: int)
signal vertebra_hovered(index: int)

const MIN_VERTEBRAE: int = 3
const MAX_VERTEBRAE: int = 20
const DEFAULT_VERTEBRAE: int = 5

@export var body_mesh_instance: MeshInstance3D
@export var collision_shape: CollisionShape3D
@export var camera: Camera3D
@export var editor_state: EditorState
@export var creature_data: CreatureData

@export_group("Mesh Generation")
@export var ring_segments: int = 20          ## Resolução angular do corte transversal
@export var curve_subdivisions: int = 6     ## Subdivisões Catmull-Rom entre cada par de vértebras
@export var min_radius: float = 0.15        ## Raio mínimo (0.15m)
@export var max_radius: float = 2.50        ## Raio máximo (2.50m)
@export var min_vertebra_size: float = 0.50 ## Tamanho/comprimento mínimo da vértebra
@export var max_vertebra_size: float = 2.00 ## Tamanho/comprimento máximo da vértebra
@export var scroll_step: float = 0.05       ## Passo de ajuste no Scroll (0.05m)
@export var base_default_radius: float = 0.45

@export_group("Spine Constraints")
@export var min_height: float = -0.45        ## Altura mínima local
@export var max_height: float = 3.20         ## Altura máxima vertical (permite puxar pescoço/cauda para cima)
@export var min_z: float = -3.80            ## Limite posterior (cauda)
@export var max_z: float = 3.80             ## Limite anterior (cabeça)
@export var max_lateral_x: float = 0.45     ## Desvio lateral máximo no eixo X
@export var base_vertebra_distance: float = 0.42 ## Distância base entre vértebras adjacentes

## Lista de Dicionários: [{ "pos": Vector3, "radius": float, "size": float, "base_radius": float }]
var vertebrae: Array[Dictionary] = []

var hovered_index: int = -1
var selected_index: int = -1

var _gizmo_container: Node3D
var _gizmo_instances: Array[MeshInstance3D] = []

var _mat_gizmo_normal: StandardMaterial3D
var _mat_gizmo_hover: StandardMaterial3D
var _mat_gizmo_selected: StandardMaterial3D
var _mat_gizmo_extremity: StandardMaterial3D

var _is_dragging_extremity: bool = false
var _drag_extremity_index: int = -1
var _drag_plane: Plane
var _drag_anchor_pos: Vector3

func _ready() -> void:
	_setup_materials()
	_setup_gizmo_container()

	if vertebrae.is_empty():
		_init_default_vertebrae()

	call_deferred("generate_mesh", true)

	if editor_state and not editor_state.mode_changed.is_connected(_on_editor_mode_changed):
		editor_state.mode_changed.connect(_on_editor_mode_changed)

func _setup_materials() -> void:
	_mat_gizmo_normal = StandardMaterial3D.new()
	_mat_gizmo_normal.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat_gizmo_normal.albedo_color = Color(0.2, 0.8, 1.0, 0.45)
	_mat_gizmo_normal.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat_gizmo_normal.no_depth_test = true

	_mat_gizmo_hover = StandardMaterial3D.new()
	_mat_gizmo_hover.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat_gizmo_hover.albedo_color = Color(1.0, 0.85, 0.2, 0.9)
	_mat_gizmo_hover.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat_gizmo_hover.no_depth_test = true

	_mat_gizmo_selected = StandardMaterial3D.new()
	_mat_gizmo_selected.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat_gizmo_selected.albedo_color = Color(1.0, 0.3, 0.2, 0.95)
	_mat_gizmo_selected.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat_gizmo_selected.no_depth_test = true

	# Material especial verde esmeralda para as pontas (cabeça/cauda), indicando que podem ser puxadas!
	_mat_gizmo_extremity = StandardMaterial3D.new()
	_mat_gizmo_extremity.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_mat_gizmo_extremity.albedo_color = Color(0.2, 0.95, 0.55, 0.8)
	_mat_gizmo_extremity.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mat_gizmo_extremity.no_depth_test = true

func _setup_gizmo_container() -> void:
	_gizmo_container = Node3D.new()
	_gizmo_container.name = "SpineGizmos"
	add_child(_gizmo_container)
	_gizmo_container.visible = (editor_state != null and editor_state.is_sculpting())

func _init_default_vertebrae() -> void:
	vertebrae.clear()
	# 5 vértebras padrão ao longo do eixo Z (0: Cabeça -> 4: Cauda)
	vertebrae.append({"pos": Vector3(0.0, 0.25, 0.84),  "radius": 0.35, "base_radius": 0.35, "size": 1.0})
	vertebrae.append({"pos": Vector3(0.0, 0.28, 0.42),  "radius": 0.52, "base_radius": 0.52, "size": 1.0})
	vertebrae.append({"pos": Vector3(0.0, 0.15, 0.0),   "radius": 0.62, "base_radius": 0.62, "size": 1.0})
	vertebrae.append({"pos": Vector3(0.0, 0.08, -0.42), "radius": 0.48, "base_radius": 0.48, "size": 1.0})
	vertebrae.append({"pos": Vector3(0.0, 0.12, -0.84), "radius": 0.28, "base_radius": 0.28, "size": 1.0})

	_rebuild_gizmos()
	_sync_spine_biomass()

func _rebuild_gizmos() -> void:
	if not _gizmo_container:
		return
	for g in _gizmo_instances:
		if is_instance_valid(g):
			g.queue_free()
	_gizmo_instances.clear()

	for i in range(vertebrae.size()):
		var gizmo = MeshInstance3D.new()
		var torus = TorusMesh.new()
		torus.inner_radius = 0.92
		torus.outer_radius = 1.0
		torus.rings = 24
		torus.ring_segments = 6
		gizmo.mesh = torus
		gizmo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		gizmo.material_override = _mat_gizmo_normal
		_gizmo_container.add_child(gizmo)
		_gizmo_instances.append(gizmo)

	_update_gizmos()

func _update_gizmos() -> void:
	if not _gizmo_container or not _gizmo_container.visible:
		return

	for i in range(vertebrae.size()):
		if i >= _gizmo_instances.size():
			break
		var g = _gizmo_instances[i]
		if not is_instance_valid(g):
			continue

		var v = vertebrae[i]
		var pos: Vector3 = v.pos
		var rad: float = v.radius

		var tangent = _get_vertebra_tangent(i)
		var basis = _build_orthonormal_basis(tangent)

		g.transform = Transform3D(basis, pos)
		g.scale = Vector3(rad, rad, rad)

		if i == selected_index:
			g.material_override = _mat_gizmo_selected
		elif i == hovered_index:
			g.material_override = _mat_gizmo_hover
		elif i == 0 or i == vertebrae.size() - 1:
			g.material_override = _mat_gizmo_extremity
		else:
			g.material_override = _mat_gizmo_normal

func _get_vertebra_tangent(idx: int) -> Vector3:
	var prev_pos = vertebrae[maxi(0, idx - 1)].pos
	var next_pos = vertebrae[mini(vertebrae.size() - 1, idx + 1)].pos
	var dir = (prev_pos - next_pos).normalized()
	if dir.length_squared() < 0.001:
		dir = Vector3.FORWARD
	return dir

func _build_orthonormal_basis(tangent: Vector3) -> Basis:
	var t = tangent.normalized()
	var up = Vector3.UP
	if abs(t.dot(up)) > 0.95:
		up = Vector3.RIGHT
	var right = t.cross(up).normalized()
	var new_up = right.cross(t).normalized()
	return Basis(right, new_up, t)

# --- Tratamento de Input e UX de Escultura ---

func _input(event: InputEvent) -> void:
	if editor_state and not editor_state.is_sculpting():
		if _gizmo_container and _gizmo_container.visible:
			_gizmo_container.visible = false
		return
	if not camera:
		return

	# Tecla Delete / Backspace para remover vértebra selecionada
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_DELETE or event.keycode == KEY_BACKSPACE:
			if selected_index >= 0 and vertebrae.size() > MIN_VERTEBRAE:
				remove_vertebra(selected_index)
				get_viewport().set_input_as_handled()
				return

	if event is InputEventMouseMotion:
		if _is_dragging_extremity:
			_handle_extremity_drag(event.position)
			get_viewport().set_input_as_handled()
		else:
			_update_hover(event.position)

	elif event is InputEventMouseButton:
		# 1. Scroll do Mouse: Modifica raio em passos de 0.05m (ou tamanho se Shift estiver pressionado)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var target_idx = hovered_index if hovered_index >= 0 else selected_index
			if target_idx >= 0 and target_idx < vertebrae.size():
				if event.pressed:
					var dir_sign = 1.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1.0
					if Input.is_key_pressed(KEY_SHIFT):
						adjust_vertebra_size(target_idx, dir_sign * 0.08)
					else:
						adjust_vertebra_radius(target_idx, dir_sign * scroll_step)
				get_viewport().set_input_as_handled()
				return

		# 2. Botão Esquerdo
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if hovered_index >= 0:
					selected_index = hovered_index
					emit_signal("vertebra_selected", selected_index)
					_update_gizmos()

					# Permite puxar e extrudar APENAS as extremidades (cabeça no índice 0 ou cauda no último índice)
					# As vértebras intermediárias permanecem com posições 100% fixas para nunca deformar a criatura!
					if selected_index == 0 or selected_index == vertebrae.size() - 1:
						_is_dragging_extremity = true
						_drag_extremity_index = selected_index
						var anchor_idx = 1 if selected_index == 0 else selected_index - 1
						_drag_anchor_pos = vertebrae[anchor_idx].pos
						var plane_normal = -camera.global_transform.basis.z.normalized()
						_drag_plane = Plane(plane_normal, to_global(_drag_anchor_pos))
					else:
						_is_dragging_extremity = false
						_drag_extremity_index = -1

					get_viewport().set_input_as_handled()
					return
			else:
				if _is_dragging_extremity:
					_is_dragging_extremity = false
					_finalize_extremity_drag()
					get_viewport().set_input_as_handled()
					return

func _handle_extremity_drag(screen_pos: Vector2) -> void:
	if not _is_dragging_extremity or not camera or vertebrae.size() < 2:
		return

	var ray_origin = camera.project_ray_origin(screen_pos)
	var ray_normal = camera.project_ray_normal(screen_pos)
	var hit = _drag_plane.intersects_ray(ray_origin, ray_normal)
	if hit == null:
		return

	var local_hit = to_local(hit)
	local_hit.x = clampf(local_hit.x, -max_lateral_x * 2.5, max_lateral_x * 2.5)
	local_hit.y = clampf(local_hit.y, min_height, max_height)
	local_hit.z = clampf(local_hit.z, min_z, max_z)

	var seg_dist = base_vertebra_distance
	var extrude_threshold = seg_dist * 1.35
	var retract_threshold = seg_dist * 0.35

	# === CASO 1: PUXANDO O FINAL DA COLUNA (CAUDA) ===
	if _drag_extremity_index == vertebrae.size() - 1:
		var anchor_idx = vertebrae.size() - 2
		_drag_anchor_pos = vertebrae[anchor_idx].pos
		var diff = local_hit - _drag_anchor_pos
		var dist = diff.length()
		var pull_dir = diff.normalized() if dist > 0.001 else Vector3.BACK

		# 1. Extrusão na cauda: Adiciona nova vértebra quando puxado além do limiar
		if dist > extrude_threshold and vertebrae.size() < MAX_VERTEBRAE:
			if not creature_data or creature_data.can_afford(2):
				vertebrae[selected_index].pos = _drag_anchor_pos + pull_dir * seg_dist
				var cur_rad = float(vertebrae[selected_index].radius)
				var new_rad = clampf(cur_rad * 0.90, min_radius, max_radius)
				var new_pos = vertebrae[selected_index].pos + pull_dir * (seg_dist * 0.75)
				vertebrae.append({
					"pos": new_pos,
					"radius": new_rad,
					"base_radius": new_rad,
					"size": 1.0
				})
				selected_index = vertebrae.size() - 1
				_drag_extremity_index = selected_index
				_drag_anchor_pos = vertebrae[selected_index - 1].pos
				var plane_normal = -camera.global_transform.basis.z.normalized()
				_drag_plane = Plane(plane_normal, to_global(_drag_anchor_pos))

				_sync_spine_biomass()
				_rebuild_gizmos()
				emit_signal("vertebra_selected", selected_index)
				generate_mesh(false)
				emit_signal("spine_modified")
				return

		# 2. Retração na cauda: Remove vértebra ao empurrar de volta
		elif dist < retract_threshold and vertebrae.size() > MIN_VERTEBRAE:
			vertebrae.pop_back()
			selected_index = vertebrae.size() - 1
			_drag_extremity_index = selected_index
			_drag_anchor_pos = vertebrae[selected_index - 1].pos
			var plane_normal = -camera.global_transform.basis.z.normalized()
			_drag_plane = Plane(plane_normal, to_global(_drag_anchor_pos))

			_sync_spine_biomass()
			_rebuild_gizmos()
			emit_signal("vertebra_selected", selected_index)
			generate_mesh(false)
			emit_signal("spine_modified")
			return

		# 3. Orientação da ponta da cauda na direção puxada
		var tip_dist = clampf(dist, seg_dist * 0.7, seg_dist * 1.3)
		vertebrae[selected_index].pos = _drag_anchor_pos + pull_dir * tip_dist
		_update_gizmos()
		generate_mesh(false)
		emit_signal("spine_modified")

	# === CASO 2: PUXANDO O INÍCIO DA COLUNA (CABEÇA / PESCOÇO) ===
	elif _drag_extremity_index == 0:
		_drag_anchor_pos = vertebrae[1].pos
		var diff = local_hit - _drag_anchor_pos
		var dist = diff.length()
		var pull_dir = diff.normalized() if dist > 0.001 else Vector3.FORWARD

		# 1. Extrusão na cabeça: Insere nova vértebra no índice 0
		if dist > extrude_threshold and vertebrae.size() < MAX_VERTEBRAE:
			if not creature_data or creature_data.can_afford(2):
				vertebrae[0].pos = _drag_anchor_pos + pull_dir * seg_dist
				var cur_rad = float(vertebrae[0].radius)
				var new_rad = clampf(cur_rad * 0.92, min_radius, max_radius)
				var new_pos = vertebrae[0].pos + pull_dir * (seg_dist * 0.75)
				vertebrae.insert(0, {
					"pos": new_pos,
					"radius": new_rad,
					"base_radius": new_rad,
					"size": 1.0
				})
				_shift_bindings_on_head_insert(+1)
				selected_index = 0
				_drag_extremity_index = 0
				_drag_anchor_pos = vertebrae[1].pos
				var plane_normal = -camera.global_transform.basis.z.normalized()
				_drag_plane = Plane(plane_normal, to_global(_drag_anchor_pos))

				_sync_spine_biomass()
				_rebuild_gizmos()
				emit_signal("vertebra_selected", selected_index)
				generate_mesh(false)
				emit_signal("spine_modified")
				return

		# 2. Retração na cabeça
		elif dist < retract_threshold and vertebrae.size() > MIN_VERTEBRAE:
			vertebrae.remove_at(0)
			_shift_bindings_on_head_insert(-1)
			selected_index = 0
			_drag_extremity_index = 0
			_drag_anchor_pos = vertebrae[1].pos
			var plane_normal = -camera.global_transform.basis.z.normalized()
			_drag_plane = Plane(plane_normal, to_global(_drag_anchor_pos))

			_sync_spine_biomass()
			_rebuild_gizmos()
			emit_signal("vertebra_selected", selected_index)
			generate_mesh(false)
			emit_signal("spine_modified")
			return

		# 3. Orientação da cabeça na direção puxada
		var tip_dist = clampf(dist, seg_dist * 0.7, seg_dist * 1.3)
		vertebrae[0].pos = _drag_anchor_pos + pull_dir * tip_dist
		_update_gizmos()
		generate_mesh(false)
		emit_signal("spine_modified")

func _finalize_extremity_drag() -> void:
	if vertebrae.size() >= 2:
		if selected_index == vertebrae.size() - 1:
			var prev_pos = vertebrae[selected_index - 1].pos
			var diff = vertebrae[selected_index].pos - prev_pos
			var pull_dir = diff.normalized() if diff.length_squared() > 0.001 else Vector3.BACK
			vertebrae[selected_index].pos = prev_pos + pull_dir * base_vertebra_distance
		elif selected_index == 0:
			var next_pos = vertebrae[1].pos
			var diff = vertebrae[0].pos - next_pos
			var pull_dir = diff.normalized() if diff.length_squared() > 0.001 else Vector3.FORWARD
			vertebrae[0].pos = next_pos + pull_dir * base_vertebra_distance

	_update_gizmos()
	generate_mesh(true)
	emit_signal("spine_modified")

func _shift_bindings_on_head_insert(delta: int) -> void:
	if not creature_data:
		return
	for part in creature_data.attached_parts:
		var binding: Dictionary = part.get("spine_binding", {})
		if binding.has("seg_idx"):
			binding["seg_idx"] = maxi(0, int(binding["seg_idx"]) + delta)

func _update_hover(screen_pos: Vector2) -> void:
	var closest_idx = -1
	var min_dist_px = 55.0

	for i in range(vertebrae.size()):
		var v_world = to_global(vertebrae[i].pos)
		if camera.is_position_behind(v_world):
			continue
		var v_screen = camera.unproject_position(v_world)
		var dist = screen_pos.distance_to(v_screen)
		if dist < min_dist_px:
			min_dist_px = dist
			closest_idx = i

	if closest_idx != hovered_index:
		hovered_index = closest_idx
		emit_signal("vertebra_hovered", hovered_index)
		_update_gizmos()

func _get_max_segment_distance(idx_a: int, idx_b: int) -> float:
	var size_a = float(vertebrae[idx_a].get("size", 1.0))
	var size_b = float(vertebrae[idx_b].get("size", 1.0))
	return base_vertebra_distance * ((size_a + size_b) * 0.5)

func adjust_vertebra_radius(idx: int, delta: float) -> void:
	if idx < 0 or idx >= vertebrae.size():
		return
	var current_rad = float(vertebrae[idx].radius)
	var desired_rad = clampf(current_rad + delta, min_radius, max_radius)

	# Verifica se há biomassa suficiente caso esteja aumentando o raio (1pt por +0.2m)
	var old_cost = calculate_spine_biomass_cost()
	vertebrae[idx].radius = desired_rad
	var new_cost = calculate_spine_biomass_cost()

	if creature_data and new_cost > old_cost:
		if not creature_data.can_afford(new_cost - old_cost):
			vertebrae[idx].radius = current_rad
			return

	_sync_spine_biomass()
	_update_gizmos()
	generate_mesh(true)
	emit_signal("spine_modified")

func adjust_vertebra_size(idx: int, delta: float) -> void:
	if idx < 0 or idx >= vertebrae.size():
		return
	var old_size = float(vertebrae[idx].get("size", 1.0))
	var new_size = clampf(old_size + delta, min_vertebra_size, max_vertebra_size)
	if is_equal_approx(old_size, new_size):
		return

	var scale_ratio = new_size / old_size
	vertebrae[idx]["size"] = new_size
	vertebrae[idx].radius = clampf(float(vertebrae[idx].radius) * scale_ratio, min_radius, max_radius)

	for i in range(idx + 1, vertebrae.size()):
		var target_dist = _get_max_segment_distance(i, i - 1)
		var prev_pos = vertebrae[i - 1].pos
		var dir = (vertebrae[i].pos - prev_pos).normalized()
		if dir.length_squared() < 0.001:
			dir = Vector3.BACK
		vertebrae[i].pos = prev_pos + dir * target_dist
		vertebrae[i].pos.x = clampf(vertebrae[i].pos.x, -max_lateral_x, max_lateral_x)
		vertebrae[i].pos.y = clampf(vertebrae[i].pos.y, min_height, max_height)
		vertebrae[i].pos.z = clampf(vertebrae[i].pos.z, min_z, max_z)

	_sync_spine_biomass()
	_update_gizmos()
	generate_mesh(true)
	emit_signal("spine_modified")

func set_vertebra_size(idx: int, new_size: float) -> void:
	if idx < 0 or idx >= vertebrae.size():
		return
	var current_size = float(vertebrae[idx].get("size", 1.0))
	adjust_vertebra_size(idx, new_size - current_size)

## Calcula o custo em biomassa do aumento de raio da coluna (1pt por +0.2m acima do base_radius)
func calculate_spine_biomass_cost() -> int:
	var total_extra_radius: float = 0.0
	for v in vertebrae:
		var base_r = float(v.get("base_radius", base_default_radius))
		var cur_r = float(v.get("radius", base_r))
		if cur_r > base_r:
			total_extra_radius += (cur_r - base_r)
	# +2 pts por cada vértebra extra além das 5 padrão
	var extra_vertebrae_cost = maxi(0, vertebrae.size() - DEFAULT_VERTEBRAE) * 2
	return int(floor(total_extra_radius / 0.20 + 0.001)) + extra_vertebrae_cost

func _sync_spine_biomass() -> void:
	if creature_data:
		creature_data.set_spine_metrics(
			calculate_spine_biomass_cost(),
			get_total_spine_mass(),
			get_thorax_mass(),
			get_spine_center_of_mass()
		)

func get_total_spine_mass() -> float:
	var mass: float = 0.0
	for v in vertebrae:
		var r = float(v.get("radius", 0.4))
		var sz = float(v.get("size", 1.0))
		mass += (r * r * sz) * 8.5
	return maxf(2.0, mass)

func get_thorax_mass() -> float:
	if vertebrae.is_empty():
		return 2.0
	var mid_idx = mini(1, vertebrae.size() - 1)
	var r = float(vertebrae[mid_idx].get("radius", 0.5))
	var sz = float(vertebrae[mid_idx].get("size", 1.0))
	return (r * r * sz) * 14.0

func get_spine_center_of_mass() -> Vector3:
	if vertebrae.is_empty():
		return Vector3.ZERO
	var weighted_sum = Vector3.ZERO
	var total_w = 0.0
	for v in vertebrae:
		var r = float(v.get("radius", 0.4))
		var w = r * r
		weighted_sum += to_global(v.pos) * w
		total_w += w
	return weighted_sum / maxf(0.001, total_w)

# --- Operações de Vértebras (Adicionar/Remover/Resetar) ---

## Adiciona nova vértebra no FINAL da coluna (máx: 16)
func add_vertebra() -> void:
	if vertebrae.size() >= MAX_VERTEBRAE:
		return

	if creature_data and not creature_data.can_afford(2):
		return

	var last_idx = vertebrae.size() - 1
	var last_v = vertebrae[last_idx]
	var second_last_pos = vertebrae[maxi(0, last_idx - 1)].pos

	var extend_dir = (last_v.pos - second_last_pos).normalized()
	if extend_dir.length_squared() < 0.001:
		extend_dir = Vector3.BACK

	var seg_dist = base_vertebra_distance * 0.85
	var new_pos = last_v.pos + extend_dir * seg_dist

	if new_pos.z < min_z:
		var shift_z = min_z - new_pos.z
		for v in vertebrae:
			v.pos.z = clampf(v.pos.z + shift_z, min_z, max_z)
		new_pos.z = min_z

	new_pos.x = clampf(new_pos.x, -max_lateral_x, max_lateral_x)
	new_pos.y = clampf(new_pos.y, min_height, max_height)
	new_pos.z = clampf(new_pos.z, min_z, max_z)

	var new_rad = clampf(float(last_v.radius) * 0.85, min_radius, max_radius)
	var new_vertebra = {
		"pos": new_pos,
		"radius": new_rad,
		"base_radius": new_rad,
		"size": 1.0
	}
	vertebrae.append(new_vertebra)
	selected_index = vertebrae.size() - 1
	_sync_spine_biomass()
	_rebuild_gizmos()
	generate_mesh(true)
	emit_signal("spine_modified")
	emit_signal("vertebra_selected", selected_index)

func remove_vertebra(index: int = -1) -> void:
	if vertebrae.size() <= MIN_VERTEBRAE:
		return

	var remove_idx = vertebrae.size() - 1
	if index >= 0 and index < vertebrae.size():
		remove_idx = index

	vertebrae.remove_at(remove_idx)
	if remove_idx == 0 and creature_data:
		for part in creature_data.attached_parts:
			var binding: Dictionary = part.get("spine_binding", {})
			if binding.has("seg_idx"):
				binding["seg_idx"] = maxi(0, int(binding["seg_idx"]) - 1)
	selected_index = mini(selected_index, vertebrae.size() - 1)
	hovered_index = -1
	_sync_spine_biomass()
	_rebuild_gizmos()
	generate_mesh(true)
	emit_signal("spine_modified")

func reset_spine() -> void:
	_init_default_vertebrae()
	selected_index = -1
	hovered_index = -1
	generate_mesh(true)
	emit_signal("spine_modified")

## Alinha e endireita as vértebras perfeitamente na linha média (X = 0) com suave arco dorsal natural
## Preserva todos os raios (grossuras) e corrige qualquer torção ou deformação acidental!
func straighten_spine() -> void:
	if vertebrae.size() < 2:
		return
	var n = vertebrae.size()
	var total_length = (n - 1) * base_vertebra_distance
	var start_z = total_length * 0.5
	var end_z = -total_length * 0.5

	for i in range(n):
		var t = float(i) / float(n - 1)
		var z_pos = lerpf(start_z, end_z, t)
		var arch_y = 0.18 + sin(t * PI) * 0.08
		vertebrae[i].pos = Vector3(0.0, arch_y, z_pos)

	_update_gizmos()
	generate_mesh(true)
	emit_signal("spine_modified")

# --- Sistema de Vínculo (Skinning) para Apêndices Acompanharem o Corpo ---

func compute_surface_attachment_binding(world_pos: Vector3, world_basis: Basis) -> Dictionary:
	var local_pos = to_local(world_pos)
	var best_seg: int = 0
	var best_t: float = 0.5
	var min_dist_sq: float = INF

	var num_segments = maxi(1, vertebrae.size() - 1)
	for seg in range(num_segments):
		for step in range(11):
			var t = float(step) / 10.0
			var c_pos = _catmull_rom_pos(seg, t)
			var d_sq = local_pos.distance_squared_to(c_pos)
			if d_sq < min_dist_sq:
				min_dist_sq = d_sq
				best_seg = seg
				best_t = t

	var spine_center = sample_spine_pos_at_segment(best_seg, best_t)
	var spine_radius = maxf(0.05, sample_spine_radius_at_segment(best_seg, best_t))
	var spine_basis = sample_spine_basis_at_segment(best_seg, best_t)

	var rel_offset = spine_basis.inverse() * (local_pos - spine_center)
	var norm_offset = rel_offset / spine_radius
	var local_part_basis = global_transform.basis.inverse() * world_basis
	var rel_basis = spine_basis.inverse() * local_part_basis

	var global_u = (float(best_seg) + best_t) / float(num_segments)

	return {
		"spine_u": global_u,
		"seg_idx": best_seg,
		"seg_t": best_t,
		"normalized_offset": norm_offset,
		"relative_basis": rel_basis
	}

func evaluate_surface_attachment_transform(binding: Dictionary) -> Transform3D:
	var num_segments = maxi(1, vertebrae.size() - 1)
	var seg_idx: int = 0
	var seg_t: float = 0.5

	if binding.has("seg_idx"):
		seg_idx = clampi(int(binding["seg_idx"]), 0, num_segments - 1)
		seg_t = clampf(float(binding.get("seg_t", 0.5)), 0.0, 1.0)
	elif binding.has("spine_u"):
		var u = clampf(float(binding.get("spine_u", 0.5)), 0.0, 1.0)
		var s_float = u * float(num_segments)
		seg_idx = mini(int(s_float), num_segments - 1)
		seg_t = s_float - float(seg_idx)

	var spine_center = sample_spine_pos_at_segment(seg_idx, seg_t)
	var spine_radius = maxf(0.05, sample_spine_radius_at_segment(seg_idx, seg_t))
	var spine_basis = sample_spine_basis_at_segment(seg_idx, seg_t)

	var norm_offset: Vector3 = binding.get("normalized_offset", Vector3.UP)
	var rel_basis: Basis = binding.get("relative_basis", Basis.IDENTITY)

	var new_local_pos = spine_center + (spine_basis * (norm_offset * spine_radius))
	var new_world_pos = to_global(new_local_pos)
	var new_world_basis = global_transform.basis * spine_basis * rel_basis

	return Transform3D(new_world_basis, new_world_pos)

func sample_spine_pos_at_segment(seg_idx: int, t_local: float) -> Vector3:
	if vertebrae.is_empty():
		return Vector3.ZERO
	if vertebrae.size() == 1:
		return vertebrae[0].pos
	var s_idx = clampi(seg_idx, 0, maxi(0, vertebrae.size() - 2))
	var t = clampf(t_local, 0.0, 1.0)
	return _catmull_rom_pos(s_idx, t)

func sample_spine_radius_at_segment(seg_idx: int, t_local: float) -> float:
	if vertebrae.is_empty():
		return 0.5
	if vertebrae.size() == 1:
		return float(vertebrae[0].radius)
	var s_idx = clampi(seg_idx, 0, maxi(0, vertebrae.size() - 2))
	var t = clampf(t_local, 0.0, 1.0)
	return _catmull_rom_radius(s_idx, t)

func sample_spine_basis_at_segment(seg_idx: int, t_local: float) -> Basis:
	var s_idx = clampi(seg_idx, 0, maxi(0, vertebrae.size() - 2))
	var t = clampf(t_local, 0.0, 1.0)
	var eps = 0.02
	var p_prev = _catmull_rom_pos(s_idx, maxf(0.0, t - eps))
	var p_next = _catmull_rom_pos(s_idx, minf(1.0, t + eps))
	var tangent = (p_next - p_prev).normalized()
	if tangent.length_squared() < 0.0001:
		tangent = Vector3.BACK
	return _build_smooth_basis(tangent, Basis.IDENTITY)

func sample_spine_pos(u: float) -> Vector3:
	if vertebrae.is_empty():
		return Vector3.ZERO
	if vertebrae.size() == 1:
		return vertebrae[0].pos
	var num_segments = vertebrae.size() - 1
	var seg_float = clampf(u, 0.0, 1.0) * float(num_segments)
	var seg_idx = mini(int(seg_float), num_segments - 1)
	var t_local = seg_float - float(seg_idx)
	return _catmull_rom_pos(seg_idx, t_local)

func sample_spine_radius(u: float) -> float:
	if vertebrae.is_empty():
		return 0.5
	if vertebrae.size() == 1:
		return float(vertebrae[0].radius)
	var num_segments = vertebrae.size() - 1
	var seg_float = clampf(u, 0.0, 1.0) * float(num_segments)
	var seg_idx = mini(int(seg_float), num_segments - 1)
	var t_local = seg_float - float(seg_idx)
	return _catmull_rom_radius(seg_idx, t_local)

func sample_spine_basis(u: float) -> Basis:
	var eps = 0.02
	var p_prev = sample_spine_pos(maxf(0.0, u - eps))
	var p_next = sample_spine_pos(minf(1.0, u + eps))
	var tangent = (p_next - p_prev).normalized()
	if tangent.length_squared() < 0.0001:
		tangent = Vector3.BACK
	return _build_smooth_basis(tangent, Basis.IDENTITY)

# --- Geração Procedural da Malha (SurfaceTool & Lofting Catmull-Rom) ---

func generate_mesh(update_collider: bool = true) -> void:
	if not body_mesh_instance or vertebrae.size() < 2:
		return

	var sampled_points: Array[Vector3] = []
	var sampled_radii: Array[float] = []

	var num_segments = vertebrae.size() - 1
	var total_samples = num_segments * curve_subdivisions

	for step in range(total_samples + 1):
		var t_global = float(step) / float(total_samples)
		var seg_float = t_global * float(num_segments)
		var seg_idx = mini(int(seg_float), num_segments - 1)
		var t_local = seg_float - float(seg_idx)

		var p = _catmull_rom_pos(seg_idx, t_local)
		var r = _catmull_rom_radius(seg_idx, t_local)

		sampled_points.append(p)
		sampled_radii.append(r)

	var ring_count = sampled_points.size()
	if ring_count < 2:
		return

	var rings_vertices: Array[Array] = []
	var rings_uvs: Array[Array] = []
	var prev_basis = Basis.IDENTITY

	for i in range(ring_count):
		var center = sampled_points[i]
		var radius = sampled_radii[i]

		var tangent: Vector3
		if i == 0:
			tangent = (sampled_points[1] - sampled_points[0]).normalized()
		elif i == ring_count - 1:
			tangent = (sampled_points[i] - sampled_points[i - 1]).normalized()
		else:
			tangent = (sampled_points[i + 1] - sampled_points[i - 1]).normalized()

		if tangent.length_squared() < 0.0001:
			tangent = Vector3.FORWARD

		var basis = _build_smooth_basis(tangent, prev_basis if i > 0 else Basis.IDENTITY)
		prev_basis = basis

		var ring_verts: Array[Vector3] = []
		var ring_uvs_arr: Array[Vector2] = []
		var u_progress = float(i) / float(ring_count - 1)

		for j in range(ring_segments):
			var angle = (float(j) / float(ring_segments)) * TAU
			var local_offset = (basis.x * cos(angle) + basis.y * sin(angle)) * radius
			ring_verts.append(center + local_offset)
			ring_uvs_arr.append(Vector2(float(j) / float(ring_segments), u_progress))

		rings_vertices.append(ring_verts)
		rings_uvs.append(ring_uvs_arr)

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# 1. Tampa Frontal (Cabeça)
	var head_center = sampled_points[0]
	var head_tangent = (sampled_points[0] - sampled_points[1]).normalized()
	var head_cap_point = head_center + head_tangent * (sampled_radii[0] * 0.4)

	for j in range(ring_segments):
		var next_j = (j + 1) % ring_segments
		st.set_uv(Vector2(0.5, 0.0))
		st.add_vertex(head_cap_point)
		st.set_uv(rings_uvs[0][next_j])
		st.add_vertex(rings_vertices[0][next_j])
		st.set_uv(rings_uvs[0][j])
		st.add_vertex(rings_vertices[0][j])

	# 2. Conexão entre anéis adjacentes
	for i in range(ring_count - 1):
		for j in range(ring_segments):
			var next_j = (j + 1) % ring_segments

			var v00 = rings_vertices[i][j]
			var v01 = rings_vertices[i][next_j]
			var v10 = rings_vertices[i + 1][j]
			var v11 = rings_vertices[i + 1][next_j]

			var uv00 = rings_uvs[i][j]
			var uv01 = rings_uvs[i][next_j]
			var uv10 = rings_uvs[i + 1][j]
			var uv11 = rings_uvs[i + 1][next_j]

			st.set_uv(uv00)
			st.add_vertex(v00)
			st.set_uv(uv01)
			st.add_vertex(v01)
			st.set_uv(uv11)
			st.add_vertex(v11)

			st.set_uv(uv00)
			st.add_vertex(v00)
			st.set_uv(uv11)
			st.add_vertex(v11)
			st.set_uv(uv10)
			st.add_vertex(v10)

	# 3. Tampa Traseira (Cauda)
	var tail_idx = ring_count - 1
	var tail_center = sampled_points[tail_idx]
	var tail_tangent = (sampled_points[tail_idx] - sampled_points[tail_idx - 1]).normalized()
	var tail_cap_point = tail_center + tail_tangent * (sampled_radii[tail_idx] * 0.4)

	for j in range(ring_segments):
		var next_j = (j + 1) % ring_segments
		st.set_uv(Vector2(0.5, 1.0))
		st.add_vertex(tail_cap_point)
		st.set_uv(rings_uvs[tail_idx][j])
		st.add_vertex(rings_vertices[tail_idx][j])
		st.set_uv(rings_uvs[tail_idx][next_j])
		st.add_vertex(rings_vertices[tail_idx][next_j])

	st.generate_normals()
	st.generate_tangents()

	var new_mesh = st.commit()
	body_mesh_instance.mesh = new_mesh
	body_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

	if body_mesh_instance is ApplyCreatureShader:
		var mat = (body_mesh_instance as ApplyCreatureShader).get_creature_material()
		if mat:
			body_mesh_instance.set_surface_override_material(0, mat)

	if update_collider:
		_update_collision_shape(new_mesh)

func _update_collision_shape(mesh: Mesh) -> void:
	if not collision_shape or not mesh:
		return
	var trimesh_shape = mesh.create_trimesh_shape()
	if trimesh_shape:
		trimesh_shape.backface_collision = true
		collision_shape.shape = trimesh_shape

# --- Matemática de Curvas Catmull-Rom e Bases ---

func _catmull_rom_pos(seg_idx: int, t: float) -> Vector3:
	var p0 = vertebrae[maxi(0, seg_idx - 1)].pos
	var p1 = vertebrae[seg_idx].pos
	var p2 = vertebrae[mini(vertebrae.size() - 1, seg_idx + 1)].pos
	var p3 = vertebrae[mini(vertebrae.size() - 1, seg_idx + 2)].pos
	return 0.5 * (
		(2.0 * p1) +
		(-p0 + p2) * t +
		(2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * (t * t) +
		(-p0 + 3.0 * p1 - 3.0 * p2 + p3) * (t * t * t)
	)

func _catmull_rom_radius(seg_idx: int, t: float) -> float:
	var r0 = float(vertebrae[maxi(0, seg_idx - 1)].radius)
	var r1 = float(vertebrae[seg_idx].radius)
	var r2 = float(vertebrae[mini(vertebrae.size() - 1, seg_idx + 1)].radius)
	var r3 = float(vertebrae[mini(vertebrae.size() - 1, seg_idx + 2)].radius)
	var val = 0.5 * (
		(2.0 * r1) +
		(-r0 + r2) * t +
		(2.0 * r0 - 5.0 * r1 + 4.0 * r2 - r3) * (t * t) +
		(-r0 + 3.0 * r1 - 3.0 * r2 + r3) * (t * t * t)
	)
	return clampf(val, min_radius, max_radius)

func _build_smooth_basis(tangent: Vector3, prev_basis: Basis) -> Basis:
	var t = tangent.normalized()
	var right: Vector3
	var up: Vector3

	if prev_basis != Basis.IDENTITY and abs(prev_basis.z.dot(t)) > 0.1:
		right = prev_basis.x - t * (t.dot(prev_basis.x))
		if right.length_squared() < 0.001:
			right = prev_basis.y.cross(t)
		right = right.normalized()
		up = right.cross(t).normalized()
	else:
		var ref_up = Vector3.UP
		if abs(t.dot(ref_up)) > 0.95:
			ref_up = Vector3.RIGHT
		right = t.cross(ref_up).normalized()
		up = right.cross(t).normalized()

	return Basis(right, up, t)

func _on_editor_mode_changed(new_mode: EditorState.Mode, _old_mode: EditorState.Mode) -> void:
	var is_sculpt = (new_mode == EditorState.Mode.MODO_ESCULTURA)
	if _gizmo_container:
		_gizmo_container.visible = is_sculpt
	if not is_sculpt:
		hovered_index = -1
		selected_index = -1
		_is_dragging_extremity = false
		generate_mesh(true)
	else:
		_update_gizmos()

