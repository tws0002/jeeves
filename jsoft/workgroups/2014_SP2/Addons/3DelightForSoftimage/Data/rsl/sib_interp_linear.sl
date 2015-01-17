/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_interp_linear_sl
#define __sib_interp_linear_sl

void sib_interp_linear(
	float i_input;

	float i_oldrange_min, i_oldrange_max;
	float i_newrange_min, i_newrange_max; 

	output float o_result; )
{
	float delta_oldrange = i_oldrange_max - i_oldrange_min;
	float delta_newrange = i_newrange_max - i_newrange_min;	

	if( abs(delta_oldrange) < EPS )
		delta_oldrange = EPS;

	o_result = i_newrange_min + 
		delta_newrange*((i_input-i_oldrange_min)/delta_oldrange);
}
#endif
