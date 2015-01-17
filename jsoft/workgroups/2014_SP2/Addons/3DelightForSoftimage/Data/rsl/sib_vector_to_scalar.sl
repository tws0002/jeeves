/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_vector_to_scalar_sl
#define __sib_vector_to_scalar_sl

void sib_vector_to_scalar(
	point i_input;
	float i_component;

	output float o_result; )
{
	float c = mod(i_component, 3);

	if( c == 0 )
		o_result = xcomp(i_input);
	else if( c == 1 )
		o_result = ycomp(i_input);
	else
		o_result = zcomp(i_input);
}

void sib_vector_to_scalar(
	point i_input;
	output float o_result; )
{
	o_result = length(vector(i_input));
}

#endif
