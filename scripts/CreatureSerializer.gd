class_name CreatureSerializer
extends Node

## PILAR 4: Sistema de Serialização e Persistência da Criatura em JSON (Save / Load).
## Salva e reconstrói integralmente:
## 1. Estrutura de nós da coluna (posições 3D, raios/diâmetros, tamanhos)
## 2. Cores e parâmetros do Shader Triplanar / SSS da pele
## 3. Lista de membros anexados (cena, Transform3D local, escala, rotação, tag anatômica, custos)
## 4. Atributos finais (HP, STR, AGL, SPD, Biomassa) e atalhos da Hotbar (Q, E, R, F, V)

signal creature_saved(file_path: String, success: bool)
signal creature_loaded(file_path: String, success: bool)

const DEFAULT_SAVE_PATH: String = "user://saved_creature.json"
const TOTAL_SLOTS: int = 15

@export var spine_manager: SpineManager
@export var attachment_system: AttachmentSystem
@export var creature_data: CreatureData
@export var body_mesh: MeshInstance3D
@export var skill_factory: SkillFactory

static func get_slot_path(slot_index: int) -> String:
	return "user://creature_slot_%02d.json" % slot_index

## Salva a criatura em um slot específico (1 a 15) com nome personalizado
func save_creature_to_slot(slot_index: int, creature_name: String = "") -> bool:
	var path = get_slot_path(slot_index)
	var default_name = "Criatura Slot %02d" % slot_index
	var name_to_save = creature_name.strip_edges()
	if name_to_save.is_empty():
		name_to_save = default_name
	return save_creature_to_json(path, name_to_save)

## Carrega a criatura salva em um slot específico (1 a 15)
func load_creature_from_slot(slot_index: int) -> bool:
	var path = get_slot_path(slot_index)
	return load_creature_from_json(path)

## Remove o arquivo de salvamento de um slot específico
func delete_slot(slot_index: int) -> bool:
	var path = get_slot_path(slot_index)
	if FileAccess.file_exists(path):
		var err = DirAccess.remove_absolute(path)
		return err == OK
	return false

## Retorna metadados resumidos de um slot para exibição na UI
func get_slot_info(slot_index: int) -> Dictionary:
	var path = get_slot_path(slot_index)
	if not FileAccess.file_exists(path):
		return {
			"exists": false,
			"slot": slot_index,
			"name": "Slot %02d [Vazio]" % slot_index,
			"timestamp": "",
			"health": 0.0,
			"strength": 0.0,
			"speed": 0.0,
			"agility": 0.0,
			"parts_count": 0,
			"vertebrae_count": 0,
			"biomass_used": 0,
			"locomotion_valid": false
		}

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {
			"exists": false,
			"slot": slot_index,
			"name": "Slot %02d [Erro]" % slot_index,
			"timestamp": "",
			"health": 0.0,
			"strength": 0.0,
			"speed": 0.0,
			"agility": 0.0,
			"parts_count": 0,
			"vertebrae_count": 0,
			"biomass_used": 0,
			"locomotion_valid": false
		}

	var json_str = file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(json_str)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {
			"exists": false,
			"slot": slot_index,
			"name": "Slot %02d [Inválido]" % slot_index,
			"timestamp": "",
			"health": 0.0,
			"strength": 0.0,
			"speed": 0.0,
			"agility": 0.0,
			"parts_count": 0,
			"vertebrae_count": 0,
			"biomass_used": 0,
			"locomotion_valid": false
		}

	var stats: Dictionary = parsed.get("final_stats", {})
	var parts: Array = parsed.get("attached_parts", [])
	var spine: Array = parsed.get("spine_vertebrae", [])
	var c_name: String = str(parsed.get("creature_name", "Criatura %02d" % slot_index))
	var t_stamp: String = str(parsed.get("timestamp", ""))

	return {
		"exists": true,
		"slot": slot_index,
		"name": c_name,
		"timestamp": t_stamp,
		"health": float(stats.get("health", 100.0)),
		"strength": float(stats.get("strength", 10.0)),
		"speed": float(stats.get("speed", 0.0)),
		"agility": float(stats.get("agility", 0.0)),
		"parts_count": parts.size(),
		"vertebrae_count": spine.size(),
		"biomass_used": 100 - int(stats.get("current_biomass", 100)),
		"locomotion_valid": bool(stats.get("locomotion_valid", false))
	}

