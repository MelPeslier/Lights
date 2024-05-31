shader_type canvas_item;

const int WAVES_MAX = 10;
const float OUTER_LIMIT = 0.001;
const float INNER_LIMIT = 0.01;

group_uniforms Waves;
uniform vec3[WAVES_MAX] wave_colors;
uniform float[WAVES_MAX] wave_radius;
uniform float[WAVES_MAX] wave_outer_line_coefs;
uniform vec2[WAVES_MAX] wave_origins;
uniform float[WAVES_MAX] wave_current_radius;
uniform float[WAVES_MAX] wave_inner_radius;

uniform int actual_array_size = 1;

uniform sampler2D wave_mask_01 : hint_default_black;
uniform sampler2D wave_mask_02 : hint_default_black;
uniform sampler2D wave_mask_03 : hint_default_black;
uniform sampler2D wave_mask_04 : hint_default_black;
uniform sampler2D wave_mask_05 : hint_default_black;
uniform sampler2D wave_mask_06 : hint_default_black;
uniform sampler2D wave_mask_07 : hint_default_black;
uniform sampler2D wave_mask_08 : hint_default_black;
uniform sampler2D wave_mask_09 : hint_default_black;
uniform sampler2D wave_mask_10 : hint_default_black;


group_uniforms Darkness;
//uniform sampler2D inner_noise : hint_default_black;
uniform sampler2D darkness_noise : hint_default_black, repeat_enable;


group_uniforms world;
uniform float tex_tiling = 1.0;
uniform vec2 tex_size = vec2(512.0);
uniform sampler2D screen_tex : hint_screen_texture;


//float stroke(float _edge, float _aim, float _width){
	//return step(_edge, _aim + _width * 0.5) - step(_edge, _aim - _width * 0.5);
//}

float smooth_stroke(float _edge, float _aim, vec2 _width){
	float inner = smoothstep(_edge, _edge + _width.x, _aim);
	float outer = smoothstep(_edge - _width.y, _edge, _aim);
	return outer - inner;
}

varying vec2 world_pos; // Keep the variable for the fragment shader
void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy; // Get world position
}

void fragment() {
	vec2 tex_uv = tex_tiling / tex_size; // Define the uv size and stretch
	vec2 world_uv = tex_uv * world_pos; // Apply size to world position to get world_uv

	vec2 uv = UV ;
	uv = uv * 2.0 - 1.0;

	vec4 tex = texture( screen_tex, SCREEN_UV ); // maping our original  image to the screen_uv

	float all_baked_mask_for_darkness = 0.0;

	vec3 waves_output = vec3(0.0);
	for (int i = 0; i < actual_array_size; i++) {
		
	// * Captured Mask * : Darken non reachable areas (based on previous light mask capture and wave radius)
		vec2 uv_mask = ( ((uv - wave_origins[i]) / wave_radius[i]) + 1.0) / 2.0 ; // keep it at origin location and keep the right aspect
		float baked_mask = texture( wave_mask_01, uv_mask).r;
		if (i==1){
			baked_mask = texture( wave_mask_02, uv_mask).r;
		}else if (i == 2){
			baked_mask = texture( wave_mask_03, uv_mask).r;
		}else if (i == 3){
			baked_mask = texture( wave_mask_04, uv_mask).r;
		}else if (i == 4){
			baked_mask = texture( wave_mask_05, uv_mask).r;
		}else if (i == 5){
			baked_mask = texture( wave_mask_06, uv_mask).r;
		}else if (i == 6){
			baked_mask = texture( wave_mask_07, uv_mask).r;
		}else if (i == 7){
			baked_mask = texture( wave_mask_08, uv_mask).r;
		}else if (i == 8){
			baked_mask = texture( wave_mask_09, uv_mask).r;
		}else if (i == 9){
			baked_mask = texture( wave_mask_10, uv_mask).r;
		}
		uv_mask = (uv - wave_origins[i]) ;
		baked_mask = mix(0.0, baked_mask,
			step(uv_mask.x + INNER_LIMIT, wave_radius[i] - OUTER_LIMIT) * step(-wave_radius[i] + OUTER_LIMIT, uv_mask.x - INNER_LIMIT) *
			step(uv_mask.y + INNER_LIMIT, wave_radius[i] - OUTER_LIMIT) * step(-wave_radius[i] + OUTER_LIMIT, uv_mask.y - INNER_LIMIT)
		); // make what's outdise of the mask texture black per default of the texture : no reapeat and so we want black
		// 0.01 threshold to erase all abnormalities in borders
		//COLOR.rgb += baked_mask; // Debug

	// * World mask * : Circle visible
		float circle_sdf = length(uv - wave_origins[i] ) / wave_radius[i] ; // divide length(...) by  radius / screen.x
		float outer_edge = step(circle_sdf, wave_current_radius[i]); // TODO : make smoothstep
		float inner_edge = smoothstep(circle_sdf, 0.0, wave_inner_radius[i]);
		inner_edge = pow(inner_edge, 0.5);
		float inner_part = min(inner_edge, outer_edge);
		float world_mask = inner_part;

		//baked_mask *= circle_sdf
		all_baked_mask_for_darkness += world_mask * baked_mask;
		all_baked_mask_for_darkness = clamp(all_baked_mask_for_darkness, 0.0, 1.0);

		// Mask inner part with a noise # TODO
		vec3 world_output = tex.rgb * world_mask * baked_mask * wave_colors[i];

	// * Outer Line *

		float outer_line_mask = pow( smooth_stroke(circle_sdf, wave_current_radius[i], wave_outer_line_coefs[i] * vec2(1.0, 0.25)), 2.0);
		float line_fade_out = smoothstep(1.0, 0.75, wave_current_radius[i]);
		vec3 wave_output = wave_colors[i] * outer_line_mask * baked_mask * line_fade_out;

		vec3 world_wave = mix(world_output, wave_output, outer_line_mask * line_fade_out);

		waves_output += world_wave;
	}
	// * Darkness *
	// Local player mask so darkness isn't on top of him
		vec3 darkness_output = texture(darkness_noise, world_uv).rgb;
		
	COLOR.rgb = mix(waves_output, darkness_output, 1.0-all_baked_mask_for_darkness);
	//COLOR.rgb = waves_output;

}

