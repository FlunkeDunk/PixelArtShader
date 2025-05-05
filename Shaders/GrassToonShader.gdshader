// NOTE: Shader automatically converted from Godot Engine 4.3.stable's StandardMaterial3D.

shader_type spatial;
render_mode depth_draw_opaque, cull_back;

uniform vec3 highlightColor : source_color = vec3(0.45, 0.74, 0.82);
uniform vec3 midToneColor : source_color = vec3(0.23, 0.36, 0.54);
uniform vec3 shadowColor : source_color = vec3(0.09, 0.12, 0.21);

uniform float highlightThreshhold: hint_range(0.0, 1.0, 0.01) = 0.8;
uniform float shadowThreshhold: hint_range(0.0, 0.5, 0.01) = 0.1;

uniform sampler2D texture_albedo : source_color, filter_nearest, repeat_enable;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

varying vec3 viewNormal;

void vertex() {
	// Billboard Mode: Enabled
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			MAIN_CAM_INV_VIEW_MATRIX[0],
			MAIN_CAM_INV_VIEW_MATRIX[1],
			MAIN_CAM_INV_VIEW_MATRIX[2],
			MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	  // Convert the world normal to view (camera) space
    vec3 view_normal = (VIEW_MATRIX * vec4(INSTANCE_CUSTOM.rgb, 0.0)).xyz;

    // Normalize the result, as screen normals should be normalized
    //view_normal = normalize(view_normal);

	viewNormal = view_normal;
}

void fragment() {
	ALBEDO = vec3(1.0);
	//ALBEDO = viewNormal;
	vec4 albedo_tex = texture(texture_albedo, UV);
	ALPHA *= albedo_tex.a;
}

void light() {
	float lightValue = clamp(dot(viewNormal, LIGHT) * ATTENUATION, 0.0, 1.0);
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
