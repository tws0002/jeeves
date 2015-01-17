/*
	Copyright (c) DNA Research.
*/

#ifndef __map_lookup_color_sl
#define __map_lookup_color_sl

void map_lookup_color(
	point i_p;
	float i_factor;
	
	RGBA_DECLARE_OUTPUT(o_result);)
{
	o_result = color(i_p[0], i_p[1], i_p[2]);
	o_result_a = 1.0;
}

void map_lookup_color(
	string i_texture;
	point i_uvw;
	float i_factor;
	
	RGBA_DECLARE_OUTPUT(o_result);)
{
	if(i_texture == "")
	{
		map_lookup_color(i_uvw, i_factor, RGBA_USE(o_result));
	}
	else
	{
		color tex = texture(i_texture, i_uvw[0], 1-i_uvw[1]);
		o_result = tex * i_factor;
	}
}

void map_lookup_color(
	string i_texture;
	color i_uvw;
	float i_factor;
	
	RGBA_DECLARE_OUTPUT(o_result);)
{
	map_lookup_color(
		i_texture,
		point(i_uvw[0], i_uvw[1], i_uvw[2]),
		i_factor,
		RGBA_USE( o_result ) );
}

void map_lookup_color(
	color i_uvw;
	float i_factor;
	
	RGBA_DECLARE_OUTPUT(o_result);)
{
	map_lookup_color(
		point(i_uvw[0], i_uvw[1], i_uvw[2]),
		i_factor,
		RGBA_USE( o_result ) );
}

#endif // __map_lookup_color_sl
