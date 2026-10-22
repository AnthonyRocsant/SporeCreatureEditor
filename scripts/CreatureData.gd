class_name CreatureData
extends Resource

## PILAR 2: Matemática de Biomassa, Atributos, Trava de Validação de Locomoção
## e Penalidades Anti-Abuso (Divisão de Dano por sqrt(N) e Instabilidade do CoM).

signal biomass_changed(current: int, max_val: int)
signal stats_updated(health: float, strength: float, speed: float)
signal extended_stats_updated(hp: float, str_val: float, agl: float, spd: float, knockback_mult: float)
signal locomotion_validation_changed(is_valid: bool, error_message: String)
signal part_added(part_data: Dictionary)
signal part_removed(part_id: String)
signal parts_changed()

const COST_LEG: int = 8
const COST_WING: int = 12
const COST_ATTACK: int = 6
const COST_TAIL_SUPPORT: int = 7
const COST_EYE_SENSORY: int = 2
const K_LOCOMOTION: float = 18.0
const INVALID_LOCOMOTION_MSG: String = "⚠️ Locomoção Terrestre Inválida: Reposicione as patas no plano do solo"

@export var max_biomass: int = 100
@export var current_biomass: int = 100

# Métricas vindas da coluna vertebral (SpineManager)
var spine_biomass_cost: int = 0
var spine_mass: float = 8.0
var thorax_mass: float = 4.0
var spine_com: Vector3 = Vector3(0.0, 1.0, 0.0)

# Atributos Finais Calculados
var health: float = 100.0
var strength: float = 10.0
var agility: float = 0.0
var speed: float = 0.0

# Métricas Físicas e Anti-Abuso
var total_mass: float = 8.0
var center_of_mass: Vector3 = Vector3(0.0, 1.0, 0.0)
var support_center: Vector3 = Vector3.ZERO
var com_deviation: float = 0.0
var knockback_multiplier: float = 1.0

# Validação de Locomoção Terrestre
var valid_ground_contacts: int = 0
var locomotion_valid: bool = false
var locomotion_error_message: String = INVALID_LOCOMOTION_MSG

## Lista de partes anexadas:
## [{
##   "id": String, "node": Node3D, "type": String, "category": String, "tag": String,
##   "scene_path": String, "transform": Transform3D, "scale_factor": float, "rotation_rad": float,
##   "cost": int, "mass": float, "base_damage": float, "leg_force": float, "wing_area": float,
##   "carapace_defense": float, "surface_normal": Vector3, "is_mirrored": bool, "pair_id": String
## }]
@export var attached_parts: Array[Dictionary] = []

## Calcula o custo oficial pela Tabela do Pilar 2
static func calculate_part_cost(category: String, scale_factor: float = 1.0) -> int:
	var scale_extra = maxi(0, int(round((scale_factor - 1.0) * 4.0)))
	match category.to_lower():
		"leg":
			return COST_LEG + scale_extra
		"wing":
			return COST_WING + scale_extra
		"attack":
			return COST_ATTACK + scale_extra
		"tail", "support":
			return COST_TAIL_SUPPORT + scale_extra
		"eye", "sensory":
			return COST_EYE_SENSORY
		_:
			return COST_ATTACK + scale_extra

func get_used_parts_biomass() -> int:
	var used: int = 0
	for p in attached_parts:
		used += int(p.get("cost", 0))
	return used

func _recompute_available_biomass() -> void:
	var total_used = spine_biomass_cost + get_used_parts_biomass()
	current_biomass = maxi(0, max_biomass - total_used)
	emit_signal("biomass_changed", current_biomass, max_biomass)

func can_afford(cost: int) -> bool:
	return current_biomass >= cost

func set_spine_metrics(cost: int, s_mass: float, t_mass: float, s_com: Vector3) -> void:
	spine_biomass_cost = maxi(0, cost)
	spine_mass = maxf(1.0, s_mass)
	thorax_mass = maxf(0.5, t_mass)
	spine_com = s_com
	_recompute_available_biomass()
	recalculate_stats()

func add_part(part_data: Dictionary) -> bool:
	var category = str(part_data.get("category", part_data.get("type", "attack")))
	var scale_f = float(part_data.get("scale_factor", 1.0))
	var cost = int(part_data.get("cost", calculate_part_cost(category, scale_f)))
	part_data["cost"] = cost

	if not can_afford(cost):
		push_warning("Biomassa insuficiente! Custo: %d | Disponível: %d" % [cost, current_biomass])
		return false

	attached_parts.append(part_data)
	_recompute_available_biomass()
	recalculate_stats()

	emit_signal("part_added", part_data)
	emit_signal("parts_changed")
	return true

func remove_part(part_id: String) -> bool:
	for i in range(attached_parts.size()):
		if attached_parts[i].get("id") == part_id:
			attached_parts.remove_at(i)
			_recompute_available_biomass()
			recalculate_stats()
			emit_signal("part_removed", part_id)
			emit_signal("parts_changed")
			return true
	return false

func update_part_scale(part_id: String, new_scale: float) -> bool:
	for part in attached_parts:
		if part.get("id") == part_id:
			var category = str(part.get("category", part.get("type", "attack")))
			var old_cost = int(part.get("cost", 0))
			var new_cost = calculate_part_cost(category, new_scale)
			if new_cost > old_cost and not can_afford(new_cost - old_cost):
				return false
			part["scale_factor"] = new_scale
			part["cost"] = new_cost
			_recompute_available_biomass()
			recalculate_stats()
			emit_signal("parts_changed")
			return true
	return false