## Retorna lista completa dos 15 slots
func get_all_slots_info() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	for i in range(1, TOTAL_SLOTS + 1):
		list.append(get_slot_info(i))
	return list

## Salva todos os dados da criatura em formato JSON estruturado
func save_creature_to_json(file_path: String = DEFAULT_SAVE_PATH, creature_name: String = "Criatura") -> bool:
	if not spine_manager or not creature_data:
		push_error("CreatureSerializer: Referências de spine_manager ou creature_data ausentes.")
		emit_signal("creature_saved", file_path, false)
		return false

	# 1. Serializa vértebras da coluna
	var spine_list: Array = []
	for v in spine_manager.vertebrae:
		var pos: Vector3 = v.get("pos", Vector3.ZERO)
		var rad: float = float(v.get("radius", 0.45))
		spine_list.append({
			"pos": _vec3_to_array(pos),
			"radius": rad,
			"diameter": rad * 2.0,
			"base_radius": float(v.get("base_radius", rad)),
			"size": float(v.get("size", 1.0))
		})

	# 2. Serializa parâmetros do Shader de pele
	var skin_data: Dictionary = _serialize_skin_shader()

	# 3. Serializa todas as partes anexadas
	var parts_list: Array = []
	for part in creature_data.attached_parts:
		var node = part.get("node") as Node3D
		var local_xform: Transform3D = node.transform if is_instance_valid(node) else part.get("transform", Transform3D.IDENTITY)
		var surf_norm: Vector3 = part.get("surface_normal", Vector3.UP)
		var binding: Dictionary = part.get("spine_binding", {})
		var serialized_bind: Dictionary = {}
		if not binding.is_empty():
			serialized_bind = {
				"spine_u": float(binding.get("spine_u", 0.5)),
				"seg_idx": int(binding.get("seg_idx", 0)),
				"seg_t": float(binding.get("seg_t", 0.5)),
				"normalized_offset": _vec3_to_array(binding.get("normalized_offset", Vector3.UP)),
				"relative_basis": _basis_to_dict(binding.get("relative_basis", Basis.IDENTITY))
			}

		parts_list.append({
			"id": str(part.get("id", "")),
			"pair_id": str(part.get("pair_id", "")),
			"name": str(part.get("name", "Membro")),
			"type": str(part.get("type", "attack")),
			"category": str(part.get("category", "attack")),
			"tag": str(part.get("tag", "")),
			"scene_path": str(part.get("scene_path", "")),
			"transform": _transform_to_dict(local_xform),
			"scale_factor": float(part.get("scale_factor", 1.0)),
			"rotation_rad": float(part.get("rotation_rad", 0.0)),
			"surface_normal": _vec3_to_array(surf_norm),
			"spine_binding": serialized_bind,
			"cost": int(part.get("cost", 0)),
			"mass": float(part.get("mass", 0.8)),
			"base_damage": float(part.get("base_damage", 0.0)),
			"leg_force": float(part.get("leg_force", 0.0)),
			"wing_area": float(part.get("wing_area", 0.0)),
			"carapace_defense": float(part.get("carapace_defense", 0.0)),
			"is_mirrored": bool(part.get("is_mirrored", false))
		})

	# 4. Serializa atributos finais e Hotbar
	var final_stats: Dictionary = {
		"max_biomass": creature_data.max_biomass,
		"current_biomass": creature_data.current_biomass,
		"health": snappedf(creature_data.health, 0.01),
		"strength": snappedf(creature_data.strength, 0.01),
		"agility": snappedf(creature_data.agility, 0.01),
		"speed": snappedf(creature_data.speed, 0.01),
		"total_mass": snappedf(creature_data.total_mass, 0.01),
		"knockback_multiplier": snappedf(creature_data.knockback_multiplier, 0.01),
		"locomotion_valid": creature_data.locomotion_valid
	}

	var payload: Dictionary = {
		"version": "1.0",
		"creature_name": creature_name,
		"timestamp": Time.get_datetime_string_from_system(),
		"spine_vertebrae": spine_list,
		"skin_shader": skin_data,
		"attached_parts": parts_list,
		"final_stats": final_stats,
		"hotbar_slots": skill_factory.serialize_hotbar() if skill_factory else {}
	}

	var json_text = JSON.stringify(payload, "\t")
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("CreatureSerializer: Falha ao abrir arquivo para escrita: %s" % file_path)
		emit_signal("creature_saved", file_path, false)
		return false

	file.store_string(json_text)
	file.close()

	emit_signal("creature_saved", file_path, true)
	return true

