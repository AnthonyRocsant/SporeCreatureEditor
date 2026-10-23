class_name AttachmentSystem
extends Node3D

## PILAR 2, 3 e 4: Sistema de Raycast, Posicionamento, Seleção 3D, Edição (Rotação, Escala, Posição Local)
## e Remoção (Delete/Backspace com reembolso de Biomassa) de Apêndices no Corpo.
## Inclui espelhamento simétrico sem inversão de faces e vínculo de superfície (skinning) com a coluna.

signal part_attached(node: Node3D)
signal part_selected(part_data: Dictionary)
signal part_deselected()
signal part_removed(part_id: String)
signal rotation_changed(angle_deg: float)
signal scale_changed(scale_val: float)

const LAYER_BODY: int = 1
const LAYER_PARTS: int = 2

@export var camera: Camera3D
@export var body_mesh: MeshInstance3D
@export var creature_root: Node3D
@export var creature_data: CreatureData
@export var editor_state: EditorState
@export var spine_controller: SpineManager

@export var symmetrical_mode: bool = true
@export var ray_length: float = 1000.0
@export var snap_collision_mask: int = 1

## Estado atual de transformação para novas peças ou peça selecionada
var current_rotation: float = 0.0
var current_scale: float = 1.0
var min_part_scale: float = 0.50
var max_part_scale: float = 2.00

## Cores ativas sincronizadas com o corpo
var current_primary_color: Color = Color(0.85, 0.45, 0.35, 1.0)
var current_secondary_color: Color = Color(0.30, 0.15, 0.10, 1.0)
var current_detail_color: Color = Color(0.92, 0.88, 0.78, 1.0)

## Cena e metadados da peça ativa no catálogo
@export var active_part_scene: PackedScene
var active_part_info: Dictionary = {
	"type": "leg",
	"category": "leg",
	"tag": "#Claw_Front",
	"name": "Pata Locomotora",
	"mass": 1.2,
	"base_damage": 6.0,
	"leg_force": 4.2,
	"wing_area": 0.0,
	"carapace_defense": 2.0
}

# Previews fantasmas para nova colocação
var _preview_instance: Node3D = null
var _preview_mirrored_instance: Node3D = null

# Anéis visuais de gizmo para destacar a peça selecionada na malha
var _gizmo_main: MeshInstance3D = null
var _gizmo_mirror: MeshInstance3D = null

# Peça atualmente selecionada na malha (Pilar 4) e seu par simétrico
var selected_part: Dictionary = {}
var selected_mirror_part: Dictionary = {}
var _is_repositioning_selected: bool = false

# Controle de impacto do Raycast sobre o corpo
var _has_valid_hit: bool = false
var _last_hit_position: Vector3 = Vector3.ZERO
var _last_hit_normal: Vector3 = Vector3.UP

# Controle de impacto no lado espelhado
var _has_valid_mirror_hit: bool = false
var _mirror_hit_position: Vector3 = Vector3.ZERO
var _mirror_hit_normal: Vector3 = Vector3.UP

func _ready() -> void:
	if not creature_data:
		creature_data = CreatureData.new()
	connect_spine_signals()
	_setup_selection_gizmos()

func connect_spine_signals() -> void:
	if spine_controller and not spine_controller.spine_modified.is_connected(update_attached_parts_on_spine):
		spine_controller.spine_modified.connect(update_attached_parts_on_spine)

func _setup_selection_gizmos() -> void:
	if not _gizmo_main:
		_gizmo_main = _create_gizmo_ring(Color(0.2, 0.95, 1.0, 0.95))
		add_child(_gizmo_main)
	if not _gizmo_mirror:
		_gizmo_mirror = _create_gizmo_ring(Color(0.25, 0.85, 1.0, 0.55))
		add_child(_gizmo_mirror)
	_gizmo_main.visible = false
	_gizmo_mirror.visible = false

func _create_gizmo_ring(col: Color) -> MeshInstance3D:
	var inst = MeshInstance3D.new()
	inst.name = "SelectionGizmoRing"
	var torus = TorusMesh.new()
	torus.inner_radius = 0.20
	torus.outer_radius = 0.26
	torus.rings = 32
	torus.ring_segments = 12
	inst.mesh = torus

	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = col
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	inst.material_override = mat
	inst.top_level = true
	return inst

