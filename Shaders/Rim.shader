shader_type spatial;
render_mode cull_back;


uniform vec4 color : hint_color;
uniform float rimWidth : hint_range(0.0, 1.0) = 0.5;


void fragment(){
ROUGHNESS = rimWidth; //Play with this value
RIM = 1.0;
ALBEDO = vec3(color[0],color[1],color[2]);
ALPHA = color[3];
}