/*
	Copyright (c) 2008 TAARNA Studios International.
*/

#ifndef __sib_scalar_multi_switch_sl
#define __sib_scalar_multi_switch_sl

void sib_scalar_multi_switch(
	float i_default;
	float i_switch;
	float i_value0;
	float i_input0;
	float i_value1;
	float i_input1;
	float i_value2;
	float i_input2;
	float i_value3;
	float i_input3;
	float i_value4;
	float i_input4;
	float i_value5;
	float i_input5;
	float i_value6;
	float i_input6;
	float i_value7;
	float i_input7;
	output float o_result; )
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