func _update_selection_gizmo() -> void:
	if not _gizmo_main or not _gizmo_mirror:
		_setup_selection_gizmos()

	if selected_part.is_empty():
		_gizmo_main.visible = false
		_gizmo_mirror.visible = false
		return

	var node = selected_part.get("node") as Node3D
	if not is_instance_valid(node):
		_gizmo_main.visible = false
		_gizmo_mirror.visible = false
		return

	var s = float(selected_part.get("scale_factor", current_scale))
	_gizmo_main.visible = true
	_gizmo_main.global_transform = node.global_transform
	_gizmo_main.scale = Vector3.ONE * (s * 1.08)

	if not selected_mirror_part.is_empty():
		var m_node = selected_mirror_part.get("node") as Node3D
		if is_instance_valid(m_node):
			_gizmo_mirror.visible = true
			_gizmo_mirror.global_transform = m_node.global_transform
			_gizmo_mirror.scale = Vector3.ONE * (s * 1.08)
		else:
			_gizmo_mirror.visible = false
	else:
		_gizmo_mirror.visible = false

func _input(event: InputEvent) -> void:
	if editor_state and not editor_state.is_attaching():
		_set_preview_visible(false)
		return

	# 1. Teclas de atalho:
	# - Delete / Backspace: Remove a peça selecionada e reembolsa a biomassa em CreatureData
	# - Q / E: Rotaciona a peça selecionada ou o preview
	# - Z / X: Ajusta a escala da peça selecionada ou do preview
	# - ESC: Cancela a seleção ou a colocação
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_DELETE or event.keycode == KEY_BACKSPACE:
			if not selected_part.is_empty():
				delete_selected_part()
				get_viewport().set_input_as_handled()
				return
		elif event.keycode == KEY_Q:
			if not selected_part.is_empty() or (active_part_scene and _has_valid_hit):
				rotate_part(-0.22)
				get_viewport().set_input_as_handled()
				return
		elif event.keycode == KEY_E:
			if not selected_part.is_empty() or (active_part_scene and _has_valid_hit):
				rotate_part(0.22)
				get_viewport().set_input_as_handled()
				return
		elif event.keycode == KEY_Z:
			if not selected_part.is_empty() or (active_part_scene and _has_valid_hit):
				scale_part(-0.10)
				get_viewport().set_input_as_handled()
				return
		elif event.keycode == KEY_X:
			if not selected_part.is_empty() or (active_part_scene and _has_valid_hit):
				scale_part(0.10)
				get_viewport().set_input_as_handled()
				return
		elif event.keycode == KEY_ESCAPE:
			if active_part_scene:
				clear_active_part()
			else:
				deselect_part()
			get_viewport().set_input_as_handled()
			return

	# 2. Botões do Mouse e Scroll:
	# O scroll só é consumido para girar/escalar SE houver um apêndice selecionado OU pré-visualização ativa.
	# Caso contrário, o evento flui normalmente para o OrbitCamera poder dar zoom!
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var can_transform = (active_part_scene != null and _has_valid_hit) or (not selected_part.is_empty())
			if can_transform:
				if event.pressed:
					var dir_sign = 1.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1.0
					if Input.is_key_pressed(KEY_SHIFT):
						scale_part(dir_sign * 0.08)
					else:
						rotate_part(dir_sign * 0.20)
				get_viewport().set_input_as_handled()
				return

		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_update_raycast(event.position)

				# A) Se o usuário está com uma peça ativa da lista para fixar na criatura:
				if active_part_scene and _has_valid_hit:
					_confirm_attachment()
					get_viewport().set_input_as_handled()
					return

				# B) Se não está colocando peça nova: primeiro tenta clicar em um apêndice já existente na criatura
				var clicked_part = _pick_attached_part_at_screen(event.position)
				if not clicked_part.is_empty():
					select_existing_part(clicked_part)
					_is_repositioning_selected = true
					get_viewport().set_input_as_handled()
					return

				# C) Se já tinha uma peça selecionada e clicou em outro ponto do corpo:
				# Reposiciona a peça selecionada para o novo local clicado!
				if not selected_part.is_empty() and _has_valid_hit:
					_reposition_selected_part_to_hit(_last_hit_position, _last_hit_normal)
					_is_repositioning_selected = true
					get_viewport().set_input_as_handled()
					return

				# D) Se clicou no espaço vazio (fora da criatura e de qualquer apêndice): desseleciona
				if not selected_part.is_empty():
					deselect_part()
					get_viewport().set_input_as_handled()
					return
			else:
				# Soltou o clique esquerdo: encerra o arraste de reposicionamento
				if _is_repositioning_selected:
					_is_repositioning_selected = false
					get_viewport().set_input_as_handled()
					return

	elif event is InputEventMouseMotion:
		_update_raycast(event.position)
		if _is_repositioning_selected and _has_valid_hit and not selected_part.is_empty():
			_reposition_selected_part_to_hit(_last_hit_position, _last_hit_normal)

## Coleta pontos representativos ao longo de toda a hierarquia de nós de um apêndice
func _get_part_sample_points(part_node: Node3D) -> Array[Vector3]:
	var pts: Array[Vector3] = [part_node.global_position]
	_collect_node_sample_points(part_node, pts)
	return pts

