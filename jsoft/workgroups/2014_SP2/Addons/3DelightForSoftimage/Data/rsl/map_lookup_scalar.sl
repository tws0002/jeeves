/*
	Copyright (c) TAARNA Studios International.
*/

#ifndef __map_lookup_scalar_sl
#define __map_lookup_scalar_sl

void map_lookup_scalar(
	float i_scalar;
	float i_factor;
	
	output float o_result;)
{
	o_result = i_scalar * i_factor;
}

void map_lookup_scalar(
	point i_p;
	float i_factor;
	
	output float o_result;)
{
	o_result = (i_p[0] + i_p[1] + i_p[2]) * i_factor * 1/3;
}

void map_lookup_scalar(
	string i_texture;
	point i_map;
	float i_factor;
	
	output float o_result;)
{
	if(i_texture == "")
	{
		map_lookup_scalar(i_map, i_factor, o_result);
	}
	else
	{
		color tex = texture(i_texture, i_map[0], 1-i_map[1]);
		o_result = (tex[0] + tex[1] + tex[2]) * i_factor * 1/3;
	}
}

void map_lookup_scalar(
	string i_texture;
	color i_map;
	float i_factor;
	
	output float o_result;)
{
	point map = point( i_map[0], i_map[1], i_map[2] );
	map_lookup_scalar( i_texture, map, i_factor, o_result);
}

void map_lookup_scalar(
	RGBA_DECLARE( i_c );
	float i_factor;

	output float o_result; )
{
	o_result = (i_c[0] + i_c[1] + i_c[2]) * i_factor * 1/3;
}
#endif
