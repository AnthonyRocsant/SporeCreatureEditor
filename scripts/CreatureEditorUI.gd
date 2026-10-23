class_name CreatureEditorUI
extends Control

## UI Completa do Criador de Criaturas integrando os 4 Pilares:
## 1. Escultura da Coluna Catmull-Rom (3-16 vértebras, raio 0.15-2.50m)
## 2. Matemática de Biomassa, HP/STR/AGL/SPD, CoM e Trava de Validação Terrestre
## 3. Aba de Habilidades e Hotbar (Q, E, R, F, V) com Drag & Drop
## 4. Seleção/Edição de Peças (Rotação, Escala, Exclusão) e Save/Load em JSON

@export var creature_data: CreatureData
@export var editor_state: EditorState
@export var body_mesh: MeshInstance3D
@export var spine_controller: SpineManager
@export var attachment_system: AttachmentSystem
@export var skill_factory: SkillFactory
@export var creature_serializer: CreatureSerializer
@export var procedural_gait: ProceduralGait

# Referências da UI - HUD Top
@onready var biomass_bar: ProgressBar = %BiomassBar
@onready var biomass_label: Label = %BiomassLabel
@onready var btn_test_drive: Button = %BtnTestDrive
@onready var mode_tabs: HBoxContainer = %ModeTabs
@onready var btn_sculpt: Button = %BtnSculpt
@onready var btn_appendages: Button = %BtnAppendages
@onready var btn_paint: Button = %BtnPaint
@onready var btn_skills: Button = %BtnSkills
@onready var btn_save_json: Button = %BtnSaveJson
@onready var btn_load_json: Button = %BtnLoadJson

# Alerta de Locomoção Terrestre (Pilar 2.2)
@onready var locomotion_warning_banner: PanelContainer = %LocomotionWarningBanner
@onready var lbl_locomotion_warning: Label = %LblLocomotionWarning

# Referências da UI - Painel de Escultura da Coluna
@onready var sculpt_panel: PanelContainer = %SculptPanel
@onready var lbl_vertebra_info: Label = %LblVertebraInfo
@onready var lbl_vertebra_radius_val: Label = %LblVertebraRadiusVal
@onready var slider_vertebra_radius: HSlider = %SliderVertebraRadius
@onready var lbl_vertebra_size_val: Label = %LblVertebraSizeVal
@onready var slider_vertebra_size: HSlider = %SliderVertebraSize
@onready var btn_reset_spine: Button = %BtnResetSpine

# Referências da UI - Painel de Apêndices (Membros)
@onready var appendages_panel: PanelContainer = %AppendagesPanel
@onready var btn_toggle_symmetry: Button = %BtnToggleSymmetry
@onready var lbl_part_rotation_val: Label = %LblPartRotationVal
@onready var slider_part_rotation: HSlider = %SliderPartRotation
@onready var lbl_part_scale_val: Label = %LblPartScaleVal
@onready var slider_part_scale: HSlider = %SliderPartScale
@onready var btn_cat_all: Button = %BtnCatAll
@onready var btn_cat_mouth: Button = %BtnCatMouth
@onready var btn_cat_leg: Button = %BtnCatLeg
@onready var btn_cat_eye: Button = %BtnCatEye
@onready var btn_cat_tail: Button = %BtnCatTail
@onready var btn_cat_wing: Button = %BtnCatWing
@onready var btn_cat_defense: Button = %BtnCatDefense
@onready var appendage_item_list: VBoxContainer = %AppendageItemList
@onready var lbl_part_info: Label = %LblPartInfo
@onready var btn_delete_selected_part: Button = %BtnDeleteSelectedPart
@onready var btn_clear_parts: Button = %BtnClearParts

var current_appendage_category: String = "all"
var _active_appendage_id: String = ""
var _category_buttons: Dictionary = {}

# Referências da UI - Painel de Pintura & Texturas
@onready var paint_panel: PanelContainer = %PaintPanel
@onready var option_skin_pattern: OptionButton = %OptionSkinPattern
@onready var primary_color_picker: ColorPickerButton = %PrimaryColorPicker
@onready var secondary_color_picker: ColorPickerButton = %SecondaryColorPicker
@onready var detail_color_picker: ColorPickerButton = %DetailColorPicker
@onready var slider_pattern_blend: HSlider = %SliderPatternBlend
@onready var lbl_pattern_blend_val: Label = %LblPatternBlendVal
@onready var slider_texture_scale: HSlider = %SliderTextureScale
@onready var lbl_texture_scale_val: Label = %LblTextureScaleVal
@onready var slider_normal_scale: HSlider = %SliderNormalScale
@onready var lbl_normal_scale_val: Label = %LblNormalScaleVal
@onready var slider_roughness: HSlider = %SliderRoughness
@onready var lbl_roughness_val: Label = %LblRoughnessVal
@onready var slider_sss: HSlider = %SliderSSS
@onready var lbl_sss_val: Label = %LblSSSVal

# Referências da UI - Painel de Habilidades e Hotbar (Q, E, R, F, V)
@onready var skills_panel: PanelContainer = %SkillsPanel
@onready var lbl_unlocked_skills_list: Label = %LblUnlockedSkillsList
@onready var hotbar_panel: PanelContainer = %HotbarPanel
@onready var slot_q: SkillSlotButton = %SlotQ
@onready var slot_e: SkillSlotButton = %SlotE
@onready var slot_r: SkillSlotButton = %SlotR
@onready var slot_f: SkillSlotButton = %SlotF
@onready var slot_v: SkillSlotButton = %SlotV

# Referências da UI - Painel de Atributos
@onready var stats_panel: PanelContainer = %StatsPanel
@onready var lbl_health_val: Label = %LblHealthVal
@onready var lbl_strength_val: Label = %LblStrengthVal
@onready var lbl_agility_val: Label = %LblAgilityVal
@onready var lbl_speed_val: Label = %LblSpeedVal
@onready var bar_health: ProgressBar = %BarHealth
@onready var bar_strength: ProgressBar = %BarStrength
@onready var bar_agility: ProgressBar = %BarAgility
@onready var bar_speed: ProgressBar = %BarSpeed
@onready var lbl_stability_info: Label = %LblStabilityInfo

# Referências da UI - Modal de Salvamento / Carregamento (15 Slots)
@onready var slot_menu_modal: Control = %SlotMenuModal
@onready var lbl_slot_modal_title: Label = %LblSlotModalTitle
@onready var btn_close_slot_menu: Button = %BtnCloseSlotMenu
@onready var txt_creature_name: LineEdit = %TxtCreatureName
@onready var slot_list_container: VBoxContainer = %SlotListContainer
@onready var lbl_slot_modal_status: Label = %LblSlotModalStatus

func _ready() -> void:
	_disable_button_keyboard_focus(self)
	_setup_signals()
	_init_ui_values()
	_update_sculpt_ui()
	_update_mode_panels(editor_state.current_mode if editor_state else EditorState.Mode.MODO_ESCULTURA)

## Impede que os botões da UI capturem a tecla ESPAÇO (ui_accept),
## evitando que apertar Espaço para voar no Modo Test Drive acione o botão "Voltar ao Editor".
func _disable_button_keyboard_focus(node: Node) -> void:
	if node is BaseButton and not (node is ColorPickerButton):
		(node as BaseButton).focus_mode = Control.FOCUS_NONE
	for child in node.get_children():
		_disable_button_keyboard_focus(child)

func _input(event: InputEvent) -> void:
	if slot_menu_modal and slot_menu_modal.visible:
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			close_slot_menu()
			get_viewport().set_input_as_handled()
			return

	if editor_state and editor_state.is_sandbox():
		if event is InputEventKey and event.keycode == KEY_SPACE:
			var focused = get_viewport().gui_get_focus_owner()
			if focused:
				focused.release_focus()

