/*
	Copyright (c) 2008 TAARNA Studios International.
*/

#ifndef __sib_vector_to_scalars_sl
#define __sib_vector_to_scalars_sl

void sib_vector_to_scalars(
	output float o_x;
	output float o_y;
	output float o_z;
	
	point i_input; )
{
	o_x = i_input[0];
	o_y = i_input[1];
	o_z = i_input[2];
}

void sib_vector_to_scalars(
	point i_input;
	output float o_x;
	output float o_y;
	output float o_z; )
{
	sib_vector_to_scalars(o_x, o_y, o_z, i_input);
}

#endif
