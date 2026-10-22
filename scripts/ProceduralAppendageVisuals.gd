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
	var mat_skin = _make_organic_material(primary_color, 0.55, 0.05, primary_color.lightened(0.2), 0.35)
	var mat_scales = _make_organic_material(secondary_color, 0.40, 0.10)
	var mat_claw = _make_keratin_material(secondary_color.darkened(0.4), detail_color)

	var pivot = Node3D.new()
	pivot.name = "LegPivot"
	root.add_child(pivot)

	# 1. Músculo da Anca / Quadril (em (0,0,0) encaixando firmemente no corpo)
	var hip_pts: Array[Vector3] = [
		Vector3(0.0, 0.04, -0.06),
		Vector3(0.0, 0.02, 0.0),
		Vector3(0.0, -0.04, 0.04),
		Vector3(0.0, -0.11, 0.07)
	]
	var hip_rads: Array[float] = [0.11, 0.145, 0.135, 0.105]
	var hip_mesh = _create_lofted_tube(hip_pts, hip_rads, 14, mat_skin)
	pivot.add_child(hip_mesh)

	# 2. Coxa Muscular (Fêmur descendo em direção ao solo -Y e avançando levemente em +Z)
	var thigh_pts: Array[Vector3] = [
		Vector3(0.0, -0.08, 0.05),
		Vector3(0.0, -0.18, 0.12),
		Vector3(0.0, -0.28, 0.17),
		Vector3(0.0, -0.35, 0.19)
	]
	var thigh_rads: Array[float] = [0.12, 0.135, 0.108, 0.082]
	var thigh_mesh = _create_lofted_tube(thigh_pts, thigh_rads, 14, mat_skin)
	pivot.add_child(thigh_mesh)

	# Placa dérmica protetora no joelho
	var knee_plate_pts: Array[Vector3] = [
		Vector3(0.0, -0.26, 0.23),
		Vector3(0.0, -0.34, 0.26),
		Vector3(0.0, -0.40, 0.24)
	]
	var knee_plate_rads: Array[float] = [0.035, 0.068, 0.022]
	pivot.add_child(_create_lofted_tube(knee_plate_pts, knee_plate_rads, 10, mat_scales))

	# 3. Canela / Panturrilha Digitígrada (descendo até o tornozelo em -Y)
	var shin_pts: Array[Vector3] = [
		Vector3(0.0, -0.34, 0.18),
		Vector3(0.0, -0.46, 0.07),
		Vector3(0.0, -0.58, -0.03),
		Vector3(0.0, -0.66, -0.05)
	]
	var shin_rads: Array[float] = [0.088, 0.098, 0.072, 0.062]
	var shin_mesh = _create_lofted_tube(shin_pts, shin_rads, 14, mat_skin)
	pivot.add_child(shin_mesh)

	# 4. Metatarso e Planta do Pé (apoiada plana no chão em Y = -0.75, apontando para frente +Z)
	var foot_pts: Array[Vector3] = [
		Vector3(0.0, -0.65, -0.04),
		Vector3(0.0, -0.72, 0.05),
		Vector3(0.0, -0.75, 0.15),
		Vector3(0.0, -0.75, 0.23)
	]
	var foot_rads: Array[float] = [0.065, 0.078, 0.088, 0.058]
	var foot_mesh = _create_lofted_tube(foot_pts, foot_rads, 12, mat_scales)
	pivot.add_child(foot_mesh)

	# 5. Três Garras Raptor Curvas Frontais + Esporão Traseiro
	var toe_offsets = [
		{"x": -0.065, "angle": -0.24, "scale": 0.92},
		{"x": 0.0,    "angle": 0.0,   "scale": 1.15},
		{"x": 0.065,  "angle": 0.24,  "scale": 0.92}
	]
	for toe in toe_offsets:
		var tx = float(toe["x"])
		var ang = float(toe["angle"])
		var sc = float(toe["scale"])
		var dir_x = sin(ang)
		var dir_z = cos(ang)
		var claw_pts: Array[Vector3] = [
			Vector3(tx, -0.74, 0.20),
			Vector3(tx + dir_x * 0.05, -0.72, 0.20 + dir_z * 0.09 * sc),
			Vector3(tx + dir_x * 0.09, -0.75, 0.20 + dir_z * 0.17 * sc),
			Vector3(tx + dir_x * 0.11, -0.78, 0.20 + dir_z * 0.23 * sc)
		]
		var claw_rads: Array[float] = [0.036 * sc, 0.030 * sc, 0.018 * sc, 0.003]
		pivot.add_child(_create_lofted_tube(claw_pts, claw_rads, 10, mat_claw))

	# Esporão traseiro (Hallux)
	var spur_pts: Array[Vector3] = [
		Vector3(0.0, -0.68, -0.05),
		Vector3(0.0, -0.67, -0.12),
		Vector3(0.0, -0.71, -0.17)
	]
	var spur_rads: Array[float] = [0.028, 0.018, 0.003]
	pivot.add_child(_create_lofted_tube(spur_pts, spur_rads, 8, mat_claw))

# ==============================================================================
# 1B. PATA PESADA ESMAGADORA TITÂNICA (Estilo Paquiderme / Sauropoda / T-Rex)
# ==============================================================================
func _build_sculpted_heavy_leg(root: Node3D) -> void:
	var mat_skin = _make_organic_material(primary_color, 0.65, 0.05, primary_color.lightened(0.15), 0.25)
	var mat_armor = _make_organic_material(secondary_color, 0.40, 0.12)
	var mat_claw = _make_keratin_material(secondary_color.darkened(0.4), detail_color)

	var pivot = Node3D.new()
	pivot.name = "HeavyLegPivot"
	root.add_child(pivot)

	# 1. Anca e Coxa Colunar Maciça
	var hip_pts: Array[Vector3] = [
		Vector3(0.0, 0.06, -0.06),
		Vector3(0.0, 0.02, 0.0),
		Vector3(0.0, -0.06, 0.05),
		Vector3(0.0, -0.16, 0.08)
	]
	var hip_rads: Array[float] = [0.16, 0.19, 0.18, 0.16]
	pivot.add_child(_create_lofted_tube(hip_pts, hip_rads, 16, mat_skin))

	# 2. Fêmur Muscular Pesado
	var thigh_pts: Array[Vector3] = [
		Vector3(0.0, -0.14, 0.07),
		Vector3(0.0, -0.24, 0.13),
		Vector3(0.0, -0.34, 0.16)
	]
	var thigh_rads: Array[float] = [0.17, 0.16, 0.145]
	pivot.add_child(_create_lofted_tube(thigh_pts, thigh_rads, 16, mat_skin))

	# 3. Escudo Ósseo / Placa Carapaça Dupla no Joelho
	for k in range(2):
		var y_off = -0.26 - float(k) * 0.10
		var k_pts: Array[Vector3] = [
			Vector3(0.0, y_off + 0.04, 0.18),
			Vector3(0.0, y_off, 0.23),
			Vector3(0.0, y_off - 0.04, 0.18)
		]
		var k_rads: Array[float] = [0.05, 0.09, 0.04]
		pivot.add_child(_create_lofted_tube(k_pts, k_rads, 10, mat_armor))

	# 4. Canela Colunar Espessa (Pilar cilíndrico de sustentação pesada)
	var shin_pts: Array[Vector3] = [
		Vector3(0.0, -0.34, 0.15),
		Vector3(0.0, -0.46, 0.10),
		Vector3(0.0, -0.58, 0.05),
		Vector3(0.0, -0.68, 0.02)
	]
	var shin_rads: Array[float] = [0.14, 0.145, 0.14, 0.155]
	pivot.add_child(_create_lofted_tube(shin_pts, shin_rads, 16, mat_skin))

	# 5. Pata / Almofada de Choque Circular no Solo (Y = -0.75)
	var foot_pts: Array[Vector3] = [
		Vector3(0.0, -0.66, 0.02),
		Vector3(0.0, -0.72, 0.06),
		Vector3(0.0, -0.75, 0.12),
		Vector3(0.0, -0.75, 0.18)
	]
	var foot_rads: Array[float] = [0.155, 0.175, 0.18, 0.14]
	pivot.add_child(_create_lofted_tube(foot_pts, foot_rads, 16, mat_armor))

	# 6. Quatro Garras / Cascos Curtos de Esmagamento Frontais e Laterais
	var nail_angles = [-0.65, -0.22, 0.22, 0.65]
	for a in nail_angles:
		var dir_x = sin(a)
		var dir_z = cos(a)
		var n_base = Vector3(dir_x * 0.15, -0.74, 0.10 + dir_z * 0.12)
		var n_tip = n_base + Vector3(dir_x * 0.07, -0.01, dir_z * 0.10)
		var nail_pts: Array[Vector3] = [n_base, (n_base + n_tip) * 0.5, n_tip]
		var nail_rads: Array[float] = [0.045, 0.038, 0.012]
		pivot.add_child(_create_lofted_tube(nail_pts, nail_rads, 10, mat_claw))

	# 7. Osteodermos / Nódulos ósseos protetores na lateral da perna
	for side in [-1.0, 1.0]:
		for i in range(3):
			var stud = MeshInstance3D.new()
			var sphere = SphereMesh.new()
			sphere.radius = 0.038
			sphere.height = 0.065
			stud.mesh = sphere
			stud.position = Vector3(side * 0.14, -0.30 - float(i) * 0.12, 0.08 - float(i) * 0.02)
			stud.material_override = mat_armor
			pivot.add_child(stud)