func _setup_signals() -> void:
	# 1. Abas de Modos e Save/Load
	if btn_sculpt and not btn_sculpt.pressed.is_connected(_on_btn_sculpt_pressed):
		btn_sculpt.pressed.connect(_on_btn_sculpt_pressed)
	if btn_appendages and not btn_appendages.pressed.is_connected(_on_btn_appendages_pressed):
		btn_appendages.pressed.connect(_on_btn_appendages_pressed)
	if btn_paint and not btn_paint.pressed.is_connected(_on_btn_paint_pressed):
		btn_paint.pressed.connect(_on_btn_paint_pressed)
	if btn_skills and not btn_skills.pressed.is_connected(_on_btn_skills_pressed):
		btn_skills.pressed.connect(_on_btn_skills_pressed)
	if btn_save_json and not btn_save_json.pressed.is_connected(_on_btn_save_json_pressed):
		btn_save_json.pressed.connect(_on_btn_save_json_pressed)
	if btn_load_json and not btn_load_json.pressed.is_connected(_on_btn_load_json_pressed):
		btn_load_json.pressed.connect(_on_btn_load_json_pressed)
	if btn_close_slot_menu and not btn_close_slot_menu.pressed.is_connected(close_slot_menu):
		btn_close_slot_menu.pressed.connect(close_slot_menu)

	# 2. Conexão com CreatureData (Pilar 2)
	if creature_data:
		if not creature_data.biomass_changed.is_connected(_on_biomass_changed):
			creature_data.biomass_changed.connect(_on_biomass_changed)
		if not creature_data.stats_updated.is_connected(_on_stats_updated):
			creature_data.stats_updated.connect(_on_stats_updated)
		if not creature_data.extended_stats_updated.is_connected(_on_extended_stats_updated):
			creature_data.extended_stats_updated.connect(_on_extended_stats_updated)
		if not creature_data.locomotion_validation_changed.is_connected(_on_locomotion_validation_changed):
			creature_data.locomotion_validation_changed.connect(_on_locomotion_validation_changed)
		_on_biomass_changed(creature_data.current_biomass, creature_data.max_biomass)
		_on_extended_stats_updated(
			creature_data.health,
			creature_data.strength,
			creature_data.agility,
			creature_data.speed,
			creature_data.knockback_multiplier
		)
		_on_locomotion_validation_changed(creature_data.locomotion_valid, creature_data.locomotion_error_message)

	# 3. Conexão com EditorState
	if editor_state:
		if not editor_state.mode_changed.is_connected(_on_editor_mode_changed):
			editor_state.mode_changed.connect(_on_editor_mode_changed)
		_update_mode_panels(editor_state.current_mode)

	# 4. Painel de Escultura (Pilar 1)
	if btn_reset_spine and not btn_reset_spine.pressed.is_connected(_on_reset_spine_pressed):
		btn_reset_spine.pressed.connect(_on_reset_spine_pressed)
	if slider_vertebra_radius and not slider_vertebra_radius.value_changed.is_connected(_on_vertebra_slider_radius_changed):
		slider_vertebra_radius.value_changed.connect(_on_vertebra_slider_radius_changed)
	if slider_vertebra_size and not slider_vertebra_size.value_changed.is_connected(_on_vertebra_slider_size_changed):
		slider_vertebra_size.value_changed.connect(_on_vertebra_slider_size_changed)

	if spine_controller:
		if not spine_controller.spine_modified.is_connected(_update_sculpt_ui):
			spine_controller.spine_modified.connect(_update_sculpt_ui)
		if not spine_controller.vertebra_selected.is_connected(_on_vertebra_selected):
			spine_controller.vertebra_selected.connect(_on_vertebra_selected)
		if not spine_controller.vertebra_hovered.is_connected(_on_vertebra_hovered):
			spine_controller.vertebra_hovered.connect(_on_vertebra_hovered)

	# 5. Painel de Apêndices e Edição de Membros (Pilar 2, 3, 4)
	if btn_toggle_symmetry and not btn_toggle_symmetry.pressed.is_connected(_on_toggle_symmetry_pressed):
		btn_toggle_symmetry.pressed.connect(_on_toggle_symmetry_pressed)
	if slider_part_rotation and not slider_part_rotation.value_changed.is_connected(_on_part_rotation_slider_changed):
		slider_part_rotation.value_changed.connect(_on_part_rotation_slider_changed)
	if slider_part_scale and not slider_part_scale.value_changed.is_connected(_on_part_scale_slider_changed):
		slider_part_scale.value_changed.connect(_on_part_scale_slider_changed)

	if attachment_system:
		if not attachment_system.rotation_changed.is_connected(_on_attachment_rotation_changed):
			attachment_system.rotation_changed.connect(_on_attachment_rotation_changed)
		if not attachment_system.scale_changed.is_connected(_on_attachment_scale_changed):
			attachment_system.scale_changed.connect(_on_attachment_scale_changed)
		if not attachment_system.part_selected.is_connected(_on_attachment_part_selected):
			attachment_system.part_selected.connect(_on_attachment_part_selected)
		if not attachment_system.part_deselected.is_connected(_on_attachment_part_deselected):
			attachment_system.part_deselected.connect(_on_attachment_part_deselected)
		if not attachment_system.part_attached.is_connected(_on_attachment_part_attached):
			attachment_system.part_attached.connect(_on_attachment_part_attached)

	_category_buttons = {
		"all": btn_cat_all,
		"mouth": btn_cat_mouth,
		"leg": btn_cat_leg,
		"eye": btn_cat_eye,
		"tail": btn_cat_tail,
		"wing": btn_cat_wing,
		"defense": btn_cat_defense
	}

	if btn_cat_all and not btn_cat_all.pressed.is_connected(_on_cat_all_pressed):
		btn_cat_all.pressed.connect(_on_cat_all_pressed)
	if btn_cat_mouth and not btn_cat_mouth.pressed.is_connected(_on_cat_mouth_pressed):
		btn_cat_mouth.pressed.connect(_on_cat_mouth_pressed)
	if btn_cat_leg and not btn_cat_leg.pressed.is_connected(_on_cat_leg_pressed):
		btn_cat_leg.pressed.connect(_on_cat_leg_pressed)
	if btn_cat_eye and not btn_cat_eye.pressed.is_connected(_on_cat_eye_pressed):
		btn_cat_eye.pressed.connect(_on_cat_eye_pressed)
	if btn_cat_tail and not btn_cat_tail.pressed.is_connected(_on_cat_tail_pressed):
		btn_cat_tail.pressed.connect(_on_cat_tail_pressed)
	if btn_cat_wing and not btn_cat_wing.pressed.is_connected(_on_cat_wing_pressed):
		btn_cat_wing.pressed.connect(_on_cat_wing_pressed)
	if btn_cat_defense and not btn_cat_defense.pressed.is_connected(_on_cat_defense_pressed):
		btn_cat_defense.pressed.connect(_on_cat_defense_pressed)

	if btn_delete_selected_part and not btn_delete_selected_part.pressed.is_connected(_on_delete_selected_part_pressed):
		btn_delete_selected_part.pressed.connect(_on_delete_selected_part_pressed)
	if btn_clear_parts and not btn_clear_parts.pressed.is_connected(_on_clear_parts_pressed):
		btn_clear_parts.pressed.connect(_on_clear_parts_pressed)

	_set_appendage_category("all")

	# 6. Painel de Pintura & Texturas
	if option_skin_pattern and not option_skin_pattern.item_selected.is_connected(_on_skin_pattern_selected):
		option_skin_pattern.item_selected.connect(_on_skin_pattern_selected)
	if primary_color_picker and not primary_color_picker.color_changed.is_connected(_on_primary_color_changed):
		primary_color_picker.color_changed.connect(_on_primary_color_changed)
	if secondary_color_picker and not secondary_color_picker.color_changed.is_connected(_on_secondary_color_changed):
		secondary_color_picker.color_changed.connect(_on_secondary_color_changed)
	if detail_color_picker and not detail_color_picker.color_changed.is_connected(_on_detail_color_changed):
		detail_color_picker.color_changed.connect(_on_detail_color_changed)
	_sync_appendages_colors()
	if slider_pattern_blend and not slider_pattern_blend.value_changed.is_connected(_on_pattern_blend_changed):
		slider_pattern_blend.value_changed.connect(_on_pattern_blend_changed)
	if slider_texture_scale and not slider_texture_scale.value_changed.is_connected(_on_texture_scale_changed):
		slider_texture_scale.value_changed.connect(_on_texture_scale_changed)
	if slider_normal_scale and not slider_normal_scale.value_changed.is_connected(_on_normal_scale_changed):
		slider_normal_scale.value_changed.connect(_on_normal_scale_changed)
	if slider_roughness and not slider_roughness.value_changed.is_connected(_on_roughness_changed):
		slider_roughness.value_changed.connect(_on_roughness_changed)
	if slider_sss and not slider_sss.value_changed.is_connected(_on_sss_changed):
		slider_sss.value_changed.connect(_on_sss_changed)

	# 7. Painel de Habilidades & Hotbar Q, E, R, F, V (Pilar 3)
	if skill_factory:
		if not skill_factory.skills_updated.is_connected(_on_skills_updated):
			skill_factory.skills_updated.connect(_on_skills_updated)
		if not skill_factory.skill_triggered.is_connected(_on_skill_triggered):
			skill_factory.skill_triggered.connect(_on_skill_triggered)
		_on_skills_updated(skill_factory.unlocked_skills, skill_factory.hotbar_slots)

	for slot_btn in _get_hotbar_buttons():
		if slot_btn:
			if not slot_btn.slot_dropped.is_connected(_on_hotbar_slot_dropped):
				slot_btn.slot_dropped.connect(_on_hotbar_slot_dropped)
			if not slot_btn.pressed.is_connected(_on_hotbar_slot_pressed.bind(slot_btn.slot_key)):
				slot_btn.pressed.connect(_on_hotbar_slot_pressed.bind(slot_btn.slot_key))

	# 8. Test Drive (Sandbox)
	if btn_test_drive and not btn_test_drive.pressed.is_connected(_on_test_drive_pressed):
		btn_test_drive.pressed.connect(_on_test_drive_pressed)

func _get_hotbar_buttons() -> Array[SkillSlotButton]:
	return [slot_q, slot_e, slot_r, slot_f, slot_v]

