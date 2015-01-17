/*
	Copyright (c) TAARNA Studios International.
*/

#ifndef __Vector3Passthrough
#define __Vector3Passthrough

void Vector3Passthrough(
	point i_input;
	output point o_result; )
{
	o_result = i_input;
}

void Vector3Passthrough(
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
