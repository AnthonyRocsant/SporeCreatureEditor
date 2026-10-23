@tool
class_name ProceduralAppendageVisuals
extends Node3D

## Gerador Procedural de Malhas Orgânicas de Alta Qualidade para os Apêndices.
## Substitui blocos primitivos simples por anatomia escultural detalhada:
## - Patas digitígradas musculares articuladas com 3 garras curvas + esporão
## - Asas dracônicas com dedos ósseos falangeados e membranas translúcidas (SSS)
## - Mandíbulas carnívoras com gengiva, língua e presas curvas / Bico herbívoro encouraçado
## - Chifres curvos anelados com roseta óssea basal
## - Caudas segmentadas com osteodermos dorsais, bulbo bioluminescente e ferrão curvo
## - Olhos orgânicos com pálpebras carnudas, esclera vítrea, íris âmbar e brilho especular

@export_enum("leg", "leg_heavy", "leg_hoof", "leg_insect", "claw_pincer",
	"wing", "wing_insect", "wing_feather", "wing_butterfly",
	"mouth_carnivore", "mouth_herbivore", "mouth_insectoid", "mouth_beak",
	"mouth_saber", "mouth_shark", "mouth_lamprey", "mouth_dragon",
	"horn", "horn_antler", "horn_rhino", "spike_dorsal", "blade_bone", "fin_aquatic",
	"tail", "tail_club", "tail_feather", "tail_scorpion",
	"eye", "eye_compound", "eye_stalk", "eye_cyclops", "antenna_sensory")
var appendage_kind: String = "leg":
	set(value):
		appendage_kind = value
		if is_inside_tree():
			build_visuals()

## Cores sincronizadas com o corpo da criatura (estilo Spore)
@export var primary_color: Color = Color(0.85, 0.45, 0.35, 1.0):
	set(value):
		primary_color = value
		if is_inside_tree():
			build_visuals()

@export var secondary_color: Color = Color(0.30, 0.15, 0.10, 1.0):
	set(value):
		secondary_color = value
		if is_inside_tree():
			build_visuals()

@export var detail_color: Color = Color(0.92, 0.88, 0.78, 1.0):
	set(value):
		detail_color = value
		if is_inside_tree():
			build_visuals()

func set_colors(p_col: Color, s_col: Color, d_col: Color = Color(0.92, 0.88, 0.78, 1.0)) -> void:
	primary_color = p_col
	secondary_color = s_col
	detail_color = d_col
	build_visuals()

var _visual_root: Node3D = null

func _ready() -> void:
	build_visuals()

func set_appendage_variant(variant_tag: String) -> void:
	match variant_tag:
		"#Mouth_Herbivore":
			appendage_kind = "mouth_herbivore"
		"#Mouth_Carnivore":
			appendage_kind = "mouth_carnivore"
		"#Mouth_Insectoid":
			appendage_kind = "mouth_insectoid"
		"#Mouth_Beak":
			appendage_kind = "mouth_beak"
		"#Mouth_Saber":
			appendage_kind = "mouth_saber"
		"#Mouth_Shark":
			appendage_kind = "mouth_shark"
		"#Mouth_Lamprey":
			appendage_kind = "mouth_lamprey"
		"#Mouth_Dragon":
			appendage_kind = "mouth_dragon"
		"#Wing_Membrane":
			appendage_kind = "wing"
		"#Wing_Insect":
			appendage_kind = "wing_insect"
		"#Wing_Feather":
			appendage_kind = "wing_feather"
		"#Wing_Butterfly":
			appendage_kind = "wing_butterfly"
		"#Horn_Frontal":
			appendage_kind = "horn"
		"#Horn_Antler":
			appendage_kind = "horn_antler"
		"#Horn_Rhino":
			appendage_kind = "horn_rhino"
		"#Spike_Dorsal":
			appendage_kind = "spike_dorsal"
		"#Blade_Bone":
			appendage_kind = "blade_bone"
		"#Fin_Aquatic":
			appendage_kind = "fin_aquatic"
		"#Tail_Stinger":
			appendage_kind = "tail"
		"#Tail_Heavy":
			appendage_kind = "tail"
		"#Tail_Club":
			appendage_kind = "tail_club"
		"#Tail_Feather":
			appendage_kind = "tail_feather"
		"#Tail_Scorpion":
			appendage_kind = "tail_scorpion"
		"#Claw_Front":
			appendage_kind = "leg"
		"#Claw_Heavy":
			appendage_kind = "leg_heavy"
		"#Claw_Pincer":
			appendage_kind = "claw_pincer"
		"#Leg_Hoof":
			appendage_kind = "leg_hoof"
		"#Leg_Insect":
			appendage_kind = "leg_insect"
		"#Eye_Sensory":
			appendage_kind = "eye"
		"#Eye_Compound":
			appendage_kind = "eye_compound"
		"#Eye_Stalk":
			appendage_kind = "eye_stalk"
		"#Eye_Cyclops":
			appendage_kind = "eye_cyclops"
		"#Antenna_Sensory":
			appendage_kind = "antenna_sensory"
	build_visuals()

func build_visuals() -> void:
	# Remove geometria antiga gerada
	if is_instance_valid(_visual_root):
		_visual_root.queue_free()

	# Oculta malhas primitivas antigas se existirem na cena base
	for child in get_children():
		if child is Node3D and child != _visual_root and child.name != "PartSelectionBody":
			child.visible = false

	_visual_root = Node3D.new()
	_visual_root.name = "OrganicVisualRoot"
	add_child(_visual_root)

	match appendage_kind:
		"leg":
			_build_sculpted_leg(_visual_root)
		"leg_heavy":
			_build_sculpted_heavy_leg(_visual_root)
		"leg_hoof":
			_build_sculpted_hoof_leg(_visual_root)
		"leg_insect":
			_build_sculpted_insect_leg(_visual_root)
		"claw_pincer":
			_build_sculpted_claw_pincer(_visual_root)
		"wing":
			_build_sculpted_wing(_visual_root)
		"wing_insect":
			_build_sculpted_insect_wing(_visual_root)
		"wing_feather":
			_build_sculpted_feather_wing(_visual_root)
		"wing_butterfly":
			_build_sculpted_butterfly_wing(_visual_root)
		"mouth_carnivore":
			_build_sculpted_mouth(_visual_root, false)
		"mouth_herbivore":
			_build_sculpted_mouth(_visual_root, true)
		"mouth_insectoid":
			_build_sculpted_insectoid_mouth(_visual_root)
		"mouth_beak":
			_build_sculpted_beak_mouth(_visual_root)
		"mouth_saber":
			_build_sculpted_saber_mouth(_visual_root)
		"mouth_shark":
			_build_sculpted_shark_mouth(_visual_root)
		"mouth_lamprey":
			_build_sculpted_lamprey_mouth(_visual_root)
		"mouth_dragon":
			_build_sculpted_dragon_mouth(_visual_root)
		"horn":
			_build_sculpted_horn(_visual_root)
		"horn_antler":
			_build_sculpted_antler_horn(_visual_root)
		"horn_rhino":
			_build_sculpted_rhino_horn(_visual_root)
		"spike_dorsal":
			_build_sculpted_dorsal_spike(_visual_root)
		"blade_bone":
			_build_sculpted_bone_blade(_visual_root)
		"fin_aquatic":
			_build_sculpted_aquatic_fin(_visual_root)
		"tail":
			_build_sculpted_tail(_visual_root)
		"tail_club":
			_build_sculpted_club_tail(_visual_root)
		"tail_feather":
			_build_sculpted_feather_tail(_visual_root)
		"tail_scorpion":
			_build_sculpted_scorpion_tail(_visual_root)
		"eye":
			_build_sculpted_eye(_visual_root)
		"eye_compound":
			_build_sculpted_compound_eye(_visual_root)
		"eye_stalk":
			_build_sculpted_stalk_eye(_visual_root)
		"eye_cyclops":
			_build_sculpted_cyclops_eye(_visual_root)
		"antenna_sensory":
			_build_sculpted_antenna(_visual_root)

# ==============================================================================
# 1. PATA DIGITÍGRADA MUSCULAR COM GARRAS CURVAS (Orientada para o CHÃO: -Y)
# ==============================================================================
func _build_sculpted_leg(root: Node3D) -> void:
	var mat_skin = _make_organic_material(primary_color, 0.52, 0.05, primary_color.lightened(0.2), 0.35)
	var mat_scales = _make_organic_material(secondary_color, 0.38, 0.12)
	var mat_tendon = _make_organic_material(primary_color.darkened(0.18), 0.45, 0.08)
	var mat_claw = _make_keratin_material(secondary_color.darkened(0.45), detail_color)

	var pivot = Node3D.new()
	pivot.name = "LegPivot"
	root.add_child(pivot)

	# 0. Colar muscular de encaixe na anca
	_create_attachment_collar(pivot, mat_skin, 0.125, Vector3(0.0, 0.01, -0.02))

	# 1. Músculo da Anca / Glúteo (encaixando firmemente no corpo)
	var hip_pts: Array[Vector3] = [
		Vector3(0.0, 0.04, -0.06),
		Vector3(0.0, 0.02, 0.0),
		Vector3(0.0, -0.04, 0.04),
		Vector3(0.0, -0.11, 0.07)
	]
	var hip_rads: Array[float] = [0.115, 0.15, 0.14, 0.11]
	pivot.add_child(_create_lofted_tube(hip_pts, hip_rads, 16, mat_skin, 0.0, 0.0, Vector2(0.88, 1.15)))

	# 2. Coxa Muscular (Fêmur com perfil elíptico anatômico e feixe muscular lateral)
	var thigh_pts: Array[Vector3] = [
		Vector3(0.0, -0.08, 0.05),
		Vector3(0.0, -0.18, 0.12),
		Vector3(0.0, -0.28, 0.17),
		Vector3(0.0, -0.35, 0.19)
	]
	var thigh_rads: Array[float] = [0.125, 0.142, 0.112, 0.085]
	pivot.add_child(_create_lofted_tube(thigh_pts, thigh_rads, 16, mat_skin, 0.0, 0.0, Vector2(0.84, 1.18)))

	# Duas placas dérmicas sobrepostas no joelho
	for k in range(2):
		var ky = -0.25 - float(k) * 0.06
		var kz = 0.22 + float(k) * 0.02
		var knee_plate_pts: Array[Vector3] = [
			Vector3(0.0, ky + 0.03, kz - 0.02),
			Vector3(0.0, ky, kz + 0.02),
			Vector3(0.0, ky - 0.04, kz - 0.01)
		]
		var knee_plate_rads: Array[float] = [0.032, 0.068 - float(k) * 0.01, 0.018]
		pivot.add_child(_create_lofted_tube(knee_plate_pts, knee_plate_rads, 12, mat_scales, 0.0, 0.0, Vector2(1.3, 0.65)))

	# 3. Canela / Panturrilha Digitígrada + Tendão de Aquiles tencionado atrás
	var shin_pts: Array[Vector3] = [
		Vector3(0.0, -0.34, 0.18),
		Vector3(0.0, -0.46, 0.07),
		Vector3(0.0, -0.58, -0.03),
		Vector3(0.0, -0.66, -0.05)
	]
	var shin_rads: Array[float] = [0.09, 0.104, 0.074, 0.062]
	pivot.add_child(_create_lofted_tube(shin_pts, shin_rads, 16, mat_skin, 0.0, 0.0, Vector2(0.86, 1.15)))

	# Cordão do Tendão Calcâneo (Aquiles)
	var tendon_pts: Array[Vector3] = [
		Vector3(0.0, -0.38, 0.06),
		Vector3(0.0, -0.52, -0.05),
		Vector3(0.0, -0.65, -0.08)
	]
	var tendon_rads: Array[float] = [0.028, 0.022, 0.032]
	pivot.add_child(_create_lofted_tube(tendon_pts, tendon_rads, 10, mat_tendon))

	# 4. Metatarso Escamado e Planta do Pé (apoiada em Y = -0.75)
	var foot_pts: Array[Vector3] = [
		Vector3(0.0, -0.65, -0.04),
		Vector3(0.0, -0.72, 0.05),
		Vector3(0.0, -0.75, 0.15),
		Vector3(0.0, -0.75, 0.23)
	]
	var foot_rads: Array[float] = [0.065, 0.080, 0.090, 0.060]
	pivot.add_child(_create_lofted_tube(foot_pts, foot_rads, 14, mat_scales, 0.05, 6.0, Vector2(1.15, 0.85)))

	# Escudos dorsais reptilianos sobre o dorso do pé
	for s_idx in range(3):
		var st_t = float(s_idx) / 2.0
		var scute_pos = Vector3(0.0, lerpf(-0.67, -0.71, st_t), lerpf(0.04, 0.18, st_t))
		var scute = MeshInstance3D.new()
		var s_mesh = SphereMesh.new()
		s_mesh.radius = 0.045 - float(s_idx) * 0.005
		s_mesh.height = 0.026
		scute.mesh = s_mesh
		scute.position = scute_pos
		scute.rotation = Vector3(0.35, 0.0, 0.0)
		scute.material_override = mat_scales
		pivot.add_child(scute)

	# 5. Três Dedos Articulados + Garra em Foice de Deinonychus no dedo interno
	var toe_offsets = [
		{"x": -0.068, "angle": -0.26, "scale": 0.95, "sickle": true},
		{"x": 0.0,    "angle": 0.0,   "scale": 1.18, "sickle": false},
		{"x": 0.068,  "angle": 0.26,  "scale": 0.92, "sickle": false}
	]
	for toe in toe_offsets:
		var tx = float(toe["x"])
		var ang = float(toe["angle"])
		var sc = float(toe["scale"])
		var is_sickle: bool = toe["sickle"]
		var dir_x = sin(ang)
		var dir_z = cos(ang)

		# Falange carnuda do dedo antes da garra
		var phalanx_pts: Array[Vector3] = [
			Vector3(tx * 0.8, -0.74, 0.16),
			Vector3(tx, -0.74, 0.21)
		]
		var phalanx_rads: Array[float] = [0.042 * sc, 0.036 * sc]
		pivot.add_child(_create_lofted_tube(phalanx_pts, phalanx_rads, 10, mat_scales))

		if is_sickle:
			# Garra assassina erguida em foice (estilo Velociraptor)
			var sickle_pts: Array[Vector3] = [
				Vector3(tx, -0.73, 0.20),
				Vector3(tx + dir_x * 0.04, -0.64, 0.25),
				Vector3(tx + dir_x * 0.06, -0.66, 0.34),
				Vector3(tx + dir_x * 0.07, -0.75, 0.36)
			]
			var sickle_rads: Array[float] = [0.040, 0.034, 0.022, 0.003]
			pivot.add_child(_create_lofted_tube(sickle_pts, sickle_rads, 12, mat_claw, 0.03, 8.0, Vector2(0.65, 1.35)))
		else:
			var claw_pts: Array[Vector3] = [
				Vector3(tx, -0.74, 0.20),
				Vector3(tx + dir_x * 0.05, -0.71, 0.20 + dir_z * 0.09 * sc),
				Vector3(tx + dir_x * 0.09, -0.75, 0.20 + dir_z * 0.18 * sc),
				Vector3(tx + dir_x * 0.11, -0.78, 0.20 + dir_z * 0.24 * sc)
			]
			var claw_rads: Array[float] = [0.038 * sc, 0.030 * sc, 0.018 * sc, 0.003]
			pivot.add_child(_create_lofted_tube(claw_pts, claw_rads, 12, mat_claw, 0.03, 7.0, Vector2(0.75, 1.25)))

	# Esporão traseiro (Hallux)
	var spur_pts: Array[Vector3] = [
		Vector3(0.0, -0.68, -0.05),
		Vector3(0.0, -0.66, -0.13),
		Vector3(0.0, -0.72, -0.19)
	]
	var spur_rads: Array[float] = [0.030, 0.020, 0.003]
	pivot.add_child(_create_lofted_tube(spur_pts, spur_rads, 10, mat_claw))

# ==============================================================================
# 1B. PATA PESADA ESMAGADORA TITÂNICA (Estilo Paquiderme / Sauropoda / T-Rex)
# ==============================================================================
func _build_sculpted_heavy_leg(root: Node3D) -> void:
	var mat_skin = _make_organic_material(primary_color, 0.62, 0.05, primary_color.lightened(0.15), 0.25)
	var mat_armor = _make_organic_material(secondary_color, 0.36, 0.15)
	var mat_claw = _make_keratin_material(secondary_color.darkened(0.45), detail_color)

	var pivot = Node3D.new()
	pivot.name = "HeavyLegPivot"
	root.add_child(pivot)

	# 0. Colar muscular maciço na base da anca
	_create_attachment_collar(pivot, mat_skin, 0.17, Vector3(0.0, 0.02, -0.03))

	# 1. Anca e Coxa Colunar Maciça com dobras dérmicas
	var hip_pts: Array[Vector3] = [
		Vector3(0.0, 0.06, -0.06),
		Vector3(0.0, 0.02, 0.0),
		Vector3(0.0, -0.06, 0.05),
		Vector3(0.0, -0.16, 0.08)
	]
	var hip_rads: Array[float] = [0.165, 0.195, 0.185, 0.165]
	pivot.add_child(_create_lofted_tube(hip_pts, hip_rads, 16, mat_skin, 0.025, 4.0))

	# 2. Fêmur Muscular Pesado
	var thigh_pts: Array[Vector3] = [
		Vector3(0.0, -0.14, 0.07),
		Vector3(0.0, -0.24, 0.13),
		Vector3(0.0, -0.34, 0.16)
	]
	var thigh_rads: Array[float] = [0.175, 0.165, 0.15]
	pivot.add_child(_create_lofted_tube(thigh_pts, thigh_rads, 16, mat_skin, 0.0, 0.0, Vector2(0.95, 1.12)))

	# 3. Três Escudos Ósseos Escalonados (Grevas) no Joelho e Canela + Espinho de Joelho
	for k in range(3):
		var y_off = -0.24 - float(k) * 0.095
		var z_off = 0.19 - float(k) * 0.015
		var k_pts: Array[Vector3] = [
			Vector3(0.0, y_off + 0.04, z_off - 0.02),
			Vector3(0.0, y_off, z_off + 0.045),
			Vector3(0.0, y_off - 0.04, z_off - 0.02)
		]
		var k_rads: Array[float] = [0.055, 0.095 - float(k) * 0.008, 0.045]
		pivot.add_child(_create_lofted_tube(k_pts, k_rads, 12, mat_armor, 0.0, 0.0, Vector2(1.35, 0.7)))

	var knee_spike: Array[Vector3] = [
		Vector3(0.0, -0.25, 0.22),
		Vector3(0.0, -0.22, 0.30)
	]
	var knee_spike_rads: Array[float] = [0.04, 0.004]
	pivot.add_child(_create_lofted_tube(knee_spike, knee_spike_rads, 8, mat_claw))

	# 4. Canela Colunar Espessa com Pregas de Paquiderme
	var shin_pts: Array[Vector3] = [
		Vector3(0.0, -0.34, 0.15),
		Vector3(0.0, -0.46, 0.10),
		Vector3(0.0, -0.58, 0.05),
		Vector3(0.0, -0.68, 0.02)
	]
	var shin_rads: Array[float] = [0.145, 0.15, 0.145, 0.16]
	pivot.add_child(_create_lofted_tube(shin_pts, shin_rads, 16, mat_skin, 0.03, 5.0))

	# 5. Almofada de Choque Circular Larga no Solo (Y = -0.75)
	var foot_pts: Array[Vector3] = [
		Vector3(0.0, -0.66, 0.02),
		Vector3(0.0, -0.72, 0.06),
		Vector3(0.0, -0.75, 0.12),
		Vector3(0.0, -0.75, 0.19)
	]
	var foot_rads: Array[float] = [0.16, 0.18, 0.185, 0.145]
	pivot.add_child(_create_lofted_tube(foot_pts, foot_rads, 16, mat_armor, 0.0, 0.0, Vector2(1.15, 0.90)))

	# 6. Quatro Garras / Cascos Grossos de Esmagamento + Esporão Traseiro Pesado
	var nail_angles = [-0.68, -0.23, 0.23, 0.68]
	for a in nail_angles:
		var dir_x = sin(a)
		var dir_z = cos(a)
		var n_base = Vector3(dir_x * 0.155, -0.73, 0.10 + dir_z * 0.125)
		var n_mid = n_base + Vector3(dir_x * 0.045, 0.01, dir_z * 0.06)
		var n_tip = n_base + Vector3(dir_x * 0.085, -0.02, dir_z * 0.12)
		var nail_pts: Array[Vector3] = [n_base, n_mid, n_tip]
		var nail_rads: Array[float] = [0.052, 0.042, 0.008]
		pivot.add_child(_create_lofted_tube(nail_pts, nail_rads, 10, mat_claw, 0.04, 5.0))

	# 7. Osteodermos Cônicos nas Laterais da Perna
	for side in [-1.0, 1.0]:
		for i in range(4):
			var oy = -0.22 - float(i) * 0.11
			var oz = 0.10 - float(i) * 0.02
			var osteo_pts: Array[Vector3] = [
				Vector3(side * 0.13, oy, oz),
				Vector3(side * 0.19, oy + 0.01, oz - 0.01)
			]
			var osteo_rads: Array[float] = [0.042, 0.006]
			pivot.add_child(_create_lofted_tube(osteo_pts, osteo_rads, 8, mat_claw if i == 0 else mat_armor))