func _init_ui_values() -> void:
	if option_skin_pattern:
		option_skin_pattern.clear()
		option_skin_pattern.add_item("🦖 Clássico Spore", 0)
		option_skin_pattern.add_item("🦎 Escamas de Dragão", 1)
		option_skin_pattern.add_item("🦏 Couro Enrugado", 2)
		option_skin_pattern.add_item("🐅 Listras de Predador", 3)
		option_skin_pattern.add_item("🐆 Manchas de Leopardo", 4)
		option_skin_pattern.add_item("🪲 Carapaça de Quitina", 5)
		option_skin_pattern.add_item("🐸 Anfíbio Bioluminescente", 6)
		option_skin_pattern.selected = 0
	if primary_color_picker:
		primary_color_picker.color = Color(0.85, 0.45, 0.35, 1.0)
	if secondary_color_picker:
		secondary_color_picker.color = Color(0.3, 0.15, 0.1, 1.0)
	if slider_pattern_blend:
		slider_pattern_blend.value = 0.5
		if lbl_pattern_blend_val:
			lbl_pattern_blend_val.text = "50%"
	if slider_texture_scale:
		slider_texture_scale.value = 2.0
		if lbl_texture_scale_val:
			lbl_texture_scale_val.text = "2.0x"
	if slider_normal_scale:
		slider_normal_scale.value = 1.0
		if lbl_normal_scale_val:
			lbl_normal_scale_val.text = "1.0x"
	if slider_roughness:
		slider_roughness.value = 0.5
		if lbl_roughness_val:
			lbl_roughness_val.text = "0.50"
	if slider_sss:
		slider_sss.value = 0.3
		if lbl_sss_val:
			lbl_sss_val.text = "0.30"
	_update_symmetry_button_text()

# --- Gerenciamento de Abas e Modos ---

func _on_btn_sculpt_pressed() -> void:
	_select_mode(EditorState.Mode.MODO_ESCULTURA)

func _on_btn_appendages_pressed() -> void:
	_select_mode(EditorState.Mode.MODO_APENDICES)

func _on_btn_paint_pressed() -> void:
	_select_mode(EditorState.Mode.MODO_PINTURA)

func _on_btn_skills_pressed() -> void:
	_select_mode(EditorState.Mode.MODO_HABILIDADES)

func _select_mode(mode: EditorState.Mode) -> void:
	if editor_state:
		editor_state.change_mode(mode)
	_update_mode_panels(mode)

func _on_editor_mode_changed(new_mode: EditorState.Mode, _old_mode: EditorState.Mode) -> void:
	_update_mode_panels(new_mode)

func _update_mode_panels(new_mode: EditorState.Mode) -> void:
	var is_sandbox = (new_mode == EditorState.Mode.MODO_SANDBOX)

	if sculpt_panel:
		sculpt_panel.visible = (new_mode == EditorState.Mode.MODO_ESCULTURA)
	if appendages_panel:
		appendages_panel.visible = (new_mode == EditorState.Mode.MODO_APENDICES)
	if paint_panel:
		paint_panel.visible = (new_mode == EditorState.Mode.MODO_PINTURA)
	if skills_panel:
		skills_panel.visible = (new_mode == EditorState.Mode.MODO_HABILIDADES)
	if stats_panel:
		stats_panel.visible = not is_sandbox
	if hotbar_panel:
		hotbar_panel.visible = true

	if btn_test_drive:
		btn_test_drive.text = "Voltar ao Editor" if is_sandbox else "▶ Test Drive (Sandbox)"

	if mode_tabs:
		mode_tabs.visible = not is_sandbox

	if is_sandbox and locomotion_warning_banner and lbl_locomotion_warning:
		locomotion_warning_banner.visible = true
		var has_wings = false
		if creature_data:
			for p in creature_data.attached_parts:
				var p_type = str(p.get("type", "")).to_lower()
				var p_cat = str(p.get("category", p_type)).to_lower()
				if p_type == "wing" or p_cat == "wing":
					has_wings = true
					break

		if creature_data and not creature_data.locomotion_valid:
			if has_wings:
				lbl_locomotion_warning.text = "⚠️ Sem patas no chão! Voe segurando [ESPAÇO + W,A,S,D] ou volte ao Editor para adicionar patas."
			else:
				lbl_locomotion_warning.text = "⚠️ Locomoção Inválida: Adicione 2 patas no chão para andar ou Asas para voar!"
		else:
			if has_wings:
				lbl_locomotion_warning.text = "🎮 Test Drive: [W,A,S,D] Andar | [Segurar ESPAÇO + W,A,S,D] Voar | [Botão Direito] Câmera | [Q,E,R,F,V] Skills"
			else:
				lbl_locomotion_warning.text = "🎮 Test Drive: [W,A,S,D] Andar | (Adicione Asas para Voar com ESPAÇO) | [Botão Direito] Câmera | [Q,E,R,F,V] Skills"
	elif creature_data:
		_on_locomotion_validation_changed(creature_data.locomotion_valid, creature_data.locomotion_error_message)

	_update_tab_buttons_appearance(new_mode)

func _update_tab_buttons_appearance(active_mode: EditorState.Mode) -> void:
	if btn_sculpt:
		btn_sculpt.modulate = Color(1.2, 1.2, 0.8) if active_mode == EditorState.Mode.MODO_ESCULTURA else Color(1, 1, 1)
	if btn_appendages:
		btn_appendages.modulate = Color(1.2, 1.2, 0.8) if active_mode == EditorState.Mode.MODO_APENDICES else Color(1, 1, 1)
	if btn_paint:
		btn_paint.modulate = Color(1.2, 1.2, 0.8) if active_mode == EditorState.Mode.MODO_PINTURA else Color(1, 1, 1)
	if btn_skills:
		btn_skills.modulate = Color(1.2, 1.2, 0.8) if active_mode == EditorState.Mode.MODO_HABILIDADES else Color(1, 1, 1)

# --- Callbacks de Salvar / Carregar com 15 Slots (Pilar 4.2) ---

func _on_btn_save_json_pressed() -> void:
	open_slot_menu("save")

func _on_btn_load_json_pressed() -> void:
	open_slot_menu("load")

func open_slot_menu(mode: String = "manage") -> void:
	if not slot_menu_modal:
		return
	if lbl_slot_modal_title:
		if mode == "save":
			lbl_slot_modal_title.text = "💾 Salvar Criatura (Escolha um Slot de 1 a 15)"
		elif mode == "load":
			lbl_slot_modal_title.text = "📂 Carregar Criatura (Escolha um Slot de 1 a 15)"
		else:
			lbl_slot_modal_title.text = "💾 Salvar / Carregar Criatura (15 Slots)"
	if lbl_slot_modal_status:
		lbl_slot_modal_status.text = "Escolha um dos 15 slots para salvar ou carregar sua criatura."
		lbl_slot_modal_status.modulate = Color(0.85, 0.85, 0.85, 1.0)
	slot_menu_modal.visible = true
	_refresh_slot_list()
	_disable_button_keyboard_focus(slot_menu_modal)
	if txt_creature_name and mode == "save":
		txt_creature_name.grab_focus()

func close_slot_menu() -> void:
	if slot_menu_modal:
		slot_menu_modal.visible = false

func _refresh_slot_list() -> void:
	if not slot_list_container or not creature_serializer:
		return

	for child in slot_list_container.get_children():
		child.queue_free()

	var all_slots = creature_serializer.get_all_slots_info()
	for slot_info in all_slots:
		var slot_idx: int = int(slot_info.get("slot", 1))
		var exists: bool = bool(slot_info.get("exists", false))
		var c_name: String = str(slot_info.get("name", "Slot %02d" % slot_idx))
		var t_stamp: String = str(slot_info.get("timestamp", ""))

		var card = PanelContainer.new()
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 14)
		margin.add_theme_constant_override("margin_right", 14)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_bottom", 8)
		card.add_child(margin)

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 14)
		margin.add_child(hbox)

		# 1. Badge do Slot
		var badge = Label.new()
		badge.text = "[SLOT %02d]" % slot_idx
		badge.custom_minimum_size = Vector2(80, 0)
		badge.add_theme_color_override("font_color", Color(0.3, 0.8, 1.0) if exists else Color(0.55, 0.55, 0.55))
		badge.add_theme_font_size_override("font_size", 14)
		hbox.add_child(badge)

		# 2. VBox de Informações
		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(info_vbox)

		var lbl_name = Label.new()
		if exists:
			lbl_name.text = "🐾 " + c_name
			lbl_name.add_theme_font_size_override("font_size", 14)
			lbl_name.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
		else:
			lbl_name.text = "— Slot Vazio —"
			lbl_name.add_theme_font_size_override("font_size", 14)
			lbl_name.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
		info_vbox.add_child(lbl_name)

		var lbl_details = Label.new()
		lbl_details.add_theme_font_size_override("font_size", 11)
		if exists:
			var hp = float(slot_info.get("health", 0.0))
			var str_val = float(slot_info.get("strength", 0.0))
			var spd = float(slot_info.get("speed", 0.0))
			var agl = float(slot_info.get("agility", 0.0))
			var parts_cnt = int(slot_info.get("parts_count", 0))
			var vert_cnt = int(slot_info.get("vertebrae_count", 0))
			var bio = int(slot_info.get("biomass_used", 0))
			var time_str = t_stamp if not t_stamp.is_empty() else "Salvo recentemente"
			lbl_details.text = "HP: %.0f | STR: %.0f | SPD: %.1f | AGL: %.1f | Partes: %d | Vértebras: %d | Bio: %d/100 | %s" % [
				hp, str_val, spd, agl, parts_cnt, vert_cnt, bio, time_str
			]
			lbl_details.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		else:
			lbl_details.text = "Nenhuma criatura salva. Clique em 'Salvar' para gravar a criatura atual neste slot."
			lbl_details.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
		info_vbox.add_child(lbl_details)

		# 3. Ações
		var actions_hbox = HBoxContainer.new()
		actions_hbox.add_theme_constant_override("separation", 6)
		hbox.add_child(actions_hbox)

		var btn_save = Button.new()
		btn_save.text = "💾 Salvar"
		btn_save.focus_mode = Control.FOCUS_NONE
		btn_save.tooltip_text = "Salvar a criatura atual no Slot %02d" % slot_idx
		btn_save.pressed.connect(_on_slot_save_pressed.bind(slot_idx))
		actions_hbox.add_child(btn_save)

		var btn_load = Button.new()
		btn_load.text = "📂 Carregar"
		btn_load.disabled = not exists
		btn_load.focus_mode = Control.FOCUS_NONE
		btn_load.tooltip_text = "Carregar a criatura do Slot %02d" % slot_idx
		btn_load.pressed.connect(_on_slot_load_pressed.bind(slot_idx))
		actions_hbox.add_child(btn_load)

		var btn_del = Button.new()
		btn_del.text = "🗑️"
		btn_del.disabled = not exists
		btn_del.focus_mode = Control.FOCUS_NONE
		btn_del.tooltip_text = "Excluir dados do Slot %02d" % slot_idx
		btn_del.pressed.connect(_on_slot_delete_pressed.bind(slot_idx))
		actions_hbox.add_child(btn_del)

		slot_list_container.add_child(card)

