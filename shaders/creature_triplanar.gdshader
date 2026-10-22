shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// --- Cores e Variações ---
uniform vec4 base_color : source_color = vec4(0.85, 0.45, 0.35, 1.0);
uniform vec4 secondary_color : source_color = vec4(0.3, 0.15, 0.1, 1.0);
uniform float pattern_blend : hint_range(0.0, 1.0) = 0.5;

// --- Parâmetros Físicos da Superfície ---
uniform float roughness : hint_range(0.0, 1.0) = 0.5;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float normal_scale : hint_range(0.0, 5.0) = 1.0;

// --- Mapeamento Triplanar & Texturas ---
uniform bool use_albedo_texture = false;
uniform bool use_normal_texture = false;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_normal : hint_normal, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_roughness : hint_default_white, filter_linear_mipmap, repeat_enable;

uniform float texture_scale : hint_range(0.01, 20.0) = 2.0;
uniform float triplanar_sharpness : hint_range(1.0, 32.0) = 4.0;
uniform bool use_world_coords = false;

// --- Subsurface Scattering (SSS) / Translucidez ---
uniform vec4 sss_color : source_color = vec4(1.0, 0.25, 0.15, 1.0);
uniform float sss_strength : hint_range(0.0, 2.0) = 0.3;
uniform float sss_translucency : hint_range(0.0, 1.0) = 0.2;

varying vec3 v_triplanar_pos;
varying vec3 v_triplanar_normal;

void vertex() {
	if (use_world_coords) {
		v_triplanar_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
		v_triplanar_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	} else {
		v_triplanar_pos = VERTEX;
		v_triplanar_normal = NORMAL;
	}
}

// Amostragem triplanar combinada com pesos de transição
vec4 sample_triplanar_texture(sampler2D tex, vec3 pos, vec3 weights) {
	vec4 col_x = texture(tex, pos.zy);
	vec4 col_y = texture(tex, pos.xz);
	vec4 col_z = texture(tex, pos.xy);
	return col_x * weights.x + col_y * weights.y + col_z * weights.z;
}

// Amostragem triplanar de Normal Map
vec3 sample_triplanar_normal(sampler2D norm_tex, vec3 pos, vec3 weights, vec3 geom_normal) {
	vec3 norm_x = texture(norm_tex, pos.zy).xyz * 2.0 - 1.0;
	vec3 norm_y = texture(norm_tex, pos.xz).xyz * 2.0 - 1.0;
	vec3 norm_z = texture(norm_tex, pos.xy).xyz * 2.0 - 1.0;

	norm_x.x *= sign(geom_normal.x);
	norm_y.x *= sign(geom_normal.y);
	norm_z.x *= sign(geom_normal.z);

	vec3 tangent_x = vec3(0.0, norm_x.yx);
	vec3 tangent_y = vec3(norm_y.x, 0.0, norm_y.y);
	vec3 tangent_z = vec3(norm_z.xy, 0.0);

	vec3 blended_normal = tangent_x * weights.x + tangent_y * weights.y + tangent_z * weights.z;
	return normalize(blended_normal);
}

// Função de ruído procedural rápida para gerar padrão de pele e manchas estilo Spore
float procedural_skin_pattern(vec3 p) {
	vec3 p_scaled = p * 4.0;
	// Combinação senoidal harmônica rápida simulando manchas de pele celular
	float n = sin(p_scaled.x) * sin(p_scaled.y) * sin(p_scaled.z);
	n += 0.5 * sin(p_scaled.x * 2.3 + p_scaled.y * 1.7) * cos(p_scaled.z * 2.1);
	return clamp(n * 0.5 + 0.5, 0.0, 1.0);
}

// --- Funções de Relevo Procedural de Micro-Escamas Orgânicas ---
float micro_scale_height(vec3 p) {
	vec3 s = p * 16.0;
	float b = sin(s.x) * cos(s.y) + sin(s.y * 1.3 + s.x * 0.4) * cos(s.z * 1.2) + sin(s.z * 1.4) * cos(s.x * 1.1);
	// Camada fina secundária (poros)
	vec3 s2 = p * 36.0;
	float b2 = sin(s2.x + s2.z) * cos(s2.y);
	return b * 0.25 + b2 * 0.08;
}

