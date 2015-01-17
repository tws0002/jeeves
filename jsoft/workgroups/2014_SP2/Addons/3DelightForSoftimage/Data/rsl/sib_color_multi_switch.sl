/*
	Copyright (c) 2008 TAARNA Studios International.
*/

#ifndef __sib_color_multi_switch_sl
#define __sib_color_multi_switch_sl

void sib_color_multi_switch(
	RGBA_DECLARE(i_default);
	float i_switch;
	float i_value0;
	RGBA_DECLARE(i_input0);
	float i_value1;
	RGBA_DECLARE(i_input1);
	float i_value2;
	RGBA_DECLARE(i_input2);
	float i_value3;
	RGBA_DECLARE(i_input3);
	float i_value4;
	RGBA_DECLARE(i_input4);
	float i_value5;
	RGBA_DECLARE(i_input5);
	float i_value6;
	RGBA_DECLARE(i_input6);
	float i_value7;
	RGBA_DECLARE(i_input7);
	RGBA_DECLARE_OUTPUT(o_result); )
{
	if(i_switch == i_value0)
	{
		RGBA_ASSIGN(o_result, i_input0);
	}
	else if(i_switch == i_value1)
	{
		RGBA_ASSIGN(o_result, i_input1);
	}
	else if(i_switch == i_value2)
	{
		RGBA_ASSIGN(o_result, i_input2);
	}
	else if(i_switch == i_value3)
	{
		RGBA_ASSIGN(o_result, i_input3);
	}
	else if(i_switch == i_value4)
	{
		RGBA_ASSIGN(o_result, i_input4);
	}
	else if(i_switch == i_value5)
	{
		RGBA_ASSIGN(o_result, i_input5);
	}
	else if(i_switch == i_value6)
	{
		RGBA_ASSIGN(o_result, i_input6);
	}
	else if(i_switch == i_value7)
	{
		RGBA_ASSIGN(o_result, i_input7);
	}
	else
	{
		RGBA_ASSIGN(o_result, i_default);
	}
}

#endif