func _on_slot_save_pressed(slot_idx: int) -> void:
	if not creature_serializer:
		return
	var c_name = txt_creature_name.text.strip_edges() if txt_creature_name else ""
	if c_name.is_empty():
		c_name = "Criatura Slot %02d" % slot_idx
	var ok = creature_serializer.save_creature_to_slot(slot_idx, c_name)
	if ok:
		if lbl_slot_modal_status:
			lbl_slot_modal_status.text = "✅ Criatura '%s' salva com sucesso no Slot %02d!" % [c_name, slot_idx]
			lbl_slot_modal_status.modulate = Color(0.4, 1.0, 0.4)
		_show_status_banner("💾 Salvo com sucesso no Slot %02d (%s)!" % [slot_idx, c_name], true)
		_refresh_slot_list()
	else:
		if lbl_slot_modal_status:
			lbl_slot_modal_status.text = "❌ Erro ao salvar criatura no Slot %02d." % slot_idx
			lbl_slot_modal_status.modulate = Color(1.0, 0.3, 0.3)

func _on_slot_load_pressed(slot_idx: int) -> void:
	if not creature_serializer:
		return
	var ok = creature_serializer.load_creature_from_slot(slot_idx)
	if ok:
		_sync_ui_after_load()
		var slot_info = creature_serializer.get_slot_info(slot_idx)
		var c_name = str(slot_info.get("name", "Slot %02d" % slot_idx))
		if txt_creature_name:
			txt_creature_name.text = c_name
		if lbl_slot_modal_status:
			lbl_slot_modal_status.text = "✅ Criatura '%s' carregada com sucesso do Slot %02d!" % [c_name, slot_idx]
			lbl_slot_modal_status.modulate = Color(0.4, 1.0, 0.4)
		_show_status_banner("📂 Criatura '%s' carregada do Slot %02d!" % [c_name, slot_idx], true)
		close_slot_menu()
	else:
		if lbl_slot_modal_status:
			lbl_slot_modal_status.text = "❌ Erro ao carregar criatura do Slot %02d." % slot_idx
			lbl_slot_modal_status.modulate = Color(1.0, 0.3, 0.3)

func _on_slot_delete_pressed(slot_idx: int) -> void:
	if not creature_serializer:
		return
	var ok = creature_serializer.delete_slot(slot_idx)
	if ok:
		if lbl_slot_modal_status:
			lbl_slot_modal_status.text = "🗑️ Salvamento do Slot %02d excluído com sucesso." % slot_idx
			lbl_slot_modal_status.modulate = Color(1.0, 0.6, 0.3)
		_show_status_banner("🗑️ Slot %02d excluído." % slot_idx, true)
		_refresh_slot_list()
	else:
		if lbl_slot_modal_status:
			lbl_slot_modal_status.text = "❌ Falha ao excluir o Slot %02d." % slot_idx
			lbl_slot_modal_status.modulate = Color(1.0, 0.3, 0.3)

func _show_status_banner(message: String, is_success: bool) -> void:
	if locomotion_warning_banner and lbl_locomotion_warning:
		locomotion_warning_banner.visible = true
		lbl_locomotion_warning.text = message
		lbl_locomotion_warning.modulate = Color(0.4, 1.0, 0.4) if is_success else Color(1.0, 0.8, 0.3)
		var banner_timer = get_tree().create_timer(3.5)
		banner_timer.timeout.connect(func():
			if editor_state and not editor_state.is_sandbox():
				if creature_data and creature_data.locomotion_valid:
					locomotion_warning_banner.visible = false
				elif creature_data:
					lbl_locomotion_warning.text = creature_data.locomotion_error_message
					lbl_locomotion_warning.modulate = Color(1.0, 1.0, 1.0)
					locomotion_warning_banner.visible = true
		)

func _sync_ui_after_load() -> void:
	_update_sculpt_ui()
	if body_mesh and body_mesh.has_method("get_creature_material"):
		var mat: ShaderMaterial = body_mesh.call("get_creature_material")
		if mat:
			var bc = mat.get_shader_parameter("base_color")
			if typeof(bc) == TYPE_COLOR and primary_color_picker:
				primary_color_picker.color = bc
			var sc = mat.get_shader_parameter("secondary_color")
			if typeof(sc) == TYPE_COLOR and secondary_color_picker:
				secondary_color_picker.color = sc
			var ts = mat.get_shader_parameter("texture_scale")
			if ts != null and slider_texture_scale:
				slider_texture_scale.set_value_no_signal(float(ts))
				if lbl_texture_scale_val:
					lbl_texture_scale_val.text = "%.1fx" % float(ts)
			var sss = mat.get_shader_parameter("sss_strength")
			if sss != null and slider_sss:
				slider_sss.set_value_no_signal(float(sss))
				if lbl_sss_val:
					lbl_sss_val.text = "%.2f" % float(sss)
			var spt = mat.get_shader_parameter("skin_pattern_type")
			if spt != null and option_skin_pattern:
				option_skin_pattern.select(clampi(int(spt), 0, option_skin_pattern.item_count - 1))
			var pb = mat.get_shader_parameter("pattern_blend")
			if pb != null and slider_pattern_blend:
				slider_pattern_blend.set_value_no_signal(float(pb))
				if lbl_pattern_blend_val:
					lbl_pattern_blend_val.text = "%d%%" % int(float(pb) * 100)
			var ns = mat.get_shader_parameter("normal_scale")
			if ns != null and slider_normal_scale:
				slider_normal_scale.set_value_no_signal(float(ns))
				if lbl_normal_scale_val:
					lbl_normal_scale_val.text = "%.1fx" % float(ns)
			var rough = mat.get_shader_parameter("roughness")
			if rough != null and slider_roughness:
				slider_roughness.set_value_no_signal(float(rough))
				if lbl_roughness_val:
					lbl_roughness_val.text = "%.2f" % float(rough)

	if creature_data:
		_on_biomass_changed(creature_data.current_biomass, creature_data.max_biomass)
		_on_extended_stats_updated(
			creature_data.health,
			creature_data.strength,
			creature_data.agility,
			creature_data.speed,
			creature_data.knockback_multiplier
		)
		_on_locomotion_validation_changed(creature_data.locomotion_valid, creature_data.locomotion_error_message)

	if skill_factory:
		skill_factory.rebuild_skills_from_anatomy()

# --- Callbacks de Apêndices & Seleção (Pilar 2, 3 e 4) ---

func _on_toggle_symmetry_pressed() -> void:
	if attachment_system:
		attachment_system.set_symmetry(not attachment_system.symmetrical_mode)
		_update_symmetry_button_text()

func _update_symmetry_button_text() -> void:
	if not btn_toggle_symmetry:
		return
	var is_sym = attachment_system.symmetrical_mode if attachment_system else true
	btn_toggle_symmetry.text = "Simetria Bilateral: %s" % ("LIGADA" if is_sym else "DESLIGADA")

func _on_part_rotation_slider_changed(deg_val: float) -> void:
	if lbl_part_rotation_val:
		lbl_part_rotation_val.text = "%.0f°" % deg_val
	if attachment_system:
		attachment_system.set_part_rotation_deg(deg_val)

func _on_attachment_rotation_changed(deg_val: float) -> void:
	if lbl_part_rotation_val:
		lbl_part_rotation_val.text = "%.0f°" % deg_val
	if slider_part_rotation and not is_equal_approx(slider_part_rotation.value, deg_val):
		slider_part_rotation.set_value_no_signal(deg_val)

func _on_part_scale_slider_changed(scale_val: float) -> void:
	if lbl_part_scale_val:
		lbl_part_scale_val.text = "%.2fx" % scale_val
	if attachment_system:
		attachment_system.set_part_scale(scale_val)

func _on_attachment_scale_changed(scale_val: float) -> void:
	if lbl_part_scale_val:
		lbl_part_scale_val.text = "%.2fx" % scale_val
	if slider_part_scale and not is_equal_approx(slider_part_scale.value, scale_val):
		slider_part_scale.set_value_no_signal(scale_val)

func _on_attachment_part_selected(part_data: Dictionary) -> void:
	if lbl_part_info:
		var p_name = str(part_data.get("name", "Membro"))
		var p_cost = int(part_data.get("cost", 0))
		lbl_part_info.text = "Selecionado: %s (%d pts). Arraste no corpo para mover, use Scroll/Q,E para girar, Shift+Scroll/Z,X para escalar ou Delete para excluir." % [p_name, p_cost]
	if btn_delete_selected_part:
		btn_delete_selected_part.disabled = false

