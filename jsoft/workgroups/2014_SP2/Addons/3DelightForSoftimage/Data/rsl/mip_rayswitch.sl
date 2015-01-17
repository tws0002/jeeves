/*
	Copyright (c) 2011 DNA Research.
*/

#ifndef __mip_rayswitch_sl
#define __mip_rayswitch_sl

/*
	The mip_rayswitch shader allow different types of rays
	to return different results.
*/

#include "sib_color_rayswitch.sl"

void mip_rayswitch(
	RGBA_DECLARE(i_eye);
	RGBA_DECLARE(i_transparent);
	RGBA_DECLARE(i_reflection);
	RGBA_DECLARE(i_refraction);
	RGBA_DECLARE(i_finalgather);
	RGBA_DECLARE(i_environment);
	RGBA_DECLARE(i_shadow);
	RGBA_DECLARE(i_photon);
	RGBA_DECLARE(i_default);
	
	RGBA_DECLARE_OUTPUT(o_result);)
{
	uniform string raytype = "unknown";
	rayinfo( "type", raytype );
	
	if(
		raytype == "camera" || 
		raytype == "specular" ||
		raytype == "diffuse" ||
		raytype == "transmission" ||
		raytype == "light" )
	{
		sib_color_rayswitch(
			RGBA_USE(i_eye),
			RGBA_USE(i_refraction),
			RGBA_USE(i_reflection),
			RGBA_USE(i_shadow),
			RGBA_USE(i_photon),
			RGBA_USE(i_finalgather),
			
			true,
			true,
			
			RGBA_USE(o_result));
	}
	else
	{
		RGBA_ASSIGN(o_result, i_default);
	}
}

#endif