func _collect_node_sample_points(node: Node, out_pts: Array[Vector3]) -> void:
	for child in node.get_children():
		if child is Node3D and not (child is StaticBody3D) and child.name != "SelectionGizmoRing":
			out_pts.append(child.global_position)
			if child is MeshInstance3D and child.mesh:
				var aabb = child.mesh.get_aabb()
				out_pts.append(child.global_transform * aabb.get_center())
				out_pts.append(child.global_transform * (aabb.position + aabb.size * 0.5))
				out_pts.append(child.global_transform * (aabb.position + aabb.size))
			_collect_node_sample_points(child, out_pts)

## Raycast / Screen-picking de alta precisão para encontrar apêndices já anexados na malha
func _pick_attached_part_at_screen(screen_pos: Vector2) -> Dictionary:
	if not camera or not creature_data or creature_data.attached_parts.is_empty():
		return {}

	var ray_origin = camera.project_ray_origin(screen_pos)
	var ray_dir = camera.project_ray_normal(screen_pos)
	var ray_end = ray_origin + ray_dir * ray_length

	# 1. Tenta colisão física na camada LAYER_PARTS
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end, LAYER_PARTS)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var res = space_state.intersect_ray(query)
	if not res.is_empty() and res.collider and res.collider.has_meta("part_id"):
		var pid = str(res.collider.get_meta("part_id"))
		var found = _find_part_by_id(pid)
		if not found.is_empty():
			return found

	# 2. Varredura 3D geométrica e projeção 2D detalhada em todos os pontos e membros do apêndice
	var best_part: Dictionary = {}
	var best_score: float = 999999.0

	for part in creature_data.attached_parts:
		var node = part.get("node") as Node3D
		if not is_instance_valid(node):
			continue
		if camera.is_position_behind(node.global_position):
			continue

		var scale_f = float(part.get("scale_factor", 1.0))
		var max_hit_dist_3d = 0.42 * maxf(scale_f, 0.6)
		var max_hit_dist_2d = 55.0

		var pts = _get_part_sample_points(node)
		for p in pts:
			# Distância 3D até o raio emitido pelo mouse
			var v = p - ray_origin
			var proj = v.dot(ray_dir)
			if proj > 0.0:
				var perp = v - ray_dir * proj
				var d3d = perp.length()
				if d3d < max_hit_dist_3d:
					var score = d3d + (proj * 0.005)
					if score < best_score:
						best_score = score
						best_part = part

			# Distância 2D em pixels na tela
			if not camera.is_position_behind(p):
				var scr_pt = camera.unproject_position(p)
				var d2d = screen_pos.distance_to(scr_pt)
				if d2d < max_hit_dist_2d:
					var score2d = (d2d / max_hit_dist_2d) * 0.4 + (proj * 0.005)
					if score2d < best_score:
						best_score = score2d
						best_part = part

	return best_part

func _find_part_by_id(part_id: String) -> Dictionary:
	if not creature_data or part_id == "":
		return {}
	for part in creature_data.attached_parts:
		if str(part.get("id", "")) == part_id:
			return part
	return {}

## Seleciona um apêndice existente para edição de Rotação, Escala, Posição ou Exclusão (Delete)
func select_existing_part(part_dict: Dictionary) -> void:
	if part_dict.is_empty():
		deselect_part()
		return

	selected_part = part_dict
	var pair_id = str(part_dict.get("pair_id", ""))
	selected_mirror_part = _find_part_by_id(pair_id) if pair_id != "" else {}

	current_rotation = float(selected_part.get("rotation_rad", current_rotation))
	current_scale = float(selected_part.get("scale_factor", 1.0))

	_set_preview_visible(false)
	_update_selection_gizmo()

	emit_signal("rotation_changed", rad_to_deg(current_rotation))
	emit_signal("scale_changed", current_scale)
	emit_signal("part_selected", selected_part)

func deselect_part() -> void:
	selected_part = {}
	selected_mirror_part = {}
	_is_repositioning_selected = false
	_update_selection_gizmo()
	emit_signal("part_deselected")

## Remove a peça atualmente selecionada (e seu par simétrico, se ativo) e reembolsa a Biomassa
func delete_selected_part() -> bool:
	if selected_part.is_empty() or not creature_data:
		return false

	var main_id = str(selected_part.get("id", ""))
	var main_node = selected_part.get("node") as Node3D

	var mirror_id = str(selected_mirror_part.get("id", ""))
	var mirror_node = selected_mirror_part.get("node") as Node3D

	if is_instance_valid(main_node):
		main_node.queue_free()
	if main_id != "":
		creature_data.remove_part(main_id)
		emit_signal("part_removed", main_id)

	if symmetrical_mode and mirror_id != "":
		if is_instance_valid(mirror_node):
			mirror_node.queue_free()
		creature_data.remove_part(mirror_id)
		emit_signal("part_removed", mirror_id)

	deselect_part()
	return true

