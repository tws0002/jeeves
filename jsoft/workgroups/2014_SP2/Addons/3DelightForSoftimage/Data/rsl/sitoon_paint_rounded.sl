/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sitoon_paint_rounded_sl
#define __sitoon_paint_rounded_sl

#include "sitoon_utils.h"
#include "sitoon_paint_highlight.sl"

#define rounded_rimlight_mode_NONE 0
#define rounded_rimlight_mode_ADD 1
#define rounded_rimlight_mode_DIFFEENCE 2

void sitoon_paint_rounded(
	uniform float i_spot_enable; 
	RGBA_COLOR(i_spot_color);
	uniform float i_spot_mix_mode;
	float i_spot_trim;
	uniform float i_crescent_enable;
	RGBA_COLOR(i_crescent_color);
	uniform float i_crescent_mix_mode;
	float i_crescent_trim;
	float i_roundness; 
	uniform float i_highlight_enable, i_highlight_mode;
	float i_highlight_cover;

	uniform float i_rimlight_enable, i_rimlight_mode; 
	float i_rimlight_cover; 

	RGBA_COLOR( i_surface );

	output color o_result;
	output float o_result_a; )
{
	float factor_accum = 0;

	if( i_highlight_enable != 0 )
	{
		RGBA_COLOR( col );
		RGBA_COLOR( filter );
		filter = 1; filter_a = 1;

		float res =  sitoon_highlight(
			filter, filter_a, i_highlight_cover, i_roundness, i_highlight_mode,
			false , col, col_a );

		if( res != 0 )
			factor_accum += col_a;
	}

	if( i_rimlight_enable != 0 )
	{
		extern vector I;
		float factor = sitoon_incidence_vector(
			sqrt(1-i_rimlight_cover), i_roundness, -I, true );

		if( factor != 0 )
		{
			if( i_rimlight_mode == rounded_rimlight_mode_ADD )
				factor_accum += factor;
			else
				factor_accum -= factor;
		}
	}

	RGBA_ASSIGN( o_result, i_surface );

	if( i_crescent_enable != 0 )
	{
		/* The following line of code is the filtered version of:
		   	float crescent_enable =
				( 1-factor_accum > (1 + i_crescent_trim)*0.5 ) ?
					1 : 0; 
		*/
		float crescent_enable = filterstep( (1+i_crescent_trim)*0.5, 1-factor_accum );

		if( crescent_enable!=0 )
		{
			sitoon_color_mix(
				RGBA_COLOR_PARAM(o_result), 
				RGBA_COLOR_PARAM(i_crescent_color), 
				RGBA_COLOR_PARAM(o_result), i_crescent_color_a*crescent_enable,
				i_crescent_mix_mode );
		}
	}

	if( i_spot_enable != 0 )
	{
		/* we do the same filtering as we did for 'crescent_enable' above */
		float spot_enable = filterstep( (1 + i_spot_trim)*0.5, factor_accum );

		if( spot_enable!=0 )
		{
			sitoon_color_mix(
				RGBA_COLOR_PARAM(o_result ), 
				RGBA_COLOR_PARAM(i_spot_color), 
				RGBA_COLOR_PARAM(o_result), i_spot_color_a*spot_enable,
				i_spot_mix_mode );
		}
	}
}
#endif
