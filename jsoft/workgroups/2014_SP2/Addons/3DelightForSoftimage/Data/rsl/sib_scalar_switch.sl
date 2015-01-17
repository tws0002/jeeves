/*
	Copyright (c) 2007 TAARNA Studios International.
*/
#ifndef __sib_scalar_switch_sl
#define __sib_scalar_switch_sl
void sib_scalar_switch(
	float i_input;
	float i_scalar1, i_scalar2;
	output float o_output )
{
	if( i_input == 1 )
		o_output = i_scalar2;
	else
		o_output = i_scalar1;
}
#endif