# ==============================================================================
# 2. ASA DRACÔNICA / WYVERN MAJESTOSA COM FALANGES E MEMBRANA TRANSLÚCIDA
# ==============================================================================
func _build_sculpted_wing(root: Node3D) -> void:
	var mat_skin = _make_organic_material(primary_color, 0.48, 0.06, primary_color.lightened(0.2), 0.30)
	var mat_bone = _make_organic_material(primary_color.darkened(0.18), 0.38, 0.14)
	var mat_claw = _make_keratin_material(secondary_color.darkened(0.45), detail_color)
	var mat_membrane = StandardMaterial3D.new()
	mat_membrane.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat_membrane.albedo_color = secondary_color
	mat_membrane.vertex_color_use_as_albedo = true
	mat_membrane.roughness = 0.38
	mat_membrane.rim_enabled = true
	mat_membrane.rim = 0.45
	mat_membrane.backlight_enabled = true
	mat_membrane.backlight = primary_color.lightened(0.25) * 0.85
	mat_membrane.normal_enabled = true
	mat_membrane.normal_scale = 0.30
	mat_membrane.normal_texture = _get_organic_normal_tex()

	var wing_pivot = Node3D.new()
	wing_pivot.name = "WingRoot"
	root.add_child(wing_pivot)

	# 0. Colar Peitoral / Escápula Muscular na Base
	_create_attachment_collar(wing_pivot, mat_skin, 0.125, Vector3(0.0, 0.0, 0.0))

	# 1. Base Muscular do Ombro / Deltoide Alar
	var shoulder_pts: Array[Vector3] = [
		Vector3(0.0, -0.04, 0.0),
		Vector3(0.0, 0.08, -0.02),
		Vector3(0.0, 0.22, -0.05)
	]
	var shoulder_rads: Array[float] = [0.125, 0.14, 0.098]
	wing_pivot.add_child(_create_lofted_tube(shoulder_pts, shoulder_rads, 14, mat_skin, 0.0, 0.0, Vector2(0.85, 1.15)))

	# 2. Braço e Antebraço da Asa (Úmero -> Cotovelo -> Carpo/Pulso -> Ponta Mestra)
	var shoulder = Vector3(0.0, 0.18, -0.04)
	var elbow = Vector3(0.0, 0.45, -0.16)
	var wrist = Vector3(0.0, 0.95, 0.18)
	var main_tip = Vector3(0.0, 1.58, -0.14)

	var arm_pts: Array[Vector3] = [shoulder, elbow, wrist, main_tip]
	var arm_rads: Array[float] = [0.098, 0.078, 0.064, 0.018]
	wing_pivot.add_child(_create_lofted_tube(arm_pts, arm_rads, 14, mat_bone, 0.02, 6.0))

	# Esporão ósseo no cotovelo
	var elbow_spur: Array[Vector3] = [
		elbow,
		elbow + Vector3(0.0, -0.06, -0.11)
	]
	var elbow_spur_rads: Array[float] = [0.035, 0.003]
	wing_pivot.add_child(_create_lofted_tube(elbow_spur, elbow_spur_rads, 8, mat_claw))

	# 3. Garra Curva de Rapina no Polegar do Pulso (Alula)
	var thumb_pts: Array[Vector3] = [
		wrist,
		wrist + Vector3(0.0, 0.13, 0.15),
		wrist + Vector3(0.0, 0.07, 0.27)
	]
	var thumb_rads: Array[float] = [0.042, 0.026, 0.003]
	wing_pivot.add_child(_create_lofted_tube(thumb_pts, thumb_rads, 10, mat_claw, 0.03, 5.0))

	# 4. Dedos Longos Falangeados Curvos com Nós Articulares (Phalanges 1 a 5)
	var finger_defs = [
		{"tip": main_tip, "mid": wrist.lerp(main_tip, 0.55) + Vector3(0.04, 0.06, 0.08)},
		{"tip": Vector3(0.0, 1.38, -0.56), "mid": wrist.lerp(Vector3(0.0, 1.38, -0.56), 0.55) + Vector3(0.06, 0.08, -0.04)},
		{"tip": Vector3(0.0, 1.06, -0.88), "mid": wrist.lerp(Vector3(0.0, 1.06, -0.88), 0.55) + Vector3(0.05, 0.06, -0.10)},
		{"tip": Vector3(0.0, 0.60, -0.82), "mid": wrist.lerp(Vector3(0.0, 0.60, -0.82), 0.55) + Vector3(0.03, 0.04, -0.08)},
		{"tip": Vector3(0.0, 0.14, -0.52), "mid": elbow.lerp(Vector3(0.0, 0.14, -0.52), 0.50) + Vector3(0.02, -0.04, -0.06)}
	]

	var finger_curves: Array[Array] = []
	for f_idx in range(finger_defs.size()):
		var f = finger_defs[f_idx]
		var tip: Vector3 = f["tip"]
		var mid: Vector3 = f["mid"]
		var root_p: Vector3 = wrist if f_idx < 4 else elbow
		var f_pts: Array[Vector3] = [root_p, mid, tip]
		var f_rads: Array[float] = [0.038, 0.024, 0.006]
		wing_pivot.add_child(_create_lofted_tube(f_pts, f_rads, 10, mat_bone))

		# Nó articular na falange média
		var knuckle = MeshInstance3D.new()
		var k_sph = SphereMesh.new()
		k_sph.radius = 0.028
		k_sph.height = 0.056
		knuckle.mesh = k_sph
		knuckle.position = mid
		knuckle.material_override = mat_bone
		wing_pivot.add_child(knuckle)

		# Garra afiada na ponta de cada dedo da asa
		var tip_claw_pts: Array[Vector3] = [
			tip,
			tip + (tip - mid).normalized() * 0.09 + Vector3(0.0, -0.04, -0.02)
		]
		var tip_claw_rads: Array[float] = [0.015, 0.002]
		wing_pivot.add_child(_create_lofted_tube(tip_claw_pts, tip_claw_rads, 8, mat_claw))

		finger_curves.append([root_p, mid, tip])

	# 5. Membrana Patagial 3D Subdividida com Curvatura Aerodinâmica (Camber) e Borda Recortada
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(0)
	var steps_u = 6
	var steps_v = 6
	for bay in range(finger_curves.size() - 1):
		var c_a: Array = finger_curves[bay]
		var c_b: Array = finger_curves[bay + 1]
		for iu in range(steps_u):
			var u0 = float(iu) / float(steps_u)
			var u1 = float(iu + 1) / float(steps_u)
			for iv in range(steps_v):
				var v0 = float(iv) / float(steps_v)
				var v1 = float(iv + 1) / float(steps_v)

				var p00 = _eval_wing_bay_point(c_a, c_b, u0, v0)
				var p10 = _eval_wing_bay_point(c_a, c_b, u1, v0)
				var p01 = _eval_wing_bay_point(c_a, c_b, u0, v1)
				var p11 = _eval_wing_bay_point(c_a, c_b, u1, v1)

				var col00 = Color(lerpf(0.78, 1.06, u0), lerpf(0.78, 1.06, u0), lerpf(0.78, 1.06, u0), 1.0)
				var col10 = Color(lerpf(0.78, 1.06, u1), lerpf(0.78, 1.06, u1), lerpf(0.78, 1.06, u1), 1.0)

				st.set_color(col00)
				st.set_uv(Vector2(u0, v0))
				st.add_vertex(p00)
				st.set_color(col10)
				st.set_uv(Vector2(u1, v0))
				st.add_vertex(p10)
				st.set_color(col10)
				st.set_uv(Vector2(u1, v1))
				st.add_vertex(p11)

				st.set_color(col00)
				st.set_uv(Vector2(u0, v0))
				st.add_vertex(p00)
				st.set_color(col10)
				st.set_uv(Vector2(u1, v1))
				st.add_vertex(p11)
				st.set_color(col00)
				st.set_uv(Vector2(u0, v1))
				st.add_vertex(p01)

	st.index()
	st.generate_normals()
	st.generate_tangents()
	var web_inst = MeshInstance3D.new()
	web_inst.mesh = st.commit()
	web_inst.material_override = mat_membrane
	wing_pivot.add_child(web_inst)

func _eval_wing_bay_point(c_a: Array, c_b: Array, u: float, v: float) -> Vector3:
	# Avalia ponto quadrático ao longo do dedo A e dedo B
	var inv_u = 1.0 - u
	var pa: Vector3 = (inv_u * inv_u) * c_a[0] + (2.0 * inv_u * u) * c_a[1] + (u * u) * c_a[2]
	var pb: Vector3 = (inv_u * inv_u) * c_b[0] + (2.0 * inv_u * u) * c_b[1] + (u * u) * c_b[2]
	var p = pa.lerp(pb, v)
	# Recorte côncavo profundo na borda de fuga (scallop) e arqueamento dorsal (camber)
	var scallop_arch = 4.0 * v * (1.0 - v)
	var root_anchor: Vector3 = c_a[0].lerp(c_b[0], v)
	var span_dir = (p - root_anchor)
	p -= span_dir * (0.20 * u * u * scallop_arch)
	p.x += 0.045 * sin(u * PI) * scallop_arch
	return p

# ==============================================================================
# 3. MANDÍBULA CARNÍVORA FEROZ OU BICO HERBÍVORO ENCOURAÇADO
# ==============================================================================
func _build_sculpted_mouth(root: Node3D, is_herbivore: bool) -> void:
	var mat_skin = _make_organic_material(
		primary_color.darkened(0.08) if is_herbivore else primary_color,
		0.46, 0.05, primary_color.lightened(0.2), 0.30
	)
	var mat_scales = _make_organic_material(secondary_color, 0.38, 0.10)
	var mat_gum = _make_organic_material(Color(0.78, 0.20, 0.26).lerp(primary_color, 0.22), 0.22, 0.0, Color(0.95, 0.25, 0.25), 0.45)
	var mat_tooth = _make_keratin_material(secondary_color.darkened(0.25), detail_color)
	var mat_beak = _make_keratin_material(secondary_color.darkened(0.35), detail_color)

	var jaw_root = Node3D.new()
	jaw_root.name = "JawRoot"
	root.add_child(jaw_root)

	# 0. Músculos Masseteres da Bochecha (articulação mandibular robusta)
	for side in [-1.0, 1.0]:
		var cheek_pts: Array[Vector3] = [
			Vector3(side * 0.10, 0.02, -0.02),
			Vector3(side * 0.14, 0.10, 0.01),
			Vector3(side * 0.11, 0.18, -0.02)
		]
		var cheek_rads: Array[float] = [0.075, 0.085, 0.055]
		jaw_root.add_child(_create_lofted_tube(cheek_pts, cheek_rads, 12, mat_skin))

	# 1. Maxilar Superior (Focinho esculpido largo e achatado)
	var upper_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.04),
		Vector3(0.0, 0.14, 0.07),
		Vector3(0.0, 0.28, 0.05),
		Vector3(0.0, 0.39, 0.01)
	]
	var upper_rads: Array[float] = [0.16, 0.155, 0.125, 0.065]
	jaw_root.add_child(_create_lofted_tube(upper_pts, upper_rads, 16, mat_beak if is_herbivore else mat_skin, 0.0, 0.0, Vector2(1.18, 0.82)))

	# Crista nasal e narinas esculpidas no topo do focinho
	for side in [-1.0, 1.0]:
		var nostril = MeshInstance3D.new()
		var n_torus = TorusMesh.new()
		n_torus.inner_radius = 0.012
		n_torus.outer_radius = 0.028
		nostril.mesh = n_torus
		nostril.position = Vector3(side * 0.055, 0.27, 0.11)
		nostril.rotation = Vector3(0.3, side * 0.3, 0.0)
		nostril.material_override = mat_scales
		jaw_root.add_child(nostril)

	# 2. Mandíbula Inferior Articulada + Gengiva Interna
	var lower_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, -0.05),
		Vector3(0.0, 0.12, -0.11),
		Vector3(0.0, 0.25, -0.14),
		Vector3(0.0, 0.35, -0.11)
	]
	var lower_rads: Array[float] = [0.145, 0.125, 0.098, 0.050]
	jaw_root.add_child(_create_lofted_tube(lower_pts, lower_rads, 16, mat_beak if is_herbivore else mat_skin, 0.0, 0.0, Vector2(1.15, 0.80)))

	# 3. Língua Carnuda Curvada e Gengivas
	var tongue_pts: Array[Vector3] = [
		Vector3(0.0, 0.05, -0.02),
		Vector3(0.0, 0.18, -0.05),
		Vector3(0.0, 0.28, -0.07),
		Vector3(0.0, 0.33, -0.05)
	]
	var tongue_rads: Array[float] = [0.075, 0.062, 0.042, 0.015]
	jaw_root.add_child(_create_lofted_tube(tongue_pts, tongue_rads, 12, mat_gum, 0.0, 0.0, Vector2(1.35, 0.55)))

	if is_herbivore:
		# Chifres jugais laterais + placas trituradoras e corno nasal de herbívoro encouraçado
		for side in [-1.0, 1.0]:
			var tusk_pts: Array[Vector3] = [
				Vector3(side * 0.12, 0.10, 0.02),
				Vector3(side * 0.21, 0.19, 0.06),
				Vector3(side * 0.26, 0.28, 0.13)
			]
			var tusk_rads: Array[float] = [0.045, 0.028, 0.004]
			jaw_root.add_child(_create_lofted_tube(tusk_pts, tusk_rads, 10, mat_tooth, 0.04, 6.0))

			# Escudo malar secundário
			var flange_pts: Array[Vector3] = [
				Vector3(side * 0.11, 0.06, -0.06),
				Vector3(side * 0.18, 0.12, -0.10)
			]
			var flange_rads: Array[float] = [0.035, 0.006]
			jaw_root.add_child(_create_lofted_tube(flange_pts, flange_rads, 8, mat_beak))
	else:
		# Presas, Incisivos, Caninos Sabre e Molares Carniceiros de Predador Carnívoro
		var x_positions = [-0.105, -0.075, -0.042, -0.015, 0.015, 0.042, 0.075, 0.105]
		for x_pos in x_positions:
			var abs_x = abs(x_pos)
			var is_canine = abs_x > 0.06 and abs_x < 0.09
			var is_molar = abs_x > 0.09
			var len_f = 1.45 if is_canine else (0.75 if is_molar else 0.65)
			var y_fwd = 0.28 if is_canine else (0.18 if is_molar else 0.34)

			# Dente superior curvado para baixo e para dentro
			var u_tooth: Array[Vector3] = [
				Vector3(x_pos, y_fwd, 0.02),
				Vector3(x_pos * 0.96, y_fwd + 0.02, -0.035 * len_f),
				Vector3(x_pos * 0.92, y_fwd + 0.03, -0.085 * len_f)
			]
			var u_rads: Array[float] = [0.024 * len_f, 0.015 * len_f, 0.002]
			jaw_root.add_child(_create_lofted_tube(u_tooth, u_rads, 8, mat_tooth))

			# Dente inferior apontando para cima
			var l_tooth: Array[Vector3] = [
				Vector3(x_pos * 0.85, y_fwd - 0.02, -0.11),
				Vector3(x_pos * 0.85, y_fwd, -0.065),
				Vector3(x_pos * 0.85, y_fwd + 0.02, -0.025)
			]
			var l_rads: Array[float] = [0.020 * minf(1.1, len_f), 0.012, 0.002]
			jaw_root.add_child(_create_lofted_tube(l_tooth, l_rads, 8, mat_tooth))

		# Espinhos ósseos de queixo (mentonianos)
		for side in [-1.0, 1.0]:
			var chin_spk: Array[Vector3] = [
				Vector3(side * 0.05, 0.24, -0.14),
				Vector3(side * 0.07, 0.28, -0.19)
			]
			var chin_rads: Array[float] = [0.020, 0.003]
			jaw_root.add_child(_create_lofted_tube(chin_spk, chin_rads, 6, mat_tooth))

# ==============================================================================
# 4. CHIFRE CURVO DE QUERATINA COM ROSETA BASAL E ESPINHOS LATERAIS
# ==============================================================================
func _build_sculpted_horn(root: Node3D) -> void:
	var mat_base = _make_organic_material(primary_color.darkened(0.15), 0.52, 0.06)
	var mat_horn = _make_keratin_material(secondary_color.darkened(0.42), detail_color)

	# 1. Roseta óssea rugosa na base (Pedículo craniano)
	_create_attachment_collar(root, mat_base, 0.135, Vector3(0.0, 0.02, 0.0))
	var base_pts: Array[Vector3] = [
		Vector3(0.0, -0.02, 0.0),
		Vector3(0.0, 0.04, 0.0),
		Vector3(0.0, 0.09, 0.01)
	]
	var base_rads: Array[float] = [0.135, 0.145, 0.108]
	root.add_child(_create_lofted_tube(base_pts, base_rads, 16, mat_base, 0.06, 5.0))

	# 2. Chifre principal longo e curvo com anéis 3D esculpidos de crescimento
	var horn_pts: Array[Vector3] = [
		Vector3(0.0, 0.06, 0.0),
		Vector3(0.0, 0.19, 0.02),
		Vector3(0.0, 0.34, 0.08),
		Vector3(0.0, 0.48, 0.17),
		Vector3(0.0, 0.62, 0.29)
	]
	var horn_rads: Array[float] = [0.10, 0.082, 0.058, 0.030, 0.003]
	root.add_child(_create_lofted_tube(horn_pts, horn_rads, 16, mat_horn, 0.065, 14.0, Vector2(0.92, 1.08)))

	# 3. Par de chifres menores de guarda na base + nódulos frontais
	for side in [-1.0, 1.0]:
		var sub_pts: Array[Vector3] = [
			Vector3(side * 0.075, 0.04, 0.0),
			Vector3(side * 0.14, 0.15, 0.03),
			Vector3(side * 0.18, 0.26, 0.09)
		]
		var sub_rads: Array[float] = [0.046, 0.026, 0.003]
		root.add_child(_create_lofted_tube(sub_pts, sub_rads, 12, mat_horn, 0.05, 8.0))

# ==============================================================================
# 5. CAUDA SEGMENTADA COM CLAVA ÓSSEA, BULBO VENENOSO BIOLUMINESCENTE E FERRÃO
# ==============================================================================
func _build_sculpted_tail(root: Node3D) -> void:
	var mat_skin = _make_organic_material(primary_color, 0.48, 0.06)
	var mat_armor = _make_organic_material(secondary_color, 0.38, 0.14)
	var mat_stinger = _make_keratin_material(secondary_color.darkened(0.5), detail_color)

	var mat_venom = StandardMaterial3D.new()
	mat_venom.albedo_color = detail_color
	mat_venom.roughness = 0.15
	mat_venom.clearcoat_enabled = true
	mat_venom.clearcoat = 0.9
	mat_venom.emission_enabled = true
	mat_venom.emission = detail_color
	mat_venom.emission_energy_multiplier = 1.6

	var tail_root = Node3D.new()
	tail_root.name = "TailRoot"
	root.add_child(tail_root)

	_create_attachment_collar(tail_root, mat_skin, 0.115, Vector3.ZERO)

	# 1. Cauda segmentada com anéis orgânicos
	var tail_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.16, -0.05),
		Vector3(0.0, 0.34, -0.08),
		Vector3(0.0, 0.50, -0.02),
		Vector3(0.0, 0.62, 0.10)
	]
	var tail_rads: Array[float] = [0.115, 0.098, 0.082, 0.070, 0.085]
	tail_root.add_child(_create_lofted_tube(tail_pts, tail_rads, 16, mat_armor, 0.045, 9.0))

	# 2. Quatro Cristas Osteodérmicas Dorsais ao longo da cauda
	for i in range(4):
		var t_c = float(i + 1) / 5.0
		var c_pos = Vector3(0.0, lerpf(0.08, 0.52, t_c), lerpf(-0.04, -0.02, t_c) - 0.06)
		var crest_pts: Array[Vector3] = [
			c_pos + Vector3(0.0, -0.02, 0.03),
			c_pos + Vector3(0.0, 0.03, -0.05)
		]
		var crest_rads: Array[float] = [0.032, 0.004]
		tail_root.add_child(_create_lofted_tube(crest_pts, crest_rads, 8, mat_stinger, 0.0, 0.0, Vector2(0.45, 1.5)))

	# 3. Bulbo de Veneno Bioluminescente (Telson) abraçado por costelas quitinosas
	var bulb = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.098
	sphere.height = 0.22
	bulb.mesh = sphere
	bulb.position = Vector3(0.0, 0.64, 0.12)
	bulb.material_override = mat_venom
	tail_root.add_child(bulb)

	# 4. Aguilhão / Ferrão Curvo Afiado
	var sting_pts: Array[Vector3] = [
		Vector3(0.0, 0.68, 0.15),
		Vector3(0.0, 0.79, 0.25),
		Vector3(0.0, 0.74, 0.38)
	]
	var sting_rads: Array[float] = [0.054, 0.026, 0.002]
	tail_root.add_child(_create_lofted_tube(sting_pts, sting_rads, 12, mat_stinger))

	# 5. Espinhos laterais de clava
	for side in [-1.0, 1.0]:
		var mace_pts: Array[Vector3] = [
			Vector3(side * 0.06, 0.56, 0.05),
			Vector3(side * 0.16, 0.60, 0.07),
			Vector3(side * 0.25, 0.65, 0.11)
		]
		var mace_rads: Array[float] = [0.038, 0.022, 0.003]
		tail_root.add_child(_create_lofted_tube(mace_pts, mace_rads, 10, mat_stinger))

