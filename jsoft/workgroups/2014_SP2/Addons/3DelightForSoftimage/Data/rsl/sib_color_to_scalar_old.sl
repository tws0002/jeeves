/*
	Copyright (c) 2008 TAARNA Studios International.
*/

#ifndef __sib_color_to_scalar_old_sl
#define __sib_color_to_scalar_old_sl

#include "sib_color_to_scalar.sl"

void sib_color_to_scalar_old(
	RGBA_COLOR( i_input );
	float i_alpha;

	output float o_result; )
{
	sib_color_to_scalar(RGBA_USE(i_input), i_alpha, o_result);
}
#endif 