## Carrega os dados de um arquivo JSON e reconstrói a criatura inteira em tempo real
func load_creature_from_json(file_path: String = DEFAULT_SAVE_PATH) -> bool:
	var target_path = file_path
	if not FileAccess.file_exists(target_path):
		if file_path == DEFAULT_SAVE_PATH and FileAccess.file_exists("res://saved_creature.json"):
			target_path = "res://saved_creature.json"
		else:
			push_warning("CreatureSerializer: Arquivo não encontrado: %s" % file_path)
			emit_signal("creature_loaded", file_path, false)
			return false

	var file = FileAccess.open(target_path, FileAccess.READ)
	if not file:
		emit_signal("creature_loaded", target_path, false)
		return false

	var json_text = file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(json_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("CreatureSerializer: JSON inválido em %s" % target_path)
		emit_signal("creature_loaded", target_path, false)
		return false

	var data: Dictionary = parsed

	# 1. Limpa membros atuais antes de reconstruir
	if attachment_system:
		attachment_system.clear_all_attached_parts()
	elif creature_data:
		creature_data.clear_all_parts()

	# 2. Reconstrói a espinha dorsal e malha procedural
	var spine_list: Array = data.get("spine_vertebrae", [])
	if spine_manager and spine_list.size() >= SpineManager.MIN_VERTEBRAE:
		spine_manager.vertebrae.clear()
		for v_dict in spine_list:
			if typeof(v_dict) == TYPE_DICTIONARY:
				var pos = _array_to_vec3(v_dict.get("pos", [0.0, 0.2, 0.0]))
				var rad = clampf(float(v_dict.get("radius", 0.45)), spine_manager.min_radius, spine_manager.max_radius)
				var base_r = float(v_dict.get("base_radius", rad))
				var sz = clampf(float(v_dict.get("size", 1.0)), spine_manager.min_vertebra_size, spine_manager.max_vertebra_size)
				spine_manager.vertebrae.append({
					"pos": pos,
					"radius": rad,
					"base_radius": base_r,
					"size": sz
				})
		spine_manager._rebuild_gizmos()
		spine_manager._sync_spine_biomass()
		spine_manager.generate_mesh(true)
		spine_manager.emit_signal("spine_modified")

	# 3. Aplica configurações do Shader de pele
	var skin_data: Dictionary = data.get("skin_shader", {})
	if not skin_data.is_empty():
		_deserialize_skin_shader(skin_data)

	# 4. Reinstancia todos os membros anexados nos pontos exatos
	var parts_list: Array = data.get("attached_parts", [])
	if attachment_system:
		for p_raw in parts_list:
			if typeof(p_raw) != TYPE_DICTIONARY:
				continue
			var raw_bind: Dictionary = p_raw.get("spine_binding", {})
			var deserialized_bind: Dictionary = {}
			if not raw_bind.is_empty():
				deserialized_bind = {
					"spine_u": float(raw_bind.get("spine_u", 0.5)),
					"seg_idx": int(raw_bind.get("seg_idx", 0)),
					"seg_t": float(raw_bind.get("seg_t", 0.5)),
					"normalized_offset": _array_to_vec3(raw_bind.get("normalized_offset", [0.0, 1.0, 0.0])),
					"relative_basis": _dict_to_basis(raw_bind.get("relative_basis", {}))
				}

			var p_dict: Dictionary = {
				"id": str(p_raw.get("id", "part_%d" % Time.get_ticks_msec())),
				"pair_id": str(p_raw.get("pair_id", "")),
				"name": str(p_raw.get("name", "Membro")),
				"type": str(p_raw.get("type", "attack")),
				"category": str(p_raw.get("category", "attack")),
				"tag": str(p_raw.get("tag", "")),
				"scene_path": str(p_raw.get("scene_path", "")),
				"transform": _dict_to_transform(p_raw.get("transform", {})),
				"scale_factor": float(p_raw.get("scale_factor", 1.0)),
				"rotation_rad": float(p_raw.get("rotation_rad", 0.0)),
				"surface_normal": _array_to_vec3(p_raw.get("surface_normal", [0.0, 1.0, 0.0])),
				"spine_binding": deserialized_bind,
				"cost": int(p_raw.get("cost", 6)),
				"mass": float(p_raw.get("mass", 0.8)),
				"base_damage": float(p_raw.get("base_damage", 0.0)),
				"leg_force": float(p_raw.get("leg_force", 0.0)),
				"wing_area": float(p_raw.get("wing_area", 0.0)),
				"carapace_defense": float(p_raw.get("carapace_defense", 0.0)),
				"is_mirrored": bool(p_raw.get("is_mirrored", false))
			}
			attachment_system.reconstruct_part_from_dict(p_dict)

	# 5. Restaura mapeamento da Hotbar de Habilidades (Q, E, R, F, V)
	var hotbar_map: Dictionary = data.get("hotbar_slots", {})
	if skill_factory:
		skill_factory.deserialize_hotbar(hotbar_map)

	if creature_data:
		creature_data.recalculate_stats()

	emit_signal("creature_loaded", target_path, true)
	return true

# --- Helpers de Serialização de Shader e Matemática 3D ---

func _serialize_skin_shader() -> Dictionary:
	var result = {
		"base_color": [0.85, 0.45, 0.35, 1.0],
		"secondary_color": [0.30, 0.15, 0.10, 1.0],
		"texture_scale": 2.0,
		"sss_strength": 0.3,
		"sss_translucency": 0.25,
		"skin_pattern_type": 0,
		"roughness": 0.5,
		"normal_scale": 1.0
	}
	if body_mesh and body_mesh.has_method("get_creature_material"):
		var mat: ShaderMaterial = body_mesh.call("get_creature_material")
		if mat:
			var bc = mat.get_shader_parameter("base_color")
			if typeof(bc) == TYPE_COLOR:
				result["base_color"] = [bc.r, bc.g, bc.b, bc.a]
			var sc = mat.get_shader_parameter("secondary_color")
			if typeof(sc) == TYPE_COLOR:
				result["secondary_color"] = [sc.r, sc.g, sc.b, sc.a]
			var ts = mat.get_shader_parameter("texture_scale")
			if ts != null:
				result["texture_scale"] = float(ts)
			var sss = mat.get_shader_parameter("sss_strength")
			if sss != null:
				result["sss_strength"] = float(sss)
			var spt = mat.get_shader_parameter("skin_pattern_type")
			if spt != null:
				result["skin_pattern_type"] = int(spt)
			var rough = mat.get_shader_parameter("roughness")
			if rough != null:
				result["roughness"] = float(rough)
			var norm = mat.get_shader_parameter("normal_scale")
			if norm != null:
				result["normal_scale"] = float(norm)
	return result

func _deserialize_skin_shader(skin_data: Dictionary) -> void:
	if not body_mesh:
		return
	var bc_arr: Array = skin_data.get("base_color", [0.85, 0.45, 0.35, 1.0])
	var sc_arr: Array = skin_data.get("secondary_color", [0.30, 0.15, 0.10, 1.0])
	var tex_scale: float = float(skin_data.get("texture_scale", 2.0))
	var sss_str: float = float(skin_data.get("sss_strength", 0.3))
	var sss_trans: float = float(skin_data.get("sss_translucency", 0.25))
	var pattern_type: int = int(skin_data.get("skin_pattern_type", 0))
	var rough: float = float(skin_data.get("roughness", 0.5))
	var norm_scale: float = float(skin_data.get("normal_scale", 1.0))

	var bc = _array_to_color(bc_arr)
	var sc = _array_to_color(sc_arr)

	if body_mesh.has_method("set_base_color"):
		body_mesh.call("set_base_color", bc)
	if body_mesh.has_method("set_secondary_color"):
		body_mesh.call("set_secondary_color", sc)
	if body_mesh.has_method("set_texture_scale"):
		body_mesh.call("set_texture_scale", tex_scale)
	if body_mesh.has_method("set_sss_properties"):
		body_mesh.call("set_sss_properties", bc, sss_str, sss_trans)
	if body_mesh.has_method("set_skin_pattern"):
		body_mesh.call("set_skin_pattern", pattern_type)
	if body_mesh.has_method("set_roughness"):
		body_mesh.call("set_roughness", rough)
	if body_mesh.has_method("set_normal_scale"):
		body_mesh.call("set_normal_scale", norm_scale)

static func _vec3_to_array(v: Vector3) -> Array:
	return [snappedf(v.x, 0.0001), snappedf(v.y, 0.0001), snappedf(v.z, 0.0001)]

static func _array_to_vec3(arr: Variant) -> Vector3:
	if typeof(arr) == TYPE_ARRAY and arr.size() >= 3:
		return Vector3(float(arr[0]), float(arr[1]), float(arr[2]))
	return Vector3.ZERO

static func _array_to_color(arr: Variant) -> Color:
	if typeof(arr) == TYPE_ARRAY and arr.size() >= 3:
		var a = float(arr[3]) if arr.size() >= 4 else 1.0
		return Color(float(arr[0]), float(arr[1]), float(arr[2]), a)
	return Color.WHITE

static func _transform_to_dict(t: Transform3D) -> Dictionary:
	return {
		"origin": _vec3_to_array(t.origin),
		"basis_x": _vec3_to_array(t.basis.x),
		"basis_y": _vec3_to_array(t.basis.y),
		"basis_z": _vec3_to_array(t.basis.z)
	}

static func _dict_to_transform(d: Variant) -> Transform3D:
	if typeof(d) != TYPE_DICTIONARY:
		return Transform3D.IDENTITY
	var origin = _array_to_vec3(d.get("origin", [0.0, 0.0, 0.0]))
	var bx = _array_to_vec3(d.get("basis_x", [1.0, 0.0, 0.0]))
	var by = _array_to_vec3(d.get("basis_y", [0.0, 1.0, 0.0]))
	var bz = _array_to_vec3(d.get("basis_z", [0.0, 0.0, 1.0]))
	return Transform3D(Basis(bx, by, bz), origin)

static func _basis_to_dict(b: Basis) -> Dictionary:
	return {
		"x": _vec3_to_array(b.x),
		"y": _vec3_to_array(b.y),
		"z": _vec3_to_array(b.z)
	}

static func _dict_to_basis(d: Variant) -> Basis:
	if typeof(d) != TYPE_DICTIONARY:
		return Basis.IDENTITY
	var bx = _array_to_vec3(d.get("x", [1.0, 0.0, 0.0]))
	var by = _array_to_vec3(d.get("y", [0.0, 1.0, 0.0]))
	var bz = _array_to_vec3(d.get("z", [0.0, 0.0, 1.0]))
	return Basis(bx, by, bz)

