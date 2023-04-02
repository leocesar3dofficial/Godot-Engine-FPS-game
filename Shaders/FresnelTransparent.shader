shader_type spatial;
render_mode blend_add, cull_disabled, unshaded;


uniform vec4 albedo_color : hint_color = vec4(1, 0.95, 0.9, 1);
uniform bool invert = true;
uniform float fresnel_power = 6;
uniform float proximity_fade_distance = 1;
uniform float transparency_factor = 0.3;
uniform float distance_fade_max = 1;


void fragment() {
// ColorUniform:5
	vec3 n_out5p0 = albedo_color.rgb;
	float n_out5p1 = albedo_color.a;

// BooleanUniform:7
	bool n_out7p0 = invert;

// ScalarUniform:8
	float n_out8p0 = fresnel_power;

// Fresnel:3
	float n_out3p0 = n_out7p0 ? (pow(clamp(dot(NORMAL, VIEW), 0.0, 1.0), n_out8p0)) : (pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), n_out8p0));

// ScalarUniform:6
	float n_out6p0 = transparency_factor;

// ScalarOp:4
	float n_out4p0 = n_out3p0 * n_out6p0;

// Output:0
	ALBEDO = n_out5p0;
	ALPHA = n_out4p0;
	float depth_tex = textureLod(DEPTH_TEXTURE,SCREEN_UV, 0.0).r;
	vec4 world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV* 2.0 - 1.0,depth_tex * 2.0 - 1.0, 1.0);
	world_pos.xyz /= world_pos.w;
	ALPHA*=clamp(1.0 - smoothstep(world_pos.z + proximity_fade_distance,world_pos.z, VERTEX.z), 0.0, 1.0);
	ALPHA*=clamp(smoothstep(0, distance_fade_max, -VERTEX.z), 0.0, 1.0);
}