# ==============================================================================
# 2. ASA DRACÔNICA / WYVERN MAJESTOSA COM FALANGES E MEMBRANA TRANSLÚCIDA
# ==============================================================================
func _build_sculpted_wing(root: Node3D) -> void:
	var mat_bone = _make_organic_material(primary_color.darkened(0.15), 0.40, 0.12)
	var mat_claw = _make_keratin_material(secondary_color.darkened(0.4), detail_color)
	var mat_membrane = StandardMaterial3D.new()
	mat_membrane.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat_membrane.albedo_color = secondary_color
	mat_membrane.roughness = 0.42
	mat_membrane.backlight_enabled = true
	mat_membrane.backlight = primary_color.lightened(0.2)

	var wing_pivot = Node3D.new()
	wing_pivot.name = "WingRoot"
	root.add_child(wing_pivot)

	# 1. Base Muscular do Ombro / Escápula
	var shoulder_pts: Array[Vector3] = [
		Vector3(0.0, -0.04, 0.0),
		Vector3(0.0, 0.08, -0.02),
		Vector3(0.0, 0.22, -0.05)
	]
	var shoulder_rads: Array[float] = [0.12, 0.135, 0.095]
	wing_pivot.add_child(_create_lofted_tube(shoulder_pts, shoulder_rads, 14, mat_bone))

	# 2. Braço e Antebraço da Asa (Úmero -> Cotovelo -> Carpo/Pulso da Asa)
	var shoulder = Vector3(0.0, 0.18, -0.04)
	var elbow = Vector3(0.0, 0.45, -0.16)
	var wrist = Vector3(0.0, 0.95, 0.18)
	var main_tip = Vector3(0.0, 1.55, -0.15)

	var arm_pts: Array[Vector3] = [shoulder, elbow, wrist, main_tip]
	var arm_rads: Array[float] = [0.095, 0.075, 0.060, 0.020]
	wing_pivot.add_child(_create_lofted_tube(arm_pts, arm_rads, 14, mat_bone))

	# 3. Garra Curva de Rapina no Polegar do Pulso (Alula)
	var thumb_pts: Array[Vector3] = [
		wrist,
		wrist + Vector3(0.0, 0.12, 0.14),
		wrist + Vector3(0.0, 0.08, 0.25)
	]
	var thumb_rads: Array[float] = [0.038, 0.024, 0.003]
	wing_pivot.add_child(_create_lofted_tube(thumb_pts, thumb_rads, 10, mat_claw))

	# 4. Dedos Longos Falangeados Curvos (Phalanges 1 a 4)
	var finger_defs = [
		{"tip": main_tip, "mid": wrist.lerp(main_tip, 0.55) + Vector3(0.0, 0.06, 0.08)},
		{"tip": Vector3(0.0, 1.35, -0.55), "mid": wrist.lerp(Vector3(0.0, 1.35, -0.55), 0.55) + Vector3(0.0, 0.08, -0.05)},
		{"tip": Vector3(0.0, 1.05, -0.85), "mid": wrist.lerp(Vector3(0.0, 1.05, -0.85), 0.55) + Vector3(0.0, 0.06, -0.12)},
		{"tip": Vector3(0.0, 0.60, -0.80), "mid": wrist.lerp(Vector3(0.0, 0.60, -0.80), 0.55) + Vector3(0.0, 0.04, -0.10)},
		{"tip": Vector3(0.0, 0.15, -0.50), "mid": elbow.lerp(Vector3(0.0, 0.15, -0.50), 0.50) + Vector3(0.0, -0.04, -0.08)}
	]

	var finger_tips: Array[Vector3] = []
	for f in finger_defs:
		var tip: Vector3 = f["tip"]
		var mid: Vector3 = f["mid"]
		finger_tips.append(tip)
		var f_pts: Array[Vector3] = [wrist if f != finger_defs.back() else elbow, mid, tip]
		var f_rads: Array[float] = [0.035, 0.022, 0.006]
		wing_pivot.add_child(_create_lofted_tube(f_pts, f_rads, 10, mat_bone))

		# Pequena garra na ponta do dedo da asa
		var tip_claw_pts: Array[Vector3] = [
			tip,
			tip + (tip - mid).normalized() * 0.08 + Vector3(0.0, -0.04, 0.0)
		]
		var tip_claw_rads: Array[float] = [0.012, 0.002]
		wing_pivot.add_child(_create_lofted_tube(tip_claw_pts, tip_claw_rads, 6, mat_claw))

	# 5. Membrana Patagial Curva com Vão recortado entre os dedos
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(finger_tips.size() - 1):
		var p_a = finger_tips[i]
		var p_b = finger_tips[i + 1]
		var anchor = wrist if i < 3 else elbow

		# Subdivide a borda da membrana em arco côncavo recortado (scalloped bat wing edge)
		var mid_edge = p_a.lerp(p_b, 0.5) - (p_a.lerp(p_b, 0.5) - anchor).normalized() * 0.15

		# Triângulo 1 (anchor, p_a, mid_edge)
		st.set_uv(Vector2(0.0, 0.0))
		st.add_vertex(anchor)
		st.set_uv(Vector2(1.0, 0.0))
		st.add_vertex(p_a)
		st.set_uv(Vector2(0.5, 0.5))
		st.add_vertex(mid_edge)

		# Triângulo 2 (anchor, mid_edge, p_b)
		st.set_uv(Vector2(0.0, 0.0))
		st.add_vertex(anchor)
		st.set_uv(Vector2(0.5, 0.5))
		st.add_vertex(mid_edge)
		st.set_uv(Vector2(0.0, 1.0))
		st.add_vertex(p_b)

	st.generate_normals()
	var web_inst = MeshInstance3D.new()
	web_inst.mesh = st.commit()
	web_inst.material_override = mat_membrane
	wing_pivot.add_child(web_inst)

# ==============================================================================
# 3. MANDÍBULA CARNÍVORA FEROZ OU BICO HERBÍVORO ENCOURAÇADO
# ==============================================================================
func _build_sculpted_mouth(root: Node3D, is_herbivore: bool) -> void:
	var mat_skin = _make_organic_material(
		primary_color.darkened(0.1) if is_herbivore else primary_color,
		0.48, 0.05
	)
	var mat_gum = _make_organic_material(Color(0.75, 0.22, 0.28).lerp(primary_color, 0.25), 0.25, 0.0)
	var mat_tooth = _make_keratin_material(secondary_color.darkened(0.2), detail_color)
	var mat_beak = _make_keratin_material(secondary_color, detail_color)

	var jaw_root = Node3D.new()
	jaw_root.name = "JawRoot"
	root.add_child(jaw_root)

	# Maxilar Superior (Focinho esculpido projetando-se ao longo de +Y da normal)
	var upper_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.04),
		Vector3(0.0, 0.14, 0.07),
		Vector3(0.0, 0.28, 0.05),
		Vector3(0.0, 0.38, 0.01)
	]
	var upper_rads: Array[float] = [0.16, 0.15, 0.12, 0.06]
	jaw_root.add_child(_create_lofted_tube(upper_pts, upper_rads, 14, mat_beak if is_herbivore else mat_skin))

	# Mandíbula Inferior articulada (aberta em ângulo agressivo)
	var lower_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, -0.05),
		Vector3(0.0, 0.12, -0.11),
		Vector3(0.0, 0.25, -0.14),
		Vector3(0.0, 0.34, -0.11)
	]
	var lower_rads: Array[float] = [0.14, 0.12, 0.095, 0.045]
	jaw_root.add_child(_create_lofted_tube(lower_pts, lower_rads, 14, mat_skin))

	# Língua carnuda interna
	var tongue_pts: Array[Vector3] = [
		Vector3(0.0, 0.05, -0.02),
		Vector3(0.0, 0.18, -0.06),
		Vector3(0.0, 0.27, -0.08)
	]
	var tongue_rads: Array[float] = [0.07, 0.055, 0.02]
	jaw_root.add_child(_create_lofted_tube(tongue_pts, tongue_rads, 10, mat_gum))

	if is_herbivore:
		# Chifres jugais laterais de herbívoro encouraçado
		for side in [-1.0, 1.0]:
			var tusk_pts: Array[Vector3] = [
				Vector3(side * 0.12, 0.10, 0.02),
				Vector3(side * 0.20, 0.18, 0.06),
				Vector3(side * 0.24, 0.26, 0.11)
			]
			var tusk_rads: Array[float] = [0.04, 0.025, 0.004]
			jaw_root.add_child(_create_lofted_tube(tusk_pts, tusk_rads, 8, mat_tooth))
	else:
		# Presas e Caninos Curvos de Predador Carnívoro
		var x_positions = [-0.09, -0.045, 0.045, 0.09]
		for x_pos in x_positions:
			var is_canine = abs(x_pos) > 0.06
			var len_f = 1.25 if is_canine else 0.85
			# Dente superior apontando para baixo/frente
			var u_tooth: Array[Vector3] = [
				Vector3(x_pos, 0.24, 0.02),
				Vector3(x_pos, 0.26, -0.03 * len_f),
				Vector3(x_pos, 0.29, -0.08 * len_f)
			]
			var u_rads: Array[float] = [0.024 * len_f, 0.014 * len_f, 0.002]
			jaw_root.add_child(_create_lofted_tube(u_tooth, u_rads, 8, mat_tooth))

			# Dente inferior apontando para cima
			var l_tooth: Array[Vector3] = [
				Vector3(x_pos * 0.85, 0.22, -0.11),
				Vector3(x_pos * 0.85, 0.24, -0.07),
				Vector3(x_pos * 0.85, 0.27, -0.03)
			]
			var l_rads: Array[float] = [0.020, 0.012, 0.002]
			jaw_root.add_child(_create_lofted_tube(l_tooth, l_rads, 8, mat_tooth))

