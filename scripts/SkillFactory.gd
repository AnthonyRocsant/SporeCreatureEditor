class_name SkillFactory
extends Node

## PILAR 3: Leitura Anatômica de Tags na Malha e Geração Procedural de Habilidades (Q, E, R, F, V).
## Analisa `creature_data.attached_parts`, identifica tags anatômicas e posições relativas no corpo,
## calcula o impacto de cada golpe e preenche automaticamente a Hotbar de 5 atalhos (Q, E, R, F, V),
## permitindo também reordenação por Drag & Drop na aba "Habilidades".

signal skills_updated(unlocked_skills: Array[Dictionary], hotbar_slots: Dictionary)
signal skill_triggered(slot_key: String, skill_data: Dictionary)

const HOTBAR_KEYS: Array[String] = ["Q", "E", "R", "F", "V"]

## Catálogo oficial de Habilidades Anatômicas do Pilar 3
const SKILL_CATALOG: Dictionary = {
	"#Mouth_Carnivore": {
		"id": "bite_devour",
		"tag": "#Mouth_Carnivore",
		"name": "Mordida Devoradora",
		"description": "Curto alcance + Roubo de Vida (Lifesteal)",
		"effect_type": "lifesteal_melee",
		"base_impact": 88.0,
		"cooldown": 3.5,
		"icon": "🦷"
	},
	"#Mouth_Herbivore": {
		"id": "roar_stun",
		"tag": "#Mouth_Herbivore",
		"name": "Roco Atordoante",
		"description": "Grito sônico em cone (AoE Frontal + Stun)",
		"effect_type": "aoe_frontal_stun",
		"base_impact": 78.0,
		"cooldown": 6.0,
		"icon": "📢"
	},
	"#Horn_Frontal": {
		"id": "charge_devastating",
		"tag": "#Horn_Frontal",
		"name": "Investida Devastadora",
		"description": "Arrancada frontal com Knockback linear",
		"effect_type": "linear_knockback",
		"base_impact": 92.0,
		"cooldown": 5.0,
		"icon": "🦏"
	},
	"#Claw_Front": {
		"id": "triple_claw",
		"tag": "#Claw_Front",
		"name": "Garrada Tripla",
		"description": "Combo rápido de 3 golpes dilacerantes",
		"effect_type": "fast_combo",
		"base_impact": 80.0,
		"cooldown": 2.5,
		"icon": "🐾"
	},
	"#Claw_Heavy": {
		"id": "seismic_stomp",
		"tag": "#Claw_Heavy",
		"name": "Pisotão Sísmico",
		"description": "Onda de choque esmagadora no plano do solo",
		"effect_type": "ground_shockwave",
		"base_impact": 95.0,
		"cooldown": 7.0,
		"icon": "💥"
	},
	"#Wing_Membrane": {
		"id": "aerial_dive",
		"tag": "#Wing_Membrane",
		"name": "Impulso Aéreo / Rasante",
		"description": "Salto propulsado seguido de voo rasante",
		"effect_type": "aerial_dash",
		"base_impact": 85.0,
		"cooldown": 4.5,
		"icon": "🦅"
	},
	"#Tail_Heavy": {
		"id": "tail_sweep_360",
		"tag": "#Tail_Heavy",
		"name": "Varredura de Cauda 360°",
		"description": "Giro corporal que derruba inimigos atrás",
		"effect_type": "rear_knockdown_360",
		"base_impact": 84.0,
		"cooldown": 5.5,
		"icon": "🦎"
	},
	"#Tail_Stinger": {
		"id": "venom_sting",
		"tag": "#Tail_Stinger",
		"name": "Ferroada Venenosa",
		"description": "Injeta toxina letal (DoT de 4s)",
		"effect_type": "poison_dot_4s",
		"base_impact": 90.0,
		"cooldown": 4.0,
		"icon": "🦂"
	},
	"#Mouth_Insectoid": {
		"id": "acid_spray",
		"tag": "#Mouth_Insectoid",
		"name": "Mandíbula Ácida",
		"description": "Cuspe de ácido corrosivo que reduz defesa",
		"effect_type": "poison_dot_4s",
		"base_impact": 86.0,
		"cooldown": 4.0,
		"icon": "🧪"
	},
	"#Mouth_Beak": {
		"id": "piercing_beak",
		"tag": "#Mouth_Beak",
		"name": "Bicada Perfurante",
		"description": "Golpe rápido perfurador de carapaças",
		"effect_type": "fast_combo",
		"base_impact": 82.0,
		"cooldown": 3.0,
		"icon": "🦅"
	},
	"#Mouth_Saber": {
		"id": "saber_pounce",
		"tag": "#Mouth_Saber",
		"name": "Bote Predatório",
		"description": "Salto letal com dano crítico massivo e sangramento",
		"effect_type": "lifesteal_melee",
		"base_impact": 110.0,
		"cooldown": 4.0,
		"icon": "🗡️"
	},
	"#Mouth_Shark": {
		"id": "shark_frenzy",
		"tag": "#Mouth_Shark",
		"name": "Frenesi do Megalodonte",
		"description": "Rajada contínua de mordidas dilaceradoras",
		"effect_type": "fast_combo",
		"base_impact": 105.0,
		"cooldown": 3.8,
		"icon": "🦈"
	},
	"#Mouth_Lamprey": {
		"id": "parasite_drain",
		"tag": "#Mouth_Lamprey",
		"name": "Dreno Parasitário",
		"description": "Sucção contínua que drena vida e reduz velocidade do alvo",
		"effect_type": "lifesteal_melee",
		"base_impact": 88.0,
		"cooldown": 3.2,
		"icon": "🌀"
	},
	"#Mouth_Dragon": {
		"id": "dragon_breath",
		"tag": "#Mouth_Dragon",
		"name": "Sopro Dracônico",
		"description": "Cone frontal devastador de fogo e energia",
		"effect_type": "aoe_frontal_stun",
		"base_impact": 118.0,
		"cooldown": 5.0,
		"icon": "🔥"
	},
	"#Leg_Hoof": {
		"id": "trample_hoof",
		"tag": "#Leg_Hoof",
		"name": "Casco Atropelador",
		"description": "Avanço com passada pesada e estabilidade",
		"effect_type": "linear_knockback",
		"base_impact": 84.0,
		"cooldown": 4.5,
		"icon": "🐎"
	},
	"#Leg_Insect": {
		"id": "acrobat_leap",
		"tag": "#Leg_Insect",
		"name": "Salto Articulado",
		"description": "Salto evasivo alto com pouso seguro",
		"effect_type": "aerial_dash",
		"base_impact": 79.0,
		"cooldown": 3.5,
		"icon": "🦗"
	},
	"#Tail_Club": {
		"id": "mace_bash",
		"tag": "#Tail_Club",
		"name": "Pancada Sísmica",
		"description": "Impacto esmagador com onda de choque",
		"effect_type": "ground_shockwave",
		"base_impact": 94.0,
		"cooldown": 6.0,
		"icon": "🔨"
	},
	"#Tail_Feather": {
		"id": "wind_rudder",
		"tag": "#Tail_Feather",
		"name": "Leque de Vento",
		"description": "Rajada de vento que empurra alvos e equilibra o corpo",
		"effect_type": "rear_knockdown_360",
		"base_impact": 75.0,
		"cooldown": 4.0,
		"icon": "🪶"
	},
	"#Wing_Insect": {
		"id": "hover_dash",
		"tag": "#Wing_Insect",
		"name": "Voo Pairado",
		"description": "Zumbido e arrancada rápida no ar em qualquer direção",
		"effect_type": "aerial_dash",
		"base_impact": 83.0,
		"cooldown": 3.8,
		"icon": "🪰"
	},
	"#Wing_Feather": {
		"id": "glide_dive",
		"tag": "#Wing_Feather",
		"name": "Planagem Suave",
		"description": "Rasante prolongado com alta sustentação e agilidade",
		"effect_type": "aerial_dash",
		"base_impact": 81.0,
		"cooldown": 4.2,
		"icon": "🪽"
	},
	"#Horn_Antler": {
		"id": "antler_guard",
		"tag": "#Horn_Antler",
		"name": "Defesa Chifrada",
		"description": "Bloqueia impactos frontais e desfere contra-ataque",
		"effect_type": "linear_knockback",
		"base_impact": 87.0,
		"cooldown": 5.0,
		"icon": "🦌"
	},
	"#Spike_Dorsal": {
		"id": "spike_burst",
		"tag": "#Spike_Dorsal",
		"name": "Erupção de Espinhos",
		"description": "Onda defensiva de espinhos com ricochete",
		"effect_type": "aoe_frontal_stun",
		"base_impact": 82.0,
		"cooldown": 5.5,
		"icon": "🛡️"
	},
	"#Blade_Bone": {
		"id": "scythe_slash",
		"tag": "#Blade_Bone",
		"name": "Golpe em Foice",
		"description": "Corte em arco de lâmina óssea afiada",
		"effect_type": "fast_combo",
		"base_impact": 89.0,
		"cooldown": 3.0,
		"icon": "⚔️"
	},
	"#Eye_Compound": {
		"id": "compound_vision",
		"tag": "#Eye_Compound",
		"name": "Visão Ocular Composta",
		"description": "Aura sensorial 360° que amplia reflexos e evasão",
		"effect_type": "aoe_frontal_stun",
		"base_impact": 70.0,
		"cooldown": 6.0,
		"icon": "🟢"
	},
	"#Antenna_Sensory": {
		"id": "sonar_pulse",
		"tag": "#Antenna_Sensory",
		"name": "Pulso Ecolocalizador",
		"description": "Emite onda acústica que detecta fraquezas",
		"effect_type": "aoe_frontal_stun",
		"base_impact": 68.0,
		"cooldown": 5.0,
		"icon": "📡"
	},
	"#Claw_Pincer": {
		"id": "crush_pincer",
		"tag": "#Claw_Pincer",
		"name": "Pinça Esmagadora",
		"description": "Aperto demolidor de carapaça com dentes crustáceos",
		"effect_type": "fast_combo",
		"base_impact": 94.0,
		"cooldown": 3.5,
		"icon": "🦞"
	},
	"#Wing_Butterfly": {
		"id": "fairy_gust",
		"tag": "#Wing_Butterfly",
		"name": "Vendaval Místico de Ocelos",
		"description": "Bate de asas lepidóptero com pólen atordoante e agilidade aérea",
		"effect_type": "aerial_dash",
		"base_impact": 88.0,
		"cooldown": 4.0,
		"icon": "🦋"
	},
	"#Tail_Scorpion": {
		"id": "neurotoxic_sting",
		"tag": "#Tail_Scorpion",
		"name": "Picada Neurotóxica",
		"description": "Injeção letal de veneno com aguilhão duplo",
		"effect_type": "dot_poison",
		"base_impact": 95.0,
		"cooldown": 4.5,
		"icon": "🦂"
	},
	"#Fin_Aquatic": {
		"id": "hydro_surge",
		"tag": "#Fin_Aquatic",
		"name": "Arrancada Hidrodinâmica",
		"description": "Impulso fluido cortante com quilha cartilaginosa",
		"effect_type": "linear_knockback",
		"base_impact": 84.0,
		"cooldown": 3.8,
		"icon": "🦈"
	},
	"#Horn_Rhino": {
		"id": "demolishing_charge",
		"tag": "#Horn_Rhino",
		"name": "Carga Demolidora",
		"description": "Avanço imparável que arremessa qualquer inimigo",
		"effect_type": "linear_knockback",
		"base_impact": 98.0,
		"cooldown": 5.0,
		"icon": "🦏"
	},
	"#Eye_Cyclops": {
		"id": "dread_gaze",
		"tag": "#Eye_Cyclops",
		"name": "Olhar Aterrorizante",
		"description": "Fixa o olho titânico paralisando alvos em cone frontal",
		"effect_type": "aoe_frontal_stun",
		"base_impact": 85.0,
		"cooldown": 5.5,
		"icon": "🧿"
	}
}

