/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_vector_switch_sl
#define __sib_vector_switch_sl
void sib_vector_switch(
	float i_t;
	point i_vector1, i_vector2;

	output point o_result; )
{
	if( i_t == 1 )
		o_result = i_vector2;
	else
		o_result = i_vector1;
}
#endif