# ==============================================================================
# 6. OLHO ORGÂNICO REALISTA COM PÁLPEBRAS, ÍRIS ÂMBAR E BRILHO DE CÓRNEA
# ==============================================================================
func _build_sculpted_eye(root: Node3D) -> void:
	var mat_lid = _make_organic_material(primary_color, 0.50, 0.05, primary_color.lightened(0.2), 0.35)
	var mat_brow = _make_organic_material(secondary_color, 0.42, 0.10)

	var mat_sclera = StandardMaterial3D.new()
	mat_sclera.albedo_color = Color(0.97, 0.96, 0.92)
	mat_sclera.roughness = 0.03
	mat_sclera.metallic = 0.02
	mat_sclera.clearcoat_enabled = true
	mat_sclera.clearcoat = 1.0
	mat_sclera.clearcoat_roughness = 0.03

	var mat_limbus = StandardMaterial3D.new()
	mat_limbus.albedo_color = secondary_color.darkened(0.55)
	mat_limbus.roughness = 0.15

	var mat_iris = StandardMaterial3D.new()
	mat_iris.albedo_color = secondary_color.lightened(0.1)
	mat_iris.roughness = 0.10
	mat_iris.emission_enabled = true
	mat_iris.emission = secondary_color.lightened(0.28)
	mat_iris.emission_energy_multiplier = 0.55

	var mat_pupil = StandardMaterial3D.new()
	mat_pupil.albedo_color = Color(0.02, 0.02, 0.03)
	mat_pupil.roughness = 0.02

	var mat_glint = StandardMaterial3D.new()
	mat_glint.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_glint.albedo_color = Color(1.0, 1.0, 1.0)

	# 1. Soquete Muscular + Pálpebras Superior e Inferior Esculpidas
	var socket = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.088
	torus.outer_radius = 0.168
	torus.rings = 24
	torus.ring_segments = 14
	socket.mesh = torus
	socket.position = Vector3(0.0, 0.08, 0.0)
	socket.material_override = mat_lid
	root.add_child(socket)

	# Crista superciliar superior arqueada (Pálpebra/Sobrancelha)
	var upper_lid_pts: Array[Vector3] = [
		Vector3(-0.13, 0.11, 0.04),
		Vector3(0.0, 0.16, 0.12),
		Vector3(0.13, 0.11, 0.04)
	]
	var upper_lid_rads: Array[float] = [0.032, 0.048, 0.032]
	root.add_child(_create_lofted_tube(upper_lid_pts, upper_lid_rads, 12, mat_brow))

	# Pálpebra inferior carnuda
	var lower_lid_pts: Array[Vector3] = [
		Vector3(-0.12, 0.10, -0.04),
		Vector3(0.0, 0.14, -0.11),
		Vector3(0.12, 0.10, -0.04)
	]
	var lower_lid_rads: Array[float] = [0.026, 0.038, 0.026]
	root.add_child(_create_lofted_tube(lower_lid_pts, lower_lid_rads, 10, mat_lid))

	# 2. Globo Ocular Vítreo
	var eyeball = MeshInstance3D.new()
	var eye_sphere = SphereMesh.new()
	eye_sphere.radius = 0.135
	eye_sphere.height = 0.27
	eyeball.mesh = eye_sphere
	eyeball.position = Vector3(0.0, 0.11, 0.0)
	eyeball.material_override = mat_sclera
	root.add_child(eyeball)

	# 3. Anel Limbal Escuro + Íris Luminosa no ápice do olho (+Y)
	var limbus = MeshInstance3D.new()
	var limbus_cyl = CylinderMesh.new()
	limbus_cyl.top_radius = 0.076
	limbus_cyl.bottom_radius = 0.082
	limbus_cyl.height = 0.020
	limbus.mesh = limbus_cyl
	limbus.position = Vector3(0.0, 0.230, 0.0)
	limbus.material_override = mat_limbus
	root.add_child(limbus)

	var iris = MeshInstance3D.new()
	var iris_cyl = CylinderMesh.new()
	iris_cyl.top_radius = 0.066
	iris_cyl.bottom_radius = 0.072
	iris_cyl.height = 0.025
	iris.mesh = iris_cyl
	iris.position = Vector3(0.0, 0.233, 0.0)
	iris.material_override = mat_iris
	root.add_child(iris)

	# 4. Pupila Reptiliana em Fenda Diamante
	var pupil = MeshInstance3D.new()
	var pupil_box = BoxMesh.new()
	pupil_box.size = Vector3(0.024, 0.022, 0.098)
	pupil.mesh = pupil_box
	pupil.position = Vector3(0.0, 0.241, 0.0)
	pupil.material_override = mat_pupil
	root.add_child(pupil)

	# 5. Duplo Reflexo Especular (Brilho vivo principal + brilho secundário da córnea)
	var glint = MeshInstance3D.new()
	var glint_sphere = SphereMesh.new()
	glint_sphere.radius = 0.019
	glint_sphere.height = 0.038
	glint.mesh = glint_sphere
	glint.position = Vector3(0.028, 0.247, 0.026)
	glint.material_override = mat_glint
	root.add_child(glint)

	var glint2 = MeshInstance3D.new()
	var glint2_sphere = SphereMesh.new()
	glint2_sphere.radius = 0.010
	glint2_sphere.height = 0.020
	glint2.mesh = glint2_sphere
	glint2.position = Vector3(-0.024, 0.244, -0.022)
	glint2.material_override = mat_glint
	root.add_child(glint2)

# ==============================================================================
# 7. NOVOS APÊNDICES: BOCAS, PATAS, OLHOS, RABOS, ASAS E DEFESA
# ==============================================================================

# --- A. PATA COM CASCO BLINDADO (Herbívoros / Quadrúpedes pesados) ---
func _build_sculpted_hoof_leg(root: Node3D) -> void:
	var mat_skin = _make_organic_material(primary_color, 0.56, 0.05)
	var mat_hoof = _make_keratin_material(secondary_color.darkened(0.45), detail_color)
	var mat_plate = _make_organic_material(secondary_color, 0.36, 0.12)
	var mat_tendon = _make_organic_material(primary_color.darkened(0.14), 0.48, 0.06)

	var pivot = Node3D.new()
	pivot.name = "HoofPivot"
	root.add_child(pivot)

	# 0. Colar muscular de encaixe na anca
	_create_attachment_collar(pivot, mat_skin, 0.145, Vector3(0.0, -0.02, -0.02), Vector3(0.25, 0.0, 0.0))

	# 1. Fêmur e Anca musculosa elíptica
	var thigh_pts: Array[Vector3] = [
		Vector3(0.0, 0.02, -0.04),
		Vector3(0.0, -0.10, 0.04),
		Vector3(0.0, -0.22, 0.11),
		Vector3(0.0, -0.34, 0.16)
	]
	var thigh_rads: Array[float] = [0.135, 0.16, 0.13, 0.095]
	pivot.add_child(_create_lofted_tube(thigh_pts, thigh_rads, 16, mat_skin, 0.0, 0.0, Vector2(0.84, 1.18)))

	# 2. Escudo ósseo duplo no joelho (Patela blindada)
	for k_idx in range(2):
		var ky = float(k_idx) * 0.055
		var knee_pts: Array[Vector3] = [
			Vector3(0.0, -0.26 - ky, 0.20),
			Vector3(0.0, -0.33 - ky, 0.24 - ky * 0.15),
			Vector3(0.0, -0.39 - ky, 0.20 - ky * 0.15)
		]
		var knee_rads: Array[float] = [0.038, 0.076 - ky * 0.15, 0.025]
		pivot.add_child(_create_lofted_tube(knee_pts, knee_rads, 10, mat_plate, 0.0, 0.0, Vector2(1.25, 0.72)))

	# 3. Canela ungulada e Jarrete (Hock) com tendão calcâneo destacado
	var shin_pts: Array[Vector3] = [
		Vector3(0.0, -0.34, 0.15),
		Vector3(0.0, -0.46, 0.05),
		Vector3(0.0, -0.58, -0.04),
		Vector3(0.0, -0.67, 0.02)
	]
	var shin_rads: Array[float] = [0.095, 0.098, 0.072, 0.062]
	pivot.add_child(_create_lofted_tube(shin_pts, shin_rads, 14, mat_skin, 0.0, 0.0, Vector2(0.88, 1.12)))

	# Tendão do jarrete (Hock cord)
	var hock_pts: Array[Vector3] = [
		Vector3(0.0, -0.30, 0.06),
		Vector3(0.0, -0.45, -0.04),
		Vector3(0.0, -0.56, -0.10)
	]
	var hock_rads: Array[float] = [0.032, 0.025, 0.038]
	pivot.add_child(_create_lofted_tube(hock_pts, hock_rads, 8, mat_tendon))

	# Esporão vestigial traseiro no boleto (Fetlock ergot / dewclaw)
	for side in [-1.0, 1.0]:
		var dew_pts: Array[Vector3] = [
			Vector3(side * 0.038, -0.62, -0.03),
			Vector3(side * 0.046, -0.67, -0.08),
			Vector3(side * 0.042, -0.71, -0.09)
		]
		var dew_rads: Array[float] = [0.024, 0.016, 0.004]
		pivot.add_child(_create_lofted_tube(dew_pts, dew_rads, 8, mat_hoof))

	# 4. Banda Coronária carnuda (Coronet band) acima do casco
	var coronet_pts: Array[Vector3] = [
		Vector3(0.0, -0.64, 0.00),
		Vector3(0.0, -0.67, 0.04),
		Vector3(0.0, -0.69, 0.09)
	]
	var coronet_rads: Array[float] = [0.068, 0.082, 0.076]
	pivot.add_child(_create_lofted_tube(coronet_pts, coronet_rads, 12, mat_plate, 0.0, 0.0, Vector2(1.15, 0.95)))

	# 5. Casco Fendido Bipartido (Cloven Hoof — 2 unhas maciças simétricas plantadas no solo Y = -0.75)
	for side in [-1.0, 1.0]:
		var clove_pts: Array[Vector3] = [
			Vector3(side * 0.024, -0.67, 0.04),
			Vector3(side * 0.038, -0.71, 0.11),
			Vector3(side * 0.044, -0.75, 0.19),
			Vector3(side * 0.036, -0.75, 0.26)
		]
		var clove_rads: Array[float] = [0.048, 0.062, 0.065, 0.038]
		pivot.add_child(_create_lofted_tube(clove_pts, clove_rads, 12, mat_hoof, 0.03, 10.0, Vector2(0.85, 1.15)))

# --- B. PATA INSETÓIDE QUITINOSA ARTICULADA ---
func _build_sculpted_insect_leg(root: Node3D) -> void:
	var mat_chitin = _make_organic_material(secondary_color, 0.28, 0.18)
	var mat_joint = _make_organic_material(primary_color.darkened(0.22), 0.35, 0.08)
	var mat_claw = _make_keratin_material(secondary_color.darkened(0.55), detail_color)

	var pivot = Node3D.new()
	pivot.name = "InsectLegPivot"
	root.add_child(pivot)

	# 0. Anel Coxal quitinoso de encaixe no tórax
	_create_attachment_collar(pivot, mat_joint, 0.095, Vector3.ZERO, Vector3(-0.6, 0.0, 0.0))

	# 1. Coxa e Trocânter segmentados
	var coxa_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.09, 0.09),
		Vector3(0.0, 0.15, 0.20)
	]
	var coxa_rads: Array[float] = [0.085, 0.098, 0.072]
	pivot.add_child(_create_lofted_tube(coxa_pts, coxa_rads, 12, mat_chitin, 0.04, 6.0))

	# 2. Fêmur achatado lateralmente com quilha e fileira dupla de espinhos raptoriais
	var femur_pts: Array[Vector3] = [
		Vector3(0.0, 0.14, 0.20),
		Vector3(0.0, 0.02, 0.31),
		Vector3(0.0, -0.16, 0.36),
		Vector3(0.0, -0.32, 0.32)
	]
	var femur_rads: Array[float] = [0.072, 0.088, 0.075, 0.056]
	pivot.add_child(_create_lofted_tube(femur_pts, femur_rads, 12, mat_chitin, 0.0, 0.0, Vector2(0.68, 1.32)))

	# Fileira de espinhos raptoriais ventrais no fêmur
	for s_i in range(4):
		var t_s = 0.22 + float(s_i) * 0.20
		var sp_base = femur_pts[0].lerp(femur_pts[3], t_s) + Vector3(0.0, -0.02, 0.04)
		for side in [-1.0, 1.0]:
			var sp_pts: Array[Vector3] = [
				sp_base + Vector3(side * 0.025, 0.0, 0.0),
				sp_base + Vector3(side * 0.045, -0.045, 0.065)
			]
			var sp_rads: Array[float] = [0.016, 0.002]
			pivot.add_child(_create_lofted_tube(sp_pts, sp_rads, 6, mat_claw))

	# 3. Articulação gínglimo do joelho com placas condilares laterais
	var joint_mesh = MeshInstance3D.new()
	var joint_sphere = SphereMesh.new()
	joint_sphere.radius = 0.064
	joint_sphere.height = 0.128
	joint_mesh.mesh = joint_sphere
	joint_mesh.position = Vector3(0.0, -0.32, 0.32)
	joint_mesh.material_override = mat_joint
	pivot.add_child(joint_mesh)

	var knee_spur_pts: Array[Vector3] = [
		Vector3(0.0, -0.29, 0.34),
		Vector3(0.0, -0.25, 0.42),
		Vector3(0.0, -0.28, 0.46)
	]
	var knee_spur_rads: Array[float] = [0.032, 0.018, 0.002]
	pivot.add_child(_create_lofted_tube(knee_spur_pts, knee_spur_rads, 8, mat_claw))

	# 4. Tíbia arqueada com esporões tibiais e serrilha interna
	var tibia_pts: Array[Vector3] = [
		Vector3(0.0, -0.32, 0.32),
		Vector3(0.0, -0.50, 0.25),
		Vector3(0.0, -0.64, 0.17),
		Vector3(0.0, -0.72, 0.18)
	]
	var tibia_rads: Array[float] = [0.054, 0.046, 0.036, 0.028]
	pivot.add_child(_create_lofted_tube(tibia_pts, tibia_rads, 10, mat_chitin, 0.0, 0.0, Vector2(0.75, 1.25)))

	for tb_i in range(3):
		var tb_pos = tibia_pts[0].lerp(tibia_pts[3], 0.30 + float(tb_i) * 0.25)
		var tb_spur: Array[Vector3] = [
			tb_pos,
			tb_pos + Vector3(0.0, -0.04, 0.06)
		]
		var tb_rads: Array[float] = [0.014, 0.002]
		pivot.add_child(_create_lofted_tube(tb_spur, tb_rads, 6, mat_claw))

	# 5. Tarsômeros segmentados + Pulvilo adesivo (Arolium) + Garras Tarsais Duplas (Ungues)
	var tarsus_pts: Array[Vector3] = [
		Vector3(0.0, -0.71, 0.18),
		Vector3(0.0, -0.74, 0.22),
		Vector3(0.0, -0.75, 0.26)
	]
	var tarsus_rads: Array[float] = [0.028, 0.024, 0.020]
	pivot.add_child(_create_lofted_tube(tarsus_pts, tarsus_rads, 8, mat_joint, 0.08, 6.0))

	for side in [-1.0, 1.0]:
		var claw_pts: Array[Vector3] = [
			Vector3(side * 0.018, -0.73, 0.24),
			Vector3(side * 0.055, -0.74, 0.29),
			Vector3(side * 0.075, -0.75, 0.33)
		]
		var claw_rads: Array[float] = [0.020, 0.012, 0.002]
		pivot.add_child(_create_lofted_tube(claw_pts, claw_rads, 8, mat_claw))

# --- C. BOCA INSETÓIDE (Quelíceras cortantes e glândula de veneno) ---
func _build_sculpted_insectoid_mouth(root: Node3D) -> void:
	var mat_chitin = _make_organic_material(primary_color.darkened(0.18), 0.28, 0.22)
	var mat_plate = _make_organic_material(secondary_color, 0.32, 0.16)
	var mat_mandible = _make_keratin_material(secondary_color.darkened(0.45), detail_color)

	var mat_acid = StandardMaterial3D.new()
	mat_acid.albedo_color = secondary_color.lightened(0.35)
	mat_acid.emission_enabled = true
	mat_acid.emission = secondary_color.lightened(0.45)
	mat_acid.emission_energy_multiplier = 1.5
	mat_acid.roughness = 0.12
	mat_acid.clearcoat_enabled = true
	mat_acid.clearcoat = 1.0

	var mouth_root = Node3D.new()
	mouth_root.name = "InsectMouthRoot"
	root.add_child(mouth_root)

	# 1. Clípeo e Labro (Escudo cefálico quitinoso abaulado)
	var shield_pts: Array[Vector3] = [
		Vector3(0.0, -0.02, 0.01),
		Vector3(0.0, 0.10, 0.06),
		Vector3(0.0, 0.20, 0.07),
		Vector3(0.0, 0.27, 0.04)
	]
	var shield_rads: Array[float] = [0.16, 0.155, 0.125, 0.075]
	mouth_root.add_child(_create_lofted_tube(shield_pts, shield_rads, 14, mat_chitin, 0.04, 6.0, Vector2(1.30, 0.78)))

	# Crista mediana do labro
	var ridge_pts: Array[Vector3] = [
		Vector3(0.0, 0.05, 0.08),
		Vector3(0.0, 0.16, 0.12),
		Vector3(0.0, 0.25, 0.08)
	]
	var ridge_rads: Array[float] = [0.035, 0.045, 0.018]
	mouth_root.add_child(_create_lofted_tube(ridge_pts, ridge_rads, 8, mat_plate))

	# 2. Glândula de Peçonha Bioluminescente e Hipofaringe
	var gland = MeshInstance3D.new()
	var g_sphere = SphereMesh.new()
	g_sphere.radius = 0.068
	g_sphere.height = 0.136
	gland.mesh = g_sphere
	gland.position = Vector3(0.0, 0.18, -0.02)
	gland.material_override = mat_acid
	mouth_root.add_child(gland)

	# 3. Par de Grandes Mandíbulas / Quelíceras Serrilhadas + Palpos Maxilares e Labiais
	for side in [-1.0, 1.0]:
		# Bulbo condilar basal da mandíbula
		var condyle_pts: Array[Vector3] = [
			Vector3(side * 0.10, 0.04, -0.01),
			Vector3(side * 0.15, 0.12, 0.00)
		]
		var condyle_rads: Array[float] = [0.065, 0.072]
		mouth_root.add_child(_create_lofted_tube(condyle_pts, condyle_rads, 10, mat_plate))

		# Pinça mandibular principal achatada com curvatura letal
		var mand_pts: Array[Vector3] = [
			Vector3(side * 0.14, 0.10, -0.01),
			Vector3(side * 0.20, 0.22, -0.02),
			Vector3(side * 0.16, 0.34, 0.01),
			Vector3(side * 0.06, 0.42, 0.03),
			Vector3(side * -0.02, 0.45, 0.04)
		]
		var mand_rads: Array[float] = [0.068, 0.054, 0.036, 0.018, 0.003]
		mouth_root.add_child(_create_lofted_tube(mand_pts, mand_rads, 12, mat_mandible, 0.0, 0.0, Vector2(1.25, 0.72)))

		# 3 Dentes incisivos internos na borda cortante da mandíbula
		for t_i in range(3):
			var f_t = 0.32 + float(t_i) * 0.22
			var m_pos = mand_pts[1].lerp(mand_pts[3], f_t)
			var tooth_pts: Array[Vector3] = [
				m_pos,
				m_pos + Vector3(-side * 0.055, 0.02, 0.01)
			]
			var tooth_rads: Array[float] = [0.020 - float(t_i) * 0.003, 0.002]
			mouth_root.add_child(_create_lofted_tube(tooth_pts, tooth_rads, 6, mat_mandible))

		# Palpo Maxilar longo articulado com bulbo sensorial luminoso na ponta
		var palp_pts: Array[Vector3] = [
			Vector3(side * 0.09, 0.08, -0.06),
			Vector3(side * 0.16, 0.17, -0.10),
			Vector3(side * 0.14, 0.27, -0.12),
			Vector3(side * 0.09, 0.34, -0.09)
		]
		var palp_rads: Array[float] = [0.028, 0.022, 0.016, 0.008]
		mouth_root.add_child(_create_lofted_tube(palp_pts, palp_rads, 8, mat_chitin, 0.08, 8.0))

		var p_tip = MeshInstance3D.new()
		var pt_sph = SphereMesh.new()
		pt_sph.radius = 0.014
		pt_sph.height = 0.028
		p_tip.mesh = pt_sph
		p_tip.position = palp_pts.back()
		p_tip.material_override = mat_acid
		mouth_root.add_child(p_tip)