@export var creature_data: CreatureData
@export var editor_state: EditorState

## Lista de habilidades desbloqueadas pela anatomia atual
var unlocked_skills: Array[Dictionary] = []

## Dicionário de slots: { "Q": skill_dict_or_empty, "E": ..., "R": ..., "F": ..., "V": ... }
var hotbar_slots: Dictionary = {
	"Q": {},
	"E": {},
	"R": {},
	"F": {},
	"V": {}
}

## Guarda preferências manuais de ordenação feitas via Drag & Drop: { "Q": "#Tag", ... }
var _custom_slot_overrides: Dictionary = {}

func _ready() -> void:
	connect_creature_data()

func connect_creature_data() -> void:
	if creature_data and not creature_data.parts_changed.is_connected(rebuild_skills_from_anatomy):
		creature_data.parts_changed.connect(rebuild_skills_from_anatomy)
		rebuild_skills_from_anatomy()

func _unhandled_input(event: InputEvent) -> void:
	# No Modo Sandbox, pressionar Q, E, R, F ou V dispara a habilidade do respectivo atalho
	if not editor_state or not editor_state.is_sandbox():
		return

	if event is InputEventKey and event.pressed and not event.echo:
		var key_str = OS.get_keycode_string(event.keycode).to_upper()
		if key_str in HOTBAR_KEYS:
			if trigger_slot(key_str):
				get_viewport().set_input_as_handled()

