shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;
uniform vec3 highlightColor : source_color = vec3(0.45, 0.74, 0.82);
uniform vec3 midToneColor : source_color = vec3(0.23, 0.36, 0.54);
uniform vec3 shadowColor : source_color = vec3(0.09, 0.12, 0.21);

void fragment() {
	ALBEDO = vec3(1.0);
}

void light() {
	float lightValue = clamp(dot(NORMAL, LIGHT) * ATTENUATION, 0.0, 1.0);
	vec3 light;
	if(lightValue < 0.1) {
		light = shadowColor;
	} else if(lightValue > 0.8){
		light = highlightColor;
	} else {
		light = midToneColor;
	}
	DIFFUSE_LIGHT = light;
}
