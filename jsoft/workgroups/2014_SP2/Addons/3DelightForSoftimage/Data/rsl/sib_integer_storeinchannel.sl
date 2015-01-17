/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_integer_storeinchannel_sl
#define __sib_integer_storeinchannel_sl

void sib_integer_storeinchannel(
	float i_input;
	output float o_channel; /* This is delcared in the shader params */
	output float o_result; )
{
	o_channel = o_result = i_input;
}

/* XSI 7.0 signature */
void sib_integer_storeinchannel(
	float i_input;
	output float o_channel; /* This is delcared in the shader params */

	float i_raytype;

	output float o_result; )
{
	o_channel = o_result = i_input;
}

#endif
