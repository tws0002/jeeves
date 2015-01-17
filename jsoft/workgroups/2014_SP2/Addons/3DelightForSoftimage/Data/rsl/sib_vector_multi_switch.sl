/*
	Copyright (c) 2008 TAARNA Studios International.
*/

#ifndef __sib_vector_multi_switch_sl
#define __sib_vector_multi_switch_sl

void sib_vector_multi_switch(
	point i_default;
	float i_switch;
	float i_value0;
	point i_input0;
	float i_value1;
	point i_input1;
	float i_value2;
	point i_input2;
	float i_value3;
	point i_input3;
	float i_value4;
	point i_input4;
	float i_value5;
	point i_input5;
	float i_value6;
	point i_input6;
	float i_value7;
	point i_input7;
	output point o_result; )
{
	if(i_switch == i_value0)
	{
		o_result = i_input0;
	}
	else if(i_switch == i_value1)
	{
		o_result = i_input1;
	}
	else if(i_switch == i_value2)
	{
		o_result = i_input2;
	}
	else if(i_switch == i_value3)
	{
		o_result = i_input3;
	}
	else if(i_switch == i_value4)
	{
		o_result = i_input4;
	}
	else if(i_switch == i_value5)
	{
		o_result = i_input5;
	}
	else if(i_switch == i_value6)
	{
		o_result = i_input6;
	}
	else if(i_switch == i_value7)
	{
		o_result = i_input7;
	}
	else
	{
		o_result = i_default;
	}
}

#endif

