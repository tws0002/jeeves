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

#ifndef __sib_slide_proj_light_h
#define __sib_slide_proj_light_h

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

void sib_slide_proj_light(
		XSI_TEXTURE_DECLARE(i_tex);

		RGBA_DECLARE_OUTPUT(o_out); )
{
	extern varying point __xsi_light_real_from;
	extern varying vector __xsi_light_real_dir;
	extern uniform float __xsi_light_coneangle;

	o_out_a = 1.0;

	float ss;
	float tt;

	if( i_tex_name != "" &&
		i_tex_name != ".tdl" )
	{
		if( __xsi_light_type == "spot" )
		{
			uniform vector up = vector "shader" (0, 1, 0);

			/* direction of light source from surf. point */
			L =  Ps - __xsi_light_real_from;

			/* normalized direction vector */
			vector relT = __xsi_light_real_dir;
			/* "vertical" perspective of surface point */
			vector relU = relT ^ up;
			vector relV = normalize(relT ^ relU);

			/* coordinates of Ps along relT, relU, relV */
			float Pt = -L.relT;
			float Pu = L.relU;
			float Pv = L.relV;

			float spread = 1/tan( __xsi_light_coneangle );

			/* perspective divide	*/
			ss = spread*Pu/Pt;
			tt = spread*Pv/Pt;

			/* correction from 0 to 1 */
			ss = ss*.5 + .5;
			tt = tt*.5 + .5;
		}

		if(ss>=0 && ss<=1 && tt>=0 && tt<=1)
		{
			o_out = xsi_textureLookupRGB(
				XSI_TEXTURE_USE(i_tex),
				ss, tt);
			return;
		}
	}

	o_out = 1.0;
}

#endif //__sib_slide_proj_light_h