# --- D. BICO DE AVE DE RAPINA (Curvo e afiado com cera e narinas) ---
func _build_sculpted_beak_mouth(root: Node3D) -> void:
	var mat_cere = _make_organic_material(primary_color, 0.42, 0.05)
	var mat_beak = _make_keratin_material(secondary_color.darkened(0.15), detail_color)
	var mat_tongue = _make_organic_material(Color(0.75, 0.22, 0.26).lerp(primary_color, 0.2), 0.25, 0.05)

	var beak_root = Node3D.new()
	beak_root.name = "BeakRoot"
	root.add_child(beak_root)

	# 1. Cera carnuda na base do bico (Cere) com narinas esculpidas
	var cere_pts: Array[Vector3] = [
		Vector3(0.0, -0.02, 0.01),
		Vector3(0.0, 0.10, 0.05),
		Vector3(0.0, 0.18, 0.04)
	]
	var cere_rads: Array[float] = [0.155, 0.145, 0.112]
	beak_root.add_child(_create_lofted_tube(cere_pts, cere_rads, 14, mat_cere, 0.0, 0.0, Vector2(1.12, 0.92)))

	for side in [-1.0, 1.0]:
		var nostril = MeshInstance3D.new()
		var n_torus = TorusMesh.new()
		n_torus.inner_radius = 0.010
		n_torus.outer_radius = 0.024
		nostril.mesh = n_torus
		nostril.position = Vector3(side * 0.065, 0.12, 0.085)
		nostril.rotation = Vector3(0.3, side * 0.5, 0.0)
		nostril.material_override = mat_cere
		beak_root.add_child(nostril)

	# 2. Rinoteca Superior (Gancho de falcão/grifo com quilha dorsal afiada e dente tomial)
	var hook_pts: Array[Vector3] = [
		Vector3(0.0, 0.15, 0.04),
		Vector3(0.0, 0.27, 0.06),
		Vector3(0.0, 0.38, 0.02),
		Vector3(0.0, 0.45, -0.06),
		Vector3(0.0, 0.43, -0.14)
	]
	var hook_rads: Array[float] = [0.108, 0.092, 0.058, 0.026, 0.003]
	beak_root.add_child(_create_lofted_tube(hook_pts, hook_rads, 14, mat_beak, 0.0, 0.0, Vector2(0.82, 1.22)))

	# Dente Tomial (Tomial tooth de falcão nas bordas cortantes da maxila)
	for side in [-1.0, 1.0]:
		var tomial_pts: Array[Vector3] = [
			Vector3(side * 0.052, 0.28, 0.00),
			Vector3(side * 0.045, 0.33, -0.04),
			Vector3(side * 0.032, 0.36, -0.01)
		]
		var tomial_rads: Array[float] = [0.022, 0.018, 0.003]
		beak_root.add_child(_create_lofted_tube(tomial_pts, tomial_rads, 8, mat_beak))

	# 3. Gnatoteca Inferior (Mandíbula inferior côncava) + Língua farpada
	var lower_pts: Array[Vector3] = [
		Vector3(0.0, 0.06, -0.04),
		Vector3(0.0, 0.19, -0.07),
		Vector3(0.0, 0.31, -0.07),
		Vector3(0.0, 0.36, -0.05)
	]
	var lower_rads: Array[float] = [0.095, 0.075, 0.042, 0.005]
	beak_root.add_child(_create_lofted_tube(lower_pts, lower_rads, 12, mat_beak, 0.0, 0.0, Vector2(0.90, 0.85)))

	var tongue_pts: Array[Vector3] = [
		Vector3(0.0, 0.12, -0.02),
		Vector3(0.0, 0.24, -0.03),
		Vector3(0.0, 0.31, -0.03)
	]
	var tongue_rads: Array[float] = [0.042, 0.028, 0.004]
	beak_root.add_child(_create_lofted_tube(tongue_pts, tongue_rads, 8, mat_tongue, 0.0, 0.0, Vector2(1.2, 0.5)))

# ==============================================================================
# NOVA BOCA 1: MANDÍBULA DENTE-DE-SABRE (Caninos gigantescos, focinho felino e flanges)
# ==============================================================================
func _build_sculpted_saber_mouth(root: Node3D) -> void:
	var mat_skin = _make_organic_material(primary_color, 0.44, 0.05, primary_color.lightened(0.2), 0.28)
	var mat_lip = _make_organic_material(primary_color.darkened(0.25), 0.35, 0.0)
	var mat_gum = _make_organic_material(Color(0.82, 0.20, 0.26).lerp(primary_color, 0.2), 0.20, 0.0, Color(0.95, 0.25, 0.25), 0.45)
	var mat_saber = _make_keratin_material(Color(0.96, 0.94, 0.88), detail_color)
	var mat_tooth = _make_keratin_material(Color(0.92, 0.90, 0.82), detail_color)
	var mat_whisker = _make_keratin_material(primary_color.darkened(0.4), detail_color)

	var saber_root = Node3D.new()
	saber_root.name = "SaberMouthRoot"
	root.add_child(saber_root)

	# 1. Bochechas e músculos temporais/masseteres poderosos
	for side in [-1.0, 1.0]:
		var cheek_pts: Array[Vector3] = [
			Vector3(side * 0.12, 0.02, 0.0),
			Vector3(side * 0.16, 0.12, 0.02),
			Vector3(side * 0.13, 0.22, -0.01)
		]
		var cheek_rads: Array[float] = [0.085, 0.095, 0.065]
		saber_root.add_child(_create_lofted_tube(cheek_pts, cheek_rads, 12, mat_skin))

	# 2. Maxilar Superior Felino com focinho largo e almofadas de bigodes (whisker pads)
	var upper_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.06),
		Vector3(0.0, 0.16, 0.08),
		Vector3(0.0, 0.30, 0.06),
		Vector3(0.0, 0.40, 0.02)
	]
	var upper_rads: Array[float] = [0.18, 0.17, 0.14, 0.08]
	saber_root.add_child(_create_lofted_tube(upper_pts, upper_rads, 16, mat_skin, 0.0, 0.0, Vector2(1.28, 0.78)))

	# Almofadas de caninos/bigodes proeminentes nas laterais do focinho
	for side in [-1.0, 1.0]:
		var pad_pts: Array[Vector3] = [
			Vector3(side * 0.07, 0.22, 0.04),
			Vector3(side * 0.13, 0.30, 0.02),
			Vector3(side * 0.11, 0.37, -0.01)
		]
		var pad_rads: Array[float] = [0.062, 0.068, 0.045]
		saber_root.add_child(_create_lofted_tube(pad_pts, pad_rads, 10, mat_lip))

		# Bigodes rígidos (vibrissas sensoriais)
		for w_i in range(3):
			var w_pts: Array[Vector3] = [
				Vector3(side * 0.14, 0.30 + float(w_i) * 0.03, 0.02 - float(w_i) * 0.02),
				Vector3(side * 0.26, 0.35 + float(w_i) * 0.04, 0.01 - float(w_i) * 0.03)
			]
			var w_rads: Array[float] = [0.006, 0.001]
			saber_root.add_child(_create_lofted_tube(w_pts, w_rads, 4, mat_whisker))

	# Trufa nasal felina esculpida
	var nose_pts: Array[Vector3] = [
		Vector3(0.0, 0.37, 0.05),
		Vector3(0.0, 0.42, 0.03)
	]
	var nose_rads: Array[float] = [0.055, 0.035]
	saber_root.add_child(_create_lofted_tube(nose_pts, nose_rads, 10, mat_lip, 0.0, 0.0, Vector2(1.4, 0.7)))

	# 3. Mandíbula Inferior com Flanges Ósseos Verticais (proteção para os sabres)
	var lower_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, -0.06),
		Vector3(0.0, 0.14, -0.12),
		Vector3(0.0, 0.28, -0.15),
		Vector3(0.0, 0.37, -0.12)
	]
	var lower_rads: Array[float] = [0.15, 0.13, 0.10, 0.055]
	saber_root.add_child(_create_lofted_tube(lower_pts, lower_rads, 14, mat_skin, 0.0, 0.0, Vector2(1.15, 0.85)))

	for side in [-1.0, 1.0]:
		var flange_pts: Array[Vector3] = [
			Vector3(side * 0.08, 0.26, -0.13),
			Vector3(side * 0.10, 0.34, -0.22)
		]
		var flange_rads: Array[float] = [0.045, 0.015]
		saber_root.add_child(_create_lofted_tube(flange_pts, flange_rads, 8, mat_skin, 0.0, 0.0, Vector2(0.65, 1.35)))

	# 4. OS DOIS GIGANTESCOS CANINOS DENTE-DE-SABRE (Curvos, serrilhados e letais)
	for side in [-1.0, 1.0]:
		var saber_pts: Array[Vector3] = [
			Vector3(side * 0.105, 0.32, 0.02),
			Vector3(side * 0.110, 0.34, -0.06),
			Vector3(side * 0.105, 0.35, -0.16),
			Vector3(side * 0.095, 0.33, -0.26),
			Vector3(side * 0.085, 0.30, -0.32)
		]
		var saber_rads: Array[float] = [0.048, 0.042, 0.032, 0.018, 0.003]
		saber_root.add_child(_create_lofted_tube(saber_pts, saber_rads, 12, mat_saber, 0.0, 0.0, Vector2(0.55, 1.45)))

	# 5. Dentes incisivos frontais e caninos inferiores
	for i in range(-2, 3):
		var x_inc = float(i) * 0.028
		var inc_pts: Array[Vector3] = [
			Vector3(x_inc, 0.38, 0.01),
			Vector3(x_inc, 0.39, -0.035)
		]
		var inc_rads: Array[float] = [0.012, 0.002]
		saber_root.add_child(_create_lofted_tube(inc_pts, inc_rads, 6, mat_tooth))

		var low_inc_pts: Array[Vector3] = [
			Vector3(x_inc * 0.85, 0.35, -0.12),
			Vector3(x_inc * 0.85, 0.36, -0.08)
		]
		var low_inc_rads: Array[float] = [0.011, 0.002]
		saber_root.add_child(_create_lofted_tube(low_inc_pts, low_inc_rads, 6, mat_tooth))

	# Língua felina com gengiva
	var tongue_pts: Array[Vector3] = [
		Vector3(0.0, 0.08, -0.04),
		Vector3(0.0, 0.22, -0.07),
		Vector3(0.0, 0.33, -0.08)
	]
	var tongue_rads: Array[float] = [0.08, 0.065, 0.02]
	saber_root.add_child(_create_lofted_tube(tongue_pts, tongue_rads, 10, mat_gum, 0.0, 0.0, Vector2(1.4, 0.5)))

# ==============================================================================
# NOVA BOCA 2: MANDÍBULA DE TUBARÃO / MEGALODONTE (Fileiras múltiplas de dentes triangulares)
# ==============================================================================
func _build_sculpted_shark_mouth(root: Node3D) -> void:
	var mat_shark_skin = _make_organic_material(primary_color.darkened(0.06), 0.30, 0.08, primary_color.lightened(0.15), 0.25)
	var mat_jaw = _make_organic_material(primary_color.darkened(0.22), 0.36, 0.05)
	var mat_gum = _make_organic_material(Color(0.85, 0.18, 0.22).lerp(primary_color, 0.18), 0.18, 0.0, Color(0.95, 0.22, 0.25), 0.48)
	var mat_teeth = _make_keratin_material(Color(0.98, 0.98, 0.95), detail_color)
	var mat_throat = _make_organic_material(Color(0.08, 0.02, 0.04), 0.75, 0.0)

	var shark_root = Node3D.new()
	shark_root.name = "SharkMouthRoot"
	root.add_child(shark_root)

	# 1. Focinho Hidrodinâmico Cônico e Arqueado Superior
	var snout_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.08),
		Vector3(0.0, 0.16, 0.12),
		Vector3(0.0, 0.32, 0.13),
		Vector3(0.0, 0.44, 0.09)
	]
	var snout_rads: Array[float] = [0.18, 0.17, 0.13, 0.04]
	shark_root.add_child(_create_lofted_tube(snout_pts, snout_rads, 16, mat_shark_skin, 0.0, 0.0, Vector2(1.35, 0.72)))

	# 2. Abertura da Boca Ampla Semicircular com Fundo Escuro (Garganta Abissal)
	var throat_mesh = MeshInstance3D.new()
	var t_sph = SphereMesh.new()
	t_sph.radius = 0.13
	t_sph.height = 0.22
	throat_mesh.mesh = t_sph
	throat_mesh.position = Vector3(0.0, 0.15, -0.04)
	throat_mesh.scale = Vector3(1.15, 0.7, 0.6)
	throat_mesh.material_override = mat_throat
	shark_root.add_child(throat_mesh)

	# 3. Arco Mandibular Inferior Curvado Aberto (Cartilagem de Tubarão)
	var lower_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, -0.08),
		Vector3(0.0, 0.15, -0.16),
		Vector3(0.0, 0.28, -0.18),
		Vector3(0.0, 0.38, -0.14)
	]
	var lower_rads: Array[float] = [0.16, 0.14, 0.105, 0.045]
	shark_root.add_child(_create_lofted_tube(lower_pts, lower_rads, 16, mat_jaw, 0.0, 0.0, Vector2(1.30, 0.75)))

	# 4. Gengiva carnuda arqueada protuberante
	var gum_upper_pts: Array[Vector3] = [
		Vector3(0.0, 0.12, 0.02),
		Vector3(0.0, 0.26, 0.04),
		Vector3(0.0, 0.38, 0.02)
	]
	var gum_upper_rads: Array[float] = [0.12, 0.10, 0.05]
	shark_root.add_child(_create_lofted_tube(gum_upper_pts, gum_upper_rads, 12, mat_gum, 0.0, 0.0, Vector2(1.4, 0.5)))

	# 5. MÚLTIPLAS FILEIRAS DE DENTES TRIANGULARES SERRILHADOS
	# Fileira Externa Principal (10 dentes superiores + 10 inferiores)
	var x_teeth = [-0.14, -0.11, -0.08, -0.05, -0.02, 0.02, 0.05, 0.08, 0.11, 0.14]
	for x_t in x_teeth:
		var rad_dist = abs(x_t)
		var y_pos = 0.38 - rad_dist * 0.95
		var tooth_len = 0.065 - rad_dist * 0.15

		# Dente superior apontando para baixo e levemente para trás
		var u_t_pts: Array[Vector3] = [
			Vector3(x_t, y_pos, 0.02),
			Vector3(x_t * 0.95, y_pos - 0.01, 0.02 - tooth_len * 0.5),
			Vector3(x_t * 0.90, y_pos - 0.02, 0.02 - tooth_len)
		]
		var u_t_rads: Array[float] = [0.022, 0.014, 0.002]
		shark_root.add_child(_create_lofted_tube(u_t_pts, u_t_rads, 6, mat_teeth, 0.0, 0.0, Vector2(1.6, 0.5)))

		# Dente inferior apontando para cima
		var l_t_pts: Array[Vector3] = [
			Vector3(x_t * 0.9, y_pos, -0.14),
			Vector3(x_t * 0.85, y_pos - 0.01, -0.14 + tooth_len * 0.5),
			Vector3(x_t * 0.80, y_pos - 0.02, -0.14 + tooth_len)
		]
		var l_t_rads: Array[float] = [0.019, 0.012, 0.002]
		shark_root.add_child(_create_lofted_tube(l_t_pts, l_t_rads, 6, mat_teeth, 0.0, 0.0, Vector2(1.6, 0.5)))

		# Fileira Interna Secundária (dentes de reposição inclinados para dentro)
		if rad_dist < 0.12:
			var u_inner: Array[Vector3] = [
				Vector3(x_t * 0.88, y_pos - 0.04, 0.01),
				Vector3(x_t * 0.85, y_pos - 0.06, 0.01 - tooth_len * 0.65)
			]
			var u_inner_rads: Array[float] = [0.015, 0.002]
			shark_root.add_child(_create_lofted_tube(u_inner, u_inner_rads, 6, mat_teeth))

	# Fendas branquiais e sulcos labiais estéticos
	for side in [-1.0, 1.0]:
		for g_i in range(3):
			var gill = MeshInstance3D.new()
			var g_cyl = CylinderMesh.new()
			g_cyl.top_radius = 0.005
			g_cyl.bottom_radius = 0.005
			g_cyl.height = 0.075
			gill.mesh = g_cyl
			gill.position = Vector3(side * 0.16, 0.04 + float(g_i) * 0.04, -0.02)
			gill.rotation = Vector3(0.3, 0.0, side * 0.4)
			gill.material_override = mat_jaw
			shark_root.add_child(gill)

# ==============================================================================
# NOVA BOCA 3: BOCA SUGADORA / LAMPREIA PARASITA (Ventosa circular com dentes em espiral)
# ==============================================================================
func _build_sculpted_lamprey_mouth(root: Node3D) -> void:
	var mat_outer_rim = _make_organic_material(primary_color, 0.46, 0.06, primary_color.lightened(0.2), 0.35)
	var mat_disc = _make_organic_material(Color(0.76, 0.20, 0.30).lerp(primary_color, 0.25), 0.22, 0.0, Color(0.96, 0.20, 0.25), 0.55)
	var mat_teeth = _make_keratin_material(Color(0.96, 0.86, 0.45).lerp(secondary_color, 0.35), detail_color)
	var mat_gullet = _make_organic_material(Color(0.12, 0.02, 0.04), 0.75, 0.0)

	var lamprey_root = Node3D.new()
	lamprey_root.name = "LampreyMouthRoot"
	root.add_child(lamprey_root)

	# 1. Corpo Muscular Cônico que se expande até a ventosa circular
	var body_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.12, 0.01),
		Vector3(0.0, 0.24, 0.02),
		Vector3(0.0, 0.32, 0.02)
	]
	var body_rads: Array[float] = [0.14, 0.155, 0.185, 0.205]
	lamprey_root.add_child(_create_lofted_tube(body_pts, body_rads, 20, mat_outer_rim, 0.04, 6.0))

	# 2. Lábio Circular Carnudo Exterior com Franjas / Papilas Sensoriais
	var rim_pts: Array[Vector3] = [
		Vector3(0.0, 0.30, 0.02),
		Vector3(0.0, 0.35, 0.02)
	]
	var rim_rads: Array[float] = [0.205, 0.220]
	lamprey_root.add_child(_create_lofted_tube(rim_pts, rim_rads, 24, mat_outer_rim))

	# Papilas periféricas da ventosa (franja sensorial externa com 16 gomos)
	for p_i in range(16):
		var angle = (float(p_i) / 16.0) * TAU
		var p_pos = Vector3(sin(angle) * 0.215, 0.35, cos(angle) * 0.215 + 0.02)
		var papilla = MeshInstance3D.new()
		var p_sph = SphereMesh.new()
		p_sph.radius = 0.016
		p_sph.height = 0.028
		papilla.mesh = p_sph
		papilla.position = p_pos
		papilla.material_override = mat_disc
		lamprey_root.add_child(papilla)

	# 3. Disco Sugador Côncavo voltado para a frente
	var disc_pts: Array[Vector3] = [
		Vector3(0.0, 0.35, 0.02),
		Vector3(0.0, 0.31, 0.02),
		Vector3(0.0, 0.25, 0.02)
	]
	var disc_rads: Array[float] = [0.205, 0.150, 0.075]
	lamprey_root.add_child(_create_lofted_tube(disc_pts, disc_rads, 20, mat_disc))

	# 4. Esôfago / Garganta Profunda Central
	var gullet_mesh = MeshInstance3D.new()
	var g_sph = SphereMesh.new()
	g_sph.radius = 0.072
	g_sph.height = 0.14
	gullet_mesh.mesh = g_sph
	gullet_mesh.position = Vector3(0.0, 0.23, 0.02)
	gullet_mesh.material_override = mat_gullet
	lamprey_root.add_child(gullet_mesh)

	# 5. DENTES CÔRNEOS EM ESPIRAIS CONCÊNTRICAS (24 dentes no total)
	# Anel Externo (12 dentes)
	for i in range(12):
		var a = (float(i) / 12.0) * TAU
		var d_pos = Vector3(sin(a) * 0.165, 0.33, cos(a) * 0.165 + 0.02)
		var t_tip = Vector3(sin(a) * 0.125, 0.28, cos(a) * 0.125 + 0.02)
		var t_pts: Array[Vector3] = [d_pos, t_tip]
		var t_rads: Array[float] = [0.018, 0.002]
		lamprey_root.add_child(_create_lofted_tube(t_pts, t_rads, 6, mat_teeth))

	# Anel Intermediário (8 dentes)
	for i in range(8):
		var a = (float(i) / 8.0) * TAU + 0.35
		var d_pos = Vector3(sin(a) * 0.115, 0.30, cos(a) * 0.115 + 0.02)
		var t_tip = Vector3(sin(a) * 0.085, 0.25, cos(a) * 0.085 + 0.02)
		var t_pts: Array[Vector3] = [d_pos, t_tip]
		var t_rads: Array[float] = [0.016, 0.002]
		lamprey_root.add_child(_create_lofted_tube(t_pts, t_rads, 6, mat_teeth))

	# Anel Interno (4 dentes farpados de ancoragem)
	for i in range(4):
		var a = (float(i) / 4.0) * TAU
		var d_pos = Vector3(sin(a) * 0.075, 0.27, cos(a) * 0.075 + 0.02)
		var t_tip = Vector3(sin(a) * 0.045, 0.22, cos(a) * 0.045 + 0.02)
		var t_pts: Array[Vector3] = [d_pos, t_tip]
		var t_rads: Array[float] = [0.014, 0.002]
		lamprey_root.add_child(_create_lofted_tube(t_pts, t_rads, 6, mat_teeth))

	# 6. Pistão Lingual Central com dente duplo de raspagem
	var piston_pts: Array[Vector3] = [
		Vector3(0.0, 0.19, 0.02),
		Vector3(0.0, 0.26, 0.02)
	]
	var piston_rads: Array[float] = [0.038, 0.032]
	lamprey_root.add_child(_create_lofted_tube(piston_pts, piston_rads, 10, mat_disc))

	for side in [-1.0, 1.0]:
		var tip_pts: Array[Vector3] = [
			Vector3(side * 0.015, 0.26, 0.02),
			Vector3(side * 0.025, 0.29, 0.02)
		]
		var tip_rads: Array[float] = [0.012, 0.002]
		lamprey_root.add_child(_create_lofted_tube(tip_pts, tip_rads, 6, mat_teeth))

