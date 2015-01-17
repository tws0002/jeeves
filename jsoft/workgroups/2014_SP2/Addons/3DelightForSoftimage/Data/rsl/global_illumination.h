/******************************************************************************/
/*                                                                            */
/*    Copyright (c)The 3Delight Developers. 2013                              */
/*    All Rights Reserved.                                                    */
/*                                                                            */
/******************************************************************************/

/*
	Copyright (c) 2006 soho vfx inc.
	Copyright (c) 2006 The 3Delight Team.
*/

#ifndef _global_illumination_h
#define _global_illumination_h

color getIndirectDiffuse( normal i_N; color i_weight; )
{
	return ColorBleeding( i_weight );
}

float getGiEnvironmentMapParameters(
		output uniform string envmap;
		output uniform string envspace;)
{
	envmap = "";
	envspace = "";

	uniform float envmap_found =
		option( "user:_3delight_envmap", envmap );
	envspace = "world";

	return envmap_found;
}

float getReflectionEnvironmentMapParameters(
		output uniform string envmap;
		output uniform string envspace;)
{
	envmap = "";
	envspace = "";

	uniform float envmap_found =
		option( "user:_3delight_reflection_envmap", envmap );
	envspace = "world";

	return envmap_found;
}

#endif
