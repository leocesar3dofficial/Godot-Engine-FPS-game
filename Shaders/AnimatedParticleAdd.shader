shader_type spatial;
render_mode blend_add, cull_disabled, diffuse_toon, specular_disabled, shadows_disabled, unshaded;


uniform sampler2D albedo_texture;
uniform vec4 albedo_color : hint_color = vec4(1);
uniform vec3 speed = vec3(0.0, 1.0, 0.0);
uniform vec4 emission : hint_color = vec4(0, 0, 0, 1);
uniform vec2 tiling = vec2(1.0, 1.0);


void fragment() {
// Input:10
	float n_out10p0 = TIME;

// VectorOp:11
	vec3 n_in11p1 = speed;
	vec3 n_out11p0 = vec3(n_out10p0) * n_in11p1;

// Input:8
	vec3 n_out8p0 = vec3(UV * tiling, 0.0);

// VectorOp:3
	vec3 n_out3p0 = n_out11p0 + n_out8p0;

// Texture:9
	vec4 tex_frg_9_read = texture(albedo_texture, n_out3p0.xy);
	vec3 n_out9p0 = tex_frg_9_read.rgb;

// Color:12
	vec3 n_out12p0 = vec3(1.000000, 0.539063, 0.000000);
	float n_out12p1 = 1.000000;

// ColorOp:13
	vec3 n_out13p0;
	{
		float base = n_out9p0.x;
		float blend = n_out12p0.x;
		if (base < 0.5) {
			n_out13p0.x = 2.0 * base * blend;
		} else {
			n_out13p0.x = 1.0 - 2.0 * (1.0 - blend) * (1.0 - base);
		}
	}
	{
		float base = n_out9p0.y;
		float blend = n_out12p0.y;
		if (base < 0.5) {
			n_out13p0.y = 2.0 * base * blend;
		} else {
			n_out13p0.y = 1.0 - 2.0 * (1.0 - blend) * (1.0 - base);
		}
	}
	{
		float base = n_out9p0.z;
		float blend = n_out12p0.z;
		if (base < 0.5) {
			n_out13p0.z = 2.0 * base * blend;
		} else {
			n_out13p0.z = 1.0 - 2.0 * (1.0 - blend) * (1.0 - base);
		}
	}

// Output:0
	ALBEDO = n_out13p0 * albedo_color.rgb;
	ALPHA = albedo_color.a;
	EMISSION = emission.rgb * tex_frg_9_read.rgb;
}