# ==============================================================================
# NOVA BOCA 4: MANDÍBULA DE DRAGÃO / RÉPTIL ANCESTRAL (Focinho escamado e língua bífida)
# ==============================================================================
func _build_sculpted_dragon_mouth(root: Node3D) -> void:
	var mat_scales = _make_organic_material(primary_color.darkened(0.08), 0.35, 0.12, primary_color.lightened(0.2), 0.25)
	var mat_plates = _make_keratin_material(secondary_color.darkened(0.35), detail_color)
	var mat_gum = _make_organic_material(Color(0.68, 0.12, 0.18).lerp(primary_color, 0.2), 0.22, 0.0)
	var mat_teeth = _make_keratin_material(Color(0.94, 0.92, 0.82), detail_color)
	var mat_tongue = _make_organic_material(Color(0.85, 0.10, 0.25), 0.18, 0.0, Color(1.0, 0.2, 0.3), 0.55)
	var mat_ember = StandardMaterial3D.new()
	mat_ember.albedo_color = Color(1.0, 0.35, 0.1)
	mat_ember.emission_enabled = true
	mat_ember.emission = Color(1.0, 0.55, 0.1)
	mat_ember.emission_energy_multiplier = 1.8

	var dragon_root = Node3D.new()
	dragon_root.name = "DragonMouthRoot"
	root.add_child(dragon_root)

	# 1. Focinho Reptiliano Longo com crista óssea esculpida
	var snout_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.05),
		Vector3(0.0, 0.18, 0.08),
		Vector3(0.0, 0.36, 0.07),
		Vector3(0.0, 0.50, 0.03)
	]
	var snout_rads: Array[float] = [0.17, 0.155, 0.125, 0.065]
	dragon_root.add_child(_create_lofted_tube(snout_pts, snout_rads, 16, mat_scales, 0.0, 0.0, Vector2(1.25, 0.80)))

	# Crista óssea dorsal com placas pontiagudas sobre o focinho
	for c_i in range(3):
		var y_c = 0.18 + float(c_i) * 0.12
		var scute_pts: Array[Vector3] = [
			Vector3(0.0, y_c, 0.08 - float(c_i) * 0.01),
			Vector3(0.0, y_c + 0.04, 0.15 - float(c_i) * 0.02)
		]
		var scute_rads: Array[float] = [0.035 - float(c_i) * 0.005, 0.004]
		dragon_root.add_child(_create_lofted_tube(scute_pts, scute_rads, 6, mat_plates, 0.0, 0.0, Vector2(0.5, 1.8)))

	# Dois pequenos cornos nasais ameaçadores na ponta do focinho
	for side in [-1.0, 1.0]:
		var hornlet_pts: Array[Vector3] = [
			Vector3(side * 0.05, 0.44, 0.05),
			Vector3(side * 0.08, 0.48, 0.12)
		]
		var hornlet_rads: Array[float] = [0.028, 0.003]
		dragon_root.add_child(_create_lofted_tube(hornlet_pts, hornlet_rads, 8, mat_plates))

		# Narinas flamejantes escavadas
		var nostril = MeshInstance3D.new()
		var n_sph = SphereMesh.new()
		n_sph.radius = 0.018
		n_sph.height = 0.032
		nostril.mesh = n_sph
		nostril.position = Vector3(side * 0.045, 0.46, 0.03)
		nostril.material_override = mat_ember
		dragon_root.add_child(nostril)

	# 2. Mandíbula Inferior Longa com Queixo Escamado
	var lower_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, -0.06),
		Vector3(0.0, 0.16, -0.12),
		Vector3(0.0, 0.32, -0.14),
		Vector3(0.0, 0.46, -0.10)
	]
	var lower_rads: Array[float] = [0.15, 0.13, 0.098, 0.050]
	dragon_root.add_child(_create_lofted_tube(lower_pts, lower_rads, 16, mat_scales, 0.0, 0.0, Vector2(1.20, 0.80)))

	# 3. Flanges angulares espinhosos na articulação da mandíbula (jugais)
	for side in [-1.0, 1.0]:
		var cheek_spk: Array[Vector3] = [
			Vector3(side * 0.13, 0.08, -0.02),
			Vector3(side * 0.22, 0.14, 0.01),
			Vector3(side * 0.28, 0.20, 0.03)
		]
		var cheek_spk_rads: Array[float] = [0.055, 0.032, 0.004]
		dragon_root.add_child(_create_lofted_tube(cheek_spk, cheek_spk_rads, 8, mat_plates))

	# 4. Dentes de Crocodilo/Dragão Intertravados (12 superiores e 12 inferiores)
	for i in range(-5, 6):
		var f_i = float(i)
		var is_center = abs(i) <= 1
		var is_great_fang = abs(i) == 3
		var len_f = 1.45 if is_great_fang else (0.75 if is_center else 1.05)
		var x_pos = f_i * 0.024
		var y_pos = 0.46 - abs(f_i) * 0.032

		# Dente superior apontando para baixo
		var u_t_pts: Array[Vector3] = [
			Vector3(x_pos, y_pos, 0.01),
			Vector3(x_pos * 0.95, y_pos + 0.01, 0.01 - 0.065 * len_f)
		]
		var u_t_rads: Array[float] = [0.018 * len_f, 0.002]
		dragon_root.add_child(_create_lofted_tube(u_t_pts, u_t_rads, 6, mat_teeth))

		# Dente inferior apontando para cima
		var l_t_pts: Array[Vector3] = [
			Vector3(x_pos * 0.9, y_pos - 0.02, -0.10),
			Vector3(x_pos * 0.9, y_pos - 0.01, -0.10 + 0.055 * len_f)
		]
		var l_t_rads: Array[float] = [0.016 * len_f, 0.002]
		dragon_root.add_child(_create_lofted_tube(l_t_pts, l_t_rads, 6, mat_teeth))

	# 5. LÍNGUA BÍFIDA BIFURCADA SAINDO PARA A FRENTE DA BOCA
	var tongue_pts: Array[Vector3] = [
		Vector3(0.0, 0.10, -0.04),
		Vector3(0.0, 0.25, -0.05),
		Vector3(0.0, 0.38, -0.04),
		Vector3(0.0, 0.45, -0.02)
	]
	var tongue_rads: Array[float] = [0.065, 0.050, 0.035, 0.022]
	dragon_root.add_child(_create_lofted_tube(tongue_pts, tongue_rads, 10, mat_tongue, 0.0, 0.0, Vector2(1.5, 0.5)))

	# Bifurcação em duas pontas afiladas na ponta da língua
	for side in [-1.0, 1.0]:
		var fork_pts: Array[Vector3] = [
			Vector3(0.0, 0.45, -0.02),
			Vector3(side * 0.028, 0.52, -0.01),
			Vector3(side * 0.045, 0.58, 0.0)
		]
		var fork_rads: Array[float] = [0.018, 0.011, 0.002]
		dragon_root.add_child(_create_lofted_tube(fork_pts, fork_rads, 6, mat_tongue))


# --- E. OLHO COMPOSTO INSETÓIDE (Facetado esmeralda com brilho) ---
func _build_sculpted_compound_eye(root: Node3D) -> void:
	var mat_socket = _make_organic_material(primary_color.darkened(0.22), 0.34, 0.12)
	var mat_bristle = _make_keratin_material(secondary_color.darkened(0.4), detail_color)

	var mat_facet = StandardMaterial3D.new()
	mat_facet.albedo_color = secondary_color
	mat_facet.metallic = 0.45
	mat_facet.roughness = 0.10
	mat_facet.clearcoat_enabled = true
	mat_facet.clearcoat = 1.0
	mat_facet.clearcoat_roughness = 0.04
	mat_facet.emission_enabled = true
	mat_facet.emission = secondary_color.lightened(0.28)
	mat_facet.emission_energy_multiplier = 0.65
	mat_facet.normal_enabled = true
	mat_facet.normal_scale = 0.65
	mat_facet.normal_texture = _get_organic_normal_tex()

	var mat_ommatidia = StandardMaterial3D.new()
	mat_ommatidia.albedo_color = detail_color.lightened(0.25)
	mat_ommatidia.metallic = 0.6
	mat_ommatidia.roughness = 0.05
	mat_ommatidia.emission_enabled = true
	mat_ommatidia.emission = detail_color
	mat_ommatidia.emission_energy_multiplier = 0.9

	var eye_root = Node3D.new()
	eye_root.name = "CompoundEyeRoot"
	root.add_child(eye_root)

	# 1. Esclerito Ocular Quitinoso (Anel de implantação esculpido)
	var socket = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.095
	torus.outer_radius = 0.175
	torus.rings = 20
	torus.ring_segments = 12
	socket.mesh = torus
	socket.position = Vector3(0.0, 0.055, 0.0)
	socket.material_override = mat_socket
	eye_root.add_child(socket)

	# Crista supra-orbital quitinosa com 3 cerdas sensoriais táteis
	var ridge_pts: Array[Vector3] = [
		Vector3(-0.14, 0.07, 0.08),
		Vector3(0.0, 0.10, 0.15),
		Vector3(0.14, 0.07, 0.08)
	]
	var ridge_rads: Array[float] = [0.025, 0.042, 0.025]
	eye_root.add_child(_create_lofted_tube(ridge_pts, ridge_rads, 8, mat_socket))

	for b_x in [-0.08, 0.0, 0.08]:
		var br_pts: Array[Vector3] = [
			Vector3(b_x, 0.09, 0.13),
			Vector3(b_x * 1.4, 0.16, 0.21)
		]
		var br_rads: Array[float] = [0.010, 0.001]
		eye_root.add_child(_create_lofted_tube(br_pts, br_rads, 6, mat_bristle))

	# 2. Cúpula Facetada Principal
	var dome = MeshInstance3D.new()
	var s_mesh = SphereMesh.new()
	s_mesh.radius = 0.145
	s_mesh.height = 0.27
	s_mesh.radial_segments = 28
	s_mesh.rings = 18
	dome.mesh = s_mesh
	dome.position = Vector3(0.0, 0.12, 0.0)
	dome.material_override = mat_facet
	eye_root.add_child(dome)

	# 3. Mosaico de Omatídeos (Micro-lentes 3D em relevo sobre a cúpula)
	var ring_configs = [
		{"r_angle": 0.0, "count": 1},
		{"r_angle": 0.35, "count": 6},
		{"r_angle": 0.68, "count": 10}
	]
	for rc in ring_configs:
		var r_a: float = rc["r_angle"]
		var cnt: int = rc["count"]
		for k in range(cnt):
			var phi = float(k) * TAU / float(cnt)
			var dir = Vector3(sin(r_a) * cos(phi), cos(r_a), sin(r_a) * sin(phi))
			var omm = MeshInstance3D.new()
			var o_sph = SphereMesh.new()
			o_sph.radius = 0.024
			o_sph.height = 0.032
			o_sph.radial_segments = 10
			o_sph.rings = 6
			omm.mesh = o_sph
			omm.position = Vector3(0.0, 0.12, 0.0) + dir * 0.132
			omm.material_override = mat_ommatidia
			eye_root.add_child(omm)

# --- F. OLHO PEDUNCULADO (Sobre haste móvel) ---
func _build_sculpted_stalk_eye(root: Node3D) -> void:
	var mat_stalk = _make_organic_material(primary_color, 0.48, 0.05)
	var mat_cup = _make_organic_material(secondary_color, 0.40, 0.08)

	var mat_sclera = StandardMaterial3D.new()
	mat_sclera.albedo_color = Color(0.97, 0.96, 0.92)
	mat_sclera.roughness = 0.04
	mat_sclera.clearcoat_enabled = true
	mat_sclera.clearcoat = 1.0
	mat_sclera.clearcoat_roughness = 0.03

	var mat_iris = StandardMaterial3D.new()
	mat_iris.albedo_color = detail_color
	mat_iris.roughness = 0.12
	mat_iris.emission_enabled = true
	mat_iris.emission = detail_color.lightened(0.25)
	mat_iris.emission_energy_multiplier = 0.75

	var mat_pupil = StandardMaterial3D.new()
	mat_pupil.albedo_color = Color(0.03, 0.03, 0.04)
	mat_pupil.roughness = 0.02

	var mat_glint = StandardMaterial3D.new()
	mat_glint.albedo_color = Color.WHITE
	mat_glint.emission_enabled = true
	mat_glint.emission = Color.WHITE
	mat_glint.emission_energy_multiplier = 2.0

	var stalk_root = Node3D.new()
	stalk_root.name = "StalkEyeRoot"
	root.add_child(stalk_root)

	# 0. Colar basal muscular
	_create_attachment_collar(stalk_root, mat_stalk, 0.09, Vector3(0.0, 0.02, 0.0))

	# 1. Pedúnculo carnudo sinuoso com anéis retráteis
	var stalk_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.12, 0.04),
		Vector3(0.0, 0.25, 0.09),
		Vector3(0.0, 0.36, 0.06)
	]
	var stalk_rads: Array[float] = [0.085, 0.062, 0.052, 0.078]
	stalk_root.add_child(_create_lofted_tube(stalk_pts, stalk_rads, 14, mat_stalk, 0.065, 9.0))

	# 2. Cálice palpebral superior no topo do pedúnculo
	var brow_pts: Array[Vector3] = [
		Vector3(-0.08, 0.38, 0.03),
		Vector3(0.0, 0.43, 0.01),
		Vector3(0.08, 0.38, 0.03)
	]
	var brow_rads: Array[float] = [0.024, 0.040, 0.024]
	stalk_root.add_child(_create_lofted_tube(brow_pts, brow_rads, 10, mat_cup))

	# 3. Bulbo Ocular Vítreo
	var ball_center = Vector3(0.0, 0.39, 0.07)
	var ball = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.096
	sphere.height = 0.192
	ball.mesh = sphere
	ball.position = ball_center
	ball.material_override = mat_sclera
	stalk_root.add_child(ball)

	# 4. Íris Luminosa + Pupila horizontal de cefalópode/anfíbio + Reflexo especular
	var iris = MeshInstance3D.new()
	var i_sph = SphereMesh.new()
	i_sph.radius = 0.056
	i_sph.height = 0.072
	iris.mesh = i_sph
	iris.position = ball_center + Vector3(0.0, 0.045, 0.055)
	iris.material_override = mat_iris
	stalk_root.add_child(iris)

	var pupil = MeshInstance3D.new()
	var p_sph = SphereMesh.new()
	p_sph.radius = 0.036
	p_sph.height = 0.045
	pupil.mesh = p_sph
	pupil.scale = Vector3(1.15, 0.55, 0.85)
	pupil.position = ball_center + Vector3(0.0, 0.055, 0.068)
	pupil.material_override = mat_pupil
	stalk_root.add_child(pupil)

	var glint = MeshInstance3D.new()
	var g_sph = SphereMesh.new()
	g_sph.radius = 0.014
	g_sph.height = 0.028
	glint.mesh = g_sph
	glint.position = ball_center + Vector3(0.025, 0.072, 0.072)
	glint.material_override = mat_glint
	stalk_root.add_child(glint)

# --- G. ANTENA SENSORIAL BIOLUMINESCENTE ---
func _build_sculpted_antenna(root: Node3D) -> void:
	var mat_base = _make_organic_material(primary_color.darkened(0.15), 0.38, 0.12)
	var mat_ant = _make_organic_material(secondary_color, 0.35, 0.15)
	var mat_glow = StandardMaterial3D.new()
	mat_glow.albedo_color = detail_color.lightened(0.2)
	mat_glow.emission_enabled = true
	mat_glow.emission = detail_color
	mat_glow.emission_energy_multiplier = 1.85
	mat_glow.roughness = 0.10

	var ant_root = Node3D.new()
	ant_root.name = "AntennaRoot"
	root.add_child(ant_root)

	# 1. Tórulo (Soquete articular basal) + Escapo robusto
	_create_attachment_collar(ant_root, mat_base, 0.065, Vector3(0.0, 0.015, 0.0))

	# 2. Flagelo longo arqueado com anéis sensoriais (ring_amp = 0.075, ring_freq = 16.0)
	var ant_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.15, -0.04),
		Vector3(0.0, 0.34, -0.06),
		Vector3(0.0, 0.52, 0.03),
		Vector3(0.0, 0.66, 0.16)
	]
	var ant_rads: Array[float] = [0.054, 0.040, 0.028, 0.018, 0.009]
	ant_root.add_child(_create_lofted_tube(ant_pts, ant_rads, 10, mat_ant, 0.075, 16.0))

	# 3. Plumas Pectinadas Laterais (Filamentos sensoriais de mariposa/inseto alienígena com pontas luminosas)
	for b_i in range(5):
		var t_b = 0.25 + float(b_i) * 0.14
		var b_origin = _eval_catmull_chain(ant_pts, t_b)
		var b_len = 0.095 * (1.0 - float(b_i) * 0.11)
		for side in [-1.0, 1.0]:
			var barb_pts: Array[Vector3] = [
				b_origin,
				b_origin + Vector3(side * b_len * 0.6, 0.025, 0.02),
				b_origin + Vector3(side * b_len, 0.05, 0.045)
			]
			var barb_rads: Array[float] = [0.011, 0.007, 0.002]
			ant_root.add_child(_create_lofted_tube(barb_pts, barb_rads, 6, mat_ant))

			var node_orb = MeshInstance3D.new()
			var n_sph = SphereMesh.new()
			n_sph.radius = 0.009
			n_sph.height = 0.018
			node_orb.mesh = n_sph
			node_orb.position = barb_pts.back()
			node_orb.material_override = mat_glow
			ant_root.add_child(node_orb)

	# 4. Bulbo Bioluminescente Apical Principal (Lanterna de Anglerfish / Sensor Químico)
	var tip = MeshInstance3D.new()
	var t_sph = SphereMesh.new()
	t_sph.radius = 0.036
	t_sph.height = 0.082
	tip.mesh = t_sph
	tip.position = Vector3(0.0, 0.68, 0.18)
	tip.rotation = Vector3(-0.6, 0.0, 0.0)
	tip.material_override = mat_glow
	ant_root.add_child(tip)

# --- H. CAUDA COM CLAVA ÓSSEA / MAÇA DE ANQUILOSSAURO ---
func _build_sculpted_club_tail(root: Node3D) -> void:
	var mat_skin = _make_organic_material(primary_color, 0.54, 0.05)
	var mat_plate = _make_organic_material(secondary_color, 0.38, 0.12)
	var mat_bone = _make_keratin_material(secondary_color.darkened(0.28), detail_color)

	var tail_root = Node3D.new()
	tail_root.name = "ClubTailRoot"
	root.add_child(tail_root)

	# 0. Colar muscular da base da cauda
	_create_attachment_collar(tail_root, mat_skin, 0.135, Vector3(0.0, 0.02, 0.0))

	# 1. Coluna da cauda encouraçada com anéis musculares
	var tail_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.15, -0.06),
		Vector3(0.0, 0.32, -0.10),
		Vector3(0.0, 0.48, -0.06),
		Vector3(0.0, 0.62, 0.02)
	]
	var tail_rads: Array[float] = [0.125, 0.105, 0.088, 0.076, 0.082]
	tail_root.add_child(_create_lofted_tube(tail_pts, tail_rads, 14, mat_skin, 0.035, 8.0, Vector2(1.12, 0.90)))

	# 2. Pares de Osteodermas Dorsolaterais (Placas ósseas protetoras ao longo da cauda)
	for seg_i in range(3):
		var t_seg = 0.22 + float(seg_i) * 0.24
		var c_pos = _eval_catmull_chain(tail_pts, t_seg)
		var r_seg = 0.095 - float(seg_i) * 0.012
		for side in [-1.0, 1.0]:
			var ost_pts: Array[Vector3] = [
				c_pos + Vector3(side * r_seg * 0.65, -0.02, -0.01),
				c_pos + Vector3(side * r_seg * 1.35, 0.03, -0.04),
				c_pos + Vector3(side * r_seg * 0.95, 0.07, -0.06)
			]
			var ost_rads: Array[float] = [0.032, 0.042, 0.008]
			tail_root.add_child(_create_lofted_tube(ost_pts, ost_rads, 8, mat_plate, 0.0, 0.0, Vector2(0.65, 1.35)))

	# 3. Maça Óssea de Anquilossauro (2 Grandes Lobos Laterais Fundidos + Protuberância Terminal)
	var club_center = Vector3(0.0, 0.66, 0.04)
	for side in [-1.0, 1.0]:
		var lobe_pts: Array[Vector3] = [
			club_center + Vector3(side * 0.03, -0.10, -0.03),
			club_center + Vector3(side * 0.11, 0.0, 0.0),
			club_center + Vector3(side * 0.05, 0.10, 0.03)
		]
		var lobe_rads: Array[float] = [0.065, 0.115, 0.055]
		tail_root.add_child(_create_lofted_tube(lobe_pts, lobe_rads, 12, mat_plate, 0.0, 0.0, Vector2(1.15, 0.85)))

	var apex_lobe: Array[Vector3] = [
		club_center + Vector3(0.0, 0.02, 0.0),
		club_center + Vector3(0.0, 0.13, 0.03),
		club_center + Vector3(0.0, 0.21, 0.05)
	]
	var apex_rads: Array[float] = [0.095, 0.082, 0.015]
	tail_root.add_child(_create_lofted_tube(apex_lobe, apex_rads, 12, mat_bone))

	# 4. 6 Espinhos Esmagadores Cônicos (Morningstar spikes)
	for angle in [0.0, 1.047, 2.094, 3.141, 4.188, 5.235]:
		var dir = Vector3(cos(angle) * 1.15, sin(angle) * 0.35, sin(angle) * 0.95)
		var spike_pts: Array[Vector3] = [
			club_center + dir * 0.07,
			club_center + dir * 0.15,
			club_center + dir * 0.22
		]
		var spike_rads: Array[float] = [0.045, 0.026, 0.004]
		tail_root.add_child(_create_lofted_tube(spike_pts, spike_rads, 8, mat_bone))

