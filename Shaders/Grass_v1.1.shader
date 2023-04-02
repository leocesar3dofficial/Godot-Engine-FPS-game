shader_type spatial;
render_mode cull_disabled, depth_draw_opaque, skip_vertex_transform, unshaded;

uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0) = 0.4;

// Wind settings.
uniform float speed = 0.5;
uniform float minStrength : hint_range(0.0, 1.0) = 0.2;
uniform float maxStrength : hint_range(0.0, 1.0) = 0.6;
uniform float interval = 3.5;
uniform float detail = 3.0;
uniform float distortion : hint_range(0.0, 1.0);
uniform vec2 direction = vec2(1.0, 0.0);
uniform float heightOffset = 0.0;

// UV Uniforms must be after other uniforms because there is a bug with vec3. 
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

vec3 getWind(mat4 worldMatrix, vec3 vertex, float timer){
	vec4 pos = worldMatrix * mix(vec4(1.0), vec4(vertex, 1.0), distortion);
	float time = timer * speed + pos.x + pos.z;
	float diff = pow(maxStrength - minStrength, 2);
	float strength = clamp(minStrength + diff + sin(time / interval) * diff, minStrength, maxStrength);
	float wind = (sin(time) + cos(time * detail)) * strength * max(0.0, vertex.y - heightOffset);
	vec2 dir = normalize(direction);
	
	return vec3(wind * dir.x, 0.0, wind * dir.y);
	}

void vertex() {
	vec4 worldPos = WORLD_MATRIX * vec4(VERTEX, 1.0);
	worldPos.xyz += getWind(WORLD_MATRIX, VERTEX, TIME);
	VERTEX = (INV_CAMERA_MATRIX * worldPos).xyz;
	NORMAL = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA = albedo.a * albedo_tex.a;
	ALPHA_SCISSOR = alpha_scissor_threshold;
}
