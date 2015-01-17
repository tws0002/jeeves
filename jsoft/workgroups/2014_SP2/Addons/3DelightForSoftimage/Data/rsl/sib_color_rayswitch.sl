/*
	Copyright (c) 2011 DNA Research.
*/

#ifndef __sib_color_rayswitch_sl
#define __sib_color_rayswitch_sl

/*
	The sib_color_rayswitch shader allow different types of rays
	to return different results.
*/

void sib_color_rayswitch_set_shadow(
	RGBA_DECLARE(i_shadow);
	bool i_shadow_modulation;)
{
	extern color Oi;
	
	if(i_shadow_modulation == false)
	{
		Oi = 1 - clamp(i_shadow, 0, 1);
	}
	else
	{
		Oi *= 1 - clamp(i_shadow, 0, 1);
	}
}

void sib_color_rayswitch(
	RGBA_DECLARE(i_eye);
	RGBA_DECLARE(i_refraction);
	RGBA_DECLARE(i_reflection);
	RGBA_DECLARE(i_shadow);
	RGBA_DECLARE(i_photon);
	RGBA_DECLARE(i_finalgather);
	
	bool i_enable_fg;
	bool i_shadow_modulation;
	
	RGBA_DECLARE_OUTPUT(o_result);)
{
	uniform string raytype = "unknown";
	rayinfo( "type", raytype );
	
	if( raytype == "camera" )
	{
		uniform string shadowmapname = "";
		option("user:__xsi_rendering_shadowmap", shadowmapname);
		uniform float xsi_bakepass = 0;
		option("user:xsi_bakepass", xsi_bakepass);
		
		if(shadowmapname != "")		/* shadow pass */
		{
			RGBA_ASSIGN(o_result, i_shadow);
			sib_color_rayswitch_set_shadow(
				RGBA_USE(i_shadow), i_shadow_modulation);
		}
		else if(					/* point bake pass */
			i_enable_fg != false &&
			xsi_bakepass == 1 )
		{
			RGBA_ASSIGN(o_result, i_finalgather);
		}
		else
		{
			RGBA_ASSIGN(o_result, i_eye);
		}
	}
	else if( raytype == "specular" )
	{
		RGBA_ASSIGN(o_result, i_reflection);
	}
	else if( raytype == "transmission" ) /* raytrace shadow */
	{
		RGBA_ASSIGN(o_result, i_shadow);
		sib_color_rayswitch_set_shadow(
			RGBA_USE(i_shadow), i_shadow_modulation);
	}
	else if( raytype == "light" )
	{
		RGBA_ASSIGN(o_result, i_photon);
	}
	else if(		/* indirectdiffuse */
		i_enable_fg != false &&
		raytype == "diffuse" )
	{
		RGBA_ASSIGN(o_result, i_finalgather);
	}
	else
	{
		RGBA_ASSIGN(o_result, i_eye);
	}
}

#endif