func _on_attachment_part_deselected() -> void:
	if attachment_system and not attachment_system.active_part_scene:
		_active_appendage_id = ""
		_update_appendage_item_buttons_modulate()
	if lbl_part_info and _active_appendage_id == "":
		lbl_part_info.text = "Clique em um apêndice na criatura para selecioná-lo e alterar posição, ângulo ou tamanho."
	if btn_delete_selected_part:
		btn_delete_selected_part.disabled = true

func _on_attachment_part_attached(_part_node: Node3D) -> void:
	# Mantém a seleção ativa para colocação contínua (estilo carimbo)
	if lbl_part_info:
		if _active_appendage_id != "":
			lbl_part_info.text = "Apêndice fixado! Continue clicando no corpo para adicionar mais, ou clique na lista / Esc para concluir."
		else:
			lbl_part_info.text = "Apêndice fixado! Clique nele para selecioná-lo e alterar posição, ângulo ou tamanho."

# --- Catálogo Oficial de 20 Apêndices Categorizados (Bocas, Patas, Olhos, Rabos, Asas, Defesa) ---
const APPENDAGE_CATALOG: Array[Dictionary] = [
	# 👄 BOCAS
	{
		"category_id": "mouth",
		"category_name": "Bocas",
		"category_icon": "👄",
		"id": "mouth_carnivore",
		"name": "Boca Carnívora",
		"icon": "🦷",
		"scene": "res://scenes/appendages/MouthJaw.tscn",
		"type": "mouth",
		"category": "attack",
		"tag": "#Mouth_Carnivore",
		"mass": 1.0,
		"base_damage": 16.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 2.0,
		"desc": "Mandíbula predadora feroz. Habilidade: Mordida Devoradora (Lifesteal). Custo: 6 + escala."
	},
	{
		"category_id": "mouth",
		"category_name": "Bocas",
		"category_icon": "👄",
		"id": "mouth_herbivore",
		"name": "Boca Herbívora",
		"icon": "📢",
		"scene": "res://scenes/appendages/MouthJaw.tscn",
		"type": "mouth",
		"category": "attack",
		"tag": "#Mouth_Herbivore",
		"mass": 1.1,
		"base_damage": 10.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 6.0,
		"desc": "Bico encouraçado e mandíbula robusta. Habilidade: Roco Atordoante (AoE Stun). Custo: 6 + escala."
	},
	{
		"category_id": "mouth",
		"category_name": "Bocas",
		"category_icon": "👄",
		"id": "mouth_insectoid",
		"name": "Mandíbula Insetóide",
		"icon": "🧪",
		"scene": "res://scenes/appendages/MouthInsectoid.tscn",
		"type": "mouth",
		"category": "attack",
		"tag": "#Mouth_Insectoid",
		"mass": 0.8,
		"base_damage": 14.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 3.0,
		"desc": "Pinças e quelíceras venenosas. Habilidade: Mandíbula Ácida (DoT Corrosivo). Custo: 6 + escala."
	},
	{
		"category_id": "mouth",
		"category_name": "Bocas",
		"category_icon": "👄",
		"id": "mouth_beak",
		"name": "Bico de Rapina",
		"icon": "🦅",
		"scene": "res://scenes/appendages/MouthBeak.tscn",
		"type": "mouth",
		"category": "attack",
		"tag": "#Mouth_Beak",
		"mass": 0.7,
		"base_damage": 15.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 4.0,
		"desc": "Bico afiado de alta perfuração. Habilidade: Bicada Perfurante. Custo: 6 + escala."
	},
	{
		"category_id": "mouth",
		"category_name": "Bocas",
		"category_icon": "👄",
		"id": "mouth_saber",
		"name": "Mandíbula Dente-de-Sabre",
		"icon": "🗡️",
		"scene": "res://scenes/appendages/MouthSaber.tscn",
		"type": "mouth",
		"category": "attack",
		"tag": "#Mouth_Saber",
		"mass": 1.3,
		"base_damage": 22.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 3.0,
		"desc": "Enormes presas afiadas recurvadas. Habilidade: Bote Predatório (Crítico + Sangramento). Custo: 8 + escala."
	},
	{
		"category_id": "mouth",
		"category_name": "Bocas",
		"category_icon": "👄",
		"id": "mouth_shark",
		"name": "Mandíbula de Tubarão",
		"icon": "🦈",
		"scene": "res://scenes/appendages/MouthShark.tscn",
		"type": "mouth",
		"category": "attack",
		"tag": "#Mouth_Shark",
		"mass": 1.2,
		"base_damage": 20.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 2.5,
		"desc": "Fileiras triplas de dentes triangulares. Habilidade: Frenesi do Megalodonte (Combo Acelerado). Custo: 8 + escala."
	},
	{
		"category_id": "mouth",
		"category_name": "Bocas",
		"category_icon": "👄",
		"id": "mouth_lamprey",
		"name": "Boca Sugadora Parasita",
		"icon": "🌀",
		"scene": "res://scenes/appendages/MouthLamprey.tscn",
		"type": "mouth",
		"category": "attack",
		"tag": "#Mouth_Lamprey",
		"mass": 0.9,
		"base_damage": 16.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 4.0,
		"desc": "Ventosa circular com 24 dentes em espiral. Habilidade: Dreno Parasitário (Sucção + Lentidão). Custo: 7 + escala."
	},
	{
		"category_id": "mouth",
		"category_name": "Bocas",
		"category_icon": "👄",
		"id": "mouth_dragon",
		"name": "Focinho de Dragão",
		"icon": "🔥",
		"scene": "res://scenes/appendages/MouthDragon.tscn",
		"type": "mouth",
		"category": "attack",
		"tag": "#Mouth_Dragon",
		"mass": 1.4,
		"base_damage": 24.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 5.0,
		"desc": "Focinho escamado ancestral com língua bífida. Habilidade: Sopro Dracônico (Cone Flamejante). Custo: 9 + escala."
	},

	# 🦵 PATAS & LOCOMOÇÃO
	{
		"category_id": "leg",
		"category_name": "Patas",
		"category_icon": "🦵",
		"id": "leg_claw",
		"name": "Pata / Garra Raptor",
		"icon": "🐾",
		"scene": "res://scenes/appendages/LegClaw.tscn",
		"type": "leg",
		"category": "leg",
		"tag": "#Claw_Front",
		"mass": 1.2,
		"base_damage": 8.0,
		"leg_force": 4.5,
		"wing_area": 0.0,
		"carapace_defense": 2.0,
		"desc": "Pata digitígrada ágil com garras. Habilidade: Garrada Tripla. Apoio no solo. Custo: 8 + escala."
	},
	{
		"category_id": "leg",
		"category_name": "Patas",
		"category_icon": "🦵",
		"id": "leg_heavy",
		"name": "Pata Pesada Titânica",
		"icon": "💥",
		"scene": "res://scenes/appendages/LegHeavy.tscn",
		"type": "leg",
		"category": "leg",
		"tag": "#Claw_Heavy",
		"mass": 1.8,
		"base_damage": 14.0,
		"leg_force": 6.5,
		"wing_area": 0.0,
		"carapace_defense": 5.0,
		"desc": "Pilar colunar maciço estilo paquiderme/sauropoda com escudos no joelho e 4 cascos esmagadores. Habilidade: Pisotão Sísmico. Custo: 8 + escala."
	},
	{
		"category_id": "leg",
		"category_name": "Patas",
		"category_icon": "🦵",
		"id": "leg_hoof",
		"name": "Casco Blindado",
		"icon": "🐎",
		"scene": "res://scenes/appendages/LegHoof.tscn",
		"type": "leg",
		"category": "leg",
		"tag": "#Leg_Hoof",
		"mass": 1.4,
		"base_damage": 10.0,
		"leg_force": 5.5,
		"wing_area": 0.0,
		"carapace_defense": 7.0,
		"desc": "Casco robusto para corrida firme no solo. Habilidade: Casco Atropelador. Custo: 8 + escala."
	},
	{
		"category_id": "leg",
		"category_name": "Patas",
		"category_icon": "🦵",
		"id": "leg_insect",
		"name": "Pata Insetóide Articulada",
		"icon": "🦗",
		"scene": "res://scenes/appendages/LegInsect.tscn",
		"type": "leg",
		"category": "leg",
		"tag": "#Leg_Insect",
		"mass": 0.7,
		"base_damage": 6.0,
		"leg_force": 4.0,
		"wing_area": 0.0,
		"carapace_defense": 3.0,
		"desc": "Perna fina quitinosa de alta rapidez. Habilidade: Salto Articulado. Custo: 8 + escala."
	},
	{
		"category_id": "leg",
		"category_name": "Patas",
		"category_icon": "🦵",
		"id": "claw_pincer",
		"name": "Pinça Crustácea Titânica",
		"icon": "🦞",
		"scene": "res://scenes/appendages/ClawPincer.tscn",
		"type": "leg",
		"category": "attack",
		"tag": "#Claw_Pincer",
		"mass": 1.9,
		"base_damage": 18.0,
		"leg_force": 3.5,
		"wing_area": 0.0,
		"carapace_defense": 8.0,
		"desc": "Pinça colossal de caranguejo com dentes de esmagamento. Habilidade: Pinça Esmagadora. Custo: 8 + escala."
	},

	# 👁️ OLHOS & SENTIDOS
	{
		"category_id": "eye",
		"category_name": "Olhos",
		"category_icon": "👁️",
		"id": "eye_simple",
		"name": "Olho Sensorial",
		"icon": "👁️",
		"scene": "res://scenes/appendages/EyeSimple.tscn",
		"type": "eye",
		"category": "eye",
		"tag": "#Eye_Sensory",
		"mass": 0.2,
		"base_damage": 0.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 1.0,
		"desc": "Olho orgânico com íris brilhante. Custo fixo: 2 pts de Biomassa."
	},
	{
		"category_id": "eye",
		"category_name": "Olhos",
		"category_icon": "👁️",
		"id": "eye_compound",
		"name": "Olho Composto",
		"icon": "🟢",
		"scene": "res://scenes/appendages/EyeCompound.tscn",
		"type": "eye",
		"category": "eye",
		"tag": "#Eye_Compound",
		"mass": 0.25,
		"base_damage": 0.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 2.0,
		"desc": "Olho com centenas de omatídeos. Habilidade: Visão Composta (Reflexos e Esquiva). Custo: 2 pts."
	},
	{
		"category_id": "eye",
		"category_name": "Olhos",
		"category_icon": "👁️",
		"id": "eye_stalk",
		"name": "Olho Pedunculado",
		"icon": "🐌",
		"scene": "res://scenes/appendages/EyeStalk.tscn",
		"type": "eye",
		"category": "eye",
		"tag": "#Eye_Stalk",
		"mass": 0.3,
		"base_damage": 0.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 1.0,
		"desc": "Olho sobre haste móvel telescópica. Campo de visão elevado. Custo: 2 pts."
	},
	{
		"category_id": "eye",
		"category_name": "Olhos",
		"category_icon": "👁️",
		"id": "antenna_sensory",
		"name": "Antena Sensorial",
		"icon": "📡",
		"scene": "res://scenes/appendages/AntennaSensory.tscn",
		"type": "eye",
		"category": "eye",
		"tag": "#Antenna_Sensory",
		"mass": 0.15,
		"base_damage": 0.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 1.0,
		"desc": "Antena biológica que detecta vibrações e ecolocalização. Custo: 2 pts."
	},
	{
		"category_id": "eye",
		"category_name": "Olhos",
		"category_icon": "👁️",
		"id": "eye_cyclops",
		"name": "Olho Ciclópeo Colossal",
		"icon": "🧿",
		"scene": "res://scenes/appendages/EyeCyclops.tscn",
		"type": "eye",
		"category": "eye",
		"tag": "#Eye_Cyclops",
		"mass": 0.6,
		"base_damage": 0.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 3.0,
		"desc": "Olho único titânico com crista superciliar pesada e chifres orbitais. Habilidade: Olhar Aterrorizante. Custo: 2 pts."
	},

	# 🦎 RABOS & CAUDAS
	{
		"category_id": "tail",
		"category_name": "Rabos",
		"category_icon": "🦎",
		"id": "tail_stinger",
		"name": "Cauda com Ferrão",
		"icon": "🦂",
		"scene": "res://scenes/appendages/TailPart.tscn",
		"type": "tail",
		"category": "tail",
		"tag": "#Tail_Stinger",
		"mass": 1.1,
		"base_damage": 13.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 5.0,
		"desc": "Cauda de escorpião com bulbo e ferrão. Habilidade: Ferroada Venenosa (DoT). Custo: 7 + escala."
	},
	{
		"category_id": "tail",
		"category_name": "Rabos",
		"category_icon": "🦎",
		"id": "tail_club",
		"name": "Cauda Maça Óssea",
		"icon": "🔨",
		"scene": "res://scenes/appendages/TailClub.tscn",
		"type": "tail",
		"category": "tail",
		"tag": "#Tail_Club",
		"mass": 1.6,
		"base_damage": 16.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 7.0,
		"desc": "Cauda de anquilossauro com nódulos e maça pesada. Habilidade: Pancada Sísmica. Custo: 7 + escala."
	},
	{
		"category_id": "tail",
		"category_name": "Rabos",
		"category_icon": "🦎",
		"id": "tail_heavy",
		"name": "Cauda Aletada / Chicote",
		"icon": "🦎",
		"scene": "res://scenes/appendages/TailPart.tscn",
		"type": "tail",
		"category": "tail",
		"tag": "#Tail_Heavy",
		"mass": 1.0,
		"base_damage": 11.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 4.0,
		"desc": "Cauda longa e flexível com aletas dorsais. Habilidade: Varredura de Cauda 360°. Custo: 7 + escala."
	},
	{
		"category_id": "tail",
		"category_name": "Rabos",
		"category_icon": "🦎",
		"id": "tail_feather",
		"name": "Leme Emplumado",
		"icon": "🪶",
		"scene": "res://scenes/appendages/TailFeather.tscn",
		"type": "tail",
		"category": "tail",
		"tag": "#Tail_Feather",
		"mass": 0.6,
		"base_damage": 4.0,
		"leg_force": 0.0,
		"wing_area": 1.2,
		"carapace_defense": 2.0,
		"desc": "Cauda com leque aerodinâmico para equilíbrio e manobras ágeis. Custo: 7 + escala."
	},
	{
		"category_id": "tail",
		"category_name": "Rabos",
		"category_icon": "🦎",
		"id": "tail_scorpion",
		"name": "Cauda de Escorpião Imperador",
		"icon": "🦂",
		"scene": "res://scenes/appendages/TailScorpion.tscn",
		"type": "tail",
		"category": "tail",
		"tag": "#Tail_Scorpion",
		"mass": 1.3,
		"base_damage": 17.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 6.0,
		"desc": "5 segmentos blindados e aguilhão duplo com veneno neurotóxico. Habilidade: Picada Neurotóxica. Custo: 7 + escala."
	},

	# 🪽 ASAS & VOO
	{
		"category_id": "wing",
		"category_name": "Asas",
		"category_icon": "🪽",
		"id": "wing_membrane",
		"name": "Asa Membranosa Dracônica",
		"icon": "🦅",
		"scene": "res://scenes/appendages/WingMembrane.tscn",
		"type": "wing",
		"category": "wing",
		"tag": "#Wing_Membrane",
		"mass": 0.9,
		"base_damage": 4.0,
		"leg_force": 0.0,
		"wing_area": 2.6,
		"carapace_defense": 1.0,
		"desc": "Asa dracônica com 5 falanges. Permite voo segurando Espaço! Custo: 12 + escala."
	},
	{
		"category_id": "wing",
		"category_name": "Asas",
		"category_icon": "🪽",
		"id": "wing_insect",
		"name": "Asa Insetóide Dupla",
		"icon": "🪰",
		"scene": "res://scenes/appendages/WingInsect.tscn",
		"type": "wing",
		"category": "wing",
		"tag": "#Wing_Insect",
		"mass": 0.5,
		"base_damage": 2.0,
		"leg_force": 0.0,
		"wing_area": 2.2,
		"carapace_defense": 0.5,
		"desc": "Asas transparentes vibratórias. Voo ágil com rápida aceleração. Custo: 12 + escala."
	},
	{
		"category_id": "wing",
		"category_name": "Asas",
		"category_icon": "🪽",
		"id": "wing_feather",
		"name": "Asa Emplumada de Ave",
		"icon": "🪽",
		"scene": "res://scenes/appendages/WingFeather.tscn",
		"type": "wing",
		"category": "wing",
		"tag": "#Wing_Feather",
		"mass": 0.8,
		"base_damage": 3.0,
		"leg_force": 0.0,
		"wing_area": 2.8,
		"carapace_defense": 1.5,
		"desc": "Asa com remiges de penas longas. Planagem suave e estável. Custo: 12 + escala."
	},
	{
		"category_id": "wing",
		"category_name": "Asas",
		"category_icon": "🪽",
		"id": "wing_butterfly",
		"name": "Asa de Borboleta Mística",
		"icon": "🦋",
		"scene": "res://scenes/appendages/WingButterfly.tscn",
		"type": "wing",
		"category": "wing",
		"tag": "#Wing_Butterfly",
		"mass": 0.6,
		"base_damage": 3.0,
		"leg_force": 0.0,
		"wing_area": 3.2,
		"carapace_defense": 2.0,
		"desc": "Asa ampla lepidóptera com cauda de fada, nervuras radiais e ocelos brilhantes. Voo gracioso. Custo: 12 + escala."
	},

	# ⚔️ DEFESA & CHIFRES
	{
		"category_id": "defense",
		"category_name": "Defesa",
		"category_icon": "⚔️",
		"id": "horn_frontal",
		"name": "Chifre Frontal Curvo",
		"icon": "🦏",
		"scene": "res://scenes/appendages/SpikeHorn.tscn",
		"type": "spike",
		"category": "attack",
		"tag": "#Horn_Frontal",
		"mass": 0.7,
		"base_damage": 14.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 4.0,
		"desc": "Chifre anelado curvado para frente. Habilidade: Investida Devastadora. Custo: 6 + escala."
	},
	{
		"category_id": "defense",
		"category_name": "Defesa",
		"category_icon": "⚔️",
		"id": "horn_antler",
		"name": "Galhada / Chifre Ramificado",
		"icon": "🦌",
		"scene": "res://scenes/appendages/HornAntler.tscn",
		"type": "spike",
		"category": "attack",
		"tag": "#Horn_Antler",
		"mass": 1.0,
		"base_damage": 12.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 8.0,
		"desc": "Chifres ramificados com múltiplas pontas defensivas. Habilidade: Defesa Chifrada. Custo: 6 + escala."
	},
	{
		"category_id": "defense",
		"category_name": "Defesa",
		"category_icon": "⚔️",
		"id": "spike_dorsal",
		"name": "Placa / Espinho Dorsal",
		"icon": "🛡️",
		"scene": "res://scenes/appendages/SpikeDorsal.tscn",
		"type": "spike",
		"category": "defense",
		"tag": "#Spike_Dorsal",
		"mass": 0.9,
		"base_damage": 6.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 9.0,
		"desc": "Placa dérmica espinhosa tipo estegossauro. Alta carapaça e defesa. Custo: 6 + escala."
	},
	{
		"category_id": "defense",
		"category_name": "Defesa",
		"category_icon": "⚔️",
		"id": "blade_bone",
		"name": "Lâmina Óssea de Foice",
		"icon": "⚔️",
		"scene": "res://scenes/appendages/BladeBone.tscn",
		"type": "spike",
		"category": "attack",
		"tag": "#Blade_Bone",
		"mass": 0.8,
		"base_damage": 15.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 3.0,
		"desc": "Lâmina curva afiada para ombros ou membros. Habilidade: Golpe em Corte. Custo: 6 + escala."
	},
	{
		"category_id": "defense",
		"category_name": "Defesa",
		"category_icon": "⚔️",
		"id": "fin_aquatic",
		"name": "Barbatana Aquática / Quilha",
		"icon": "🦈",
		"scene": "res://scenes/appendages/FinAquatic.tscn",
		"type": "spike",
		"category": "defense",
		"tag": "#Fin_Aquatic",
		"mass": 0.7,
		"base_damage": 8.0,
		"leg_force": 0.0,
		"wing_area": 1.5,
		"carapace_defense": 6.0,
		"desc": "Barbatana hidrodinâmica com raios cartilaginosos. Aumenta hidrodinâmica e estabilidade. Custo: 6 + escala."
	},
	{
		"category_id": "defense",
		"category_name": "Defesa",
		"category_icon": "⚔️",
		"id": "horn_rhino",
		"name": "Chifre Nasal de Rinoceronte",
		"icon": "🦏",
		"scene": "res://scenes/appendages/HornRhino.tscn",
		"type": "spike",
		"category": "attack",
		"tag": "#Horn_Rhino",
		"mass": 1.5,
		"base_damage": 17.0,
		"leg_force": 0.0,
		"wing_area": 0.0,
		"carapace_defense": 8.0,
		"desc": "Chifre maciço de queratina compactada sobre calo basal. Habilidade: Carga Demolidora. Custo: 6 + escala."
	}
]