# ==============================================================================
# 4. CHIFRE CURVO DE QUERATINA COM ROSETA BASAL E ESPINHOS LATERAIS
# ==============================================================================
func _build_sculpted_horn(root: Node3D) -> void:
	var mat_base = _make_organic_material(primary_color.darkened(0.15), 0.55, 0.05)
	var mat_horn = _make_keratin_material(secondary_color.darkened(0.3), detail_color)

	# Roseta óssea na base
	var base_pts: Array[Vector3] = [
		Vector3(0.0, -0.02, 0.0),
		Vector3(0.0, 0.04, 0.0),
		Vector3(0.0, 0.09, 0.01)
	]
	var base_rads: Array[float] = [0.13, 0.14, 0.105]
	root.add_child(_create_lofted_tube(base_pts, base_rads, 14, mat_base))

	# Chifre principal longo e curvo com anéis orgânicos
	var horn_pts: Array[Vector3] = [
		Vector3(0.0, 0.06, 0.0),
		Vector3(0.0, 0.18, 0.02),
		Vector3(0.0, 0.32, 0.07),
		Vector3(0.0, 0.46, 0.15),
		Vector3(0.0, 0.58, 0.26)
	]
	var horn_rads: Array[float] = [0.095, 0.078, 0.054, 0.028, 0.003]
	root.add_child(_create_lofted_tube(horn_pts, horn_rads, 14, mat_horn))

	# Dois espinhos menores de guarda na base
	for side in [-1.0, 1.0]:
		var sub_pts: Array[Vector3] = [
			Vector3(side * 0.07, 0.04, 0.0),
			Vector3(side * 0.13, 0.14, 0.03),
			Vector3(side * 0.16, 0.23, 0.08)
		]
		var sub_rads: Array[float] = [0.042, 0.024, 0.003]
		root.add_child(_create_lofted_tube(sub_pts, sub_rads, 10, mat_horn))

# ==============================================================================
# 5. CAUDA SEGMENTADA COM CLAVA ÓSSEA, BULBO VENENOSO BIOLUMINESCENTE E FERRÃO
# ==============================================================================
func _build_sculpted_tail(root: Node3D) -> void:
	var mat_armor = _make_organic_material(secondary_color, 0.42, 0.12)
	var mat_stinger = _make_keratin_material(secondary_color.darkened(0.5), detail_color)

	var mat_venom = StandardMaterial3D.new()
	mat_venom.albedo_color = detail_color
	mat_venom.roughness = 0.2
	mat_venom.emission_enabled = true
	mat_venom.emission = detail_color
	mat_venom.emission_energy_multiplier = 1.4

	var tail_root = Node3D.new()
	tail_root.name = "TailRoot"
	root.add_child(tail_root)

	# Cauda segmentada curvando-se para cima como escorpião
	var tail_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.16, -0.05),
		Vector3(0.0, 0.34, -0.08),
		Vector3(0.0, 0.50, -0.02),
		Vector3(0.0, 0.62, 0.10)
	]
	var tail_rads: Array[float] = [0.11, 0.095, 0.080, 0.068, 0.085]
	tail_root.add_child(_create_lofted_tube(tail_pts, tail_rads, 14, mat_armor))

	# Bulbo de Veneno Bioluminescente (Telson)
	var bulb = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.095
	sphere.height = 0.22
	bulb.mesh = sphere
	bulb.position = Vector3(0.0, 0.64, 0.12)
	bulb.material_override = mat_venom
	tail_root.add_child(bulb)

	# Aguilhão / Ferrão Curvo Afiado
	var sting_pts: Array[Vector3] = [
		Vector3(0.0, 0.68, 0.15),
		Vector3(0.0, 0.78, 0.24),
		Vector3(0.0, 0.74, 0.36)
	]
	var sting_rads: Array[float] = [0.052, 0.024, 0.002]
	tail_root.add_child(_create_lofted_tube(sting_pts, sting_rads, 10, mat_stinger))

	# Espinhos laterais de clava
	for side in [-1.0, 1.0]:
		var mace_pts: Array[Vector3] = [
			Vector3(side * 0.06, 0.56, 0.05),
			Vector3(side * 0.16, 0.60, 0.07),
			Vector3(side * 0.24, 0.64, 0.10)
		]
		var mace_rads: Array[float] = [0.035, 0.020, 0.003]
		tail_root.add_child(_create_lofted_tube(mace_pts, mace_rads, 8, mat_stinger))

# ==============================================================================
# 6. OLHO ORGÂNICO REALISTA COM PÁLPEBRAS, ÍRIS ÂMBAR E BRILHO DE CÓRNEA
# ==============================================================================
func _build_sculpted_eye(root: Node3D) -> void:
	var mat_lid = _make_organic_material(primary_color, 0.55, 0.05)

	var mat_sclera = StandardMaterial3D.new()
	mat_sclera.albedo_color = Color(0.96, 0.95, 0.90)
	mat_sclera.roughness = 0.04
	mat_sclera.metallic = 0.02
	mat_sclera.clearcoat_enabled = true
	mat_sclera.clearcoat = 1.0
	mat_sclera.clearcoat_roughness = 0.04

	var mat_iris = StandardMaterial3D.new()
	mat_iris.albedo_color = secondary_color
	mat_iris.roughness = 0.12
	mat_iris.emission_enabled = true
	mat_iris.emission = secondary_color.lightened(0.25)
	mat_iris.emission_energy_multiplier = 0.45

	var mat_pupil = StandardMaterial3D.new()
	mat_pupil.albedo_color = Color(0.03, 0.03, 0.04)
	mat_pupil.roughness = 0.05

	var mat_glint = StandardMaterial3D.new()
	mat_glint.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_glint.albedo_color = Color(1.0, 1.0, 1.0)

	# 1. Soquete Muscular / Pálpebra ao redor da base
	var socket = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.09
	torus.outer_radius = 0.165
	torus.rings = 20
	torus.ring_segments = 12
	socket.mesh = torus
	socket.position = Vector3(0.0, 0.08, 0.0)
	socket.material_override = mat_lid
	root.add_child(socket)

	# 2. Globo Ocular Vítreo (apontando para fora ao longo de +Y da normal)
	var eyeball = MeshInstance3D.new()
	var eye_sphere = SphereMesh.new()
	eye_sphere.radius = 0.135
	eye_sphere.height = 0.27
	eyeball.mesh = eye_sphere
	eyeball.position = Vector3(0.0, 0.11, 0.0)
	eyeball.material_override = mat_sclera
	root.add_child(eyeball)

	# 3. Íris Luminosa no ápice do olho (+Y)
	var iris = MeshInstance3D.new()
	var iris_cyl = CylinderMesh.new()
	iris_cyl.top_radius = 0.068
	iris_cyl.bottom_radius = 0.075
	iris_cyl.height = 0.025
	iris.mesh = iris_cyl
	iris.position = Vector3(0.0, 0.232, 0.0)
	iris.material_override = mat_iris
	root.add_child(iris)

	# 4. Pupila Reptiliana Vertical
	var pupil = MeshInstance3D.new()
	var pupil_box = BoxMesh.new()
	pupil_box.size = Vector3(0.028, 0.022, 0.095)
	pupil.mesh = pupil_box
	pupil.position = Vector3(0.0, 0.240, 0.0)
	pupil.material_override = mat_pupil
	root.add_child(pupil)

	# 5. Reflexo Especular (Brilho vivo da córnea)
	var glint = MeshInstance3D.new()
	var glint_sphere = SphereMesh.new()
	glint_sphere.radius = 0.018
	glint_sphere.height = 0.036
	glint.mesh = glint_sphere
	glint.position = Vector3(0.028, 0.246, 0.025)
	glint.material_override = mat_glint
	root.add_child(glint)

# ==============================================================================
# 7. NOVOS APÊNDICES: BOCAS, PATAS, OLHOS, RABOS, ASAS E DEFESA
# ==============================================================================

