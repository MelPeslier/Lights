shader_type canvas_item;

group_uniforms Waves;
uniform float wave_radius = 0.5;
uniform float wave_outer_line_coefs = 0.05;
uniform float wave_current_radius;
uniform float wave_inner_radius;


float smooth_stroke(float _edge, float _aim, vec2 _width){
	float inner = smoothstep(_edge, _edge + _width.x, _aim);
	float outer = smoothstep(_edge - _width.y, _edge, _aim);
	return outer - inner;
}

void fragment() {
// * Center UV *
	vec2 uv = UV ;
	uv = uv * 2.0 - 1.0;

// * World mask * : Circle visible
	float circle_sdf = length(uv) / wave_radius ; // divide length(...) by  radius / screen.x
	float outer_edge = step(circle_sdf, wave_current_radius); // TODO : make smoothstep
	float inner_edge = smoothstep(circle_sdf, 0.0, wave_inner_radius);
	inner_edge = pow(inner_edge, 0.5);
	float inner_part = min(inner_edge, outer_edge);

// * Outer Line *
	float outer_line_mask = pow( smooth_stroke(circle_sdf, wave_current_radius, wave_outer_line_coefs * vec2(1.0, 0.25)), 2.0);
	float line_fade_out = smoothstep(1.0, 0.75, wave_current_radius);
	float wave_output = outer_line_mask * line_fade_out;
	
	COLOR.rgb = vec3( inner_part + wave_output ) ;
	LIGHT_VERTEX.rgb = vec3( inner_part + wave_output );
}

