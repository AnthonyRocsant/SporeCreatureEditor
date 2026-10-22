class_name ApplyCreatureShader
extends MeshInstance3D

## Controlador de Material e Shader Triplanar da Criatura em tempo real.
## Anexe este script ao nó BodyMesh no CreatureEditor.

@export var shader: Shader = preload("res://shaders/creature_triplanar.gdshader")

var _material: ShaderMaterial

func _ready() -> void:
	_init_material()

func _init_material() -> void:
	# Garante uma instância única do material para evitar alterar outras instâncias globais
	var existing_mat = get_surface_override_material(0)
	if existing_mat is ShaderMaterial and existing_mat.shader == shader:
		_material = existing_mat
	else:
		_material = ShaderMaterial.new()
		_material.shader = shader
		set_surface_override_material(0, _material)

## Retorna ou inicializa o ShaderMaterial
func get_creature_material() -> ShaderMaterial:
	if not _material:
		_init_material()
	return _material

# --- Métodos de Controle em Tempo Real para a UI ---

func set_base_color(color: Color) -> void:
	get_creature_material().set_shader_parameter("base_color", color)

func set_secondary_color(color: Color) -> void:
	get_creature_material().set_shader_parameter("secondary_color", color)

func set_pattern_blend(factor: float) -> void:
	get_creature_material().set_shader_parameter("pattern_blend", clampf(factor, 0.0, 1.0))

func set_texture_scale(scale_value: float) -> void:
	get_creature_material().set_shader_parameter("texture_scale", maxf(0.01, scale_value))

func set_triplanar_sharpness(sharpness: float) -> void:
	get_creature_material().set_shader_parameter("triplanar_sharpness", clampf(sharpness, 1.0, 32.0))

func set_roughness(value: float) -> void:
	get_creature_material().set_shader_parameter("roughness", clampf(value, 0.0, 1.0))

func set_metallic(value: float) -> void:
	get_creature_material().set_shader_parameter("metallic", clampf(value, 0.0, 1.0))

func set_sss_properties(color: Color, strength: float, translucency: float) -> void:
	var mat = get_creature_material()
	mat.set_shader_parameter("sss_color", color)
	mat.set_shader_parameter("sss_strength", maxf(0.0, strength))
	mat.set_shader_parameter("sss_translucency", clampf(translucency, 0.0, 1.0))

func set_albedo_texture(texture: Texture2D) -> void:
	var mat = get_creature_material()
	mat.set_shader_parameter("texture_albedo", texture)
	mat.set_shader_parameter("use_albedo_texture", texture != null)

func set_normal_texture(texture: Texture2D, scale: float = 1.0) -> void:
	var mat = get_creature_material()
	mat.set_shader_parameter("texture_normal", texture)
	mat.set_shader_parameter("normal_scale", scale)
	mat.set_shader_parameter("use_normal_texture", texture != null)

func set_roughness_texture(texture: Texture2D) -> void:
	get_creature_material().set_shader_parameter("texture_roughness", texture)

