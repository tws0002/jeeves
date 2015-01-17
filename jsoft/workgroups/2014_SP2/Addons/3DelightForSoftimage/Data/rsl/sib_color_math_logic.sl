/*
	Copyright (c) 2009 TAARNA Studios International.
*/

#ifndef __sib_color_math_logic_sl
#define __sib_color_math_logic_sl

#define bool float

void sib_color_math_logic(
	RGBA_DECLARE(i_input1);
	RGBA_DECLARE(i_input2);
	float i_op;
	bool i_alpha;
	output float o_result; )
{
	o_result = 
		doscalarmathlogic(i_input1[0], i_input2[0], i_op) *
		doscalarmathlogic(i_input1[1], i_input2[1], i_op) *
		doscalarmathlogic(i_input1[2], i_input2[2], i_op);

	if(i_alpha != 0 && o_result != 0)
	{
		o_result = doscalarmathlogic(i_input1_a, i_input2_a, i_op);
	}
}

#endif