# --- Transformações: Rotação, Escala e Offset Local ---

func rotate_part(delta_rad: float) -> void:
	set_part_rotation_rad(current_rotation + delta_rad)

func set_part_rotation_deg(angle_deg: float) -> void:
	set_part_rotation_rad(deg_to_rad(angle_deg))

func set_part_rotation_rad(angle_rad: float) -> void:
	var old_rot = current_rotation
	current_rotation = fposmod(angle_rad, TAU)
	var delta_rot = current_rotation - old_rot

	if _has_valid_hit:
		_update_preview_transforms(_last_hit_position, _last_hit_normal)

	_rotate_selected_pair(delta_rot)
	_update_selection_gizmo()
	emit_signal("rotation_changed", rad_to_deg(current_rotation))

func _rotate_selected_pair(delta_rad: float) -> void:
	if abs(delta_rad) < 0.0001 or selected_part.is_empty():
		return

	var is_leg = str(selected_part.get("type", "")).to_lower() == "leg" or str(selected_part.get("category", "")).to_lower() == "leg"
	var node = selected_part.get("node") as Node3D
	if is_instance_valid(node):
		var rot_axis = Vector3.UP if is_leg else node.global_transform.basis.y.normalized()
		node.global_transform.basis = node.global_transform.basis.rotated(rot_axis, delta_rad)
		selected_part["rotation_rad"] = current_rotation
		selected_part["transform"] = node.transform
		if spine_controller:
			selected_part["spine_binding"] = spine_controller.compute_surface_attachment_binding(
				node.global_position, node.global_transform.basis
			)

	if not selected_mirror_part.is_empty():
		var m_node = selected_mirror_part.get("node") as Node3D
		if is_instance_valid(m_node):
			var m_axis = Vector3.UP if is_leg else m_node.global_transform.basis.y.normalized()
			m_node.global_transform.basis = m_node.global_transform.basis.rotated(m_axis, -delta_rad)
			selected_mirror_part["rotation_rad"] = -current_rotation
			selected_mirror_part["transform"] = m_node.transform
			if spine_controller:
				selected_mirror_part["spine_binding"] = spine_controller.compute_surface_attachment_binding(
					m_node.global_position, m_node.global_transform.basis
				)

func scale_part(delta_scale: float) -> void:
	set_part_scale(current_scale + delta_scale)

func set_part_scale(new_scale: float) -> void:
	var clamped = clampf(new_scale, min_part_scale, max_part_scale)
	current_scale = clamped

	if _has_valid_hit:
		_update_preview_transforms(_last_hit_position, _last_hit_normal)

	if not selected_part.is_empty() and creature_data:
		var main_id = str(selected_part.get("id", ""))
		if creature_data.update_part_scale(main_id, current_scale):
			var node = selected_part.get("node") as Node3D
			if is_instance_valid(node):
				node.scale = Vector3.ONE * current_scale
				selected_part["transform"] = node.transform
				if spine_controller:
					selected_part["spine_binding"] = spine_controller.compute_surface_attachment_binding(
						node.global_position, node.global_transform.basis
					)

			if not selected_mirror_part.is_empty():
				var m_id = str(selected_mirror_part.get("id", ""))
				if creature_data.update_part_scale(m_id, current_scale):
					var m_node = selected_mirror_part.get("node") as Node3D
					if is_instance_valid(m_node):
						m_node.scale = Vector3.ONE * current_scale
						selected_mirror_part["transform"] = m_node.transform
						if spine_controller:
							selected_mirror_part["spine_binding"] = spine_controller.compute_surface_attachment_binding(
								m_node.global_position, m_node.global_transform.basis
							)

	_update_selection_gizmo()
	emit_signal("scale_changed", current_scale)

## Move localmente a peça selecionada ao longo do corpo (eixo Z ou Y)
func translate_selected_part_local(local_delta: Vector3) -> void:
	if selected_part.is_empty():
		return
	var node = selected_part.get("node") as Node3D
	if not is_instance_valid(node):
		return

	node.position += local_delta
	selected_part["transform"] = node.transform
	if spine_controller:
		selected_part["spine_binding"] = spine_controller.compute_surface_attachment_binding(
			node.global_position, node.global_transform.basis
		)

	if not selected_mirror_part.is_empty():
		var m_node = selected_mirror_part.get("node") as Node3D
		if is_instance_valid(m_node):
			m_node.position += Vector3(-local_delta.x, local_delta.y, local_delta.z)
			selected_mirror_part["transform"] = m_node.transform
			if spine_controller:
				selected_mirror_part["spine_binding"] = spine_controller.compute_surface_attachment_binding(
					m_node.global_position, m_node.global_transform.basis
				)

	if creature_data:
		creature_data.recalculate_stats()
	_update_selection_gizmo()