# --- Filtragem e Seleção de Categorias de Apêndices ---

func _on_cat_all_pressed() -> void:
	_set_appendage_category("all")

func _on_cat_mouth_pressed() -> void:
	_set_appendage_category("mouth")

func _on_cat_leg_pressed() -> void:
	_set_appendage_category("leg")

func _on_cat_eye_pressed() -> void:
	_set_appendage_category("eye")

func _on_cat_tail_pressed() -> void:
	_set_appendage_category("tail")

func _on_cat_wing_pressed() -> void:
	_set_appendage_category("wing")

func _on_cat_defense_pressed() -> void:
	_set_appendage_category("defense")

func _set_appendage_category(category_id: String) -> void:
	current_appendage_category = category_id
	for key in _category_buttons.keys():
		var btn = _category_buttons[key] as Button
		if btn:
			if key == category_id:
				btn.modulate = Color(1.3, 1.25, 0.6)
			else:
				btn.modulate = Color(1.0, 1.0, 1.0)
	_populate_appendage_catalog()

func _populate_appendage_catalog() -> void:
	if not appendage_item_list:
		return

	for child in appendage_item_list.get_children():
		appendage_item_list.remove_child(child)
		child.queue_free()

	var shown_items: Array[Dictionary] = []
	for item in APPENDAGE_CATALOG:
		if current_appendage_category == "all" or item.category_id == current_appendage_category:
			shown_items.append(item)

	var last_cat_id = ""
	for item in shown_items:
		if current_appendage_category == "all" and item.category_id != last_cat_id:
			last_cat_id = item.category_id
			var header = Label.new()
			header.text = "── %s %s ──" % [item.category_icon, item.category_name.to_upper()]
			header.add_theme_font_size_override("font_size", 11)
			header.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
			appendage_item_list.add_child(header)

		var base_cost = CreatureData.calculate_part_cost(item.category, 1.0)
		var btn = Button.new()
		btn.text = "%s %s (%d pts)" % [item.icon, item.name, base_cost]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(0, 30)
		btn.focus_mode = Control.FOCUS_NONE
		btn.tooltip_text = "%s (%s)\nCusto Base: %d pts | Massa: %.1f kg\nDano: %.0f | Defesa: %.0f | Tração: %.1f | Voo: %.1f\n%s" % [
			item.name,
			item.tag,
			base_cost,
			item.mass,
			item.base_damage,
			item.carapace_defense,
			item.leg_force,
			item.wing_area,
			item.desc
		]

		if item.id == _active_appendage_id:
			btn.modulate = Color(1.3, 1.25, 0.6)

		btn.pressed.connect(_select_catalog_part.bind(item))
		appendage_item_list.add_child(btn)