# --- A. PATA COM CASCO BLINDADO (Herbívoros / Quadrúpedes pesados) ---
func _build_sculpted_hoof_leg(root: Node3D) -> void:
	var mat_skin = _make_organic_material(primary_color, 0.60, 0.05)
	var mat_hoof = _make_keratin_material(secondary_color.darkened(0.4), detail_color)
	var mat_plate = _make_organic_material(secondary_color, 0.40, 0.10)

	var pivot = Node3D.new()
	pivot.name = "HoofPivot"
	root.add_child(pivot)

	# Fêmur e Anca musculosa
	var thigh_pts: Array[Vector3] = [
		Vector3(0.0, 0.02, -0.04),
		Vector3(0.0, -0.12, 0.06),
		Vector3(0.0, -0.26, 0.14),
		Vector3(0.0, -0.34, 0.16)
	]
	var thigh_rads: Array[float] = [0.13, 0.15, 0.12, 0.095]
	pivot.add_child(_create_lofted_tube(thigh_pts, thigh_rads, 14, mat_skin))

	# Placa óssea no joelho
	var knee_pts: Array[Vector3] = [
		Vector3(0.0, -0.28, 0.22),
		Vector3(0.0, -0.36, 0.24),
		Vector3(0.0, -0.42, 0.21)
	]
	var knee_rads: Array[float] = [0.04, 0.075, 0.03]
	pivot.add_child(_create_lofted_tube(knee_pts, knee_rads, 10, mat_plate))

	# Canela e Jarrete
	var shin_pts: Array[Vector3] = [
		Vector3(0.0, -0.34, 0.15),
		Vector3(0.0, -0.48, 0.05),
		Vector3(0.0, -0.60, -0.04),
		Vector3(0.0, -0.68, 0.02)
	]
	var shin_rads: Array[float] = [0.09, 0.095, 0.075, 0.065]
	pivot.add_child(_create_lofted_tube(shin_pts, shin_rads, 14, mat_skin))

	# Boleto e Casco Sólido (Plano no solo em Y = -0.75, +Z para frente)
	var hoof_pts: Array[Vector3] = [
		Vector3(0.0, -0.66, 0.02),
		Vector3(0.0, -0.71, 0.08),
		Vector3(0.0, -0.75, 0.16),
		Vector3(0.0, -0.75, 0.24)
	]
	var hoof_rads: Array[float] = [0.065, 0.085, 0.095, 0.075]
	pivot.add_child(_create_lofted_tube(hoof_pts, hoof_rads, 14, mat_hoof))

# --- B. PATA INSETÓIDE QUITINOSA ARTICULADA ---
func _build_sculpted_insect_leg(root: Node3D) -> void:
	var mat_chitin = _make_organic_material(secondary_color, 0.32, 0.15)
	var mat_joint = _make_organic_material(primary_color.darkened(0.2), 0.25, 0.05)
	var mat_claw = _make_keratin_material(secondary_color.darkened(0.5), detail_color)

	var pivot = Node3D.new()
	pivot.name = "InsectLegPivot"
	root.add_child(pivot)

	# Coxa e Trocânter
	var coxa_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.10, 0.10),
		Vector3(0.0, 0.14, 0.20)
	]
	var coxa_rads: Array[float] = [0.08, 0.095, 0.07]
	pivot.add_child(_create_lofted_tube(coxa_pts, coxa_rads, 10, mat_chitin))

	# Fêmur com espinhos laterais
	var femur_pts: Array[Vector3] = [
		Vector3(0.0, 0.14, 0.20),
		Vector3(0.0, 0.02, 0.32),
		Vector3(0.0, -0.18, 0.36),
		Vector3(0.0, -0.32, 0.32)
	]
	var femur_rads: Array[float] = [0.07, 0.075, 0.065, 0.055]
	pivot.add_child(_create_lofted_tube(femur_pts, femur_rads, 10, mat_chitin))

	# Nó articular no joelho
	var joint_mesh = MeshInstance3D.new()
	var joint_sphere = SphereMesh.new()
	joint_sphere.radius = 0.062
	joint_sphere.height = 0.124
	joint_mesh.mesh = joint_sphere
	joint_mesh.position = Vector3(0.0, -0.32, 0.32)
	joint_mesh.material_override = mat_joint
	pivot.add_child(joint_mesh)

	# Tíbia arqueada descendo ao solo
	var tibia_pts: Array[Vector3] = [
		Vector3(0.0, -0.32, 0.32),
		Vector3(0.0, -0.52, 0.24),
		Vector3(0.0, -0.66, 0.16),
		Vector3(0.0, -0.74, 0.18)
	]
	var tibia_rads: Array[float] = [0.05, 0.042, 0.035, 0.025]
	pivot.add_child(_create_lofted_tube(tibia_pts, tibia_rads, 8, mat_chitin))

	# Garras duplas tarsais no solo (Y = -0.75)
	for side in [-1.0, 1.0]:
		var claw_pts: Array[Vector3] = [
			Vector3(side * 0.03, -0.73, 0.18),
			Vector3(side * 0.06, -0.75, 0.24),
			Vector3(side * 0.08, -0.75, 0.28)
		]
		var claw_rads: Array[float] = [0.022, 0.014, 0.002]
		pivot.add_child(_create_lofted_tube(claw_pts, claw_rads, 6, mat_claw))

# --- C. BOCA INSETÓIDE (Quelíceras cortantes e glândula de veneno) ---
func _build_sculpted_insectoid_mouth(root: Node3D) -> void:
	var mat_chitin = _make_organic_material(primary_color.darkened(0.2), 0.30, 0.20)
	var mat_mandible = _make_keratin_material(secondary_color.darkened(0.4), detail_color)

	var mat_acid = StandardMaterial3D.new()
	mat_acid.albedo_color = secondary_color.lightened(0.3)
	mat_acid.emission_enabled = true
	mat_acid.emission = secondary_color.lightened(0.4)
	mat_acid.emission_energy_multiplier = 1.3
	mat_acid.roughness = 0.15

	var mouth_root = Node3D.new()
	mouth_root.name = "InsectMouthRoot"
	root.add_child(mouth_root)

	# Clípeo / Escudo cefálico frontal
	var shield_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.02),
		Vector3(0.0, 0.14, 0.06),
		Vector3(0.0, 0.24, 0.04)
	]
	var shield_rads: Array[float] = [0.15, 0.14, 0.09]
	mouth_root.add_child(_create_lofted_tube(shield_pts, shield_rads, 12, mat_chitin))

	# Glândula ácida bioluminescente central
	var gland = MeshInstance3D.new()
	var g_sphere = SphereMesh.new()
	g_sphere.radius = 0.065
	g_sphere.height = 0.13
	gland.mesh = g_sphere
	gland.position = Vector3(0.0, 0.18, -0.02)
	gland.material_override = mat_acid
	mouth_root.add_child(gland)

	# Mandíbulas / Quelíceras arqueadas que se cruzam
	for side in [-1.0, 1.0]:
		var mand_pts: Array[Vector3] = [
			Vector3(side * 0.10, 0.10, -0.02),
			Vector3(side * 0.18, 0.22, -0.04),
			Vector3(side * 0.14, 0.32, 0.01),
			Vector3(side * 0.02, 0.38, 0.04)
		]
		var mand_rads: Array[float] = [0.065, 0.048, 0.028, 0.003]
		mouth_root.add_child(_create_lofted_tube(mand_pts, mand_rads, 10, mat_mandible))

		# Palpos sensoriais menores
		var palp_pts: Array[Vector3] = [
			Vector3(side * 0.08, 0.08, -0.08),
			Vector3(side * 0.12, 0.16, -0.12),
			Vector3(side * 0.09, 0.24, -0.14)
		]
		var palp_rads: Array[float] = [0.028, 0.018, 0.003]
		mouth_root.add_child(_create_lofted_tube(palp_pts, palp_rads, 6, mat_chitin))

# --- D. BICO DE AVE DE RAPINA (Curvo e afiado com cera e narinas) ---
func _build_sculpted_beak_mouth(root: Node3D) -> void:
	var mat_cere = _make_organic_material(primary_color, 0.40, 0.05)
	var mat_beak = _make_keratin_material(secondary_color, detail_color)

	var beak_root = Node3D.new()
	beak_root.name = "BeakRoot"
	root.add_child(beak_root)

	# Cera base do bico
	var cere_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.02),
		Vector3(0.0, 0.12, 0.05),
		Vector3(0.0, 0.18, 0.03)
	]
	var cere_rads: Array[float] = [0.15, 0.14, 0.11]
	beak_root.add_child(_create_lofted_tube(cere_pts, cere_rads, 12, mat_cere))

	# Gancho superior agudo curvado para baixo
	var hook_pts: Array[Vector3] = [
		Vector3(0.0, 0.16, 0.04),
		Vector3(0.0, 0.28, 0.06),
		Vector3(0.0, 0.38, 0.01),
		Vector3(0.0, 0.42, -0.10)
	]
	var hook_rads: Array[float] = [0.10, 0.085, 0.05, 0.003]
	beak_root.add_child(_create_lofted_tube(hook_pts, hook_rads, 12, mat_beak))

	# Mandíbula inferior que encaixa no gancho
	var lower_pts: Array[Vector3] = [
		Vector3(0.0, 0.08, -0.04),
		Vector3(0.0, 0.20, -0.06),
		Vector3(0.0, 0.32, -0.05)
	]
	var lower_rads: Array[float] = [0.09, 0.065, 0.004]
	beak_root.add_child(_create_lofted_tube(lower_pts, lower_rads, 10, mat_beak))

