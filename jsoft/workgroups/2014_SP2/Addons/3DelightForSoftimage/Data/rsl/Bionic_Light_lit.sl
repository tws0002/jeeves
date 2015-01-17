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

#ifndef __bionic_light_lit_h
#define __bionic_light_lit_h

#include "xsi_light_utils.h"

void RotateST(
		float a;
		output float ss;
		output float tt;)
{
	float sina = sin(a);
	float cosa = cos(a);
	float sss = ss;
	float ttt = tt;

	ss = ttt*sina + sss*cosa;
	tt = ttt*cosa - sss*sina;
}

float Tile(float a)
{
	return mod(a, 1.0);
}

void Bionic_Light_lit(
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

		uniform float i_Volume_Brightness;
		uniform bool i_Volume_Shard_On;
		uniform float i_Volume_Shard_Scale;
		uniform float i_Volume_Shard_Amount;
		uniform float i_Volume_Shard_Speed;
		uniform float i_Volume_Falloff_Scale;
		uniform float i_Volume_Start_Distance;
		uniform bool i_Volume_Force_Shadows;
		uniform float i_Volume_Map_Resolution;
		uniform float i_Projector_Scale;
		uniform float i_Projector_Rotation;
		uniform bool i_Projector_Tile;
		uniform bool i_Volume_Transparent;
		uniform bool i_Volume_Falloff_Sqr;
		XSI_TEXTURE_DECLARE(i_Projector_Pic);
		uniform bool i_Star_On;
		uniform float i_Star_Ray_Number;
		uniform float i_Star_Length;
		uniform float i_Star_Length_Jitter;
		uniform float i_Star_Thickness;
		uniform float i_Star_Thickness_Jitter;
		uniform float i_Star_Rotation;
		uniform float i_Star_Brightness;
		uniform bool i_Star_Autorotate;
		uniform float i_Star_Speed;
		uniform bool i_Glow_On;
		uniform float i_Glow_Size ;
		uniform float i_Glow_Brightness;
		uniform float i_Glow_Falloff;
		uniform float i_Flare_Brightness;
		uniform float i_Flare_Scale;
		uniform float i_Flare_Aspect;
		XSI_TEXTURE_DECLARE(i_Flare_Preset);
		uniform float i_Flare_Samples;
		uniform float i_Flare_Virtual_Radius;

		RGBA_DECLARE_OUTPUT(o_out); )
{
	extern varying point __xsi_light_real_from;
	extern varying vector __xsi_light_real_dir;
	extern uniform float __xsi_light_coneangle;

	vector up = vector "shader" (0, 1, 0);
	float spreadangle = radians(i_spreadangle);
	float coneangle = __xsi_light_coneangle - radians(i_spreadangle);

	float ss;
	float tt;

	float atten = 1;
	/* perform cone attenuation only with spotlight */
	if( __xsi_light_type == "spot" )
	{
		/* NOTE: don't perform the "cone attenuation" if we have the
		   shape attenuation. Shape attenuation is performed further
		   below */
		float distance = length( L );
		float spread = cos( coneangle );
		float cone = cos(__xsi_light_coneangle);

		float d = ( L . __xsi_light_real_dir ) / distance;

		if( i_shape_enable==0 && d<spread && abs(spread-cone)>1e-6 )
			atten *= (d - cone) / (spread-cone);
	}

	atten *= i_intensity;
	o_out = atten * i_color;

	if( atten>0 &&
		i_Projector_Pic_name != "" &&
		i_Projector_Pic_name != ".tdl" )
	{
		if( __xsi_light_type == "point" || __xsi_light_type == "direct" )
		{
			vector dir;
			if( __xsi_light_type == "point" )
			{
				dir = Ps - __xsi_light_real_from;
			}
			else
			{
				dir = Ps - E;
			}

			dir = vtransform("world", dir);
			float norm = length(dir);

			float theta;

			/* avoid calling atan2(0, 0), which return NaN on some platforms */
			if( dir[0]==0 && dir[2]==0 )
				theta = 0;
			else
				theta = -atan(dir[0], dir[2]) / (2*PI);
			theta -= floor(theta);

			ss = theta;
			tt = asin(dir[1]/norm) / PI + 0.5;

			/* rotate */
			ss = Tile(ss - i_Projector_Rotation/360);
		}
		else
		{
			/* direction of light source from surf. point */
			L =  Ps - __xsi_light_real_from;

			/* normalized direction vector */
			vector relT = __xsi_light_real_dir;
			/* "vertical" perspective of surface point */
			vector relU = relT ^ up;
			vector relV = normalize(relT ^ relU);

			float spread = 1/tan( coneangle );

			/* coordinates of Ps along relT, relU, relV */
			float Pt = -L.relT;
			float Pu = L.relU;
			float Pv = L.relV;

			/* perspective divide	*/
			ss = spread*Pu/Pt;
			tt = spread*Pv/Pt;

			/* rotate */
			RotateST(
				-radians( i_Projector_Rotation ),
				ss, tt);

			/* scale */
			ss /= i_Projector_Scale;
			tt /= i_Projector_Scale;

			/* correction from 0 to 1 */
			ss = ss*.5 + .5;
			tt = tt*.5 + .5;

			if(i_Projector_Tile == true)
			{
				ss = Tile(ss);
				tt = Tile(tt);
			}
		}

		if(ss>=0 && ss<=1 && tt>=0 && tt<=1)
		{
			o_out *= xsi_textureLookupRGB(
				XSI_TEXTURE_USE(i_Projector_Pic),
				ss, tt);
		}
	}

	o_out_a = 1.0;
}

#endif //__bionic_light_lit_h

