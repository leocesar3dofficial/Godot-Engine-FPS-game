shader_type spatial;
render_mode shadows_disabled, cull_disabled;

uniform vec4 lightning_color: hint_color;
uniform vec4 emission_color: hint_color;

uniform float size: hint_range (0.,1.);
uniform float width: hint_range (0.,1.);
uniform float speed;
uniform float cycle;
uniform float ratio;
uniform float time_shift;
const float PI = 3.14159265359;

float rand(float x){
	return fract(sin(x)*100000.0);
}

void fragment(){
	float bolt = abs(mod(UV.y * cycle + (rand(TIME) + time_shift) * speed * -1., 0.5)-0.25)-0.125;
	bolt *= 4. * rand(width);
	// why 4 ? Because we use mod 0.5, the value be devide by half
	// and we -0.25 (which is half again) for abs function. So it 25%!
	
	// scale down at start and end
	bolt *=  (0.5 - abs(UV.y-0.5)) * 2.; 
	
	// turn to a line
	// center align line
	float wave = abs(UV.x - 0.5 + bolt);
	// invert and ajust size
	wave = 1. - step(size*.5, wave);
	
	float blink = step(rand(TIME)*ratio, .5);
	wave *= blink;
	
	vec3 display = vec3(lightning_color.r, lightning_color.g, lightning_color.b) * vec3(wave);
	vec3 display_emission = vec3(emission_color.r, emission_color.g, emission_color.b) * vec3(wave);
	
	ALBEDO = display;
	EMISSION = display_emission * 0.8;
	ALPHA = lightning_color.a * wave;
}