# --- E. OLHO COMPOSTO INSETÓIDE (Facetado esmeralda com brilho) ---
func _build_sculpted_compound_eye(root: Node3D) -> void:
	var mat_socket = _make_organic_material(primary_color.darkened(0.2), 0.35, 0.10)

	var mat_facet = StandardMaterial3D.new()
	mat_facet.albedo_color = secondary_color
	mat_facet.metallic = 0.35
	mat_facet.roughness = 0.12
	mat_facet.emission_enabled = true
	mat_facet.emission = secondary_color.lightened(0.25)
	mat_facet.emission_energy_multiplier = 0.6

	var eye_root = Node3D.new()
	eye_root.name = "CompoundEyeRoot"
	root.add_child(eye_root)

	# Anel de fixação quitinoso
	var socket = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.10
	torus.outer_radius = 0.17
	socket.mesh = torus
	socket.position = Vector3(0.0, 0.06, 0.0)
	socket.material_override = mat_socket
	eye_root.add_child(socket)

	# Cúpula facetada composta
	var dome = MeshInstance3D.new()
	var s_mesh = SphereMesh.new()
	s_mesh.radius = 0.14
	s_mesh.height = 0.26
	s_mesh.radial_segments = 24
	s_mesh.rings = 16
	dome.mesh = s_mesh
	dome.position = Vector3(0.0, 0.12, 0.0)
	dome.material_override = mat_facet
	eye_root.add_child(dome)

# --- F. OLHO PEDUNCULADO (Sobre haste móvel) ---
func _build_sculpted_stalk_eye(root: Node3D) -> void:
	var mat_stalk = _make_organic_material(primary_color, 0.50, 0.05)
	var mat_sclera = StandardMaterial3D.new()
	mat_sclera.albedo_color = Color(0.95, 0.94, 0.90)
	mat_sclera.roughness = 0.04
	mat_sclera.clearcoat_enabled = true
	mat_sclera.clearcoat = 1.0
	mat_sclera.clearcoat_roughness = 0.04
	var mat_pupil = StandardMaterial3D.new()
	mat_pupil.albedo_color = Color(0.05, 0.05, 0.06)

	var stalk_root = Node3D.new()
	stalk_root.name = "StalkEyeRoot"
	root.add_child(stalk_root)

	# Pedúnculo carnudo curvo
	var stalk_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.12, 0.04),
		Vector3(0.0, 0.25, 0.08),
		Vector3(0.0, 0.36, 0.06)
	]
	var stalk_rads: Array[float] = [0.08, 0.065, 0.055, 0.07]
	stalk_root.add_child(_create_lofted_tube(stalk_pts, stalk_rads, 10, mat_stalk))

	# Bulbo ocular
	var ball = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.095
	sphere.height = 0.19
	ball.mesh = sphere
	ball.position = Vector3(0.0, 0.38, 0.06)
	ball.material_override = mat_sclera
	stalk_root.add_child(ball)

	# Pupila frontal
	var pupil = MeshInstance3D.new()
	var p_sphere = SphereMesh.new()
	p_sphere.radius = 0.038
	p_sphere.height = 0.076
	pupil.mesh = p_sphere
	pupil.position = Vector3(0.0, 0.44, 0.11)
	pupil.material_override = mat_pupil
	stalk_root.add_child(pupil)

# --- G. ANTENA SENSORIAL BIOLUMINESCENTE ---
func _build_sculpted_antenna(root: Node3D) -> void:
	var mat_ant = _make_organic_material(secondary_color, 0.40, 0.10)
	var mat_glow = StandardMaterial3D.new()
	mat_glow.albedo_color = detail_color
	mat_glow.emission_enabled = true
	mat_glow.emission = detail_color
	mat_glow.emission_energy_multiplier = 1.6

	var ant_root = Node3D.new()
	ant_root.name = "AntennaRoot"
	root.add_child(ant_root)

	# Antena longa e elegante arqueada
	var ant_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.15, -0.04),
		Vector3(0.0, 0.32, -0.06),
		Vector3(0.0, 0.50, 0.02),
		Vector3(0.0, 0.64, 0.14)
	]
	var ant_rads: Array[float] = [0.05, 0.038, 0.026, 0.016, 0.008]
	ant_root.add_child(_create_lofted_tube(ant_pts, ant_rads, 8, mat_ant))

	# Ponta bioluminescente
	var tip = MeshInstance3D.new()
	var t_sph = SphereMesh.new()
	t_sph.radius = 0.032
	t_sph.height = 0.064
	tip.mesh = t_sph
	tip.position = Vector3(0.0, 0.66, 0.16)
	tip.material_override = mat_glow
	ant_root.add_child(tip)

# --- H. CAUDA COM CLAVA ÓSSEA / MAÇA DE ANQUILOSSAURO ---
func _build_sculpted_club_tail(root: Node3D) -> void:
	var mat_skin = _make_organic_material(primary_color, 0.55, 0.05)
	var mat_bone = _make_keratin_material(secondary_color.darkened(0.2), detail_color)

	var tail_root = Node3D.new()
	tail_root.name = "ClubTailRoot"
	root.add_child(tail_root)

	# Coluna da cauda
	var tail_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.15, -0.06),
		Vector3(0.0, 0.32, -0.10),
		Vector3(0.0, 0.48, -0.06),
		Vector3(0.0, 0.62, 0.02)
	]
	var tail_rads: Array[float] = [0.12, 0.10, 0.085, 0.075, 0.08]
	tail_root.add_child(_create_lofted_tube(tail_pts, tail_rads, 12, mat_skin))

	# Maça óssea terminal
	var club = MeshInstance3D.new()
	var c_sphere = SphereMesh.new()
	c_sphere.radius = 0.14
	c_sphere.height = 0.26
	club.mesh = c_sphere
	club.position = Vector3(0.0, 0.66, 0.04)
	club.material_override = mat_bone
	tail_root.add_child(club)

	# Espinhos rombudos da maça
	for angle in [0.0, 1.57, 3.14, 4.71]:
		var dir = Vector3(cos(angle), 0.0, sin(angle))
		var spike_pts: Array[Vector3] = [
			Vector3(0.0, 0.66, 0.04) + dir * 0.09,
			Vector3(0.0, 0.66, 0.04) + dir * 0.20
		]
		var spike_rads: Array[float] = [0.045, 0.005]
		tail_root.add_child(_create_lofted_tube(spike_pts, spike_rads, 8, mat_bone))

# --- I. LEME EMPLUMADO / CAUDA DE PENAS ---
func _build_sculpted_feather_tail(root: Node3D) -> void:
	var mat_tail = _make_organic_material(primary_color, 0.50, 0.05)
	var mat_feather = StandardMaterial3D.new()
	mat_feather.albedo_color = secondary_color
	mat_feather.roughness = 0.35

	var tail_root = Node3D.new()
	tail_root.name = "FeatherTailRoot"
	root.add_child(tail_root)

	var tail_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.16, -0.04),
		Vector3(0.0, 0.32, -0.06),
		Vector3(0.0, 0.46, -0.02)
	]
	var tail_rads: Array[float] = [0.10, 0.08, 0.06, 0.04]
	tail_root.add_child(_create_lofted_tube(tail_pts, tail_rads, 10, mat_tail))

	# Leque de 5 penas longas
	var angles = [-0.45, -0.22, 0.0, 0.22, 0.45]
	for a in angles:
		var f_dir = Vector3(sin(a) * 0.25, 0.42, cos(a) * 0.10)
		var f_pts: Array[Vector3] = [
			Vector3(0.0, 0.44, -0.02),
			Vector3(0.0, 0.44, -0.02) + f_dir * 0.55,
			Vector3(0.0, 0.44, -0.02) + f_dir
		]
		var f_rads: Array[float] = [0.035, 0.085, 0.005]
		tail_root.add_child(_create_lofted_tube(f_pts, f_rads, 8, mat_feather))

# --- J. ASA INSETÓIDE DUPLA (Libélula translúcida) ---
func _build_sculpted_insect_wing(root: Node3D) -> void:
	var mat_vein = _make_organic_material(secondary_color.darkened(0.3), 0.3, 0.2)
	var mat_membrane = StandardMaterial3D.new()
	mat_membrane.albedo_color = Color(secondary_color.r, secondary_color.g, secondary_color.b, 0.65)
	mat_membrane.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_membrane.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat_membrane.roughness = 0.1
	mat_membrane.metallic = 0.2

	var wing_pivot = Node3D.new()
	wing_pivot.name = "InsectWingPivot"
	root.add_child(wing_pivot)

	# Par de asas (anterior longa e posterior curta)
	var wing_pairs = [
		{"tip": Vector3(0.0, 1.45, 0.15), "mid": Vector3(0.0, 0.75, 0.22), "width": 0.28},
		{"tip": Vector3(0.0, 1.05, -0.35), "mid": Vector3(0.0, 0.55, -0.25), "width": 0.22}
	]
	for wp in wing_pairs:
		var tip: Vector3 = wp["tip"]
		var mid: Vector3 = wp["mid"]
		var w: float = wp["width"]

		# Nervura mestre principal
		var vein_pts: Array[Vector3] = [Vector3.ZERO, mid, tip]
		var vein_rads: Array[float] = [0.045, 0.025, 0.005]
		wing_pivot.add_child(_create_lofted_tube(vein_pts, vein_rads, 8, mat_vein))

		# Superfície translúcida
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var back_mid = mid + Vector3(0.0, -0.15, -w)
		st.add_vertex(Vector3.ZERO)
		st.add_vertex(mid)
		st.add_vertex(back_mid)
		st.add_vertex(mid)
		st.add_vertex(tip)
		st.add_vertex(back_mid)
		st.generate_normals()

		var w_mesh = MeshInstance3D.new()
		w_mesh.mesh = st.commit()
		w_mesh.material_override = mat_membrane
		wing_pivot.add_child(w_mesh)