# --- I. LEME EMPLUMADO / CAUDA DE PENAS ---
func _build_sculpted_feather_tail(root: Node3D) -> void:
	var mat_tail = _make_organic_material(primary_color, 0.48, 0.05)
	var mat_covert = _make_organic_material(primary_color.lightened(0.12), 0.36, 0.10)
	var mat_feather = _make_organic_material(secondary_color, 0.30, 0.14)
	var mat_quill = _make_keratin_material(secondary_color.darkened(0.35), detail_color)

	var mat_ocellus = StandardMaterial3D.new()
	mat_ocellus.albedo_color = detail_color
	mat_ocellus.emission_enabled = true
	mat_ocellus.emission = detail_color.lightened(0.2)
	mat_ocellus.emission_energy_multiplier = 0.75
	mat_ocellus.roughness = 0.18

	var tail_root = Node3D.new()
	tail_root.name = "FeatherTailRoot"
	root.add_child(tail_root)

	# 0. Colar basal + Haste caudal (Pigóstilo)
	_create_attachment_collar(tail_root, mat_tail, 0.11, Vector3(0.0, 0.02, 0.0))

	var tail_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.16, -0.04),
		Vector3(0.0, 0.32, -0.06),
		Vector3(0.0, 0.46, -0.02)
	]
	var tail_rads: Array[float] = [0.105, 0.085, 0.068, 0.048]
	tail_root.add_child(_create_lofted_tube(tail_pts, tail_rads, 12, mat_tail))

	# 1. Leque de 7 Grandes Retrizes (Penas caudais achatadas como lâminas + ráquis central + ocelo de pavão/fênix)
	var fan_origin = Vector3(0.0, 0.42, -0.02)
	var angles = [-0.66, -0.44, -0.22, 0.0, 0.22, 0.44, 0.66]
	for idx in range(angles.size()):
		var a: float = angles[idx]
		var len_mult = 1.0 - abs(a) * 0.28
		var f_dir = Vector3(sin(a) * 0.38, 0.48 * len_mult, cos(a) * 0.12 - 0.04)
		var f_mid = fan_origin + f_dir * 0.52
		var f_tip = fan_origin + f_dir

		# Vexilo da pena (achatado: aspect_xy = Vector2(1.65, 0.22))
		var f_pts: Array[Vector3] = [fan_origin, f_mid, f_tip]
		var f_rads: Array[float] = [0.028, 0.068, 0.012]
		tail_root.add_child(_create_lofted_tube(f_pts, f_rads, 10, mat_feather, 0.0, 0.0, Vector2(1.65, 0.22)))

		# Ráquis central (haste da pena)
		var q_rads: Array[float] = [0.014, 0.009, 0.002]
		tail_root.add_child(_create_lofted_tube(f_pts, q_rads, 6, mat_quill))

		# Ocelo brilhante na ponta das 5 penas centrais
		if abs(a) < 0.50:
			var eye_spot = MeshInstance3D.new()
			var e_sph = SphereMesh.new()
			e_sph.radius = 0.026
			e_sph.height = 0.018
			eye_spot.mesh = e_sph
			eye_spot.position = fan_origin.lerp(f_tip, 0.80)
			eye_spot.material_override = mat_ocellus
			tail_root.add_child(eye_spot)

	# 2. Camada de Coberteiras Superiores (5 plumas menores sobrepostas na base do leque)
	for c_a in [-0.40, -0.20, 0.0, 0.20, 0.40]:
		var c_dir = Vector3(sin(c_a) * 0.22, 0.24, cos(c_a) * 0.08 + 0.02)
		var c_pts: Array[Vector3] = [
			fan_origin + Vector3(0.0, -0.04, 0.02),
			fan_origin + c_dir * 0.55,
			fan_origin + c_dir
		]
		var c_rads: Array[float] = [0.025, 0.052, 0.008]
		tail_root.add_child(_create_lofted_tube(c_pts, c_rads, 8, mat_covert, 0.0, 0.0, Vector2(1.5, 0.25)))

# --- J. ASA INSETÓIDE DUPLA (Libélula translúcida) ---
func _build_sculpted_insect_wing(root: Node3D) -> void:
	var mat_hinge = _make_organic_material(primary_color.darkened(0.18), 0.35, 0.15)
	var mat_vein = _make_keratin_material(secondary_color.darkened(0.4), detail_color)
	var mat_stigma = _make_organic_material(detail_color.darkened(0.15), 0.25, 0.20)

	var mat_membrane = StandardMaterial3D.new()
	mat_membrane.albedo_color = Color(secondary_color.r, secondary_color.g, secondary_color.b, 0.58)
	mat_membrane.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_membrane.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat_membrane.roughness = 0.08
	mat_membrane.metallic = 0.35
	mat_membrane.clearcoat_enabled = true
	mat_membrane.clearcoat = 1.0
	mat_membrane.clearcoat_roughness = 0.05
	mat_membrane.rim_enabled = true
	mat_membrane.rim = 0.75

	var wing_pivot = Node3D.new()
	wing_pivot.name = "InsectWingPivot"
	root.add_child(wing_pivot)

	# 1. Esclerito Axilar / Bulbo Muscular Torácico da Asa
	var hinge_pts: Array[Vector3] = [
		Vector3(0.0, -0.02, 0.0),
		Vector3(0.0, 0.08, 0.02),
		Vector3(0.0, 0.16, 0.01)
	]
	var hinge_rads: Array[float] = [0.085, 0.095, 0.065]
	wing_pivot.add_child(_create_lofted_tube(hinge_pts, hinge_rads, 10, mat_hinge))

	# 2. Par de Asas de Libélula (Anterior longa + Posterior ligeiramente menor e angulada)
	var wing_configs = [
		{
			"origin": Vector3(0.0, 0.12, 0.04),
			"perim": [
				Vector3(0.0, 0.12, 0.04),
				Vector3(0.0, 0.55, 0.20),
				Vector3(0.0, 1.05, 0.26),
				Vector3(0.0, 1.48, 0.18),
				Vector3(0.0, 1.56, 0.04),
				Vector3(0.0, 1.42, -0.14),
				Vector3(0.0, 1.05, -0.22),
				Vector3(0.0, 0.60, -0.20),
				Vector3(0.0, 0.24, -0.08)
			]
		},
		{
			"origin": Vector3(0.0, 0.08, -0.06),
			"perim": [
				Vector3(0.0, 0.08, -0.06),
				Vector3(0.0, 0.45, -0.14),
				Vector3(0.0, 0.85, -0.22),
				Vector3(0.0, 1.18, -0.32),
				Vector3(0.0, 1.22, -0.46),
				Vector3(0.0, 1.04, -0.60),
				Vector3(0.0, 0.72, -0.58),
				Vector3(0.0, 0.38, -0.44),
				Vector3(0.0, 0.14, -0.22)
			]
		}
	]

	for wc in wing_configs:
		var orig: Vector3 = wc["origin"]
		var raw_perim: Array = wc["perim"]
		var perim: Array[Vector3] = []
		for p in raw_perim:
			perim.append(p)

		# Nervura Costal (Bordo de ataque espesso)
		var costa_pts: Array[Vector3] = [perim[0], perim[1], perim[2], perim[3], perim[4]]
		var costa_rads: Array[float] = [0.038, 0.028, 0.020, 0.012, 0.004]
		wing_pivot.add_child(_create_lofted_tube(costa_pts, costa_rads, 8, mat_vein))

		# Nervuras Radiais e Medianas ramificadas pelo interior da asa
		for v_idx in [5, 6, 7]:
			var v_pts: Array[Vector3] = [
				orig,
				orig.lerp(perim[v_idx], 0.52) + Vector3(0.0, 0.04, 0.04),
				perim[v_idx]
			]
			var v_rads: Array[float] = [0.022, 0.012, 0.003]
			wing_pivot.add_child(_create_lofted_tube(v_pts, v_rads, 6, mat_vein))

		# Pterostigma (Célula quitinosa pigmentada perto da ponta do bordo de ataque)
		var stigma_pts: Array[Vector3] = [
			perim[2].lerp(perim[3], 0.35) + Vector3(0.0, 0.0, -0.03),
			perim[3] + Vector3(0.0, 0.0, -0.03)
		]
		var stigma_rads: Array[float] = [0.022, 0.018]
		wing_pivot.add_child(_create_lofted_tube(stigma_pts, stigma_rads, 6, mat_stigma, 0.0, 0.0, Vector2(0.4, 1.6)))

		# Membrana translúcida iridescente
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		st.set_smooth_group(0)
		var hub = (perim[0] + perim[2] + perim[6]) / 3.0
		for i in range(perim.size()):
			var p_a = perim[i]
			var p_b = perim[(i + 1) % perim.size()]
			st.add_vertex(hub)
			st.add_vertex(p_a)
			st.add_vertex(p_b)
		st.index()
		st.generate_normals()

		var w_mesh = MeshInstance3D.new()
		w_mesh.mesh = st.commit()
		w_mesh.material_override = mat_membrane
		wing_pivot.add_child(w_mesh)

# --- K. ASA EMPLUMADA DE AVE ---
func _build_sculpted_feather_wing(root: Node3D) -> void:
	var mat_arm = _make_organic_material(primary_color, 0.48, 0.05)
	var mat_lesser = _make_organic_material(primary_color.lightened(0.10), 0.38, 0.08)
	var mat_secondary = _make_organic_material(secondary_color.lerp(primary_color, 0.35), 0.34, 0.10)
	var mat_primary = _make_organic_material(secondary_color, 0.30, 0.14)
	var mat_quill = _make_keratin_material(secondary_color.darkened(0.35), detail_color)

	var wing_pivot = Node3D.new()
	wing_pivot.name = "FeatherWingPivot"
	root.add_child(wing_pivot)

	# 0. Colar escapular no ombro
	_create_attachment_collar(wing_pivot, mat_arm, 0.105, Vector3(0.0, 0.02, 0.0))

	# 1. Braço Esquelético da Asa (Úmero, Rádio/Ulna e Carpometacarpo)
	var arm_pts: Array[Vector3] = [
		Vector3.ZERO,
		Vector3(0.0, 0.36, 0.22),
		Vector3(0.0, 0.82, 0.14),
		Vector3(0.0, 1.32, -0.18)
	]
	var arm_rads: Array[float] = [0.095, 0.075, 0.052, 0.024]
	wing_pivot.add_child(_create_lofted_tube(arm_pts, arm_rads, 12, mat_arm))

	# Álula (Bastard wing — tufo aerodinâmico de 2 penas no polegar da asa)
	for al_i in range(2):
		var al_pts: Array[Vector3] = [
			Vector3(0.0, 0.78 + float(al_i) * 0.08, 0.15),
			Vector3(0.0, 0.94 + float(al_i) * 0.08, 0.22),
			Vector3(0.0, 1.08 + float(al_i) * 0.06, 0.18)
		]
		var al_rads: Array[float] = [0.022, 0.036, 0.005]
		wing_pivot.add_child(_create_lofted_tube(al_pts, al_rads, 8, mat_lesser, 0.0, 0.0, Vector2(0.28, 1.45)))

	# 2. Camada 1: Rêmiges Primárias e Secundárias (9 longas penas de voo com ráquis)
	var primary_count = 9
	for i in range(primary_count):
		var t = float(i) / float(primary_count - 1)
		var root_pos = _eval_catmull_chain(arm_pts, 0.18 + t * 0.80)
		var span_y = lerpf(0.22, 1.54, t)
		var trail_z = lerpf(-0.62, -0.36, t) - sin(t * PI) * 0.28
		var tip_pos = Vector3(0.0, span_y, trail_z)
		var mid_pos = root_pos.lerp(tip_pos, 0.52) + Vector3(0.0, 0.04, -0.05)

		var f_pts: Array[Vector3] = [root_pos, mid_pos, tip_pos]
		var f_rads: Array[float] = [0.028, 0.078, 0.010]
		wing_pivot.add_child(_create_lofted_tube(f_pts, f_rads, 10, mat_primary, 0.0, 0.0, Vector2(0.22, 1.65)))

		var q_rads: Array[float] = [0.014, 0.009, 0.002]
		wing_pivot.add_child(_create_lofted_tube(f_pts, q_rads, 6, mat_quill))

	# 3. Camada 2: Coberteiras Médias (7 penas intermediárias sobrepostas em ambos os lados)
	var covert_count = 7
	for i in range(covert_count):
		var t = float(i) / float(covert_count - 1)
		var root_pos = _eval_catmull_chain(arm_pts, 0.12 + t * 0.74)
		var tip_pos = Vector3(0.0, lerpf(0.20, 1.22, t), lerpf(-0.34, -0.14, t) - sin(t * PI) * 0.16)
		var c_pts: Array[Vector3] = [root_pos, root_pos.lerp(tip_pos, 0.55), tip_pos]
		var c_rads: Array[float] = [0.032, 0.068, 0.012]
		wing_pivot.add_child(_create_lofted_tube(c_pts, c_rads, 8, mat_secondary, 0.0, 0.0, Vector2(0.32, 1.45)))

	# 4. Camada 3: Coberteiras Menores Escapulares (5 plumas curtas macias junto ao bordo de ataque)
	for i in range(5):
		var t = float(i) / 4.0
		var root_pos = _eval_catmull_chain(arm_pts, 0.08 + t * 0.62)
		var tip_pos = root_pos + Vector3(0.0, 0.08, -0.24)
		var l_pts: Array[Vector3] = [root_pos, root_pos.lerp(tip_pos, 0.5), tip_pos]
		var l_rads: Array[float] = [0.036, 0.058, 0.014]
		wing_pivot.add_child(_create_lofted_tube(l_pts, l_rads, 8, mat_lesser, 0.0, 0.0, Vector2(0.42, 1.30)))

# --- L. GALHADA / CHIFRE RAMIFICADO DE CERVO ---
func _build_sculpted_antler_horn(root: Node3D) -> void:
	var mat_pedicle = _make_organic_material(primary_color.darkened(0.12), 0.55, 0.05)
	var mat_coronet = _make_organic_material(secondary_color.darkened(0.22), 0.48, 0.08)
	var mat_antler = _make_keratin_material(secondary_color.darkened(0.32), detail_color)

	var horn_root = Node3D.new()
	horn_root.name = "AntlerRoot"
	root.add_child(horn_root)

	# 1. Pedículo Craniano + Roseta rugosa (Burr coronet ring)
	_create_attachment_collar(horn_root, mat_pedicle, 0.095, Vector3(0.0, 0.015, 0.0))

	var burr_pts: Array[Vector3] = [
		Vector3(0.0, 0.01, 0.0),
		Vector3(0.0, 0.05, 0.0),
		Vector3(0.0, 0.08, -0.01)
	]
	var burr_rads: Array[float] = [0.082, 0.102, 0.078]
	horn_root.add_child(_create_lofted_tube(burr_pts, burr_rads, 12, mat_coronet, 0.08, 6.0))

	# 2. Haste Mestra (Main Beam) arqueada com textura rugosa (ring_amp = 0.035, ring_freq = 12.0)
	var main_pts: Array[Vector3] = [
		Vector3(0.0, 0.05, 0.0),
		Vector3(0.0, 0.18, -0.05),
		Vector3(0.0, 0.36, -0.07),
		Vector3(0.0, 0.54, 0.03),
		Vector3(0.0, 0.72, 0.20)
	]
	var main_rads: Array[float] = [0.082, 0.068, 0.054, 0.038, 0.005]
	horn_root.add_child(_create_lofted_tube(main_pts, main_rads, 12, mat_antler, 0.035, 12.0))

	# 3. 5 Pontas Ramificadas (Brow tine, Bez tine, Trez tine e Coroa Real Bipartida no ápice)
	var tines = [
		{"base": Vector3(0.0, 0.12, -0.02), "mid": Vector3(0.05, 0.18, 0.10), "tip": Vector3(0.08, 0.26, 0.22), "r": 0.042},
		{"base": Vector3(0.0, 0.26, -0.06), "mid": Vector3(-0.04, 0.35, 0.06), "tip": Vector3(-0.07, 0.45, 0.19), "r": 0.038},
		{"base": Vector3(0.0, 0.42, -0.03), "mid": Vector3(0.06, 0.52, 0.10), "tip": Vector3(0.11, 0.62, 0.25), "r": 0.034},
		{"base": Vector3(0.0, 0.54, 0.03),  "mid": Vector3(-0.06, 0.63, 0.06), "tip": Vector3(-0.11, 0.73, 0.12), "r": 0.030},
		{"base": Vector3(0.0, 0.60, 0.09),  "mid": Vector3(0.05, 0.68, 0.10), "tip": Vector3(0.09, 0.76, 0.08), "r": 0.026}
	]
	for tn in tines:
		var t_pts: Array[Vector3] = [tn["base"], tn["mid"], tn["tip"]]
		var r0: float = tn["r"]
		var t_rads: Array[float] = [r0, r0 * 0.62, 0.003]
		horn_root.add_child(_create_lofted_tube(t_pts, t_rads, 10, mat_antler, 0.025, 8.0))

# --- M. PLACA / ESPINHO DORSAL ESTEGOSSAURO ---
func _build_sculpted_dorsal_spike(root: Node3D) -> void:
	var mat_base = _make_organic_material(primary_color.darkened(0.10), 0.52, 0.05)
	var mat_plate = _make_organic_material(primary_color.lightened(0.08), 0.38, 0.10)
	var mat_rim = _make_keratin_material(secondary_color.darkened(0.25), detail_color)

	var spike_root = Node3D.new()
	spike_root.name = "DorsalSpikeRoot"
	root.add_child(spike_root)

	# 1. Bainha dérmica basal alongada
	var mound_pts: Array[Vector3] = [
		Vector3(0.0, -0.02, -0.10),
		Vector3(0.0, 0.04, 0.0),
		Vector3(0.0, -0.02, 0.10)
	]
	var mound_rads: Array[float] = [0.065, 0.115, 0.065]
	spike_root.add_child(_create_lofted_tube(mound_pts, mound_rads, 12, mat_base, 0.0, 0.0, Vector2(0.75, 1.35)))

	# 2. Placa Losangular Pentagonal de Estegossauro (achatada lateralmente com sulcos vasculares)
	var plate_pts: Array[Vector3] = [
		Vector3(0.0, 0.02, 0.0),
		Vector3(0.0, 0.18, 0.03),
		Vector3(0.0, 0.36, 0.02),
		Vector3(0.0, 0.54, -0.02)
	]
	var plate_rads: Array[float] = [0.11, 0.185, 0.125, 0.006]
	spike_root.add_child(_create_lofted_tube(plate_pts, plate_rads, 14, mat_plate, 0.04, 10.0, Vector2(0.28, 1.55)))

	# 3. Quilha Córnea Central e Bordas Cortantes (Anterior e Posterior)
	var keel_pts: Array[Vector3] = [
		Vector3(0.0, 0.04, 0.0),
		Vector3(0.0, 0.24, 0.02),
		Vector3(0.0, 0.44, 0.0),
		Vector3(0.0, 0.58, -0.03)
	]
	var keel_rads: Array[float] = [0.065, 0.052, 0.032, 0.003]
	spike_root.add_child(_create_lofted_tube(keel_pts, keel_rads, 10, mat_rim))

	# Esporões basais de proteção (anterior e posterior)
	for z_dir in [-1.0, 1.0]:
		var guard_pts: Array[Vector3] = [
			Vector3(0.0, 0.05, z_dir * 0.08),
			Vector3(0.0, 0.18, z_dir * 0.19),
			Vector3(0.0, 0.28, z_dir * 0.24)
		]
		var guard_rads: Array[float] = [0.042, 0.024, 0.003]
		spike_root.add_child(_create_lofted_tube(guard_pts, guard_rads, 8, mat_rim))

# --- N. LÂMINA ÓSSEA DE FOICE (Mantis / Cotovelo) ---
func _build_sculpted_bone_blade(root: Node3D) -> void:
	var mat_base = _make_organic_material(primary_color.darkened(0.18), 0.42, 0.10)
	var mat_guard = _make_organic_material(secondary_color, 0.34, 0.15)
	var mat_blade = _make_keratin_material(secondary_color.darkened(0.30), detail_color)

	var blade_root = Node3D.new()
	blade_root.name = "BoneBladeRoot"
	root.add_child(blade_root)

	# 1. Bainha Muscular e Guarda Óssea Articular com Esporão Traseiro
	_create_attachment_collar(blade_root, mat_base, 0.10, Vector3(0.0, 0.02, 0.0))

	var base_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.10, 0.02),
		Vector3(0.0, 0.18, 0.05)
	]
	var base_rads: Array[float] = [0.095, 0.088, 0.068]
	blade_root.add_child(_create_lofted_tube(base_pts, base_rads, 12, mat_guard))

	var back_spur: Array[Vector3] = [
		Vector3(0.0, 0.10, -0.02),
		Vector3(0.0, 0.16, -0.12),
		Vector3(0.0, 0.22, -0.18)
	]
	var spur_rads: Array[float] = [0.045, 0.025, 0.003]
	blade_root.add_child(_create_lofted_tube(back_spur, spur_rads, 8, mat_blade))

	# 2. Lâmina Principal Achatada em Foice (aspect_xy = Vector2(0.24, 1.65))
	var scythe_pts: Array[Vector3] = [
		Vector3(0.0, 0.15, 0.04),
		Vector3(0.0, 0.32, 0.14),
		Vector3(0.0, 0.50, 0.26),
		Vector3(0.0, 0.64, 0.22),
		Vector3(0.0, 0.70, 0.10)
	]
	var scythe_rads: Array[float] = [0.068, 0.062, 0.048, 0.026, 0.003]
	blade_root.add_child(_create_lofted_tube(scythe_pts, scythe_rads, 12, mat_blade, 0.0, 0.0, Vector2(0.24, 1.65)))

	# 3. 4 Dentes Serrilhados no Gume Interno da Foice
	for b_i in range(4):
		var t_b = 0.28 + float(b_i) * 0.16
		var b_pos = _eval_catmull_chain(scythe_pts, t_b)
		var barb_pts: Array[Vector3] = [
			b_pos,
			b_pos + Vector3(0.0, 0.02, -0.085)
		]
		var barb_rads: Array[float] = [0.020, 0.002]
		blade_root.add_child(_create_lofted_tube(barb_pts, barb_rads, 6, mat_blade, 0.0, 0.0, Vector2(0.35, 1.4)))

