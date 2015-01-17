/*
	Copyright (c) 2008 TAARNA Studios International.
*/

#ifndef __sib_vector_storeinchannel_sl
#define __sib_vector_storeinchannel_sl

void sib_vector_storeinchannel(
	point i_input;
	output point o_channel;
	output point o_result; )
{
	o_channel = o_result = i_input;
}

/* XSI 7.0 signature */
void sib_vector_storeinchannel(
	point i_input;
	output point o_channel;
	float i_raytype;
	float i_component;
	output point o_result; )
{
	if(i_component == 0)
	{
		o_result = i_input;
	}
	else
	{
		o_result = point(0, 0, 0);
		float index = clamp(i_component, 1, 3)-1;
		o_result[index] = i_input[index];
	}
	
	o_channel = o_result;
}

#endif