func recalculate_stats() -> void:
	# 1. Cálculo de Massa Total e Centro de Massa (CoM)
	var sum_mass = spine_mass
	var weighted_com = spine_com * spine_mass
	var sum_carapace_def: float = 0.0
	var sum_wing_area: float = 0.0
	var sum_leg_force: float = 0.0

	var attack_parts: Array[Dictionary] = []
	var support_points: Array[Vector3] = []

	for part in attached_parts:
		var scale_f = float(part.get("scale_factor", 1.0))
		var p_mass = float(part.get("mass", 0.8)) * scale_f
		sum_mass += p_mass

		var p_pos = _get_part_world_pos(part)
		weighted_com += p_pos * p_mass

		# Defesa de carapaças/suporte
		sum_carapace_def += float(part.get("carapace_defense", 0.0)) * scale_f

		# Área das asas
		var p_type = str(part.get("type", "")).to_lower()
		var p_cat = str(part.get("category", p_type)).to_lower()
		if p_type == "wing" or p_cat == "wing":
			sum_wing_area += float(part.get("wing_area", 1.8)) * (scale_f * scale_f)

		# Membros de ataque (para divisão anti-abuso por sqrt(N))
		var base_dmg = float(part.get("base_damage", 0.0))
		if base_dmg > 0.0:
			attack_parts.append(part)

		# Validação individual de Pata como ponto de apoio funcional no plano do solo
		if p_type == "leg" or p_cat == "leg":
			if _is_leg_functional_ground_support(part, p_pos):
				support_points.append(p_pos)
				sum_leg_force += float(part.get("leg_force", 3.5)) * scale_f

	total_mass = maxf(1.0, sum_mass)
	center_of_mass = weighted_com / total_mass

	# 2. Fórmula de HP: HP = (MassaTotal * 12) + Sum(DefesaCarapaças)
	health = (total_mass * 12.0) + sum_carapace_def

	# 3. Fórmula de STR com Divisão Anti-Abuso:
	# Dano_Membro = DanoBase / sqrt(N_membros)
	# STR = Sum(Dano_Membro * Scale) + (MassaTórax * 0.5)
	var n_attack = attack_parts.size()
	var sum_damage: float = 0.0
	if n_attack > 0:
		var penalty_div = sqrt(float(n_attack))
		for atk in attack_parts:
			var d_base = float(atk.get("base_damage", 0.0))
			var s_factor = float(atk.get("scale_factor", 1.0))
			var adjusted_member_dmg = d_base / penalty_div
			sum_damage += adjusted_member_dmg * s_factor
	strength = sum_damage + (thorax_mass * 0.5)

	# 4. Fórmula de AGL: AGL = (ÁreaAsas / MassaTotal) * 100
	agility = (sum_wing_area / total_mass) * 100.0

	# 5. Trava de Validação de Locomoção Terrestre (mínimo 2 apoios funcionais no plano do solo)
	valid_ground_contacts = support_points.size()
	if valid_ground_contacts >= 2:
		locomotion_valid = true
		locomotion_error_message = ""
		# SPD = (Sum(ForçaPatas) / MassaTotal) * k_locomoção
		speed = (sum_leg_force / total_mass) * K_LOCOMOTION

		# Cálculo de estabilidade do Centro de Massa (CoM) em relação aos apoios
		var avg_support = Vector3.ZERO
		for pt in support_points:
			avg_support += pt
		avg_support /= float(valid_ground_contacts)
		support_center = avg_support

		var com_xz = Vector2(center_of_mass.x, center_of_mass.z)
		var sup_xz = Vector2(support_center.x, support_center.z)
		com_deviation = com_xz.distance_to(sup_xz)
		# Multiplicador de knockback se o CoM estiver desequilibrado
		knockback_multiplier = 1.0 + maxf(0.0, com_deviation - 0.20) * 2.5
	else:
		locomotion_valid = false
		locomotion_error_message = INVALID_LOCOMOTION_MSG
		speed = 0.0
		com_deviation = 1.0
		knockback_multiplier = 2.5

	emit_signal("locomotion_validation_changed", locomotion_valid, locomotion_error_message)
	emit_signal("stats_updated", health, strength, speed)
	emit_signal("extended_stats_updated", health, strength, agility, speed, knockback_multiplier)

## Verifica se uma pata está em posição funcional de apoio terrestre
## (não pode estar nas costas nem virada para cima)
func _is_leg_functional_ground_support(part: Dictionary, world_pos: Vector3) -> bool:
	var surf_normal: Vector3 = part.get("surface_normal", Vector3.DOWN)
	var node = part.get("node") as Node3D
	if is_instance_valid(node) and not part.has("surface_normal"):
		surf_normal = node.global_transform.basis.y.normalized()

	# Se a normal da superfície onde a pata foi colocada aponta para o topo/costas (> 0.65),
	# a pata foi colocada no dorso ou virada para cima -> Inválida!
	if surf_normal.y > 0.65:
		return false

	# Se a pata estiver muito acima da linha dorsal da coluna (nas costas), também é inválida
	if world_pos.y > spine_com.y + 0.45:
		return false

	return true

func _get_part_world_pos(part: Dictionary) -> Vector3:
	var node = part.get("node") as Node3D
	if is_instance_valid(node):
		return node.global_position
	var xform: Transform3D = part.get("transform", Transform3D.IDENTITY)
	return xform.origin

func clear_all_parts() -> void:
	attached_parts.clear()
	_recompute_available_biomass()
	recalculate_stats()
	emit_signal("parts_changed")
