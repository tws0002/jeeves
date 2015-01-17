/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_texture3Dwarp_sl
#define __sib_texture3Dwarp_sl

void sib_texture3Dwarp(
	point i_texture_coord, i_noise_coord;
	float i_intensity, i_scale;

	output point o_result )
{
	vector noise_value = (noise(i_noise_coord*i_scale)-point(0.5))*2;
	noise_value *= i_intensity;
	
	o_result = noise_value + i_texture_coord;
}
#endif
