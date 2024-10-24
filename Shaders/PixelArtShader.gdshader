shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D normal_texture : hint_normal_roughness_texture, repeat_disable, filter_nearest;

uniform float outlineThreshold: hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float inlineThreshold: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform vec3 normalEdgeBias = vec3(1.0);

float getDepth(vec2 screen_uv, mat4 invProjectionMatrix) {
	float depth = texture(depth_texture, screen_uv).r;
	vec3 ndc = vec3(screen_uv * 2.0 - 1.0, depth);
	vec4 view = invProjectionMatrix * vec4(ndc, 1.0);
	view.xyz /= view.w;
	return -view.z;
}

vec3 getNormal(vec2 screen_uv) {
	vec3 normal = texture(normal_texture, screen_uv).rgb * 2.0 - 1.0; 
	
	return normal;
}

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec3 original = texture(screen_texture, SCREEN_UV).rgb;
	float depth = getDepth(SCREEN_UV, INV_PROJECTION_MATRIX);
	vec3 normal = getNormal(SCREEN_UV);
	
	vec2 texelSize = 1.0 / VIEWPORT_SIZE;
	texelSize = 1.0 / VIEWPORT_SIZE;
	
	vec2 borderUvs[4];
	borderUvs[0] = vec2(SCREEN_UV.x, SCREEN_UV.y + texelSize.y);
	borderUvs[1] = vec2(SCREEN_UV.x, SCREEN_UV.y - texelSize.y);
	borderUvs[2] = vec2(SCREEN_UV.x + texelSize.x, SCREEN_UV.y);
	borderUvs[3] = vec2(SCREEN_UV.x - texelSize.x, SCREEN_UV.y);
	
	
	float depthDifference = 0.0;
	float normalSum = 0.0;
	vec2 nearestUV;
	float nearestDepth = depth;
	
	for(int i = 0; i < 4; i++) {
		float tempDepth = getDepth(borderUvs[i], INV_PROJECTION_MATRIX);
		vec3 tempNormal = getNormal(borderUvs[i]);
		 
		
		if(tempDepth < nearestDepth){
			nearestDepth = tempDepth;
			nearestUV = borderUvs[i];
		}
		
		//depthDifference += depth - tempDepth;
		depthDifference += tempDepth - depth;
		
		vec3 normalDifference = normal - tempNormal;
		//vec3 normalDifference = tempNormal - normal;
		float normalBiasDiff = dot(normalDifference, normalEdgeBias);
		float normalIndicator = smoothstep(0.01, 0.01, normalBiasDiff);
		
		normalSum += dot(normalDifference, normalDifference) * normalIndicator;
	}
	
	float outlineValue = step(outlineThreshold, depthDifference);
	float inlineValue = step(inlineThreshold, sqrt(normalSum));
	inlineValue *= step(0.0, depthDifference);
	vec3 edgeMix;
	if(outlineValue > 0.0){
		edgeMix = mix(original, original * 0.4, outlineValue);
	} else {
		edgeMix = mix(original, original * 2.0, inlineValue);
	}
	ALBEDO = edgeMix;
	//ALBEDO = vec3(inlineValue);
}
