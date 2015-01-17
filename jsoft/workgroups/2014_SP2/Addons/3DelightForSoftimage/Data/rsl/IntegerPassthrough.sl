/*
	Copyright (c) TAARNA Studios International.
*/

#ifndef __IntegerPassthrough
#define __IntegerPassthrough

void IntegerPassthrough(
	float i_input;
	output float o_result; )
{
	o_result = i_input;
}

void IntegerPassthrough(
	float i_input;
	float i_channel1; /* dummy */
	float i_channel2; /* dummy */
	float i_channel3; /* dummy */
	float i_channel4; /* dummy */
	float i_channel5; /* dummy */
	float i_channel6; /* dummy */
	float i_channel7; /* dummy */
	float i_channel8; /* dummy */
	output float o_result; )
{
	o_result = i_input;
}

#endif