func _reposition_selected_part_to_hit(pos: Vector3, normal: Vector3) -> void:
	if selected_part.is_empty():
		return
	var node = selected_part.get("node") as Node3D
	if not is_instance_valid(node):
		return

	var s = float(selected_part.get("scale_factor", current_scale))
	var p_type = str(selected_part.get("type", "attack"))
	var xform = _align_transform_for_type(pos, normal, current_rotation, p_type)
	node.global_transform = xform
	node.scale = Vector3.ONE * s
	selected_part["surface_normal"] = normal
	selected_part["transform"] = node.transform
	if spine_controller:
		selected_part["spine_binding"] = spine_controller.compute_surface_attachment_binding(
			node.global_position, node.global_transform.basis
		)

	_compute_mirror_hit(pos, normal)
	if not selected_mirror_part.is_empty() and _has_valid_mirror_hit:
		var m_node = selected_mirror_part.get("node") as Node3D
		if is_instance_valid(m_node):
			var m_xform = _align_transform_for_type(_mirror_hit_position, _mirror_hit_normal, -current_rotation, p_type)
			m_node.global_transform = m_xform
			m_node.scale = Vector3.ONE * s
			selected_mirror_part["surface_normal"] = _mirror_hit_normal
			selected_mirror_part["transform"] = m_node.transform
			if spine_controller:
				selected_mirror_part["spine_binding"] = spine_controller.compute_surface_attachment_binding(
					m_node.global_position, m_node.global_transform.basis
				)

	if creature_data:
		creature_data.recalculate_stats()
	_update_selection_gizmo()

func clear_active_part() -> void:
	active_part_scene = null
	active_part_info = {}
	_has_valid_hit = false
	_set_preview_visible(false)
	if is_instance_valid(_preview_instance):
		_preview_instance.queue_free()
		_preview_instance = null
	if is_instance_valid(_preview_mirrored_instance):
		_preview_mirrored_instance.queue_free()
		_preview_mirrored_instance = null

# --- Configuração de Peça Ativa e Previews ---

func set_active_part(part_scene: PackedScene, info: Dictionary = {}) -> void:
	active_part_scene = part_scene
	if not info.is_empty():
		active_part_info = info
	deselect_part()
	_setup_preview_instances()

func set_symmetry(enabled: bool) -> void:
	symmetrical_mode = enabled
	if not symmetrical_mode and is_instance_valid(_preview_mirrored_instance):
		_preview_mirrored_instance.visible = false

func _setup_preview_instances() -> void:
	if is_instance_valid(_preview_instance):
		_preview_instance.queue_free()
	if is_instance_valid(_preview_mirrored_instance):
		_preview_mirrored_instance.queue_free()

	if not active_part_scene:
		return

	_preview_instance = active_part_scene.instantiate() as Node3D
	_preview_mirrored_instance = active_part_scene.instantiate() as Node3D

	var active_tag = str(active_part_info.get("tag", ""))
	if active_tag != "":
		if _preview_instance.has_method("set_appendage_variant"):
			_preview_instance.call("set_appendage_variant", active_tag)
		if _preview_mirrored_instance.has_method("set_appendage_variant"):
			_preview_mirrored_instance.call("set_appendage_variant", active_tag)

	_apply_colors_to_part(_preview_instance)
	_apply_colors_to_part(_preview_mirrored_instance)

	_disable_colliders(_preview_instance)
	_disable_colliders(_preview_mirrored_instance)

	add_child(_preview_instance)
	add_child(_preview_mirrored_instance)

	_set_preview_visible(false)

func _disable_colliders(node: Node) -> void:
	for child in node.get_children():
		if child is CollisionShape3D or child is CollisionPolygon3D:
			child.set_deferred("disabled", true)
		_disable_colliders(child)

func _apply_colors_to_part(part_node: Node3D) -> void:
	if not is_instance_valid(part_node):
		return
	if part_node.has_method("set_colors"):
		part_node.call("set_colors", current_primary_color, current_secondary_color, current_detail_color)
	else:
		if "primary_color" in part_node:
			part_node.set("primary_color", current_primary_color)
		if "secondary_color" in part_node:
			part_node.set("secondary_color", current_secondary_color)
		if "detail_color" in part_node:
			part_node.set("detail_color", current_detail_color)