## Lê a anatomia (`attached_parts`), identifica as tags e posições e reconstrói as habilidades
func rebuild_skills_from_anatomy() -> void:
	unlocked_skills.clear()
	if not creature_data:
		_clear_hotbar()
		emit_signal("skills_updated", unlocked_skills, hotbar_slots)
		return

	# Agrupa partes por tag anatômica efetiva
	var tag_Disable_map: Dictionary = {} # { tag: { "count": int, "max_scale": float, "part_Z": float } }

	for part in creature_data.attached_parts:
		var resolved_tag = _resolve_anatomical_tag(part)
		if resolved_tag == "" or not SKILL_CATALOG.has(resolved_tag):
			continue

		var scale_f = float(part.get("scale_factor", 1.0))
		var pos_z = _get_part_z(part)

		if not tag_Disable_map.has(resolved_tag):
			tag_Disable_map[resolved_tag] = {
				"count": 1,
				"max_scale": scale_f,
				"avg_z": pos_z
			}
		else:
			var entry = tag_Disable_map[resolved_tag]
			entry["count"] = int(entry["count"]) + 1
			entry["max_scale"] = maxf(float(entry["max_scale"]), scale_f)
			entry["avg_z"] = (float(entry["avg_z"]) + pos_z) * 0.5

	# Constrói a lista de habilidades desbloqueadas com pontuação de impacto calculada
	for tag in tag_Disable_map.keys():
		var template: Dictionary = SKILL_CATALOG[tag]
		var info: Dictionary = tag_Disable_map[tag]
		var count: int = int(info["count"])
		var max_scale: float = float(info["max_scale"])

		var skill_instance = template.duplicate(true)
		# Impacto aumenta com a escala do membro e levemente com membros extras (ex: par simétrico)
		var impact = float(template["base_impact"]) * (0.85 + 0.15 * max_scale) + minf(12.0, float(count - 1) * 4.0)
		skill_instance["impact_score"] = snappedf(impact, 0.1)
		skill_instance["part_count"] = count
		skill_instance["max_scale"] = max_scale
		unlocked_skills.append(skill_instance)

	# Ordena por maior impacto (decrescente)
	unlocked_skills.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("impact_score", 0.0)) > float(b.get("impact_score", 0.0))
	)

	_auto_assign_hotbar_slots()
	emit_signal("skills_updated", unlocked_skills, hotbar_slots)

