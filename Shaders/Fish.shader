shader_type spatial;
render_mode unshaded;

uniform sampler2D texture_albedo : hint_albedo;
uniform float time_scale = 2.0;
uniform float side_to_side = 0.5;
uniform float pivot = 1.0;
uniform float wave = 0.5;
uniform float twist = 1.0;
uniform float mask_black = 0.0;
uniform float mask_white = 1.0;


void vertex() {
	float time = TIME * time_scale;
	//angle is scaled by 0.1 so that the fish only pivots and doesn't rotate all the way around
	float pivot_angle = cos(time) * 0.1 * pivot;
	mat2 rotation_matrix = mat2(vec2(cos(pivot_angle), -sin(pivot_angle)), vec2(sin(pivot_angle), cos(pivot_angle)));
	
	float body = (VERTEX.z + 1.0) / 2.0; //for a fish centered at (0, 0) with a length of 2
	
	float twist_angle = cos(time + body) * 0.3 * twist;
	mat2 twist_matrix = mat2(vec2(cos(twist_angle), -sin(twist_angle)), vec2(sin(twist_angle), cos(twist_angle)));
	
	//mask_black and mask_white are uniforms
	float mask = smoothstep(mask_black, mask_white, 1.0 - body);
	
	VERTEX.x += cos(time) * side_to_side;
	VERTEX.xz = rotation_matrix * VERTEX.xz;
	VERTEX.x += cos(time + body) * mask * wave;
	//twist motion with mask
	VERTEX.xy = mix(VERTEX.xy, twist_matrix * VERTEX.xy, mask);
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo_tex.rgb;
}
