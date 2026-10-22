class_name SkillSlotButton
extends Button

## Botão de Slot da Hotbar (Q, E, R, F, V) com suporte nativo a Drag & Drop do Godot 4
## para reordenação de habilidades na UI.

signal slot_dropped(source_slot: String, target_slot: String)

@export var slot_key: String = "Q"
var skill_tag: String = ""
var skill_name: String = ""

func _get_drag_data(_at_position: Vector2) -> Variant:
	if skill_tag == "":
		return null

	var preview = Label.new()
	preview.text = " [%s] %s " % [slot_key, skill_name]
	preview.modulate = Color(1.0, 0.9, 0.4)
	set_drag_preview(preview)

	return {
		"type": "skill_hotbar_slot",
		"source_slot": slot_key,
		"tag": skill_tag
	}

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return false
	return data.get("type", "") == "skill_hotbar_slot"

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if typeof(data) != TYPE_DICTIONARY:
		return
	var source_slot = str(data.get("source_slot", ""))
	if source_slot != "" and source_slot != slot_key:
		emit_signal("slot_dropped", source_slot, slot_key)

