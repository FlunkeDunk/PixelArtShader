shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

uniform float highlightThreshhold: hint_range(0.0, 1.0, 0.01) = 0.8;
uniform float shadowThreshhold: hint_range(0.0, 0.5, 0.01) = 0.1;

uniform sampler2D noiseMap: repeat_enable;
uniform sampler2D noiseNormalMap: repeat_enable;

uniform float heightScale = 1.0;

vec3 getNormal(vec2 uv, float texelSize) {
	float t = texture(noiseMap, uv + vec2(texelSize * vec2(0.0, -1.0))).r * heightScale;
	float r = texture(noiseMap, uv + vec2(texelSize * vec2(1.0, 0.0))).r * heightScale;
	float l = texture(noiseMap, uv + vec2(texelSize * vec2(-1.0, 0.0))).r * heightScale;
	float b = texture(noiseMap, uv + vec2(texelSize * vec2(0.0, 1.0))).r * heightScale;
	
	return normalize(vec3(2.0 * (r - l), 2.0 * (b - t), -4.0));
}
void vertex() {
	float noiseValue = texture(noiseMap, UV * 0.5).x * heightScale;
	VERTEX.y += noiseValue;
	NORMAL = getNormal(UV, 0.45);
	//NORMAL.z *= -1.0;
}

void fragment() {
	ALBEDO = NORMAL * 1.0;
	//ALBEDO.rg = UV;
	ALBEDO.g *= 0.0;
	//ALBEDO = vec3(1.0);
}

void light() {
	DIFFUSE_LIGHT = vec3(1.0);
}