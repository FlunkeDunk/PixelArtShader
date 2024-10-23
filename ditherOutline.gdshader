shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D normal_texture : hint_normal_roughness_texture, repeat_disable, filter_nearest;


uniform sampler2D colorPallette : filter_nearest;
uniform float colorCount;
uniform float ditherSpread : hint_range(0.0, 1.0, 0.01);
uniform float backgroundDistance : hint_range(0.0, 10000.0, 1.0);
uniform float outlineThreshhold : hint_range(0.0, 10.0, 0.01) = 0.01;
uniform float outlineDarkness: hint_range(0.0, 1.0, 0.01) = 0.2;
uniform float inlineLight: hint_range(1.0, 5.0, 0.01) = 1.5;
uniform float normalThreshhold: hint_range(0.0, 10.0, 0.1) = 1.0;
uniform vec3 normalEdgeBias;

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


const int[64] ditherTable = int[](
	
     0, 32,  8, 40,  2, 34, 10, 42,
    48, 16, 56, 24, 50, 18, 58, 26,  
    12, 44, 4,  36, 14, 46,  6, 38, 
    60, 28, 52, 20, 62, 30, 54, 22,  
     3, 35, 11, 43,  1,  33, 9, 41,  
    51, 19, 59, 27, 49, 17, 57, 25, 
    15, 47,  7, 39, 13, 45,  5, 37, 
    63, 31, 55, 23, 61, 29, 53, 21
	
);
const float ditherTableDimension = 8.0;

vec3 getClosestColor(vec3 originalColor){
	float minimumDistance = 10000000.0;
	vec3 closestColor = vec3(1.0);
	
	for(int i = 0; i < int(colorCount); i++) {
		vec3 testColor = texture(colorPallette, vec2(float(i) / colorCount, 0.0)).rgb;
		float tempDistance = distance(testColor, originalColor);
		bool isCloser = tempDistance < minimumDistance;
		closestColor = testColor * float(isCloser) + closestColor * float(!isCloser);
		minimumDistance = min(minimumDistance, tempDistance);
	}
	
	return vec3(closestColor);
}


float dither(vec2 uv, vec2 screenSize){
	vec2 screenCoord = uv * screenSize;
	ivec2 thresholdMapCoord = ivec2(mod(screenCoord, ditherTableDimension));
	int thresholdMapValue = ditherTable[thresholdMapCoord.x + thresholdMapCoord.y * int(ditherTableDimension)];
	float dither = float(thresholdMapValue) / 64.0 - 0.5;
	return dither * ditherSpread;
}


void fragment() {
    vec3 color = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	float dither = dither(SCREEN_UV, VIEWPORT_SIZE);
	float depth = getDepth(SCREEN_UV, INV_PROJECTION_MATRIX);
	vec3 normal = getNormal(SCREEN_UV);
	
	vec2 texelSize = 0.5 / VIEWPORT_SIZE;
	
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
		
		depthDifference += distance(tempDepth, depth);
		vec3 normalDifference = normal - tempNormal;
		float normalBiasDiff = dot(normalDifference, normalEdgeBias);
		float normalIndicator = smoothstep(0.01, 0.01, normalBiasDiff);
		
		normalSum += dot(normalDifference, normalDifference) * normalIndicator;
	}
	
	bool isInline = normalSum > normalThreshhold;
	bool isOutline = depthDifference > outlineThreshhold;
	
	vec3 nearestColor = textureLod(screen_texture, nearestUV, 0.0).rgb;
	depthDifference = float(isOutline);
	vec3 colorFromPallette;
	if(isOutline) {
	colorFromPallette = getClosestColor(mix(color, nearestColor * outlineDarkness, depthDifference));
	}
	else if(isInline){
		colorFromPallette = getClosestColor(mix(color, color * inlineLight, normalThreshhold));
	}
	else{
		colorFromPallette = getClosestColor(color);
	}
	
	bool isBackground = depth > backgroundDistance && !isOutline;
	
	vec3 characterColor = float(!isBackground) * colorFromPallette;
	
	vec3 backgroundColor =  float(isBackground) * floor(mod(UV.x * VIEWPORT_SIZE.x / 2.0 + floor(mod(UV.y * VIEWPORT_SIZE.y / 2.0, 2.0)), 2.0)) * vec3(0.4);
	
	ALBEDO = characterColor + backgroundColor;
	}