func update_all_appendages_colors(p_col: Color, s_col: Color, d_col: Color) -> void:
	current_primary_color = p_col
	current_secondary_color = s_col
	current_detail_color = d_col

	_apply_colors_to_part(_preview_instance)
	_apply_colors_to_part(_preview_mirrored_instance)

	if creature_data:
		for part_info in creature_data.attached_parts:
			var node = part_info.get("node") as Node3D
			if is_instance_valid(node):
				_apply_colors_to_part(node)

## Adiciona um corpo de seleção na camada LAYER_PARTS para permitir Raycast sobre a peça anexada
func _attach_selection_collider(part_node: Node3D, part_id: String) -> void:
	var sel_body = StaticBody3D.new()
	sel_body.name = "PartSelectionBody"
	sel_body.collision_layer = LAYER_PARTS
	sel_body.collision_mask = 0
	sel_body.set_meta("part_id", part_id)

	var col_shape = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.24
	col_shape.shape = sphere
	col_shape.position = Vector3(0.0, 0.14, 0.0)

	sel_body.add_child(col_shape)
	part_node.add_child(sel_body)

func _set_preview_visible(state: bool) -> void:
	if is_instance_valid(_preview_instance):
		_preview_instance.visible = state
	if is_instance_valid(_preview_mirrored_instance):
		_preview_mirrored_instance.visible = state and symmetrical_mode and _has_valid_mirror_hit

func _get_body_static() -> StaticBody3D:
	if body_mesh:
		return body_mesh.get_node_or_null("StaticBody3D") as StaticBody3D
	return null

func _update_raycast(screen_pos: Vector2) -> void:
	if not camera or not body_mesh:
		return

	var body_static = _get_body_static()
	if not body_static:
		return

	var space_state = get_world_3d().direct_space_state
	var ray_origin = camera.project_ray_origin(screen_pos)
	var ray_dir = camera.project_ray_normal(screen_pos)
	var ray_end = ray_origin + (ray_dir * ray_length)

	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end, snap_collision_mask)
	query.hit_back_faces = true
	var result = space_state.intersect_ray(query)

	if result.is_empty() or result.collider != body_static:
		_has_valid_hit = false
		_set_preview_visible(false)
		return

	_has_valid_hit = true
	_last_hit_position = result.position
	var hit_norm: Vector3 = result.normal.normalized()
	if hit_norm.dot(ray_dir) > 0.0:
		hit_norm = -hit_norm
	_last_hit_normal = hit_norm

	_set_preview_visible(true)
	_update_preview_transforms(_last_hit_position, _last_hit_normal)

## Alinha o apêndice conforme a categoria:
## - Se for PATA ("leg"), mantém a perna SEMPRE vertical apontando para o chão (-Y) e virada para frente (+Z)!
## - Demais membros (olhos, bocas, chifres, asas, caudas) alinham-se à normal da superfície.
func _align_transform_for_type(pos: Vector3, normal: Vector3, extra_rot: float, part_type: String) -> Transform3D:
	if part_type.to_lower() == "leg":
		var t = Transform3D()
		t.origin = pos
		var base_basis = creature_root.global_transform.basis.orthonormalized() if creature_root else Basis.IDENTITY
		if abs(extra_rot) > 0.001:
			base_basis = base_basis.rotated(Vector3.UP, extra_rot)
		t.basis = base_basis
		return t
	return _align_transform(pos, normal, extra_rot)

func _align_transform(pos: Vector3, normal: Vector3, extra_rot: float) -> Transform3D:
	var t = Transform3D()
	t.origin = pos

	var norm = normal.normalized()
	var up_ref = Vector3.UP
	if abs(norm.dot(up_ref)) > 0.92:
		up_ref = Vector3.FORWARD if abs(norm.dot(Vector3.FORWARD)) < 0.9 else Vector3.RIGHT

	var x_axis = norm.cross(up_ref).normalized()
	var z_axis = x_axis.cross(norm).normalized()

	var base_basis = Basis(x_axis, norm, z_axis)
	if abs(extra_rot) > 0.001:
		base_basis = base_basis.rotated(norm, extra_rot)

	t.basis = base_basis
	return t

