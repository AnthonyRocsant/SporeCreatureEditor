class_name CreatureEditorScene
extends Node3D

@onready var editor_state: EditorState = $EditorState
@onready var attachment_system: AttachmentSystem = $AttachmentSystem
@onready var procedural_gait: ProceduralGait = $ProceduralGait
@onready var body_mesh: MeshInstance3D = $CreatureRoot/BodyMesh
@onready var spine_controller: SpineManager = $CreatureRoot/SpineController
@onready var ui: CreatureEditorUI = $CanvasLayer/CreatureEditorUI
@onready var sandbox_env: Node3D = $SandboxEnvironment

var creature_data: CreatureData
var skill_factory: SkillFactory
var creature_serializer: CreatureSerializer

func _ready() -> void:
	creature_data = CreatureData.new()

	# 1. Configura o controlador de espinha e modelagem procedural (Pilar 1)
	spine_controller.body_mesh_instance = body_mesh
	spine_controller.collision_shape = body_mesh.get_node("StaticBody3D/CollisionShape3D") as CollisionShape3D
	spine_controller.camera = $OrbitCamera
	spine_controller.editor_state = editor_state
	spine_controller.creature_data = creature_data
	spine_controller._sync_spine_biomass()

	# 2. Configura o sistema de anexação, seleção de peças e vínculo com a coluna (Pilar 2 & 4)
	attachment_system.creature_data = creature_data
	attachment_system.editor_state = editor_state
	attachment_system.camera = $OrbitCamera
	attachment_system.body_mesh = body_mesh
	attachment_system.creature_root = $CreatureRoot
	attachment_system.spine_controller = spine_controller
	attachment_system.connect_spine_signals()
	attachment_system.set_active_part(
		preload("res://scenes/appendages/LegClaw.tscn"),
		{
			"type": "leg",
			"category": "leg",
			"tag": "#Claw_Front",
			"name": "Pata / Garra",
			"mass": 1.2,
			"base_damage": 8.0,
			"leg_force": 4.2,
			"wing_area": 0.0,
			"carapace_defense": 2.0
		}
	)

	# 3. Configura a fábrica de habilidades anatômicas (Pilar 3)
	skill_factory = SkillFactory.new()
	skill_factory.name = "SkillFactory"
	skill_factory.creature_data = creature_data
	skill_factory.editor_state = editor_state
	add_child(skill_factory)

	# 4. Configura o serializador JSON de Save/Load (Pilar 4)
	creature_serializer = CreatureSerializer.new()
	creature_serializer.name = "CreatureSerializer"
	creature_serializer.spine_manager = spine_controller
	creature_serializer.attachment_system = attachment_system
	creature_serializer.creature_data = creature_data
	creature_serializer.body_mesh = body_mesh
	creature_serializer.skill_factory = skill_factory
	add_child(creature_serializer)

	# 5. Configura a locomoção procedural e voo no Sandbox
	procedural_gait.creature_root = $CreatureRoot
	procedural_gait.creature_data = creature_data
	procedural_gait.camera = $OrbitCamera as OrbitCamera

	# 6. Enriquece visualmente a arena do Modo Sandbox
	_decorate_sandbox_environment()

	# 7. Configura a UI completa
	ui.creature_data = creature_data
	ui.editor_state = editor_state
	ui.body_mesh = body_mesh
	ui.spine_controller = spine_controller
	ui.attachment_system = attachment_system
	ui.skill_factory = skill_factory
	ui.creature_serializer = creature_serializer
	ui.procedural_gait = procedural_gait
	ui._setup_signals()

	editor_state.mode_changed.connect(_on_mode_changed)

	# Inicializa a malha procedural da espinha
	spine_controller.generate_mesh(true)

	# Inicia no modo escultura por padrão
	editor_state.change_mode(EditorState.Mode.MODO_ESCULTURA)

func _on_mode_changed(new_mode: EditorState.Mode, _old_mode: EditorState.Mode) -> void:
	if new_mode == EditorState.Mode.MODO_SANDBOX:
		sandbox_env.visible = true
		procedural_gait.register_limbs()
		procedural_gait.is_moving = true
	else:
		sandbox_env.visible = false
		procedural_gait.is_moving = false
		procedural_gait.reset_limbs_pose()

## Adiciona referências visuais (piso amplo texturizado, rochas e pilares) para percepção de movimento e voo no Sandbox
func _decorate_sandbox_environment() -> void:
	if not sandbox_env:
		return

	var floor_mesh = sandbox_env.get_node_or_null("Floor/MeshInstance3D") as MeshInstance3D
	if floor_mesh:
		var big_box = BoxMesh.new()
		big_box.size = Vector3(60.0, 0.5, 60.0)
		floor_mesh.mesh = big_box
		var floor_mat = StandardMaterial3D.new()
		floor_mat.albedo_color = Color(0.22, 0.34, 0.18)
		floor_mat.roughness = 0.85
		floor_mesh.material_override = floor_mat

	var mat_stone = StandardMaterial3D.new()
	mat_stone.albedo_color = Color(0.38, 0.36, 0.34)
	mat_stone.roughness = 0.75

	var mat_crystal = StandardMaterial3D.new()
	mat_crystal.albedo_color = Color(0.25, 0.75, 0.95)
	mat_crystal.roughness = 0.15
	mat_crystal.emission_enabled = true
	mat_crystal.emission = Color(0.15, 0.55, 0.85)
	mat_crystal.emission_energy_multiplier = 0.6

	# Anéis concêntricos de marcação no solo e rochas/cristais de referência para caminhada e voo
	var prop_coords = [
		{"pos": Vector3(4.5, 0.6, 4.0),   "scale": Vector3(1.2, 1.2, 1.2), "crystal": false},
		{"pos": Vector3(-5.0, 0.9, 3.5),  "scale": Vector3(1.5, 1.8, 1.3), "crystal": false},
		{"pos": Vector3(6.0, 1.4, -5.5),  "scale": Vector3(0.9, 2.8, 0.9), "crystal": true},
		{"pos": Vector3(-6.5, 1.2, -4.5), "scale": Vector3(0.8, 2.4, 0.8), "crystal": true},
		{"pos": Vector3(0.0, 0.4, 8.0),   "scale": Vector3(2.2, 0.8, 1.4), "crystal": false},
		{"pos": Vector3(9.5, 2.2, 0.0),   "scale": Vector3(1.4, 4.4, 1.4), "crystal": false},
		{"pos": Vector3(-9.5, 2.0, -1.0), "scale": Vector3(1.3, 4.0, 1.3), "crystal": false}
	]

	for info in prop_coords:
		var p = MeshInstance3D.new()
		var cyl = CylinderMesh.new()
		cyl.top_radius = 0.35 if bool(info["crystal"]) else 0.65
		cyl.bottom_radius = 0.85
		cyl.height = 1.0
		cyl.radial_segments = 7
		p.mesh = cyl
		p.position = info["pos"]
		p.scale = info["scale"]
		p.material_override = mat_crystal if bool(info["crystal"]) else mat_stone
		sandbox_env.add_child(p)
