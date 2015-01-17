/******************************************************************************/
/*                                                                            */
/*    Copyright (c)The 3Delight Developers. 2011                              */
/*    All Rights Reserved.                                                    */
/*                                                                            */
/******************************************************************************/

// ===========================================================================
// = LIBRARY
//     3dfs
// = AUTHOR(S)
//     Victor Yudin
// = VERSION
//     $Revision$
// = DATE RELEASED
//     $Date$
// = RCSID
//     $Id$
// ===========================================================================

#ifndef __soft_light_h
#define __soft_light_h

#include "xsi_light_utils.h"

void soft_light(
		uniform bool i_mode;
		RGBA_DECLARE(i_color);
		float i_intensity;
		bool i_shadow;
		float i_factor;
		bool i_atten;
		float i_start;
		float i_stop;
		float i_spreadangle;
		uniform bool i_use_color;
		uniform float i_energy_factor;
		uniform bool i_flat;
		uniform bool i_shape_enable;
		uniform float i_shape_roundness;
		uniform float i_shape_w;
		uniform float i_shape_h;
		uniform float i_shape_wedge;
		uniform float i_shape_hedge;
		uniform float i_shape_wshear;
		uniform float i_shape_hshear;
		uniform float i_rayshadow_softness;
		uniform float i_rayshadow_samples;

		RGBA_DECLARE_OUTPUT(o_out); )
{
	extern varying vector L;
	extern varying point Ps;
	extern varying normal Ns;
	extern uniform string __xsi_light_type;
	extern uniform float __xsi_light_exponent;
	extern uniform float __xsi_light_coneangle;
	extern uniform string __xsi_shadowname;
	extern uniform float __xsi_shadowsamples;
	extern uniform float __xsi_shadowblur;
	extern uniform float __xsi_shadowbias;
	extern varying vector __xsi_light_real_dir;

	extern varying color o_shadow;
	extern varying color o_unshadowed_cl;

	color sh = 0;

	float distance = length( L );

	float atten = 1;
	if(i_atten == true)
	{
		float exponent = __xsi_light_exponent;
		if( distance>i_start)
		{
			if( distance>i_stop )
				atten = 0;
			if( i_mode == false )
			{
				atten *= abs(i_stop-i_start) < 1e-6 ?
					1.0 : 1 - (distance-i_start)/(i_stop-i_start);
			}
			else
				atten *= pow( distance-i_start + 1.0, -exponent );
		}
	}

	if( atten > 0 )
	{
		/* perform cone attenuation only with spotlight */
		if( __xsi_light_type == "spot" )
		{
			/* NOTE: don't perform the "cone attenuation" if we have the
			   shape attenuation. Shape attenuation is performed further
			   below */
			float spread =
				cos( __xsi_light_coneangle - radians(i_spreadangle) );
			float cone = cos(__xsi_light_coneangle);

			float d = ( L . __xsi_light_real_dir ) / distance;

			if( i_shape_enable==0 && d<spread && abs(spread-cone)>1e-6 )
				atten *= (d - cone) / (spread-cone);
		}

		if(i_shadow == true)
		{
			if( EvaluateShadow(
					Ps,
					__xsi_shadowname,
					__xsi_shadowsamples,
					__xsi_shadowblur,
					__xsi_shadowbias,
					sh) == true  )
			{
				o_shadow = sh * (1-i_factor);
			}
		}

		o_unshadowed_cl = i_intensity * atten * i_color;

		if( i_flat == 1 && L.Ns<0 )
		{
			/* Change L so that the surface looks like it is directly 
			   above the shading point. */
			L = - normalize(Ns) * length(L);
		}

		if( __xsi_light_type == "spot" && i_shape_enable==1 )
		{
			point P_light = transform( "shader", Ps );

			/* Perform a projection. */
			P_light[0] /= P_light[2];
			P_light[1] /= P_light[2];
			P_light[2] = 0.0;

			float inner_w = max( 1e-5, i_shape_w - i_shape_wedge );
			float inner_h = max( 1e-5, i_shape_h - i_shape_hedge );

			o_unshadowed_cl *= 1 - clipSuperellipse(
				P_light,
				inner_w, inner_h, /* inner ellipse radii */
				i_shape_w, i_shape_h, /* outer ellipse radii */
				i_shape_roundness );
		}
		
		o_out = o_unshadowed_cl * mix( (1-sh), 1, i_factor );
	}
	else
	{
		o_out = 0;
		o_unshadowed_cl = 0;
	}
}

#endif