# --- K. ASA EMPLUMADA DE AVE ---
func _build_sculpted_feather_wing(root: Node3D) -> void:
	var mat_arm = _make_organic_material(primary_color, 0.5, 0.05)
	var mat_feathers = StandardMaterial3D.new()
	mat_feathers.albedo_color = secondary_color
	mat_feathers.roughness = 0.4

	var wing_pivot = Node3D.new()
	wing_pivot.name = "FeatherWingPivot"
	root.add_child(wing_pivot)

	# Braço esquelético da asa
	var arm_pts: Array[Vector3] = [
		Vector3.ZERO,
		Vector3(0.0, 0.35, 0.22),
		Vector3(0.0, 0.80, 0.12),
		Vector3(0.0, 1.30, -0.20)
	]
	var arm_rads: Array[float] = [0.09, 0.07, 0.045, 0.02]
	wing_pivot.add_child(_create_lofted_tube(arm_pts, arm_rads, 10, mat_arm))

	# Camadas de penas (Rêmiges primárias e secundárias)
	var feather_tips = [
		Vector3(0.0, 1.45, -0.35),
		Vector3(0.0, 1.25, -0.65),
		Vector3(0.0, 0.95, -0.85),
		Vector3(0.0, 0.65, -0.80),
		Vector3(0.0, 0.35, -0.65)
	]
	for i in range(feather_tips.size()):
		var f_tip = feather_tips[i]
		var f_pts: Array[Vector3] = [
			Vector3(0.0, 0.35 + i * 0.18, 0.20 - i * 0.08),
			f_tip * 0.6,
			f_tip
		]
		var f_rads: Array[float] = [0.03, 0.09, 0.005]
		wing_pivot.add_child(_create_lofted_tube(f_pts, f_rads, 8, mat_feathers))

# --- L. GALHADA / CHIFRE RAMIFICADO DE CERVO ---
func _build_sculpted_antler_horn(root: Node3D) -> void:
	var mat_antler = _make_keratin_material(secondary_color.darkened(0.3), detail_color)

	var horn_root = Node3D.new()
	horn_root.name = "AntlerRoot"
	root.add_child(horn_root)

	# Haste principal curvada para cima e para trás
	var main_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.16, -0.04),
		Vector3(0.0, 0.34, -0.06),
		Vector3(0.0, 0.52, 0.04),
		Vector3(0.0, 0.68, 0.18)
	]
	var main_rads: Array[float] = [0.085, 0.07, 0.052, 0.035, 0.005]
	horn_root.add_child(_create_lofted_tube(main_pts, main_rads, 10, mat_antler))

	# Pontas ramificadas projetando-se para frente
	var tines = [
		{"base": Vector3(0.0, 0.18, -0.04), "tip": Vector3(0.08, 0.28, 0.16)},
		{"base": Vector3(0.0, 0.36, -0.05), "tip": Vector3(-0.06, 0.48, 0.18)},
		{"base": Vector3(0.0, 0.50, 0.02),  "tip": Vector3(0.09, 0.62, 0.26)}
	]
	for tn in tines:
		var t_pts: Array[Vector3] = [tn["base"], (tn["base"] + tn["tip"]) * 0.5, tn["tip"]]
		var t_rads: Array[float] = [0.038, 0.024, 0.003]
		horn_root.add_child(_create_lofted_tube(t_pts, t_rads, 8, mat_antler))

# --- M. PLACA / ESPINHO DORSAL ESTEGOSSAURO ---
func _build_sculpted_dorsal_spike(root: Node3D) -> void:
	var mat_plate = _make_organic_material(primary_color, 0.45, 0.08)
	var mat_rim = _make_keratin_material(secondary_color, detail_color)

	var spike_root = Node3D.new()
	spike_root.name = "DorsalSpikeRoot"
	root.add_child(spike_root)

	# Quilha central espessa
	var keel_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.18, 0.02),
		Vector3(0.0, 0.36, 0.03),
		Vector3(0.0, 0.52, 0.0)
	]
	var keel_rads: Array[float] = [0.11, 0.085, 0.05, 0.004]
	spike_root.add_child(_create_lofted_tube(keel_pts, keel_rads, 10, mat_plate))

	# Aletas em lâmina losangular ao redor da quilha
	for side in [-1.0, 1.0]:
		var blade_pts: Array[Vector3] = [
			Vector3(side * 0.04, 0.08, -0.04),
			Vector3(side * 0.16, 0.26, 0.0),
			Vector3(side * 0.03, 0.46, 0.02)
		]
		var blade_rads: Array[float] = [0.035, 0.045, 0.008]
		spike_root.add_child(_create_lofted_tube(blade_pts, blade_rads, 8, mat_rim))

# --- N. LÂMINA ÓSSEA DE FOICE (Mantis / Cotovelo) ---
func _build_sculpted_bone_blade(root: Node3D) -> void:
	var mat_base = _make_organic_material(primary_color.darkened(0.2), 0.45, 0.10)
	var mat_blade = _make_keratin_material(secondary_color.darkened(0.2), detail_color)

	var blade_root = Node3D.new()
	blade_root.name = "BoneBladeRoot"
	root.add_child(blade_root)

	# Bainha muscular de base
	var base_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.10, 0.02),
		Vector3(0.0, 0.16, 0.04)
	]
	var base_rads: Array[float] = [0.09, 0.08, 0.06]
	blade_root.add_child(_create_lofted_tube(base_pts, base_rads, 10, mat_base))

	# Lâmina afiada curva como foice
	var scythe_pts: Array[Vector3] = [
		Vector3(0.0, 0.14, 0.04),
		Vector3(0.0, 0.28, 0.14),
		Vector3(0.0, 0.44, 0.28),
		Vector3(0.0, 0.56, 0.22)
	]
	var scythe_rads: Array[float] = [0.06, 0.045, 0.028, 0.002]
	blade_root.add_child(_create_lofted_tube(scythe_pts, scythe_rads, 8, mat_blade))

# --- O. PINÇA CRUSTÁCEA MACIÇA ARTICULADA ---
func _build_sculpted_claw_pincer(root: Node3D) -> void:
	var mat_shell = _make_organic_material(secondary_color, 0.35, 0.15)
	var mat_joint = _make_organic_material(primary_color, 0.50, 0.05)
	var mat_teeth = _make_keratin_material(secondary_color.darkened(0.3), detail_color)

	var pincer_root = Node3D.new()
	pincer_root.name = "ClawPincerRoot"
	root.add_child(pincer_root)

	# 1. Braço / Mero e Carpo articulado
	var arm_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, -0.10, 0.10),
		Vector3(0.0, -0.22, 0.18),
		Vector3(0.0, -0.32, 0.22)
	]
	var arm_rads: Array[float] = [0.08, 0.09, 0.08, 0.07]
	pincer_root.add_child(_create_lofted_tube(arm_pts, arm_rads, 10, mat_joint))

	# 2. Bulbo robusto da pinça (Propodus)
	var palm_pts: Array[Vector3] = [
		Vector3(0.0, -0.30, 0.22),
		Vector3(0.0, -0.42, 0.30),
		Vector3(0.0, -0.54, 0.36)
	]
	var palm_rads: Array[float] = [0.075, 0.13, 0.11]
	pincer_root.add_child(_create_lofted_tube(palm_pts, palm_rads, 12, mat_shell))

	# 3. Dedo Fixo da Pinça (curvado para dentro)
	var fixed_pts: Array[Vector3] = [
		Vector3(0.0, -0.52, 0.34),
		Vector3(0.0, -0.66, 0.38),
		Vector3(0.0, -0.78, 0.34)
	]
	var fixed_rads: Array[float] = [0.075, 0.045, 0.005]
	pincer_root.add_child(_create_lofted_tube(fixed_pts, fixed_rads, 10, mat_shell))

	# 4. Dedo Móvel Oposto (Dactylus) em garra curva afiada
	var movable_pts: Array[Vector3] = [
		Vector3(0.0, -0.50, 0.38),
		Vector3(0.0, -0.64, 0.48),
		Vector3(0.0, -0.78, 0.40)
	]
	var mov_rads: Array[float] = [0.065, 0.040, 0.004]
	pincer_root.add_child(_create_lofted_tube(movable_pts, mov_rads, 10, mat_shell))

	# Dentes de esmagamento no vão da pinça
	for i in range(4):
		var t_f = float(i) / 3.0
		var pos_fixed = fixed_pts[1].lerp(fixed_pts[2], t_f) + Vector3(0.0, 0.0, 0.03)
		var tooth_pts: Array[Vector3] = [pos_fixed, pos_fixed + Vector3(0.0, 0.015, 0.02)]
		var tooth_rads: Array[float] = [0.018, 0.004]
		pincer_root.add_child(_create_lofted_tube(tooth_pts, tooth_rads, 6, mat_teeth))

