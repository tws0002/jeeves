/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __simple_aniward_sl
#define __simple_aniward_sl

#include "sib_illum_aniward.sl"

void simple_aniward(
	RGBA_COLOR( i_ambient );
	RGBA_COLOR( i_ambience );
	RGBA_COLOR( i_diffuse );
	RGBA_COLOR( i_glossy );
	
	float i_shiny_u, i_shiny_v;	

	RGBA_COLOR( i_image );
	float i_surfderiv_mode;

	RGBA_COLOR( i_radiance );
	
	output color o_result;
	output float o_result_a )
{
	extern normal N;
	extern vector dPdu, dPdv;

	vector x_dir = normalize(dPdu);
	vector y_dir = normalize(N^x_dir);

	sib_illum_aniward( SIB_ILLUM_PARAMS_LIST, point(x_dir), point(y_dir),
		RGBA_COLOR_PARAM(i_radiance), 0 /* filter radiance */, o_result, o_result_a ); 	
}

void simple_aniward(
	RGBA_COLOR( i_ambient );
	RGBA_COLOR( i_diffuse );
	RGBA_COLOR( i_glossy );
	
	float i_shiny_u, i_shiny_v;	

	RGBA_COLOR( i_image );
	float i_surfderiv_mode;

	RGBA_COLOR( i_radiance );
	
	output color o_result;
	output float o_result_a )
{
	extern normal N;
	extern vector dPdu, dPdv;

	vector x_dir = normalize(dPdu);
	vector y_dir = normalize(N^x_dir);

	sib_illum_aniward( SIB_ILLUM_PARAMS_LIST, point(x_dir), point(y_dir),
		RGBA_COLOR_PARAM(i_radiance), 0 /* filter radiance */, o_result, o_result_a ); 	
}
#endif
