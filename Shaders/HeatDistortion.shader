shader_type spatial;
render_mode unshaded, cull_disabled;


uniform sampler2D normalMap : hint_normal;
uniform float normalStrength : hint_range(0.0, 1.0);
uniform vec2 normalTiling = vec2(1.0, 1.0);
uniform vec2 normalOffset = vec2(0.0, 0.0);
uniform float proximity_fade_distance = 1;
uniform float distance_fade_max = 1;


void fragment(){
vec2 uvModifier = (texture(normalMap, (UV * normalTiling) + (normalOffset * TIME)).xy * normalStrength) - normalStrength * 0.5;
vec3 color = texture(SCREEN_TEXTURE, SCREEN_UV + uvModifier).rgb;
ALBEDO = color;
float depth_tex = textureLod(DEPTH_TEXTURE,SCREEN_UV, 0.0).r;
vec4 world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV* 2.0 - 1.0,depth_tex * 2.0 - 1.0, 1.0);
world_pos.xyz /= world_pos.w;
ALPHA*=clamp(1.0 - smoothstep(world_pos.z + proximity_fade_distance,world_pos.z, VERTEX.z), 0.0, 1.0);
ALPHA*=clamp(smoothstep(0, distance_fade_max, -VERTEX.z), 0.0, 1.0);
}