# --- P. CAUDA DE ESCORPIÃO COM METASOMA SEGMENTADO E AGUILHÃO DUPLO ---
func _build_sculpted_scorpion_tail(root: Node3D) -> void:
	var mat_chitin = _make_organic_material(secondary_color, 0.30, 0.16)
	var mat_joint = _make_organic_material(primary_color.darkened(0.15), 0.45, 0.08)
	var mat_stinger = _make_keratin_material(secondary_color.darkened(0.5), detail_color)

	var scorp_root = Node3D.new()
	scorp_root.name = "ScorpionTailRoot"
	root.add_child(scorp_root)

	# 1. Metasoma completo em arco contínuo para cima e para frente (+Y e +Z)
	var tail_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.14, -0.05),
		Vector3(0.0, 0.30, -0.09),
		Vector3(0.0, 0.46, -0.06),
		Vector3(0.0, 0.60, 0.04),
		Vector3(0.0, 0.70, 0.18)
	]
	var tail_rads: Array[float] = [0.125, 0.11, 0.095, 0.082, 0.075, 0.085]
	scorp_root.add_child(_create_lofted_tube(tail_pts, tail_rads, 14, mat_chitin))

	# 2. Anéis quitinosos articulados e cristas espinhosas dorsais em cada junta
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
		# Anel articular
		var ring = MeshInstance3D.new()
		var torus = TorusMesh.new()
		torus.inner_radius = j_r * 0.85
		torus.outer_radius = j_r * 1.08
		torus.rings = 14
		torus.ring_segments = 8
		ring.mesh = torus
		ring.position = j_pos
		ring.material_override = mat_joint
		scorp_root.add_child(ring)

		# Espinho dorsal carinado no topo do anel
		var spine_pts: Array[Vector3] = [
			j_pos,
			j_pos + Vector3(0.0, 0.04, -0.06)
		]
		var spine_rads: Array[float] = [0.025, 0.003]
		scorp_root.add_child(_create_lofted_tube(spine_pts, spine_rads, 6, mat_stinger))

	# 3. Telson (bulbo do veneno)
	var telson = MeshInstance3D.new()
	var t_sph = SphereMesh.new()
	t_sph.radius = 0.095
	t_sph.height = 0.19
	telson.mesh = t_sph
	telson.position = Vector3(0.0, 0.74, 0.22)
	telson.material_override = mat_chitin
	scorp_root.add_child(telson)

	# 4. Aguilhão curvo mortal apontando para frente/baixo
	var sting_pts: Array[Vector3] = [
		Vector3(0.0, 0.78, 0.26),
		Vector3(0.0, 0.88, 0.38),
		Vector3(0.0, 0.84, 0.52)
	]
	var sting_rads: Array[float] = [0.048, 0.024, 0.002]
	scorp_root.add_child(_create_lofted_tube(sting_pts, sting_rads, 10, mat_stinger))

	# 5. Espinho subaculear de veneno
	var sub_pts: Array[Vector3] = [
		Vector3(0.0, 0.80, 0.31),
		Vector3(0.0, 0.83, 0.37)
	]
	var sub_rads: Array[float] = [0.018, 0.002]
	scorp_root.add_child(_create_lofted_tube(sub_pts, sub_rads, 6, mat_stinger))

# --- R. BARBATANA AQUÁTICA COM RAIOS CARTILAGINOSOS ---
func _build_sculpted_aquatic_fin(root: Node3D) -> void:
	var mat_base = _make_organic_material(primary_color, 0.45, 0.08)
	var mat_ray = _make_organic_material(secondary_color, 0.35, 0.15)
	var mat_web = StandardMaterial3D.new()
	mat_web.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat_web.albedo_color = Color(secondary_color.r, secondary_color.g, secondary_color.b, 0.85)
	mat_web.roughness = 0.28
	mat_web.rim_enabled = true
	mat_web.rim = 0.5
	mat_web.backlight_enabled = true
	mat_web.backlight = primary_color.lightened(0.2)

	var fin_root = Node3D.new()
	fin_root.name = "AquaticFinRoot"
	root.add_child(fin_root)

	# Base muscular de implantação
	var base_pts: Array[Vector3] = [
		Vector3(0.0, 0.0, 0.0),
		Vector3(0.0, 0.10, 0.02),
		Vector3(0.0, 0.18, 0.03)
	]
	var base_rads: Array[float] = [0.10, 0.08, 0.06]
	fin_root.add_child(_create_lofted_tube(base_pts, base_rads, 10, mat_base))

	# Raio líder principal (bordo de ataque de tubarão)
	var lead_pts: Array[Vector3] = [
		Vector3(0.0, 0.16, 0.03),
		Vector3(0.0, 0.34, 0.10),
		Vector3(0.0, 0.54, 0.22),
		Vector3(0.0, 0.68, 0.30)
	]
	var lead_rads: Array[float] = [0.055, 0.038, 0.022, 0.003]
	fin_root.add_child(_create_lofted_tube(lead_pts, lead_rads, 8, mat_ray))

	# Raios secundários estendendo para trás
	var fin_tips = [
		lead_pts.back(),
		Vector3(0.0, 0.52, 0.10),
		Vector3(0.0, 0.34, -0.06),
		Vector3(0.0, 0.16, -0.14)
	]
	for i in range(1, fin_tips.size()):
		var r_pts: Array[Vector3] = [
			Vector3(0.0, 0.10 + i * 0.02, 0.0),
			fin_tips[i] * 0.7,
			fin_tips[i]
		]
		var r_rads: Array[float] = [0.035, 0.020, 0.003]
		fin_root.add_child(_create_lofted_tube(r_pts, r_rads, 6, mat_ray))

	# Malha da membrana aquática entre os raios
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var origin = Vector3(0.0, 0.12, 0.0)
	for i in range(fin_tips.size() - 1):
		st.add_vertex(origin)
		st.add_vertex(fin_tips[i])
		st.add_vertex(fin_tips[i + 1])
	st.generate_normals()

	var web_inst = MeshInstance3D.new()
	web_inst.mesh = st.commit()
	web_inst.material_override = mat_web
	fin_root.add_child(web_inst)

# --- S. CHIFRE MACIÇO DE RINOCERONTE COM QUERATINA COMPACTADA ---
func _build_sculpted_rhino_horn(root: Node3D) -> void:
	var mat_boss = _make_organic_material(primary_color.darkened(0.12), 0.65, 0.05)
	var mat_horn = _make_keratin_material(secondary_color.darkened(0.4), detail_color)

	var horn_root = Node3D.new()
	horn_root.name = "RhinoHornRoot"
	root.add_child(horn_root)

	# Placa basal dérmica espessada (boss)
	var boss_pts: Array[Vector3] = [
		Vector3(0.0, -0.02, 0.0),
		Vector3(0.0, 0.06, 0.02),
		Vector3(0.0, 0.12, 0.03)
	]
	var boss_rads: Array[float] = [0.16, 0.17, 0.14]
	horn_root.add_child(_create_lofted_tube(boss_pts, boss_rads, 14, mat_boss))

	# Chifre maciço principal curvado para trás
	var horn_pts: Array[Vector3] = [
		Vector3(0.0, 0.10, 0.03),
		Vector3(0.0, 0.24, 0.08),
		Vector3(0.0, 0.40, 0.16),
		Vector3(0.0, 0.54, 0.28),
		Vector3(0.0, 0.64, 0.38)
	]
	var horn_rads: Array[float] = [0.13, 0.105, 0.075, 0.040, 0.004]
	horn_root.add_child(_create_lofted_tube(horn_pts, horn_rads, 14, mat_horn))

	# Chifre acessório frontal menor
	var sub_pts: Array[Vector3] = [
		Vector3(0.0, 0.06, -0.12),
		Vector3(0.0, 0.18, -0.18),
		Vector3(0.0, 0.28, -0.22)
	]
	var sub_rads: Array[float] = [0.075, 0.042, 0.003]
	horn_root.add_child(_create_lofted_tube(sub_pts, sub_rads, 10, mat_horn))