func _compute_mirror_hit(pos: Vector3, normal: Vector3) -> void:
	_has_valid_mirror_hit = false
	if not symmetrical_mode:
		return

	var body_static = _get_body_static()
	if not body_static:
		return

	var target_center_x = creature_root.global_position.x if creature_root else 0.0
	var rel_x = pos.x - target_center_x

	if abs(rel_x) > 0.03:
		var mirr_approx_pos = Vector3(target_center_x - rel_x, pos.y, pos.z)
		var mirr_dir = Vector3(-normal.x, normal.y, normal.z).normalized()

		var ray_start = mirr_approx_pos + mirr_dir * 3.0
		var ray_target = Vector3(target_center_x, pos.y, pos.z) - mirr_dir * 1.5
		var space_state = get_world_3d().direct_space_state
		var q = PhysicsRayQueryParameters3D.create(ray_start, ray_target, snap_collision_mask)
		q.hit_back_faces = true
		var mirr_res = space_state.intersect_ray(q)

		# Fallback lateral direto caso a normal seja muito inclinada
		if mirr_res.is_empty() or mirr_res.collider != body_static:
			var side_sign = -signf(rel_x)
			var lat_start = Vector3(target_center_x + side_sign * 3.5, pos.y, pos.z)
			var lat_target = Vector3(target_center_x - side_sign * 0.5, pos.y, pos.z)
			var q_lat = PhysicsRayQueryParameters3D.create(lat_start, lat_target, snap_collision_mask)
			q_lat.hit_back_faces = true
			mirr_res = space_state.intersect_ray(q_lat)

		if not mirr_res.is_empty() and mirr_res.collider == body_static:
			_has_valid_mirror_hit = true
			_mirror_hit_position = mirr_res.position
			_mirror_hit_normal = mirr_res.normal.normalized()

func _update_preview_transforms(pos: Vector3, normal: Vector3) -> void:
	if not is_instance_valid(_preview_instance):
		return

	var active_type = str(active_part_info.get("type", "attack"))
	var main_xform = _align_transform_for_type(pos, normal, current_rotation, active_type)
	_preview_instance.global_transform = main_xform
	_preview_instance.scale = Vector3.ONE * current_scale

	_compute_mirror_hit(pos, normal)
	if symmetrical_mode and is_instance_valid(_preview_mirrored_instance):
		if _has_valid_mirror_hit:
			var mirror_xform = _align_transform_for_type(_mirror_hit_position, _mirror_hit_normal, -current_rotation, active_type)
			_preview_mirrored_instance.global_transform = mirror_xform
			_preview_mirrored_instance.scale = Vector3.ONE * current_scale
			_preview_mirrored_instance.visible = true
		else:
			_preview_mirrored_instance.visible = false
	elif is_instance_valid(_preview_mirrored_instance):
		_preview_mirrored_instance.visible = false

func _confirm_attachment() -> void:
	if not active_part_scene or not creature_root or not _has_valid_hit:
		return

	var p_type = str(active_part_info.get("type", "attack"))
	var p_cat = str(active_part_info.get("category", p_type))
	var p_tag = str(active_part_info.get("tag", ""))
	var p_name = str(active_part_info.get("name", "Membro"))
	var cost = CreatureData.calculate_part_cost(p_cat, current_scale)

	if not creature_data.can_afford(cost):
		return

	var parent_target = creature_root
	var base_id = "part_%d_%d" % [Time.get_ticks_msec(), creature_data.attached_parts.size()]
	var mirror_id = base_id + "_mirror"
	var will_mirror = symmetrical_mode and _has_valid_mirror_hit and creature_data.can_afford(cost * 2)

	# 1. Instancia parte principal
	var part = active_part_scene.instantiate() as Node3D
	parent_target.add_child(part)
	if p_tag != "" and part.has_method("set_appendage_variant"):
		part.call("set_appendage_variant", p_tag)
	_apply_colors_to_part(part)
	part.global_transform = _preview_instance.global_transform
	part.scale = Vector3.ONE * current_scale
	_attach_selection_collider(part, base_id)

	var binding: Dictionary = {}
	if spine_controller:
		binding = spine_controller.compute_surface_attachment_binding(
			part.global_position, part.global_transform.basis
		)

	var main_dict = {
		"id": base_id,
		"pair_id": mirror_id if will_mirror else "",
		"node": part,
		"name": p_name,
		"type": p_type,
		"category": p_cat,
		"tag": p_tag,
		"scene_path": active_part_scene.resource_path,
		"transform": part.transform,
		"scale_factor": current_scale,
		"rotation_rad": current_rotation,
		"surface_normal": _last_hit_normal,
		"spine_binding": binding,
		"cost": cost,
		"mass": float(active_part_info.get("mass", 0.8)),
		"base_damage": float(active_part_info.get("base_damage", 0.0)),
		"leg_force": float(active_part_info.get("leg_force", 0.0)),
		"wing_area": float(active_part_info.get("wing_area", 0.0)),
		"carapace_defense": float(active_part_info.get("carapace_defense", 0.0)),
		"is_mirrored": false
	}
	creature_data.add_part(main_dict)
	emit_signal("part_attached", part)

	# 2. Instancia parte espelhada se houver superfície válida e biomassa
	var mirror_dict: Dictionary = {}
	if will_mirror:
		var mirror_part = active_part_scene.instantiate() as Node3D
		parent_target.add_child(mirror_part)
		if p_tag != "" and mirror_part.has_method("set_appendage_variant"):
			mirror_part.call("set_appendage_variant", p_tag)
		_apply_colors_to_part(mirror_part)
		mirror_part.global_transform = _preview_mirrored_instance.global_transform
		mirror_part.scale = Vector3.ONE * current_scale
		_attach_selection_collider(mirror_part, mirror_id)

		var mirror_binding: Dictionary = {}
		if spine_controller:
			mirror_binding = spine_controller.compute_surface_attachment_binding(
				mirror_part.global_position, mirror_part.global_transform.basis
			)

		mirror_dict = {
			"id": mirror_id,
			"pair_id": base_id,
			"node": mirror_part,
			"name": p_name + " (Espelho)",
			"type": p_type,
			"category": p_cat,
			"tag": p_tag,
			"scene_path": active_part_scene.resource_path,
			"transform": mirror_part.transform,
			"scale_factor": current_scale,
			"rotation_rad": -current_rotation,
			"surface_normal": _mirror_hit_normal,
			"spine_binding": mirror_binding,
			"cost": cost,
			"mass": float(active_part_info.get("mass", 0.8)),
			"base_damage": float(active_part_info.get("base_damage", 0.0)),
			"leg_force": float(active_part_info.get("leg_force", 0.0)),
			"wing_area": float(active_part_info.get("wing_area", 0.0)),
			"carapace_defense": float(active_part_info.get("carapace_defense", 0.0)),
			"is_mirrored": true
		}
		creature_data.add_part(mirror_dict)
		emit_signal("part_attached", mirror_part)

	# Conforme solicitado: após o apêndice ser colocado, finaliza a colocação
	# e limpa a seleção para que seu ângulo não mude acidentalmente até que
	# o jogador clique nele expressamente!
	clear_active_part()
	deselect_part()

