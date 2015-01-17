/*
	Copyright (c) 2011 DNA Research.
*/

#ifndef __misss_lambert_gamma_sl
#define __misss_lambert_gamma_sl

#include "xsi_illum.h"

void misss_lambert_gamma(
	RGBA_COLOR( i_ambient );
	RGBA_COLOR( i_ambience );
	RGBA_COLOR( i_diffuse );
	color	i_indirect;
	float   i_diffuse_curve;
	bool	i_flip;
	normal  i_normal_camera;
	float   i_mode; // unused
	string  i_lights; // unused

	RGBA_DECLARE_OUTPUT( o_result ); )
{
	extern point P;
	extern vector I;
	normal Nn = normalize(i_normal_camera);

	color result_amb = i_ambient != 0 ? xsi_ambience() * i_ambient : i_ambient;

	color result_dif = 0;
	illuminance("diffuse", P)
	{
		float nondiff = 0;
		lightsource ("__nondiffuse", nondiff);

		if (nondiff < 1) 
		{
			vector Ln = normalize(L);
			if( i_flip == 0 || i_flip == 2 )
			{
				result_dif +=
					Cl *
					i_diffuse *
					pow(max(Ln.Nn, 0), i_diffuse_curve) *
					(1-nondiff);
			}
			if( i_flip == 1 || i_flip == 2 )
			{
				result_dif +=
					Cl *
					i_diffuse *
					pow(max(-Ln.Nn, 0), i_diffuse_curve) *
					(1-nondiff);
			}
		}
	}
	
	color result_ind = 0;
	if(i_indirect != 0)
	{
		result_ind = i_diffuse * i_indirect;
		result_ind *= ColorBleeding( result_ind );
	}
	
	o_result = result_amb + result_dif + result_ind;
	o_result_a = 1;
	
	XSI_MATERIAL_SET_OUTPUT( Ambient, result_amb );
	XSI_MATERIAL_SET_OUTPUT( Diffuse, result_dif );
	XSI_MATERIAL_SET_OUTPUT( Irradiance, result_ind );
}

// Softimage 2012
void misss_lambert_gamma(
	color	i_ambient;
	color	i_ambience;
	color	i_diffuse;
	bool	i_indirect;
	float   i_diffuse_curve;
	bool	i_flip;
	float   i_mode;

	RGBA_DECLARE_OUTPUT( o_result );)
{
	extern normal N;
	
	misss_lambert_gamma(
		i_ambient, 1.0,
		i_ambience, 1.0,
		i_diffuse, 1.0,
		i_indirect,
		i_diffuse_curve,
		i_flip,
		N,
		i_mode,
		"",
		RGBA_USE( o_result ));
}
#endif