func _select_catalog_part(item: Dictionary) -> void:
	var item_id = str(item.get("id", ""))
	# Se clicou no mesmo item da lista (duplo clique ou 2º clique): cancela e desseleciona!
	if _active_appendage_id == item_id:
		_deselect_catalog_part()
		return

	_active_appendage_id = item_id
	var scene_path = str(item.get("scene", ""))
	if ResourceLoader.exists(scene_path):
		var packed = load(scene_path) as PackedScene
		if packed and attachment_system:
			attachment_system.set_active_part(packed, item)

	if lbl_part_info:
		lbl_part_info.text = "%s %s: %s (Clique no corpo para fixar continuamente. Clique novamente na lista ou Esc para cancelar)" % [item.icon, item.name, item.desc]

	_update_appendage_item_buttons_modulate()

func _deselect_catalog_part() -> void:
	_active_appendage_id = ""
	if attachment_system:
		attachment_system.clear_active_part()
	if lbl_part_info:
		lbl_part_info.text = "Seleção de apêndice cancelada. Clique em um apêndice anexado para editá-lo."
	_update_appendage_item_buttons_modulate()

func _update_appendage_item_buttons_modulate() -> void:
	if not appendage_item_list:
		return
	for child in appendage_item_list.get_children():
		if child is Button:
			var btn_txt = child.text
			var is_active = false
			for item in APPENDAGE_CATALOG:
				if item.id == _active_appendage_id and btn_txt.contains(item.name):
					is_active = true
					break
			child.modulate = Color(1.3, 1.25, 0.6) if is_active else Color(1.0, 1.0, 1.0)

# Redirecionadores compatíveis para métodos legados
func _select_catalog_part_by_id(part_id: String) -> void:
	for item in APPENDAGE_CATALOG:
		if item.id == part_id:
			_select_catalog_part(item)
			return

func _on_select_part_leg() -> void:
	_select_catalog_part_by_id("leg_claw")

func _on_select_part_wing() -> void:
	_select_catalog_part_by_id("wing_membrane")

func _on_select_part_mouth() -> void:
	_select_catalog_part_by_id("mouth_carnivore")

func _on_select_part_herb_mouth() -> void:
	_select_catalog_part_by_id("mouth_herbivore")

func _on_select_part_spike() -> void:
	_select_catalog_part_by_id("horn_frontal")

func _on_select_part_tail() -> void:
	_select_catalog_part_by_id("tail_stinger")

func _on_select_part_eye() -> void:
	_select_catalog_part_by_id("eye_simple")

func _on_delete_selected_part_pressed() -> void:
	if attachment_system and attachment_system.delete_selected_part():
		if lbl_part_info:
			lbl_part_info.text = "Peça selecionada removida e biomassa reembolsada!"

func _on_clear_parts_pressed() -> void:
	if attachment_system:
		attachment_system.clear_all_attached_parts()
	if lbl_part_info:
		lbl_part_info.text = "Todos os membros removidos. Biomassa reembolsada!"

# --- Callbacks de Escultura (Pilar 1) ---

func _on_add_vertebra_pressed() -> void:
	if spine_controller:
		spine_controller.add_vertebra()

func _on_remove_vertebra_pressed() -> void:
	if spine_controller:
		spine_controller.remove_vertebra(spine_controller.selected_index)

func _on_reset_spine_pressed() -> void:
	if spine_controller:
		spine_controller.reset_spine()

func _on_vertebra_slider_radius_changed(value: float) -> void:
	if not spine_controller:
		return
	var target_idx = _get_active_vertebra_index()
	if target_idx >= 0 and target_idx < spine_controller.vertebrae.size():
		var delta = value - float(spine_controller.vertebrae[target_idx].radius)
		if abs(delta) > 0.005:
			spine_controller.adjust_vertebra_radius(target_idx, delta)

func _on_vertebra_slider_size_changed(value: float) -> void:
	if not spine_controller:
		return
	var target_idx = _get_active_vertebra_index()
	if target_idx >= 0 and target_idx < spine_controller.vertebrae.size():
		spine_controller.set_vertebra_size(target_idx, value)