void fragment() {
	vec3 abs_normal = abs(v_triplanar_normal);
	vec3 weights = pow(abs_normal, vec3(triplanar_sharpness));
	weights /= (weights.x + weights.y + weights.z);

	vec3 uv_pos = v_triplanar_pos * texture_scale;

	// 1. Cálculo da cor com suporte a padrão procedural ou textura
	float blend_factor = 0.0;
	vec3 tint_result = base_color.rgb;
	float skin_noise = 0.5;

	if (use_albedo_texture) {
		vec4 tex_albedo = sample_triplanar_texture(texture_albedo, uv_pos, weights);
		blend_factor = tex_albedo.r * pattern_blend;
		tint_result = mix(base_color.rgb, secondary_color.rgb, blend_factor) * tex_albedo.rgb;
	} else {
		// Padrão orgânico estilo Spore:
		// 1) Máscara de ventre/dorso baseada na normal Y (barriga vs costas)
		float belly_dorso = clamp((-v_triplanar_normal.y * 0.6 + 0.4), 0.0, 1.0);
		// 2) Manchas de pele celulares via ruído procedural
		skin_noise = procedural_skin_pattern(uv_pos);
		// 3) Mistura modulada pelo pattern_blend
		blend_factor = clamp(mix(belly_dorso, skin_noise, 0.45) * pattern_blend * 1.5, 0.0, 1.0);
		tint_result = mix(base_color.rgb, secondary_color.rgb, blend_factor);
	}

	// 2. Efeito Fresnel / Velvet Rim Orgânico (brilho aveludado de borda)
	float n_dot_v = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	float fresnel = pow(1.0 - n_dot_v, 3.2);
	vec3 rim_sheen = mix(tint_result, sss_color.rgb, 0.6) * fresnel * (0.35 * (1.0 + sss_translucency));

	ALBEDO = tint_result + rim_sheen;
	ALPHA = 1.0;

	// 3. Normal Map: se tiver textura usa a textura; se não, calcula micro-escamas orgânicas em tempo real!
	if (use_normal_texture) {
		vec3 tri_norm = sample_triplanar_normal(texture_normal, uv_pos, weights, v_triplanar_normal);
		NORMAL_MAP = tri_norm;
		NORMAL_MAP_DEPTH = normal_scale;
	} else {
		// Micro-escamas procedurais que reagem à luz nos ângulos rasantes
		float eps = 0.035;
		float h_c = micro_scale_height(uv_pos);
		float h_x = micro_scale_height(uv_pos + vec3(eps, 0.0, 0.0));
		float h_y = micro_scale_height(uv_pos + vec3(0.0, eps, 0.0));
		float h_z = micro_scale_height(uv_pos + vec3(0.0, 0.0, eps));
		vec3 world_grad = vec3(h_x - h_c, h_y - h_c, h_z - h_c) / eps;
		
		// Converte gradiente para o espaço de visão
		vec3 view_grad = mat3(VIEW_MATRIX) * world_grad;
		NORMAL = normalize(NORMAL - view_grad * (0.09 * normal_scale));
	}

	// 4. Roughness orgânica com micro-variação celular
	float micro_rough = micro_scale_height(uv_pos) * 0.12;
	ROUGHNESS = clamp(roughness + micro_rough, 0.08, 0.95);
	METALLIC = metallic;

	// 5. Oclusão de Cavidades da Pele (Ambient Cavity Occlusion)
	AO = clamp(0.72 + 0.28 * skin_noise, 0.5, 1.0);
	AO_LIGHT_AFFECT = 0.55;

	// 6. Subsurface Scattering / Translucidez sem artefatos
	if (sss_strength > 0.0) {
		SSS_STRENGTH = sss_strength;
		SSS_TRANSMITTANCE_COLOR = sss_color;
		SSS_TRANSMITTANCE_DEPTH = sss_translucency;
		BACKLIGHT = sss_color.rgb * sss_translucency * 0.35;
	}
}
