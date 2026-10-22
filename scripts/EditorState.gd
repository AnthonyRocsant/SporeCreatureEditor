class_name EditorState
extends Node

## Gerencia os modos de edição e transição do Criador de Criaturas
enum Mode {
	MODO_ESCULTURA,
	MODO_APENDICES,
	MODO_PINTURA,
	MODO_HABILIDADES,
	MODO_SANDBOX
}

signal mode_changed(new_mode: Mode, old_mode: Mode)

@export var current_mode: Mode = Mode.MODO_ESCULTURA:
	set(value):
		if current_mode != value:
			var previous = current_mode
			current_mode = value
			emit_signal("mode_changed", current_mode, previous)

func change_mode(new_mode: Mode) -> void:
	current_mode = new_mode

func is_sculpting() -> bool:
	return current_mode == Mode.MODO_ESCULTURA

func is_attaching() -> bool:
	return current_mode == Mode.MODO_APENDICES

func is_painting() -> bool:
	return current_mode == Mode.MODO_PINTURA

func is_skills() -> bool:
	return current_mode == Mode.MODO_HABILIDADES

func is_sandbox() -> bool:
	return current_mode == Mode.MODO_SANDBOX