func _get_active_vertebra_index() -> int:
	if not spine_controller or spine_controller.vertebrae.is_empty():
		return -1
	if spine_controller.selected_index >= 0:
		return spine_controller.selected_index
	if spine_controller.hovered_index >= 0:
		return spine_controller.hovered_index
	return int(spine_controller.vertebrae.size() / 2)

func _on_vertebra_selected(index: int) -> void:
	_sync_sliders_with_vertebra(index)

func _on_vertebra_hovered(index: int) -> void:
	if spine_controller and spine_controller.selected_index < 0:
		_sync_sliders_with_vertebra(index)

func _sync_sliders_with_vertebra(index: int) -> void:
	if not spine_controller or index < 0 or index >= spine_controller.vertebrae.size():
		return
	var r = float(spine_controller.vertebrae[index].radius)
	var sz = float(spine_controller.vertebrae[index].get("size", 1.0))

	if lbl_vertebra_radius_val:
		lbl_vertebra_radius_val.text = "%.2fm" % r
	if slider_vertebra_radius and not is_equal_approx(slider_vertebra_radius.value, r):
		slider_vertebra_radius.set_value_no_signal(r)

	if lbl_vertebra_size_val:
		lbl_vertebra_size_val.text = "%.2fx" % sz
	if slider_vertebra_size and not is_equal_approx(slider_vertebra_size.value, sz):
		slider_vertebra_size.set_value_no_signal(sz)

func _update_sculpt_ui() -> void:
	if not spine_controller:
		return
	if lbl_vertebra_info:
		lbl_vertebra_info.text = "Vértebras Ativas: %d (3 a 16)" % spine_controller.vertebrae.size()

	var active_idx = _get_active_vertebra_index()
	if active_idx >= 0 and active_idx < spine_controller.vertebrae.size():
		_sync_sliders_with_vertebra(active_idx)

# --- Callbacks do CreatureData & Validação de Locomoção (Pilar 2) ---

func _on_biomass_changed(current: int, max_val: int) -> void:
	if biomass_bar:
		biomass_bar.max_value = max_val
		biomass_bar.value = current
	if biomass_label:
		biomass_label.text = "Biomassa: %d / %d" % [current, max_val]

func _on_stats_updated(h: float, s: float, spd: float) -> void:
	var agl = creature_data.agility if creature_data else 0.0
	var kb = creature_data.knockback_multiplier if creature_data else 1.0
	_on_extended_stats_updated(h, s, agl, spd, kb)

func _on_extended_stats_updated(hp: float, str_val: float, agl: float, spd: float, knockback_mult: float) -> void:
	if lbl_health_val:
		lbl_health_val.text = "%.0f" % hp
	if lbl_strength_val:
		lbl_strength_val.text = "%.1f" % str_val
	if lbl_agility_val:
		lbl_agility_val.text = "%.1f" % agl
	if lbl_speed_val:
		lbl_speed_val.text = "%.1f" % spd

	if bar_health:
		bar_health.value = hp
	if bar_strength:
		bar_strength.value = str_val
	if bar_agility:
		bar_agility.value = agl
	if bar_speed:
		bar_speed.value = spd

	if lbl_stability_info and creature_data:
		lbl_stability_info.text = "Massa Total: %.1f kg\nKnockback CoM: %.2fx\nApoios no Solo: %d (mín: 2)" % [
			creature_data.total_mass,
			knockback_mult,
			creature_data.valid_ground_contacts
		]

func _on_locomotion_validation_changed(is_valid: bool, error_message: String) -> void:
	if locomotion_warning_banner:
		locomotion_warning_banner.visible = not is_valid
	if lbl_locomotion_warning and error_message != "":
		lbl_locomotion_warning.text = error_message

# --- Callbacks do SkillFactory & Hotbar Q, E, R, F, V (Pilar 3) ---

func _on_skills_updated(unlocked: Array[Dictionary], slots: Dictionary) -> void:
	var slot_map = {
		"Q": slot_q,
		"E": slot_e,
		"R": slot_r,
		"F": slot_f,
		"V": slot_v
	}

	for key in slot_map.keys():
		var btn: SkillSlotButton = slot_map[key]
		if not btn:
			continue
		var sk: Dictionary = slots.get(key, {})
		if sk.is_empty():
			btn.skill_tag = ""
			btn.skill_name = ""
			btn.text = "[%s] Vazio" % key
			btn.tooltip_text = "Arraste uma habilidade para este slot"
		else:
			btn.skill_tag = str(sk.get("tag", ""))
			btn.skill_name = str(sk.get("name", ""))
			var icon = str(sk.get("icon", "⚡"))
			btn.text = "[%s] %s %s" % [key, icon, btn.skill_name]
			btn.tooltip_text = "%s\n%s\nImpacto: %.1f | Cooldown: %.1fs" % [
				btn.skill_name,
				str(sk.get("description", "")),
				float(sk.get("impact_score", 0.0)),
				float(sk.get("cooldown", 0.0))
			]

	if lbl_unlocked_skills_list:
		if unlocked.is_empty():
			lbl_unlocked_skills_list.text = "Nenhuma habilidade ativa.\nAdicione Bocas, Garras, Chifres, Asas ou Caudas na aba Apêndices!"
		else:
			var lines: PackedStringArray = []
			for sk in unlocked:
				lines.append("%s %s (%s)\n   • %s | Impacto: %.1f" % [
					str(sk.get("icon", "⚡")),
					str(sk.get("name", "")),
					str(sk.get("tag", "")),
					str(sk.get("description", "")),
					float(sk.get("impact_score", 0.0))
				])
			lbl_unlocked_skills_list.text = "\n\n".join(lines)

func _on_hotbar_slot_dropped(source_slot: String, target_slot: String) -> void:
	if skill_factory:
		skill_factory.swap_slots(source_slot, target_slot)

func _on_hotbar_slot_pressed(slot_key: String) -> void:
	if skill_factory:
		skill_factory.trigger_slot(slot_key)

func _on_skill_triggered(slot_key: String, skill_data: Dictionary) -> void:
	var sk_name = str(skill_data.get("name", "Habilidade"))
	var effect_type = str(skill_data.get("effect_type", ""))
	if procedural_gait:
		procedural_gait.play_skill_motion(effect_type)
	if lbl_part_info:
		lbl_part_info.text = "⚡ [%s] %s ativada!" % [slot_key, sk_name]

# --- Callbacks do ApplyCreatureShader (Pintura & Texturas) ---

func _on_skin_pattern_selected(index: int) -> void:
	if body_mesh and body_mesh.has_method("set_skin_pattern"):
		body_mesh.call("set_skin_pattern", index)

func _on_pattern_blend_changed(value: float) -> void:
	if lbl_pattern_blend_val:
		lbl_pattern_blend_val.text = "%d%%" % int(value * 100)
	if body_mesh and body_mesh.has_method("set_pattern_blend"):
		body_mesh.call("set_pattern_blend", value)

func _on_normal_scale_changed(value: float) -> void:
	if lbl_normal_scale_val:
		lbl_normal_scale_val.text = "%.1fx" % value
	if body_mesh and body_mesh.has_method("set_normal_scale"):
		body_mesh.call("set_normal_scale", value)

func _on_roughness_changed(value: float) -> void:
	if lbl_roughness_val:
		lbl_roughness_val.text = "%.2f" % value
	if body_mesh and body_mesh.has_method("set_roughness"):
		body_mesh.call("set_roughness", value)

func _on_primary_color_changed(color: Color) -> void:
	if body_mesh and body_mesh.has_method("set_base_color"):
		body_mesh.call("set_base_color", color)
	_sync_appendages_colors()

func _on_secondary_color_changed(color: Color) -> void:
	if body_mesh and body_mesh.has_method("set_secondary_color"):
		body_mesh.call("set_secondary_color", color)
	_sync_appendages_colors()

func _on_detail_color_changed(_color: Color) -> void:
	_sync_appendages_colors()

func _sync_appendages_colors() -> void:
	if attachment_system:
		var p_col = primary_color_picker.color if primary_color_picker else Color(0.85, 0.45, 0.35)
		var s_col = secondary_color_picker.color if secondary_color_picker else Color(0.3, 0.15, 0.1)
		var d_col = detail_color_picker.color if detail_color_picker else Color(0.92, 0.88, 0.78)
		attachment_system.update_all_appendages_colors(p_col, s_col, d_col)

func _on_texture_scale_changed(value: float) -> void:
	if lbl_texture_scale_val:
		lbl_texture_scale_val.text = "%.1fx" % value
	if body_mesh and body_mesh.has_method("set_texture_scale"):
		body_mesh.call("set_texture_scale", value)

func _on_sss_changed(value: float) -> void:
	if lbl_sss_val:
		lbl_sss_val.text = "%.2f" % value
	if body_mesh and body_mesh.has_method("set_sss_properties"):
		var sss_col = primary_color_picker.color if primary_color_picker else Color(1.0, 0.25, 0.15)
		body_mesh.call("set_sss_properties", sss_col, value, 0.25)

# --- Alternância de Modos e Sandbox ---

func _on_test_drive_pressed() -> void:
	if not editor_state:
		return
	if editor_state.current_mode == EditorState.Mode.MODO_SANDBOX:
		editor_state.change_mode(EditorState.Mode.MODO_APENDICES)
	else:
		editor_state.change_mode(EditorState.Mode.MODO_SANDBOX)
