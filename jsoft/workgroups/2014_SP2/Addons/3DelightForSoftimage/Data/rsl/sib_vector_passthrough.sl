/*
	Copyright (c) TAARNA Studios International.
*/

#ifndef __sib_vector_passthrough_sl
#define __sib_vector_passthrough_sl

void sib_vector_passthrough(
	point i_input;
	output point o_result; )
{
	o_result = i_input;
}

void sib_vector_passthrough(
	point i_input;
	point i_channel1; /* dummy */
	point i_channel2; /* dummy */
	point i_channel3; /* dummy */
	point i_channel4; /* dummy */
	point i_channel5; /* dummy */
	point i_channel6; /* dummy */
	point i_channel7; /* dummy */
	point i_channel8; /* dummy */
	output point o_result; )
{
	o_result = i_input;
}

#endif