## Resolve a tag anatômica da peça combinando a tag explícita e a posição na coluna
func _resolve_anatomical_tag(part: Dictionary) -> String:
	var explicit_tag = str(part.get("tag", "")).strip_edges()
	var scale_f = float(part.get("scale_factor", 1.0))
	var pos_z = _get_part_z(part)

	# Se já possui uma tag explícita válida do catálogo, verifica apenas se a escala/posição
	# promove uma variante (ex: Pata muito grande vira #Claw_Heavy)
	if explicit_tag in SKILL_CATALOG:
		if explicit_tag == "#Claw_Front" and scale_f >= 1.35:
			return "#Claw_Heavy"
		return explicit_tag

	# Fallback caso a peça tenha sido criada apenas com "type" ou "category"
	var p_type = str(part.get("type", "")).to_lower()
	match p_type:
		"mouth":
			return "#Mouth_Carnivore" if pos_z >= 0.0 else "#Mouth_Herbivore"
		"spike", "horn":
			return "#Horn_Frontal"
		"leg", "claw":
			return "#Claw_Heavy" if scale_f >= 1.30 else "#Claw_Front"
		"wing":
			return "#Wing_Membrane"
		"tail":
			return "#Tail_Stinger" if pos_z <= -0.2 else "#Tail_Heavy"
		_:
			return ""

func _get_part_z(part: Dictionary) -> float:
	var node = part.get("node") as Node3D
	if is_instance_valid(node):
		return node.position.z
	var xform: Transform3D = part.get("transform", Transform3D.IDENTITY)
	return xform.origin.z

func _clear_hotbar() -> void:
	for k in HOTBAR_KEYS:
		hotbar_slots[k] = {}

