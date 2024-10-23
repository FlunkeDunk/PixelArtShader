shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D colorPallette : filter_nearest;
uniform float colorCount;
uniform float downScaleFactor;
uniform float ditherSpread;
uniform vec2 screenSize;

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
	float minimumDistance = 10000.0;
	vec3 closestColor = vec3(1.0);
	
	for(int i = 0; i < int(colorCount); i++) {
		vec3 testColor = texture(colorPallette, vec2(float(i) / colorCount, 0.0)).rgb;
		float tempDistance = 0.0;
		tempDistance += 2.5 * abs(originalColor.r * originalColor.r - testColor.r * testColor.r);
		tempDistance += 1.0 * abs(originalColor.g * originalColor.g - testColor.g * testColor.g);
		tempDistance += 1.0 * abs(originalColor.b * originalColor.b - testColor.b * testColor.b);
		bool isCloser = tempDistance < minimumDistance;
		closestColor = testColor * float(isCloser) + closestColor * float(!isCloser);
		minimumDistance = min(minimumDistance, tempDistance);
	}
	
	return vec3(closestColor);
}


float dither(vec2 uv){
	vec2 screenCoord = floor(uv * screenSize / downScaleFactor + 0.5);
	ivec2 thresholdMapCoord = ivec2(mod(screenCoord, ditherTableDimension));
	int thresholdMapValue = ditherTable[thresholdMapCoord.x + thresholdMapCoord.y * int(ditherTableDimension)];
	float dither = float(thresholdMapValue) / 64.0 - 0.5;
	return dither * ditherSpread;
}

void fragment() {
	vec2 downScaleSize = screenSize / downScaleFactor;
	vec2 downScaledScreenUV = floor(SCREEN_UV * downScaleSize + 0.5) / downScaleSize;
    vec3 color;
	color = textureLod(screen_texture, downScaledScreenUV, 0.0).rgb + dither(UV);
	color = getClosestColor(color);
	COLOR = vec4(color, 1.0);
}