# --- O. PINÇA CRUSTÁCEA MACIÇA ARTICULADA ---
func _build_sculpted_claw_pincer(root: Node3D) -> void:
	var mat_shell = _make_organic_material(secondary_color, 0.28, 0.18)
	var mat_joint = _make_organic_material(primary_color.darkened(0.15), 0.45, 0.08)
	var mat_teeth = _make_keratin_material(secondary_color.darkened(0.35), detail_color)

	var pincer_root = Node3D.new()
	pincer_root.name = "ClawPincerRoot"
	root.add_child(pincer_root)

	# 0. Colar articular basal
	_create_attachment_collar(pincer_root, mat_joint, 0.095, Vector3.ZERO)

	# 1. Mero e Carpo articulados com espinhos carinais
	var arm_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, -0.10, 0.10),
		Vector3(0.0, -0.22, 0.18),
		Vector3(0.0, -0.32, 0.22)
	]
	var arm_rads: Array[float] = [0.085, 0.095, 0.085, 0.075]
	pincer_root.add_child(_create_lofted_tube(arm_pts, arm_rads, 12, mat_joint, 0.05, 6.0))

	for side in [-1.0, 1.0]:
		var c_sp: Array[Vector3] = [
			Vector3(side * 0.065, -0.22, 0.19),
			Vector3(side * 0.12, -0.27, 0.25)
		]
		var c_rads: Array[float] = [0.024, 0.003]
		pincer_root.add_child(_create_lofted_tube(c_sp, c_rads, 6, mat_teeth))

	# 2. Bulbo Maciço da Quela (Propodus) achatado elipticamente com crista dorsal espinhosa
	var palm_pts: Array[Vector3] = [
		Vector3(0.0, -0.30, 0.22),
		Vector3(0.0, -0.42, 0.30),
		Vector3(0.0, -0.54, 0.36)
	]
	var palm_rads: Array[float] = [0.082, 0.145, 0.120]
	pincer_root.add_child(_create_lofted_tube(palm_pts, palm_rads, 16, mat_shell, 0.0, 0.0, Vector2(0.75, 1.28)))

	# Tubérculos / Espinhos na crista superior da palma
	for k_i in range(3):
		var kp = palm_pts[0].lerp(palm_pts[2], 0.25 + float(k_i) * 0.28) + Vector3(0.0, 0.02, 0.09)
		var k_pts: Array[Vector3] = [kp, kp + Vector3(0.0, -0.03, 0.06)]
		var k_rads: Array[float] = [0.025, 0.004]
		pincer_root.add_child(_create_lofted_tube(k_pts, k_rads, 6, mat_teeth))

	# 3. Dedo Fixo Inferior (Pollex) curvado para cima na ponta
	var fixed_pts: Array[Vector3] = [
		Vector3(0.0, -0.52, 0.32),
		Vector3(0.0, -0.66, 0.35),
		Vector3(0.0, -0.78, 0.33),
		Vector3(0.0, -0.82, 0.37)
	]
	var fixed_rads: Array[float] = [0.080, 0.052, 0.024, 0.004]
	pincer_root.add_child(_create_lofted_tube(fixed_pts, fixed_rads, 12, mat_shell, 0.0, 0.0, Vector2(0.72, 1.25)))

	# 4. Dedo Móvel Superior (Dactylus) arqueado fechando a tenaz
	var movable_pts: Array[Vector3] = [
		Vector3(0.0, -0.49, 0.39),
		Vector3(0.0, -0.63, 0.50),
		Vector3(0.0, -0.76, 0.45),
		Vector3(0.0, -0.82, 0.39)
	]
	var mov_rads: Array[float] = [0.070, 0.046, 0.022, 0.004]
	pincer_root.add_child(_create_lofted_tube(movable_pts, mov_rads, 12, mat_shell, 0.0, 0.0, Vector2(0.72, 1.25)))

	# 5. Dentes Molariformes Esmagadores em Ambas as Mandíbulas da Pinça
	for i in range(4):
		var t_f = 0.20 + float(i) * 0.22
		var pos_f = _eval_catmull_chain(fixed_pts, t_f)
		var tf_pts: Array[Vector3] = [pos_f, pos_f + Vector3(0.0, 0.01, 0.045)]
		var tf_rads: Array[float] = [0.024 - float(i) * 0.003, 0.005]
		pincer_root.add_child(_create_lofted_tube(tf_pts, tf_rads, 8, mat_teeth))

		var pos_m = _eval_catmull_chain(movable_pts, t_f)
		var tm_pts: Array[Vector3] = [pos_m, pos_m + Vector3(0.0, -0.01, -0.042)]
		var tm_rads: Array[float] = [0.020 - float(i) * 0.003, 0.004]
		pincer_root.add_child(_create_lofted_tube(tm_pts, tm_rads, 8, mat_teeth))

# --- P. CAUDA DE ESCORPIÃO COM METASOMA SEGMENTADO E AGUILHÃO DUPLO ---
func _build_sculpted_scorpion_tail(root: Node3D) -> void:
	var mat_chitin = _make_organic_material(secondary_color, 0.28, 0.18)
	var mat_joint = _make_organic_material(primary_color.darkened(0.18), 0.42, 0.08)
	var mat_stinger = _make_keratin_material(secondary_color.darkened(0.55), detail_color)

	var mat_venom = StandardMaterial3D.new()
	mat_venom.albedo_color = detail_color
	mat_venom.emission_enabled = true
	mat_venom.emission = detail_color.lightened(0.25)
	mat_venom.emission_energy_multiplier = 1.4
	mat_venom.roughness = 0.10

	var scorp_root = Node3D.new()
	scorp_root.name = "ScorpionTailRoot"
	root.add_child(scorp_root)

	# 0. Colar basal quitinoso
	_create_attachment_collar(scorp_root, mat_joint, 0.135, Vector3(0.0, 0.02, 0.0))

	# 1. Metasoma segmentado em arco sobre o dorso (+Y e +Z)
	var tail_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.14, -0.05),
		Vector3(0.0, 0.30, -0.09),
		Vector3(0.0, 0.46, -0.06),
		Vector3(0.0, 0.60, 0.04),
		Vector3(0.0, 0.70, 0.18)
	]
	var tail_rads: Array[float] = [0.125, 0.11, 0.095, 0.082, 0.075, 0.085]
	scorp_root.add_child(_create_lofted_tube(tail_pts, tail_rads, 14, mat_chitin, 0.04, 10.0, Vector2(0.92, 1.08)))

	# 2. Anéis quitinosos articulados e carenas dorsolaterais espinhosas em cada segmento
	var joint_positions: Array[Vector3] = [
		Vector3(0.0, 0.14, -0.05),
		Vector3(0.0, 0.30, -0.09),
		Vector3(0.0, 0.46, -0.06),
		Vector3(0.0, 0.60, 0.04)
	]
	var joint_radii: Array[float] = [0.115, 0.10, 0.088, 0.08]
	for i in range(joint_positions.size()):
		var j_pos = joint_positions[i]
		var j_r = joint_radii[i]
		var ring = MeshInstance3D.new()
		var torus = TorusMesh.new()
		torus.inner_radius = j_r * 0.82
		torus.outer_radius = j_r * 1.10
		torus.rings = 16
		torus.ring_segments = 10
		ring.mesh = torus
		ring.position = j_pos
		ring.material_override = mat_joint
		scorp_root.add_child(ring)

		# Par de espinhos carenados dorsolaterais
		for side in [-1.0, 1.0]:
			var spine_pts: Array[Vector3] = [
				j_pos + Vector3(side * j_r * 0.55, 0.0, -0.02),
				j_pos + Vector3(side * j_r * 0.95, 0.05, -0.08)
			]
			var spine_rads: Array[float] = [0.022, 0.003]
			scorp_root.add_child(_create_lofted_tube(spine_pts, spine_rads, 6, mat_stinger))

	# 3. Telson (Vesícula de Peçonha Bioluminescente Bilobada)
	var telson_pos = Vector3(0.0, 0.74, 0.22)
	var telson = MeshInstance3D.new()
	var t_sph = SphereMesh.new()
	t_sph.radius = 0.098
	t_sph.height = 0.21
	telson.mesh = t_sph
	telson.position = telson_pos
	telson.rotation = Vector3(-0.6, 0.0, 0.0)
	telson.material_override = mat_chitin
	scorp_root.add_child(telson)

	for side in [-1.0, 1.0]:
		var v_sac = MeshInstance3D.new()
		var vs_sph = SphereMesh.new()
		vs_sph.radius = 0.042
		vs_sph.height = 0.095
		v_sac.mesh = vs_sph
		v_sac.position = telson_pos + Vector3(side * 0.068, 0.01, 0.02)
		v_sac.rotation = Vector3(-0.6, 0.0, 0.0)
		v_sac.material_override = mat_venom
		scorp_root.add_child(v_sac)

	# 4. Acúleo (Aguilhão curvo letal) + Tubérculo Subaculear
	var sting_pts: Array[Vector3] = [
		Vector3(0.0, 0.78, 0.26),
		Vector3(0.0, 0.89, 0.39),
		Vector3(0.0, 0.87, 0.50),
		Vector3(0.0, 0.80, 0.55)
	]
	var sting_rads: Array[float] = [0.052, 0.030, 0.014, 0.002]
	scorp_root.add_child(_create_lofted_tube(sting_pts, sting_rads, 12, mat_stinger))

	var sub_pts: Array[Vector3] = [
		Vector3(0.0, 0.80, 0.31),
		Vector3(0.0, 0.83, 0.38)
	]
	var sub_rads: Array[float] = [0.020, 0.002]
	scorp_root.add_child(_create_lofted_tube(sub_pts, sub_rads, 6, mat_stinger))

# --- R. BARBATANA AQUÁTICA COM RAIOS CARTILAGINOSOS ---
func _build_sculpted_aquatic_fin(root: Node3D) -> void:
	var mat_base = _make_organic_material(primary_color, 0.42, 0.08)
	var mat_ray = _make_keratin_material(secondary_color.darkened(0.25), detail_color)
	var mat_web = StandardMaterial3D.new()
	mat_web.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat_web.albedo_color = Color(secondary_color.r, secondary_color.g, secondary_color.b, 0.82)
	mat_web.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_web.roughness = 0.20
	mat_web.clearcoat_enabled = true
	mat_web.clearcoat = 0.85
	mat_web.rim_enabled = true
	mat_web.rim = 0.65
	mat_web.backlight_enabled = true
	mat_web.backlight = detail_color.lightened(0.2)

	var mat_bio = StandardMaterial3D.new()
	mat_bio.albedo_color = detail_color
	mat_bio.emission_enabled = true
	mat_bio.emission = detail_color.lightened(0.25)
	mat_bio.emission_energy_multiplier = 1.4

	var fin_root = Node3D.new()
	fin_root.name = "AquaticFinRoot"
	root.add_child(fin_root)

	# 1. Pedúnculo Muscular Hidrodinâmico na Base
	var base_pts: Array[Vector3] = [
		Vector3(0.0, -0.02, -0.08),
		Vector3(0.0, 0.08, 0.0),
		Vector3(0.0, 0.16, 0.04)
	]
	var base_rads: Array[float] = [0.095, 0.09, 0.065]
	fin_root.add_child(_create_lofted_tube(base_pts, base_rads, 12, mat_base, 0.0, 0.0, Vector2(0.55, 1.45)))

	# 2. 6 Raios Espinhosos Hidrodinâmicos (Lepidotríquias) abrindo em leque
	var ray_origins: Array[Vector3] = [
		Vector3(0.0, 0.14, 0.04),
		Vector3(0.0, 0.13, 0.01),
		Vector3(0.0, 0.11, -0.02),
		Vector3(0.0, 0.09, -0.05),
		Vector3(0.0, 0.07, -0.08),
		Vector3(0.0, 0.05, -0.11)
	]
	var ray_tips: Array[Vector3] = [
		Vector3(0.0, 0.72, 0.32),
		Vector3(0.0, 0.62, 0.14),
		Vector3(0.0, 0.50, -0.02),
		Vector3(0.0, 0.38, -0.14),
		Vector3(0.0, 0.26, -0.22),
		Vector3(0.0, 0.14, -0.26)
	]

	for i in range(ray_origins.size()):
		var r_orig = ray_origins[i]
		var r_tip = ray_tips[i]
		var r_mid = r_orig.lerp(r_tip, 0.52) + Vector3(0.0, 0.04, 0.03)
		var r_pts: Array[Vector3] = [r_orig, r_mid, r_tip]
		var base_thick = 0.052 if i == 0 else (0.032 - float(i) * 0.003)
		var r_rads: Array[float] = [base_thick, base_thick * 0.62, 0.003]
		fin_root.add_child(_create_lofted_tube(r_pts, r_rads, 8, mat_ray))

		# Fotóforo bioluminescente ao longo da membrana
		if i < ray_origins.size() - 1:
			var spot = MeshInstance3D.new()
			var s_sph = SphereMesh.new()
			s_sph.radius = 0.016
			s_sph.height = 0.014
			spot.mesh = s_sph
			spot.position = r_orig.lerp(r_tip, 0.65).lerp(ray_tips[i + 1], 0.35)
			spot.material_override = mat_bio
			fin_root.add_child(spot)

	# 3. Membrana Inter-radial Recortada (Scalloped Webbing)
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(0)
	for i in range(ray_origins.size() - 1):
		var o_a = ray_origins[i]
		var o_b = ray_origins[i + 1]
		var t_a = ray_tips[i]
		var t_b = ray_tips[i + 1]
		var mid_scallop = (t_a + t_b) * 0.5 - ((t_a + t_b) * 0.5 - (o_a + o_b) * 0.5) * 0.12

		st.add_vertex(o_a)
		st.add_vertex(t_a)
		st.add_vertex(mid_scallop)

		st.add_vertex(o_a)
		st.add_vertex(mid_scallop)
		st.add_vertex(o_b)

		st.add_vertex(o_b)
		st.add_vertex(mid_scallop)
		st.add_vertex(t_b)
	st.index()
	st.generate_normals()

	var web_inst = MeshInstance3D.new()
	web_inst.mesh = st.commit()
	web_inst.material_override = mat_web
	fin_root.add_child(web_inst)

# --- S. CHIFRE MACIÇO DE RINOCERONTE COM QUERATINA COMPACTADA ---
func _build_sculpted_rhino_horn(root: Node3D) -> void:
	var mat_boss = _make_organic_material(primary_color.darkened(0.12), 0.62, 0.05)
	var mat_stud = _make_organic_material(secondary_color, 0.45, 0.10)
	var mat_horn = _make_keratin_material(secondary_color.darkened(0.42), detail_color)

	var horn_root = Node3D.new()
	horn_root.name = "RhinoHornRoot"
	root.add_child(horn_root)

	# 1. Placa Basal Dérmica Espessada (Nasal Boss) com tubérculos ósseos periféricos
	var boss_pts: Array[Vector3] = [
		Vector3(0.0, -0.02, -0.04),
		Vector3(0.0, 0.06, 0.0),
		Vector3(0.0, 0.12, 0.02)
	]
	var boss_rads: Array[float] = [0.165, 0.18, 0.145]
	horn_root.add_child(_create_lofted_tube(boss_pts, boss_rads, 16, mat_boss, 0.0, 0.0, Vector2(0.90, 1.18)))

	for a_idx in range(6):
		var ang = float(a_idx) * TAU / 6.0
		var stud = MeshInstance3D.new()
		var st_sph = SphereMesh.new()
		st_sph.radius = 0.032
		st_sph.height = 0.048
		stud.mesh = st_sph
		stud.position = Vector3(cos(ang) * 0.145, 0.04, sin(ang) * 0.165)
		stud.material_override = mat_stud
		horn_root.add_child(stud)

	# 2. Chifre Principal Maciço com Anéis de Queratina Compactada (ring_amp = 0.055, ring_freq = 13.0)
	var horn_pts: Array[Vector3] = [
		Vector3(0.0, 0.09, 0.03),
		Vector3(0.0, 0.24, 0.08),
		Vector3(0.0, 0.42, 0.17),
		Vector3(0.0, 0.56, 0.29),
		Vector3(0.0, 0.67, 0.40)
	]
	var horn_rads: Array[float] = [0.138, 0.112, 0.080, 0.042, 0.004]
	horn_root.add_child(_create_lofted_tube(horn_pts, horn_rads, 16, mat_horn, 0.055, 13.0, Vector2(0.82, 1.18)))

	# 3. Chifre Secundário Frontal (Estilo Rinoceronte-Branco / Arsinoitherium)
	var sub_pts: Array[Vector3] = [
		Vector3(0.0, 0.06, -0.12),
		Vector3(0.0, 0.19, -0.17),
		Vector3(0.0, 0.31, -0.21)
	]
	var sub_rads: Array[float] = [0.082, 0.048, 0.004]
	horn_root.add_child(_create_lofted_tube(sub_pts, sub_rads, 12, mat_horn, 0.05, 9.0))

# --- T. ASA LEPIDÓPTERA / FADA / BORBOLETA MÍSTICA COM OCELOS ---
func _build_sculpted_butterfly_wing(root: Node3D) -> void:
	var mat_arm = _make_organic_material(primary_color, 0.40, 0.10)
	var mat_vein = _make_keratin_material(secondary_color.darkened(0.35), detail_color)
	var mat_membrane = StandardMaterial3D.new()
	mat_membrane.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat_membrane.albedo_color = secondary_color
	mat_membrane.roughness = 0.20
	mat_membrane.metallic = 0.18
	mat_membrane.clearcoat_enabled = true
	mat_membrane.clearcoat = 0.9
	mat_membrane.rim_enabled = true
	mat_membrane.rim = 0.7
	mat_membrane.backlight_enabled = true
	mat_membrane.backlight = detail_color.lightened(0.25)

	var mat_ocellus_ring = _make_keratin_material(secondary_color, detail_color)
	var mat_ocellus_pupil = StandardMaterial3D.new()
	mat_ocellus_pupil.albedo_color = primary_color.darkened(0.45)
	mat_ocellus_pupil.emission_enabled = true
	mat_ocellus_pupil.emission = detail_color.lightened(0.2)
	mat_ocellus_pupil.emission_energy_multiplier = 1.1

	var wing_pivot = Node3D.new()
	wing_pivot.name = "ButterflyWingPivot"
	root.add_child(wing_pivot)

	# 1. Base esquelética de implantação / Espádua com colar
	_create_attachment_collar(wing_pivot, mat_arm, 0.09, Vector3(0.0, 0.02, 0.0))

	var base_pts: Array[Vector3] = [
		Vector3.ZERO,
		Vector3(0.0, 0.15, 0.08),
		Vector3(0.0, 0.32, 0.14)
	]
	var base_rads: Array[float] = [0.085, 0.065, 0.045]
	wing_pivot.add_child(_create_lofted_tube(base_pts, base_rads, 10, mat_arm))

	# 2. Bordo de ataque mestre anterior (Costal spar)
	var fore_spar: Array[Vector3] = [
		Vector3(0.0, 0.30, 0.14),
		Vector3(0.0, 0.70, 0.32),
		Vector3(0.0, 1.15, 0.40),
		Vector3(0.0, 1.50, 0.22)
	]
	var fore_rads: Array[float] = [0.045, 0.035, 0.022, 0.005]
	wing_pivot.add_child(_create_lofted_tube(fore_spar, fore_rads, 8, mat_vein))

	# 3. Asa Anterior Ampla (Forewing) recortada com nervuras e pérolas marginais
	var fore_perim: Array[Vector3] = [
		Vector3(0.0, 0.30, 0.14),
		Vector3(0.0, 0.70, 0.32),
		Vector3(0.0, 1.15, 0.40),
		Vector3(0.0, 1.50, 0.22),
		Vector3(0.0, 1.40, -0.15),
		Vector3(0.0, 1.05, -0.38),
		Vector3(0.0, 0.65, -0.42),
		Vector3(0.0, 0.32, -0.18)
	]

	var st_fore = SurfaceTool.new()
	st_fore.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_fore.set_smooth_group(0)
	var hub_fore = Vector3(0.0, 0.50, 0.0)
	for i in range(fore_perim.size()):
		var p_curr = fore_perim[i]
		var p_next = fore_perim[(i + 1) % fore_perim.size()]
		st_fore.add_vertex(hub_fore)
		st_fore.add_vertex(p_curr)
		st_fore.add_vertex(p_next)
	st_fore.index()
	st_fore.generate_normals()
	var fore_mesh = MeshInstance3D.new()
	fore_mesh.mesh = st_fore.commit()
	fore_mesh.material_override = mat_membrane
	wing_pivot.add_child(fore_mesh)

	for i in [3, 4, 5, 6]:
		var r_pts: Array[Vector3] = [hub_fore, hub_fore.lerp(fore_perim[i], 0.55), fore_perim[i]]
		var r_rads: Array[float] = [0.025, 0.015, 0.004]
		wing_pivot.add_child(_create_lofted_tube(r_pts, r_rads, 6, mat_vein))

		# Pérola marginal luminescente junto à borda da asa
		var pearl = MeshInstance3D.new()
		var p_sph = SphereMesh.new()
		p_sph.radius = 0.022
		p_sph.height = 0.016
		pearl.mesh = p_sph
		pearl.position = hub_fore.lerp(fore_perim[i], 0.88)
		pearl.material_override = mat_ocellus_pupil
		wing_pivot.add_child(pearl)

	# 4. Asa Posterior (Hindwing) com cauda de andorinha / cauda de fada
	var hind_perim: Array[Vector3] = [
		Vector3(0.0, 0.32, -0.18),
		Vector3(0.0, 0.60, -0.44),
		Vector3(0.0, 0.40, -0.72),
		Vector3(0.0, 0.05, -0.88),
		Vector3(0.0, -0.18, -0.65),
		Vector3(0.0, -0.10, -0.32),
		Vector3(0.0, 0.08, -0.12)
	]

	var st_hind = SurfaceTool.new()
	st_hind.begin(Mesh.PRIMITIVE_TRIANGLES)
	st_hind.set_smooth_group(0)
	var hub_hind = Vector3(0.0, 0.15, -0.30)
	for i in range(hind_perim.size()):
		var p_curr = hind_perim[i]
		var p_next = hind_perim[(i + 1) % hind_perim.size()]
		st_hind.add_vertex(hub_hind)
		st_hind.add_vertex(p_curr)
		st_hind.add_vertex(p_next)
	st_hind.index()
	st_hind.generate_normals()
	var hind_mesh = MeshInstance3D.new()
	hind_mesh.mesh = st_hind.commit()
	hind_mesh.material_override = mat_membrane
	wing_pivot.add_child(hind_mesh)

	for h_i in [2, 3, 4]:
		var hr_pts: Array[Vector3] = [hub_hind, hub_hind.lerp(hind_perim[h_i], 0.55), hind_perim[h_i]]
		var hr_rads: Array[float] = [0.020, 0.012, 0.003]
		wing_pivot.add_child(_create_lofted_tube(hr_pts, hr_rads, 6, mat_vein))

	# Cauda estilizada (Swallowtail ribbon)
	var tail_pts: Array[Vector3] = [
		Vector3(0.0, 0.05, -0.88),
		Vector3(0.0, -0.15, -1.05),
		Vector3(0.0, -0.35, -1.15),
		Vector3(0.0, -0.50, -1.10)
	]
	var tail_rads: Array[float] = [0.035, 0.030, 0.020, 0.003]
	wing_pivot.add_child(_create_lofted_tube(tail_pts, tail_rads, 8, mat_vein))

	# 5. Ocelos Místicos (Eyespots) concêntricos e brilhantes
	var ocellus_centers: Array[Vector3] = [
		Vector3(0.0, 1.05, -0.05),
		Vector3(0.0, 0.22, -0.55)
	]
	var ocellus_radii: Array[float] = [0.095, 0.075]
	for idx in range(ocellus_centers.size()):
		var c_pos = ocellus_centers[idx]
		var o_r = ocellus_radii[idx]

		var ring = MeshInstance3D.new()
		var t_mesh = TorusMesh.new()
		t_mesh.inner_radius = o_r * 0.55
		t_mesh.outer_radius = o_r
		ring.mesh = t_mesh
		ring.position = c_pos
		ring.rotation = Vector3(0.0, 0.0, PI * 0.5)
		ring.material_override = mat_ocellus_ring
		wing_pivot.add_child(ring)

		var center = MeshInstance3D.new()
		var s_mesh = SphereMesh.new()
		s_mesh.radius = o_r * 0.48
		s_mesh.height = 0.032
		center.mesh = s_mesh
		center.position = c_pos
		center.material_override = mat_ocellus_pupil
		wing_pivot.add_child(center)