# --- T. ASA LEPIDÓPTERA / FADA / BORBOLETA MÍSTICA COM OCELOS ---
func _build_sculpted_butterfly_wing(root: Node3D) -> void:
	var mat_arm = _make_organic_material(primary_color, 0.40, 0.10)
	var mat_vein = _make_organic_material(secondary_color.darkened(0.35), 0.35, 0.15)
	var mat_membrane = StandardMaterial3D.new()
	mat_membrane.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat_membrane.albedo_color = secondary_color
	mat_membrane.roughness = 0.25
	mat_membrane.rim_enabled = true
	mat_membrane.rim = 0.6
	mat_membrane.backlight_enabled = true
	mat_membrane.backlight = primary_color.lightened(0.25)
	var mat_ocellus_ring = _make_keratin_material(secondary_color, detail_color)
	var mat_ocellus_pupil = StandardMaterial3D.new()
	mat_ocellus_pupil.albedo_color = primary_color.darkened(0.5)
	mat_ocellus_pupil.emission_enabled = true
	mat_ocellus_pupil.emission = detail_color
	mat_ocellus_pupil.emission_energy_multiplier = 0.8

	var wing_pivot = Node3D.new()
	wing_pivot.name = "ButterflyWingPivot"
	root.add_child(wing_pivot)

	# 1. Base esquelética de implantação / Espádua
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

	# 3. Asa Anterior Ampla (Forewing) recortada com nervuras
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
	var hub_fore = Vector3(0.0, 0.50, 0.0)
	for i in range(fore_perim.size()):
		var p_curr = fore_perim[i]
		var p_next = fore_perim[(i + 1) % fore_perim.size()]
		st_fore.add_vertex(hub_fore)
		st_fore.add_vertex(p_curr)
		st_fore.add_vertex(p_next)
	st_fore.generate_normals()
	var fore_mesh = MeshInstance3D.new()
	fore_mesh.mesh = st_fore.commit()
	fore_mesh.material_override = mat_membrane
	wing_pivot.add_child(fore_mesh)

	# Nervuras radiais na asa anterior
	for i in [3, 4, 5, 6]:
		var r_pts: Array[Vector3] = [hub_fore, hub_fore.lerp(fore_perim[i], 0.55), fore_perim[i]]
		var r_rads: Array[float] = [0.025, 0.015, 0.004]
		wing_pivot.add_child(_create_lofted_tube(r_pts, r_rads, 6, mat_vein))

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
	var hub_hind = Vector3(0.0, 0.15, -0.30)
	for i in range(hind_perim.size()):
		var p_curr = hind_perim[i]
		var p_next = hind_perim[(i + 1) % hind_perim.size()]
		st_hind.add_vertex(hub_hind)
		st_hind.add_vertex(p_curr)
		st_hind.add_vertex(p_next)
	st_hind.generate_normals()
	var hind_mesh = MeshInstance3D.new()
	hind_mesh.mesh = st_hind.commit()
	hind_mesh.material_override = mat_membrane
	wing_pivot.add_child(hind_mesh)

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
	var ocellus_radii: Array[float] = [0.09, 0.07]
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
		s_mesh.radius = o_r * 0.45
		s_mesh.height = 0.03
		center.mesh = s_mesh
		center.position = c_pos
		center.material_override = mat_ocellus_pupil
		wing_pivot.add_child(center)

# --- U. OLHO CICLÓPEO COLOSSAL COM CRISTA SUPERCILIAR ---
func _build_sculpted_cyclops_eye(root: Node3D) -> void:
	var mat_brow = _make_organic_material(primary_color, 0.55, 0.05)
	var mat_rim = _make_keratin_material(secondary_color, detail_color)

	var mat_sclera = StandardMaterial3D.new()
	mat_sclera.albedo_color = Color(0.96, 0.94, 0.88)
	mat_sclera.roughness = 0.05
	mat_sclera.clearcoat_enabled = true
	mat_sclera.clearcoat = 1.0

	var mat_iris = StandardMaterial3D.new()
	mat_iris.albedo_color = secondary_color
	mat_iris.roughness = 0.1
	mat_iris.emission_enabled = true
	mat_iris.emission = secondary_color.lightened(0.3)
	mat_iris.emission_energy_multiplier = 0.8

	var mat_pupil = StandardMaterial3D.new()
	mat_pupil.albedo_color = Color(0.02, 0.02, 0.03)

	var eye_root = Node3D.new()
	eye_root.name = "CyclopsEyeRoot"
	root.add_child(eye_root)

	# 1. Crista superciliar pesada e pálpebra colossal
	var brow_pts: Array[Vector3] = [
		Vector3(-0.24, 0.16, 0.08),
		Vector3(0.0, 0.24, 0.12),
		Vector3(0.24, 0.16, 0.08)
	]
	var brow_rads: Array[float] = [0.06, 0.09, 0.06]
	eye_root.add_child(_create_lofted_tube(brow_pts, brow_rads, 10, mat_brow))

	# Pálpebra inferior
	var lower_brow: Array[Vector3] = [
		Vector3(-0.20, 0.04, -0.08),
		Vector3(0.0, 0.02, -0.12),
		Vector3(0.20, 0.04, -0.08)
	]
	var lower_rads: Array[float] = [0.05, 0.07, 0.05]
	eye_root.add_child(_create_lofted_tube(lower_brow, lower_rads, 10, mat_brow))

	# 2. Globo Ocular Colossal
	var eyeball = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.18
	sphere.height = 0.36
	eyeball.mesh = sphere
	eyeball.position = Vector3(0.0, 0.12, 0.0)
	eyeball.material_override = mat_sclera
	eye_root.add_child(eyeball)

	# 3. Íris Ciclópea Brilhante
	var iris = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.095
	cyl.bottom_radius = 0.105
	cyl.height = 0.03
	iris.mesh = cyl
	iris.position = Vector3(0.0, 0.28, 0.0)
	iris.material_override = mat_iris
	eye_root.add_child(iris)

	# 4. Pupila
	var pupil = MeshInstance3D.new()
	var p_mesh = BoxMesh.new()
	p_mesh.size = Vector3(0.038, 0.025, 0.13)
	pupil.mesh = p_mesh
	pupil.position = Vector3(0.0, 0.29, 0.0)
	pupil.material_override = mat_pupil
	eye_root.add_child(pupil)

	# 5. Pequenos espinhos córneo-orbitais de proteção
	for side in [-1.0, 1.0]:
		var horn_pts: Array[Vector3] = [
			Vector3(side * 0.22, 0.14, 0.06),
			Vector3(side * 0.34, 0.22, 0.10)
		]
		var horn_rads: Array[float] = [0.035, 0.003]
		eye_root.add_child(_create_lofted_tube(horn_pts, horn_rads, 6, mat_rim))

# ==============================================================================
# UTILITÁRIOS DE GERAÇÃO DE MALHA TUBULAR SUAVE (SURFACE TOOL) E MATERIAIS
# ==============================================================================

func _make_organic_material(albedo: Color, rough: float, metal: float, sss_col: Color = Color.BLACK, sss_str: float = 0.0) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = albedo
	mat.roughness = rough
	mat.metallic = metal
	mat.rim_enabled = true
	mat.rim = 0.35
	mat.rim_tint = 0.45
	if sss_str > 0.01:
		mat.backlight_enabled = true
		mat.backlight = sss_col * sss_str
	return mat

func _make_keratin_material(base_col: Color, tip_col: Color) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = base_col.lerp(tip_col, 0.65)
	mat.roughness = 0.24
	mat.metallic = 0.12
	mat.clearcoat_enabled = true
	mat.clearcoat = 0.65
	mat.clearcoat_roughness = 0.20
	return mat

## Gera um tubo orgânico suave (lofting) passando pelos pontos e raios informados
func _create_lofted_tube(points: Array[Vector3], radii: Array[float], radial_segments: int, mat: Material) -> MeshInstance3D:
	var inst = MeshInstance3D.new()
	if points.size() < 2 or radii.size() < points.size():
		return inst

	# Interpola sub-pontos para deixar a curvatura bem orgânica
	var smooth_pts: Array[Vector3] = []
	var smooth_rads: Array[float] = []
	var subdivs = 3
	var n_segs = points.size() - 1

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
		smooth_pts.append(pos)
		smooth_rads.append(maxf(0.002, rad))

	var rings: Array[Array] = []
	var prev_basis = Basis.IDENTITY

	for i in range(smooth_pts.size()):
		var c = smooth_pts[i]
		var r = smooth_rads[i]
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

		var ring: Array[Vector3] = []
		for j in range(radial_segments):
			var ang = (float(j) / float(radial_segments)) * TAU
			ring.append(c + (basis.x * cos(ang) + basis.y * sin(ang)) * r)
		rings.append(ring)

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# Tampa inicial
	var start_c = smooth_pts[0]
	for j in range(radial_segments):
		var nj = (j + 1) % radial_segments
		st.add_vertex(start_c)
		st.add_vertex(rings[0][nj])
		st.add_vertex(rings[0][j])

	# Corpo tubular
	for i in range(rings.size() - 1):
		for j in range(radial_segments):
			var nj = (j + 1) % radial_segments
			var v00 = rings[i][j]
			var v01 = rings[i][nj]
			var v10 = rings[i + 1][j]
			var v11 = rings[i + 1][nj]

			st.add_vertex(v00)
			st.add_vertex(v01)
			st.add_vertex(v11)

			st.add_vertex(v00)
			st.add_vertex(v11)
			st.add_vertex(v10)

	# Tampa final (ponta)
	var last_idx = rings.size() - 1
	var end_c = smooth_pts[last_idx]
	for j in range(radial_segments):
		var nj = (j + 1) % radial_segments
		st.add_vertex(end_c)
		st.add_vertex(rings[last_idx][j])
		st.add_vertex(rings[last_idx][nj])

	st.generate_normals()
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
