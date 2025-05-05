shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;
uniform vec3 highlightColor : source_color = vec3(0.45, 0.74, 0.82);
uniform vec3 midToneColor : source_color = vec3(0.23, 0.36, 0.54);
uniform vec3 shadowColor : source_color = vec3(0.09, 0.12, 0.21);

uniform float highlightThreshhold: hint_range(0.0, 1.0, 0.01) = 0.8;
uniform float shadowThreshhold: hint_range(0.0, 0.5, 0.01) = 0.1;

uniform sampler2D noiseMap: repeat_enable;
uniform sampler2D noiseNormalMap: repeat_enable;

void vertex() {
	float noiseValue = texture(noiseMap, UV).x;
	VERTEX.y += noiseValue;
	vec3 worldNormal = normalize(texture(noiseNormalMap, UV).xzy * 2.0 - 1.0);
	worldNormal.z *= -1.0;
	//NORMAL = texture(noiseNormalMap, UV).rgb;
	vec3 viewNormal = (VIEW_MATRIX * vec4(worldNormal, 0.0)).xyz;
	NORMAL = viewNormal;
}

void fragment() {
	ALBEDO = vec3(1.0);
}

void light() {
	float lightValue = clamp(dot(NORMAL, LIGHT) * ATTENUATION, 0.0, 1.0);
	vec3 light;
	if(lightValue < shadowThreshhold) {
		light = shadowColor;
	} else if(lightValue > highlightThreshhold){
		light = highlightColor;
	} else {
		light = midToneColor;
	}
	DIFFUSE_LIGHT = light;
}