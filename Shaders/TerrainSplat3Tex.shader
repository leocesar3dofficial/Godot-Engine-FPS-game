shader_type spatial;


uniform vec4 albedo_color : hint_color = vec4(1);
//texture repeating value.
uniform float tex0_repeat = 5;
uniform float tex1_repeat = 5;
uniform float tex2_repeat = 5;
//normalmap depth adjustment.
uniform float normalmap_depth = 1;
//metallic adjustment.
uniform float tex0_metallic = 0;
uniform float tex1_metallic = 0;
uniform float tex2_metallic = 0;
//texture for masking.
uniform sampler2D mask;
//texture slot 1.
uniform sampler2D tex0_albedo : hint_albedo;
uniform sampler2D tex0_roughness;
uniform sampler2D tex0_normalmap : hint_normal;
//texture slot 2.
uniform sampler2D tex1_albedo : hint_albedo;
uniform sampler2D tex1_roughness;
uniform sampler2D tex1_normalmap : hint_normal;
//texture slot 3.
uniform sampler2D tex2_albedo : hint_albedo;
uniform sampler2D tex2_roughness;
uniform sampler2D tex2_normalmap : hint_normal;


//fragment shader start.
void fragment()
{
	//mask.
	vec3 splat = texture(mask, UV).rgb;
	//albedo textures.
	vec3 color1 = texture(tex0_albedo, UV * tex0_repeat).rgb * splat.r;
	vec3 color2 = texture(tex1_albedo, UV * tex1_repeat).rgb * splat.g;
	vec3 color3 = texture(tex2_albedo, UV * tex2_repeat).rgb * splat.b;
	//roughness textures.
	float color1_r = texture(tex0_roughness, UV * tex0_repeat).r * splat.r;
	float color2_r = texture(tex1_roughness, UV * tex1_repeat).r * splat.g;
	float color3_r = texture(tex2_roughness, UV * tex2_repeat).r * splat.b;
	//normalmap textures.
	vec3 color1_n = texture(tex0_normalmap, UV * tex0_repeat).rgb * splat.r;
	vec3 color2_n = texture(tex1_normalmap, UV * tex1_repeat).rgb * splat.g;
	vec3 color3_n = texture(tex2_normalmap, UV * tex2_repeat).rgb * splat.b;
	//final render.	
	ALBEDO = (color1 + color2 + color3) * albedo_color.rgb;
	ROUGHNESS = color1_r + color2_r + color3_r;
	METALLIC = (tex0_metallic * splat.r) + (tex1_metallic * splat.g) + (tex2_metallic * splat.b);
	NORMALMAP = color1_n + color2_n + color3_n;
	NORMALMAP_DEPTH = normalmap_depth;
}