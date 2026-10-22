shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// --- Cores e Variações ---
uniform vec4 base_color : source_color = vec4(0.85, 0.45, 0.35, 1.0);
uniform vec4 secondary_color : source_color = vec4(0.3, 0.15, 0.1, 1.0);
uniform float pattern_blend : hint_range(0.0, 1.0) = 0.5;
uniform int skin_pattern_type : hint_range(0, 6) = 0; // 0: Clássico, 1: Escamas, 2: Couro, 3: Listras, 4: Leopardo, 5: Quitina, 6: Anfíbio

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

// --- Funções Auxiliares de Padrões e Ruído Orgânico ---
float procedural_skin_pattern(vec3 p) {
	vec3 p_scaled = p * 4.0;
	float n = sin(p_scaled.x) * sin(p_scaled.y) * sin(p_scaled.z);
	n += 0.5 * sin(p_scaled.x * 2.3 + p_scaled.y * 1.7) * cos(p_scaled.z * 2.1);
	return clamp(n * 0.5 + 0.5, 0.0, 1.0);
}

float micro_scale_height(vec3 p) {
	vec3 s = p * 16.0;
	float b = sin(s.x) * cos(s.y) + sin(s.y * 1.3 + s.x * 0.4) * cos(s.z * 1.2) + sin(s.z * 1.4) * cos(s.x * 1.1);
	vec3 s2 = p * 36.0;
	float b2 = sin(s2.x + s2.z) * cos(s2.y);
	return b * 0.25 + b2 * 0.08;
}

// Amostragem multi-estilo de padrões de pele Spore (7 opções estéticas completas)
void sample_skin_pattern(vec3 p, vec3 geom_norm, int p_type, out float out_mask, out float out_height, out float out_rough_bias, out vec3 out_emission) {
	out_mask = 0.5;
	out_height = 0.0;
	out_rough_bias = 0.0;
	out_emission = vec3(0.0);

	if (p_type == 1) {
		// 1: 🦎 Escamas de Dragão / Répteis (Diamond / Hexagonal Scales)
		vec3 sp = p * 4.5;
		float d1 = abs(fract(sp.x + sp.z) - 0.5);
		float d2 = abs(fract(sp.x - sp.z) - 0.5);
		float dy = abs(fract(sp.y + sp.z * 0.5) - 0.5);
		float d = max(d1 + d2, dy * 1.3);
		out_mask = smoothstep(0.36, 0.48, d);
		out_height = cos(clamp(d * 3.14159, 0.0, 3.14159)) * 0.48;
		out_rough_bias = -0.06;
	} else if (p_type == 2) {
		// 2: 🦏 Couro Paquiderme / Enrugado (Cracked Leather / Elephant)
		vec3 lp = p * 5.0;
		float c1 = abs(sin(lp.x + sin(lp.z * 1.5)) * cos(lp.y + sin(lp.x * 1.2)));
		float c2 = abs(cos(lp.z * 1.4 + sin(lp.y)) * sin(lp.x * 1.3 + cos(lp.z)));
		float cracks = smoothstep(0.18, 0.02, min(c1, c2));
		float wrinkles = sin(lp.x * 18.0) * sin(lp.y * 18.0 + lp.z * 12.0) * 0.15;
		out_mask = cracks;
		out_height = (1.0 - cracks * 0.85) + wrinkles;
		out_rough_bias = 0.18;
	} else if (p_type == 3) {
		// 3: 🐅 Listras de Predador / Tigre (Predator Tiger Stripes)
		float stripe_phase = p.z * 7.5 + sin(p.y * 3.8) * 2.4 + cos(p.x * 2.8) * 1.4;
		float stripe = smoothstep(-0.15, 0.35, sin(stripe_phase));
		float belly = clamp((-geom_norm.y * 0.6 + 0.4), 0.0, 1.0);
		out_mask = clamp(mix(stripe, belly, 0.35), 0.0, 1.0);
		out_height = (sin(p.z * 30.0) * 0.1) * (1.0 - stripe * 0.5);
		out_rough_bias = 0.0;
	} else if (p_type == 4) {
		// 4: 🐆 Manchas de Leopardo (Leopard Rosettes)
		vec2 uv_spot = vec2(p.z * 4.5, (p.y + p.x * 0.3) * 4.5);
		vec2 cell = fract(uv_spot) - 0.5;
		float dist = length(cell);
		float ring = smoothstep(0.38, 0.28, dist) * smoothstep(0.12, 0.22, dist);
		float dot_c = smoothstep(0.14, 0.04, dist);
		float spots = ring * 0.85 + dot_c * 0.35;
		float belly = clamp((-geom_norm.y * 0.7 + 0.3), 0.0, 1.0);
		out_mask = clamp(mix(spots, belly, 0.25), 0.0, 1.0);
		out_height = micro_scale_height(p) * 0.8;
		out_rough_bias = -0.05;
	} else if (p_type == 5) {
		// 5: 🪲 Carapaça de Quitina / Insetóide (Chitin Armor Plates)
		float band_coord = p.z * 3.8;
		float seg = fract(band_coord);
		float groove = smoothstep(0.12, 0.02, seg) + smoothstep(0.88, 0.98, seg);
		float plate = smoothstep(0.05, 0.25, seg) * smoothstep(0.95, 0.75, seg);
		out_mask = groove;
		out_height = plate * 0.65 - groove * 0.5;
		out_rough_bias = -0.25;
	} else if (p_type == 6) {
		// 6: 🐸 Anfíbio Místico / Bioluminescente (Smooth Bioluminescent)
		float vein_raw = sin(p.x * 6.5 + sin(p.z * 4.5)) * cos(p.y * 6.5 + cos(p.x * 3.5));
		float vein = pow(clamp(vein_raw, 0.0, 1.0), 4.5);
		float speckles = pow(clamp(sin(p.z * 16.0) * cos(p.x * 16.0), 0.0, 1.0), 6.0);
		out_mask = clamp(vein + speckles * 0.6, 0.0, 1.0);
		out_height = (sin(p.x * 30.0) * sin(p.z * 30.0)) * 0.04;
		out_rough_bias = -0.32;
		out_emission = secondary_color.rgb * (vein * 1.8 + speckles * 2.5);
	} else {
		// 0: Clássico Spore (Cellular Mottled + Belly/Back Countershading)
		float belly_dorso = clamp((-geom_norm.y * 0.6 + 0.4), 0.0, 1.0);
		float skin_noise = procedural_skin_pattern(p);
		out_mask = clamp(mix(belly_dorso, skin_noise, 0.45), 0.0, 1.0);
		out_height = micro_scale_height(p);
		out_rough_bias = 0.0;
	}
}

