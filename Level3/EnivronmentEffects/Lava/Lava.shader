shader_type canvas_item;
uniform sampler2D lava_offset_texture;
uniform sampler2D lava_mask;
uniform vec2 uv_offset_scale = vec2(1.0, 1.0);
uniform vec2 lump_size = vec2(0.1, 0.1);
uniform vec2 lava_cut_off = vec2(.25, .75);

float MaskCut (vec2 uv)
{
	vec4 lava_mask_cutout = texture(lava_mask, uv);
	float mask = lava_mask_cutout.r;
	return mask;
}

float Mask (vec2 uv) 
{
	//float area = smoothstep(0.01, 0.04, uv.y);
	float area = step(lava_cut_off.x, uv.y);
	area *= step(uv.y, lava_cut_off.y);
	//area *= smoothstep(0.99, 0.96, uv.y);
	//float mask = step(1.2, 1.1);
	//mask *= smoothstep(.25, .3, length(uv * 0.5));
	return area;
	
}

void fragment() 
{
	float t = TIME;
	
	vec2 offset_texture_uvs = UV * uv_offset_scale;
	
	vec2 texture_based_offset = texture(lava_offset_texture, offset_texture_uvs).rg;
	texture_based_offset = texture_based_offset * 2.0 - 1.0;
	
	vec3 intensity = vec3(0.5);
	intensity *= sin(t) * 0.3 + 0.3;
	float intensity_offset = UV.x - 1.0;
	intensity *= sin(intensity_offset * 20.0 + t * 1.5) + 1.0;
	
	vec2 offs = vec2( sin(t + UV.y * 100.0) * 0.3, sin(t + UV.x * 100.0) * 0.4) * 0.01;
	offs += vec2(t * 0.01, 0.0);
	vec4 texture_color = texture(TEXTURE, UV + texture_based_offset * lump_size + offs);
	
	COLOR = texture_color + texture_color * vec4(intensity,1.0);
	//COLOR.a *= MaskCut(UV);
}