## Mapeia automaticamente os 5 golpes de maior impacto nos atalhos Q, E, R, F, V,
## preservando a ordem customizada pelo usuário para as habilidades que continuam ativas.
func _auto_assign_hotbar_slots() -> void:
	_clear_hotbar()
	if unlocked_skills.is_empty():
		_custom_slot_overrides.clear()
		return

	var skill_by_tag: Dictionary = {}
	for sk in unlocked_skills:
		skill_by_tag[str(sk.get("tag", ""))] = sk

	var assigned_tags: Dictionary = {}

	# 1. Aplica escolhas manuais (Drag & Drop) que ainda estejam desbloqueadas
	for slot_key in HOTBAR_KEYS:
		if _custom_slot_overrides.has(slot_key):
			var desired_tag = str(_custom_slot_overrides[slot_key])
			if skill_by_tag.has(desired_tag) and not assigned_tags.has(desired_tag):
				hotbar_slots[slot_key] = skill_by_tag[desired_tag]
				assigned_tags[desired_tag] = true
			else:
				_custom_slot_overrides.erase(slot_key)

	# 2. Preenche os slots restantes automaticamente por ordem de maior impacto
	for sk in unlocked_skills:
		var tag = str(sk.get("tag", ""))
		if assigned_tags.has(tag):
			continue
		for slot_key in HOTBAR_KEYS:
			if hotbar_slots[slot_key].is_empty():
				hotbar_slots[slot_key] = sk
				assigned_tags[tag] = true
				break

## Troca dois slots da Hotbar (usado pelo Drag & Drop e botões de reordenação na UI)
func swap_slots(slot_a: String, slot_b: String) -> void:
	if not hotbar_slots.has(slot_a) or not hotbar_slots.has(slot_b):
		return
	if slot_a == slot_b:
		return

	var temp: Dictionary = hotbar_slots[slot_a]
	hotbar_slots[slot_a] = hotbar_slots[slot_b]
	hotbar_slots[slot_b] = temp

	_save_current_overrides()
	emit_signal("skills_updated", unlocked_skills, hotbar_slots)

## Atribui diretamente uma habilidade (pela tag) a um slot específico (Q, E, R, F, V)
func assign_tag_to_slot(tag: String, target_slot: String) -> void:
	if not hotbar_slots.has(target_slot):
		return

	var found_skill: Dictionary = {}
	for sk in unlocked_skills:
		if str(sk.get("tag", "")) == tag:
			found_skill = sk
			break

	if found_skill.is_empty():
		return

	# Se a habilidade já estava em outro slot, faz o swap
	var previous_slot: String = ""
	for k in HOTBAR_KEYS:
		if not hotbar_slots[k].is_empty() and str(hotbar_slots[k].get("tag", "")) == tag:
			previous_slot = k
			break

	if previous_slot != "" and previous_slot != target_slot:
		swap_slots(previous_slot, target_slot)
		return

	hotbar_slots[target_slot] = found_skill
	_save_current_overrides()
	emit_signal("skills_updated", unlocked_skills, hotbar_slots)

func _save_current_overrides() -> void:
	_custom_slot_overrides.clear()
	for k in HOTBAR_KEYS:
		var slot_data: Dictionary = hotbar_slots[k]
		if not slot_data.is_empty():
			_custom_slot_overrides[k] = str(slot_data.get("tag", ""))

## Executa a habilidade vinculada ao atalho (Q, E, R, F, V)
func trigger_slot(slot_key: String) -> bool:
	var key = slot_key.to_upper()
	if not hotbar_slots.has(key):
		return false
	var skill: Dictionary = hotbar_slots[key]
	if skill.is_empty():
		return false

	emit_signal("skill_triggered", key, skill)
	return true

## Serializa o mapeamento atual de atalhos para o JSON
func serialize_hotbar() -> Dictionary:
	var out: Dictionary = {}
	for k in HOTBAR_KEYS:
		var sk: Dictionary = hotbar_slots.get(k, {})
		out[k] = str(sk.get("tag", "")) if not sk.is_empty() else ""
	return out

## Restaura o mapeamento de atalhos vindo de um JSON
func deserialize_hotbar(slot_map: Dictionary) -> void:
	_custom_slot_overrides.clear()
	for k in HOTBAR_KEYS:
		if slot_map.has(k) and str(slot_map[k]) != "":
			_custom_slot_overrides[k] = str(slot_map[k])
	rebuild_skills_from_anatomy()