void fragment() {
	vec3 abs_normal = abs(v_triplanar_normal);
	vec3 weights = pow(abs_normal, vec3(triplanar_sharpness));
	weights /= (weights.x + weights.y + weights.z);

	vec3 uv_pos = v_triplanar_pos * texture_scale;

	// 1. Cálculo da cor com suporte a padrão procedural ou textura externa
	float blend_factor = 0.0;
	vec3 tint_result = base_color.rgb;
	float pat_mask = 0.5;
	float pat_height = 0.0;
	float pat_rough_bias = 0.0;
	vec3 pat_emission = vec3(0.0);

	if (use_albedo_texture) {
		vec4 tex_albedo = sample_triplanar_texture(texture_albedo, uv_pos, weights);
		blend_factor = tex_albedo.r * pattern_blend;
		tint_result = mix(base_color.rgb, secondary_color.rgb, blend_factor) * tex_albedo.rgb;
		pat_height = micro_scale_height(uv_pos);
	} else {
		sample_skin_pattern(uv_pos, v_triplanar_normal, skin_pattern_type, pat_mask, pat_height, pat_rough_bias, pat_emission);
		blend_factor = clamp(pat_mask * pattern_blend * 1.5, 0.0, 1.0);
		tint_result = mix(base_color.rgb, secondary_color.rgb, blend_factor);
	}

	// 2. Efeito Fresnel / Velvet Rim Orgânico (brilho aveludado de borda)
	float n_dot_v = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	float fresnel = pow(1.0 - n_dot_v, 3.2);
	vec3 rim_sheen = mix(tint_result, sss_color.rgb, 0.6) * fresnel * (0.35 * (1.0 + sss_translucency));

	ALBEDO = tint_result + rim_sheen;
	ALPHA = 1.0;
	EMISSION = pat_emission;

	// 3. Normal Map: textura externa ou micro-relevo procedural de acordo com o padrão ativo
	if (use_normal_texture) {
		vec3 tri_norm = sample_triplanar_normal(texture_normal, uv_pos, weights, v_triplanar_normal);
		NORMAL_MAP = tri_norm;
		NORMAL_MAP_DEPTH = normal_scale;
	} else {
		float eps = 0.035;
		float dummy_m, dummy_r; vec3 dummy_e;
		float h_c = pat_height;
		float h_x, h_y, h_z;
		sample_skin_pattern(uv_pos + vec3(eps, 0.0, 0.0), v_triplanar_normal, skin_pattern_type, dummy_m, h_x, dummy_r, dummy_e);
		sample_skin_pattern(uv_pos + vec3(0.0, eps, 0.0), v_triplanar_normal, skin_pattern_type, dummy_m, h_y, dummy_r, dummy_e);
		sample_skin_pattern(uv_pos + vec3(0.0, 0.0, eps), v_triplanar_normal, skin_pattern_type, dummy_m, h_z, dummy_r, dummy_e);

		vec3 world_grad = vec3(h_x - h_c, h_y - h_c, h_z - h_c) / eps;
		vec3 view_grad = mat3(VIEW_MATRIX) * world_grad;
		NORMAL = normalize(NORMAL - view_grad * (0.09 * normal_scale));
	}

	// 4. Roughness e Metallic orgânicos
	float micro_rough = pat_height * 0.1;
	ROUGHNESS = clamp(roughness + pat_rough_bias + micro_rough, 0.05, 0.95);
	METALLIC = clamp(metallic + (skin_pattern_type == 5 ? 0.25 : 0.0), 0.0, 1.0);

	// 5. Oclusão de Cavidades da Pele (Ambient Cavity Occlusion)
	AO = clamp(0.70 + 0.30 * (1.0 - blend_factor * 0.4), 0.45, 1.0);
	AO_LIGHT_AFFECT = 0.55;

	// 6. Subsurface Scattering / Translucidez sem artefatos
	if (sss_strength > 0.0) {
		SSS_STRENGTH = sss_strength;
		SSS_TRANSMITTANCE_COLOR = sss_color;
		SSS_TRANSMITTANCE_DEPTH = sss_translucency;
		BACKLIGHT = sss_color.rgb * sss_translucency * 0.35;
	}
}