## Reconstrói um membro a partir de dados desserializados (usado pelo CreatureSerializer.gd)
func reconstruct_part_from_dict(part_data: Dictionary) -> Node3D:
	if not creature_root or not creature_data:
		return null
	var scene_path = str(part_data.get("scene_path", ""))
	if scene_path == "" or not ResourceLoader.exists(scene_path):
		return null

	var packed = load(scene_path) as PackedScene
	if not packed:
		return null

	var part = packed.instantiate() as Node3D
	creature_root.add_child(part)
	var p_tag = str(part_data.get("tag", ""))
	if p_tag != "" and part.has_method("set_appendage_variant"):
		part.call("set_appendage_variant", p_tag)
	_apply_colors_to_part(part)

	var xform: Transform3D = part_data.get("transform", Transform3D.IDENTITY)
	var scale_f = float(part_data.get("scale_factor", 1.0))
	part.transform = xform
	part.scale = Vector3.ONE * scale_f

	var part_id = str(part_data.get("id", "part_%d" % Time.get_ticks_msec()))
	part_data["id"] = part_id
	part_data["node"] = part
	_attach_selection_collider(part, part_id)

	if spine_controller and part_data.get("spine_binding", {}).is_empty():
		part_data["spine_binding"] = spine_controller.compute_surface_attachment_binding(
			part.global_position, part.global_transform.basis
		)

	creature_data.add_part(part_data)
	emit_signal("part_attached", part)
	return part

## Atualiza a posição e rotação de todos os apêndices quando a coluna é movida/esculpida
func update_attached_parts_on_spine() -> void:
	if not spine_controller or not creature_data:
		return

	for part_info in creature_data.attached_parts:
		var node = part_info.get("node") as Node3D
		var binding: Dictionary = part_info.get("spine_binding", {})
		var scale_f = float(part_info.get("scale_factor", 1.0))
		var p_type = str(part_info.get("type", "attack"))
		if is_instance_valid(node) and not binding.is_empty():
			var eval_xform = spine_controller.evaluate_surface_attachment_transform(binding)
			if p_type.to_lower() == "leg":
				var rot_rad = float(part_info.get("rotation_rad", 0.0))
				var surf_norm: Vector3 = part_info.get("surface_normal", Vector3.DOWN)
				node.global_transform = _align_transform_for_type(eval_xform.origin, surf_norm, rot_rad, "leg")
			else:
				node.global_transform = eval_xform
				part_info["surface_normal"] = node.global_transform.basis.y.normalized()
			node.scale = Vector3.ONE * scale_f
			part_info["transform"] = node.transform

	creature_data.recalculate_stats()
	_update_selection_gizmo()

func clear_all_attached_parts() -> void:
	if not creature_root or not creature_data:
		return
	for part_data in creature_data.attached_parts:
		var node = part_data.get("node") as Node3D
		if is_instance_valid(node):
			node.queue_free()
	deselect_part()
	creature_data.clear_all_parts()