# --- U. OLHO CICLÓPEO COLOSSAL COM CRISTA SUPERCILIAR ---
func _build_sculpted_cyclops_eye(root: Node3D) -> void:
	var mat_brow = _make_organic_material(primary_color, 0.52, 0.05)
	var mat_rim = _make_keratin_material(secondary_color.darkened(0.25), detail_color)
	var mat_limbus = _make_organic_material(secondary_color.darkened(0.55), 0.20, 0.05)

	var mat_sclera = StandardMaterial3D.new()
	mat_sclera.albedo_color = Color(0.96, 0.94, 0.89)
	mat_sclera.roughness = 0.04
	mat_sclera.clearcoat_enabled = true
	mat_sclera.clearcoat = 1.0
	mat_sclera.clearcoat_roughness = 0.03

	var mat_iris = StandardMaterial3D.new()
	mat_iris.albedo_color = secondary_color
	mat_iris.roughness = 0.08
	mat_iris.clearcoat_enabled = true
	mat_iris.clearcoat = 1.0
	mat_iris.emission_enabled = true
	mat_iris.emission = detail_color.lerp(secondary_color.lightened(0.35), 0.5)
	mat_iris.emission_energy_multiplier = 0.9

	var mat_pupil = StandardMaterial3D.new()
	mat_pupil.albedo_color = Color(0.02, 0.02, 0.03)
	mat_pupil.roughness = 0.02

	var mat_glint = StandardMaterial3D.new()
	mat_glint.albedo_color = Color.WHITE
	mat_glint.emission_enabled = true
	mat_glint.emission = Color.WHITE
	mat_glint.emission_energy_multiplier = 2.2

	var eye_root = Node3D.new()
	eye_root.name = "CyclopsEyeRoot"
	root.add_child(eye_root)

	# 0. Anel muscular orbital basal
	_create_attachment_collar(eye_root, mat_brow, 0.21, Vector3(0.0, 0.04, 0.0))

	# 1. Crista superciliar pesada e pálpebra inferior com tubérculos ósseos
	var brow_pts: Array[Vector3] = [
		Vector3(-0.24, 0.14, 0.06),
		Vector3(-0.12, 0.22, 0.14),
		Vector3(0.0, 0.25, 0.17),
		Vector3(0.12, 0.22, 0.14),
		Vector3(0.24, 0.14, 0.06)
	]
	var brow_rads: Array[float] = [0.045, 0.082, 0.095, 0.082, 0.045]
	eye_root.add_child(_create_lofted_tube(brow_pts, brow_rads, 14, mat_brow))

	var lower_brow: Array[Vector3] = [
		Vector3(-0.22, 0.08, -0.06),
		Vector3(0.0, 0.14, -0.16),
		Vector3(0.22, 0.08, -0.06)
	]
	var lower_rads: Array[float] = [0.042, 0.072, 0.042]
	eye_root.add_child(_create_lofted_tube(lower_brow, lower_rads, 12, mat_brow))

	# 2. Globo Ocular Colossal
	var eyeball = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.18
	sphere.height = 0.36
	sphere.radial_segments = 32
	sphere.rings = 16
	eyeball.mesh = sphere
	eyeball.position = Vector3(0.0, 0.12, 0.0)
	eyeball.material_override = mat_sclera
	eye_root.add_child(eyeball)

	# 3. Anel Limbal Escuro + Íris Ciclópea Brilhante
	var limbus = MeshInstance3D.new()
	var l_torus = TorusMesh.new()
	l_torus.inner_radius = 0.085
	l_torus.outer_radius = 0.118
	limbus.mesh = l_torus
	limbus.position = Vector3(0.0, 0.275, 0.0)
	limbus.material_override = mat_limbus
	eye_root.add_child(limbus)

	var iris = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.096
	cyl.bottom_radius = 0.108
	cyl.height = 0.032
	iris.mesh = cyl
	iris.position = Vector3(0.0, 0.28, 0.0)
	iris.material_override = mat_iris
	eye_root.add_child(iris)

	# 4. Pupila Vertical em Losango + Duplo Reflexo Especular
	var pupil_pts: Array[Vector3] = [
		Vector3(0.0, 0.292, -0.075),
		Vector3(0.0, 0.298, 0.0),
		Vector3(0.0, 0.292, 0.075)
	]
	var pupil_rads: Array[float] = [0.004, 0.036, 0.004]
	eye_root.add_child(_create_lofted_tube(pupil_pts, pupil_rads, 10, mat_pupil, 0.0, 0.0, Vector2(1.1, 0.35)))

	for g_idx in range(2):
		var glint = MeshInstance3D.new()
		var g_sph = SphereMesh.new()
		var gr = 0.022 if g_idx == 0 else 0.011
		g_sph.radius = gr
		g_sph.height = gr * 1.3
		glint.mesh = g_sph
		glint.position = Vector3(0.045 - float(g_idx) * 0.09, 0.298, 0.042 - float(g_idx) * 0.065)
		glint.material_override = mat_glint
		eye_root.add_child(glint)

	# 5. Coroa de 5 Espinhos Córneo-Orbitais de Proteção
	for ang_x in [-0.22, -0.11, 0.0, 0.11, 0.22]:
		var h_base = Vector3(ang_x, 0.18 + (0.05 - abs(ang_x) * 0.2), 0.12)
		var horn_pts: Array[Vector3] = [
			h_base,
			h_base + Vector3(ang_x * 0.55, 0.09, 0.08)
		]
		var horn_rads: Array[float] = [0.032, 0.003]
		eye_root.add_child(_create_lofted_tube(horn_pts, horn_rads, 8, mat_rim))

# ==============================================================================
# UTILITÁRIOS DE GERAÇÃO DE MALHA TUBULAR SUAVE (SURFACE TOOL) E MATERIAIS
# ==============================================================================

static var _shared_organic_normal_tex: NoiseTexture2D = null
static var _shared_keratin_normal_tex: NoiseTexture2D = null

static func _get_organic_normal_tex() -> NoiseTexture2D:
	if _shared_organic_normal_tex == null:
		var noise = FastNoiseLite.new()
		noise.noise_type = FastNoiseLite.TYPE_CELLULAR
		noise.frequency = 0.045
		noise.cellular_distance_function = FastNoiseLite.DISTANCE_EUCLIDEAN
		noise.cellular_return_type = FastNoiseLite.RETURN_DISTANCE2_SUB
		noise.fractal_type = FastNoiseLite.FRACTAL_FBM
		noise.fractal_octaves = 3
		var tex = NoiseTexture2D.new()
		tex.width = 128
		tex.height = 128
		tex.seamless = true
		tex.as_normal_map = true
		tex.bump_strength = 3.2
		tex.noise = noise
		_shared_organic_normal_tex = tex
	return _shared_organic_normal_tex

static func _get_keratin_normal_tex() -> NoiseTexture2D:
	if _shared_keratin_normal_tex == null:
		var noise = FastNoiseLite.new()
		noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		noise.frequency = 0.06
		noise.fractal_type = FastNoiseLite.FRACTAL_RIDGED
		noise.fractal_octaves = 3
		var tex = NoiseTexture2D.new()
		tex.width = 128
		tex.height = 128
		tex.seamless = true
		tex.as_normal_map = true
		tex.bump_strength = 2.4
		tex.noise = noise
		_shared_keratin_normal_tex = tex
	return _shared_keratin_normal_tex

func _make_organic_material(albedo: Color, rough: float, metal: float, sss_col: Color = Color.BLACK, sss_str: float = 0.0) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = albedo
	mat.vertex_color_use_as_albedo = true
	mat.roughness = clampf(rough, 0.12, 0.92)
	mat.metallic = metal
	mat.metallic_specular = 0.58
	mat.rim_enabled = true
	mat.rim = 0.45
	mat.rim_tint = 0.40
	mat.clearcoat_enabled = true
	mat.clearcoat = 0.18
	mat.clearcoat_roughness = 0.45
	mat.normal_enabled = true
	mat.normal_scale = 0.42
	mat.normal_texture = _get_organic_normal_tex()
	if sss_str > 0.01:
		mat.backlight_enabled = true
		mat.backlight = sss_col * sss_str
	else:
		mat.backlight_enabled = true
		mat.backlight = albedo.lightened(0.22) * 0.18
	return mat

func _make_keratin_material(base_col: Color, tip_col: Color) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = base_col.lerp(tip_col, 0.72)
	mat.vertex_color_use_as_albedo = true
	mat.set_meta("keratin_base", base_col)
	mat.set_meta("keratin_tip", tip_col)
	mat.roughness = 0.20
	mat.metallic = 0.15
	mat.metallic_specular = 0.75
	mat.rim_enabled = true
	mat.rim = 0.30
	mat.rim_tint = 0.25
	mat.clearcoat_enabled = true
	mat.clearcoat = 0.80
	mat.clearcoat_roughness = 0.14
	mat.normal_enabled = true
	mat.normal_scale = 0.35
	mat.normal_texture = _get_keratin_normal_tex()
	return mat

## Cria um colar/dobra muscular de encaixe na base do apêndice para fundir organicamente ao corpo
func _create_attachment_collar(parent: Node3D, mat: Material, radius: float = 0.13, pos: Vector3 = Vector3.ZERO, rot: Vector3 = Vector3.ZERO) -> void:
	var collar = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = maxf(0.015, radius * 0.48)
	torus.outer_radius = radius * 1.15
	torus.rings = 18
	torus.ring_segments = 12
	collar.mesh = torus
	collar.position = pos
	collar.rotation = rot
	collar.scale = Vector3(1.0, 0.65, 1.0)
	collar.material_override = mat
	parent.add_child(collar)

## Gera um tubo orgânico suave (lofting) com sombreamento suave, gradiente raiz-ponta, anéis de queratina e seção elíptica
func _create_lofted_tube(
	points: Array[Vector3],
	radii: Array[float],
	radial_segments: int,
	mat: Material,
	ring_amp: float = 0.0,
	ring_freq: float = 0.0,
	aspect_xy: Vector2 = Vector2.ONE
) -> MeshInstance3D:
	var inst = MeshInstance3D.new()
	if points.size() < 2 or radii.size() < points.size():
		return inst

	var is_keratin = mat != null and mat.has_meta("keratin_base") and mat.has_meta("keratin_tip")
	var k_base: Color = mat.get_meta("keratin_base") if is_keratin else Color.WHITE
	var k_tip: Color = mat.get_meta("keratin_tip") if is_keratin else Color.WHITE
	var k_ref: Color = (mat as StandardMaterial3D).albedo_color if (is_keratin and mat is StandardMaterial3D) else Color.WHITE
	k_ref = Color(maxf(k_ref.r, 0.05), maxf(k_ref.g, 0.05), maxf(k_ref.b, 0.05), 1.0)

	# Interpola sub-pontos Catmull-Rom com alta densidade para curvatura orgânica impecável
	var smooth_pts: Array[Vector3] = []
	var smooth_rads: Array[float] = []
	var smooth_t: Array[float] = []
	var subdivs = 5
	var n_segs = points.size() - 1
	var segs_radial = maxi(radial_segments, 10)

	for s in range(n_segs * subdivs + 1):
		var t_global = float(s) / float(n_segs * subdivs)
		var seg_f = t_global * float(n_segs)
		var idx = mini(int(seg_f), n_segs - 1)
		var t = seg_f - float(idx)

		var p0 = points[maxi(0, idx - 1)]
		var p1 = points[idx]
		var p2 = points[mini(n_segs, idx + 1)]
		var p3 = points[mini(n_segs, idx + 2)]
		var pos = 0.5 * (
			(2.0 * p1) +
			(-p0 + p2) * t +
			(2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * (t * t) +
			(-p0 + 3.0 * p1 - 3.0 * p2 + p3) * (t * t * t)
		)
		var rad = lerpf(radii[idx], radii[idx + 1], t)
		if ring_amp != 0.0 and ring_freq > 0.0:
			var wave = sin(t_global * ring_freq * TAU)
			rad *= (1.0 + ring_amp * wave * (1.0 - t_global * 0.45))
		smooth_pts.append(pos)
		smooth_rads.append(maxf(0.002, rad))
		smooth_t.append(t_global)

	var rings: Array[Array] = []
	var ring_colors: Array[Array] = []
	var prev_basis = Basis.IDENTITY

	for i in range(smooth_pts.size()):
		var c = smooth_pts[i]
		var r = smooth_rads[i]
		var tg = smooth_t[i]
		var tangent: Vector3
		if i == 0:
			tangent = (smooth_pts[1] - smooth_pts[0]).normalized()
		elif i == smooth_pts.size() - 1:
			tangent = (smooth_pts[i] - smooth_pts[i - 1]).normalized()
		else:
			tangent = (smooth_pts[i + 1] - smooth_pts[i - 1]).normalized()

		if tangent.length_squared() < 0.0001:
			tangent = Vector3.UP

		var basis = _make_frame(tangent, prev_basis if i > 0 else Basis.IDENTITY)
		prev_basis = basis

		var ring_wave = sin(tg * ring_freq * TAU) if (ring_amp != 0.0 and ring_freq > 0.0) else 0.0
		var ring_shade = 1.0 + ring_wave * 0.08

		var ring: Array[Vector3] = []
		var cols: Array[Color] = []
		for j in range(segs_radial):
			var ang = (float(j) / float(segs_radial)) * TAU
			var cx = cos(ang) * aspect_xy.x
			var sy = sin(ang) * aspect_xy.y
			ring.append(c + (basis.x * cx + basis.y * sy) * r)

			var dorsal_bias = clampf(0.94 + 0.10 * sin(ang), 0.82, 1.08)
			if is_keratin:
				var grad_col = k_base.lerp(k_tip.lightened(0.08), smoothstep(0.0, 0.85, tg))
				var mult_r = clampf((grad_col.r / k_ref.r) * dorsal_bias * ring_shade, 0.15, 1.6)
				var mult_g = clampf((grad_col.g / k_ref.g) * dorsal_bias * ring_shade, 0.15, 1.6)
				var mult_b = clampf((grad_col.b / k_ref.b) * dorsal_bias * ring_shade, 0.15, 1.6)
				cols.append(Color(mult_r, mult_g, mult_b, 1.0))
			else:
				var root_ao = lerpf(0.76, 1.02, smoothstep(0.0, 0.28, tg))
				var s_val = clampf(root_ao * dorsal_bias * ring_shade, 0.65, 1.12)
				cols.append(Color(s_val, s_val, s_val, 1.0))

		rings.append(ring)
		ring_colors.append(cols)

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(0)

	# Tampa inicial
	var start_c = smooth_pts[0]
	var start_col = ring_colors[0][0]
	for j in range(segs_radial):
		var nj = (j + 1) % segs_radial
		st.set_color(start_col)
		st.set_uv(Vector2(0.5, 0.0))
		st.add_vertex(start_c)
		st.set_color(ring_colors[0][nj])
		st.set_uv(Vector2(float(nj) / float(segs_radial), 0.0))
		st.add_vertex(rings[0][nj])
		st.set_color(ring_colors[0][j])
		st.set_uv(Vector2(float(j) / float(segs_radial), 0.0))
		st.add_vertex(rings[0][j])

	# Corpo tubular
	for i in range(rings.size() - 1):
		var v0 = smooth_t[i] * 2.0
		var v1 = smooth_t[i + 1] * 2.0
		for j in range(segs_radial):
			var nj = (j + 1) % segs_radial
			var u0 = float(j) / float(segs_radial)
			var u1 = float(j + 1) / float(segs_radial)
			var p00 = rings[i][j]
			var p01 = rings[i][nj]
			var p10 = rings[i + 1][j]
			var p11 = rings[i + 1][nj]
			var c00 = ring_colors[i][j]
			var c01 = ring_colors[i][nj]
			var c10 = ring_colors[i + 1][j]
			var c11 = ring_colors[i + 1][nj]

			st.set_color(c00)
			st.set_uv(Vector2(u0, v0))
			st.add_vertex(p00)
			st.set_color(c01)
			st.set_uv(Vector2(u1, v0))
			st.add_vertex(p01)
			st.set_color(c11)
			st.set_uv(Vector2(u1, v1))
			st.add_vertex(p11)

			st.set_color(c00)
			st.set_uv(Vector2(u0, v0))
			st.add_vertex(p00)
			st.set_color(c11)
			st.set_uv(Vector2(u1, v1))
			st.add_vertex(p11)
			st.set_color(c10)
			st.set_uv(Vector2(u0, v1))
			st.add_vertex(p10)

	# Tampa final (ponta)
	var last_idx = rings.size() - 1
	var end_c = smooth_pts[last_idx]
	var end_col = ring_colors[last_idx][0]
	for j in range(segs_radial):
		var nj = (j + 1) % segs_radial
		st.set_color(end_col)
		st.set_uv(Vector2(0.5, 1.0))
		st.add_vertex(end_c)
		st.set_color(ring_colors[last_idx][j])
		st.set_uv(Vector2(float(j) / float(segs_radial), 1.0))
		st.add_vertex(rings[last_idx][j])
		st.set_color(ring_colors[last_idx][nj])
		st.set_uv(Vector2(float(nj) / float(segs_radial), 1.0))
		st.add_vertex(rings[last_idx][nj])

	st.index()
	st.generate_normals()
	st.generate_tangents()
	inst.mesh = st.commit()
	inst.material_override = mat
	return inst

func _make_frame(tangent: Vector3, prev: Basis) -> Basis:
	var t = tangent.normalized()
	if prev != Basis.IDENTITY and abs(prev.z.dot(t)) > 0.15:
		var rx = (prev.x - t * t.dot(prev.x)).normalized()
		var ry = rx.cross(t).normalized()
		return Basis(rx, ry, t)
	var up = Vector3.UP if abs(t.dot(Vector3.UP)) < 0.92 else Vector3.RIGHT
	var rx = t.cross(up).normalized()
	var ry = rx.cross(t).normalized()
	return Basis(rx, ry, t)

func _eval_catmull_chain(points: Array[Vector3], t_global: float) -> Vector3:
	if points.is_empty():
		return Vector3.ZERO
	if points.size() == 1:
		return points[0]
	var n_segs = points.size() - 1
	var seg_f = clampf(t_global, 0.0, 1.0) * float(n_segs)
	var idx = mini(int(seg_f), n_segs - 1)
	var t = seg_f - float(idx)
	var p0 = points[maxi(0, idx - 1)]
	var p1 = points[idx]
	var p2 = points[mini(n_segs, idx + 1)]
	var p3 = points[mini(n_segs, idx + 2)]
	return 0.5 * (
		(2.0 * p1) +
		(-p0 + p2) * t +
		(2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * (t * t) +
		(-p0 + 3.0 * p1 - 3.0 * p2 + p3) * (t * t * t)
	)
