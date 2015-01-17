/*
	Copyright (c) 2009 TAARNA Studios International.
*/

#ifndef __BA_fast_math_sl
#define __BA_fast_math_sl

#define bool float
#define true 1

#define FAST_MATH_OPERATION_NONE 9
#define FAST_MATH_OPERATION_SUBTRACT 0
#define FAST_MATH_OPERATION_MULTIPLY 1
#define FAST_MATH_OPERATION_ADD 2

#define FAST_MATH_MAGIC 2.75

float BA_fast_math_array(
	float i_operand0;
	float i_operands[];
	float i_scales[];
	float i_operations[];
	bool i_subtract_optimize;
	bool i_abort_zero)
{
	float out = i_operand0;
	
	if(out <= 0.0 && i_abort_zero == true)
	{
		return 0.0;
	}
	
	float nbOperations =
		min(arraylength(i_operands), arraylength(i_scales), arraylength(i_operations));
	float i;
	for(i = 0; i < nbOperations; i += 1)
	{
		float scale = i_scales[i];
		if(scale > 0.0)
		{
			float operand = i_operands[i];
			float operation = i_operations[i];
			if(operation == FAST_MATH_OPERATION_SUBTRACT)
			{
				if(i_subtract_optimize != 0.0 && out > FAST_MATH_MAGIC)
				{
					out -= 0.5*scale;
				}
				else
				{
					out -= operand*scale;
				}
			}
			else if(operation == FAST_MATH_OPERATION_MULTIPLY)
			{
				out *= (1.0-scale) + operand*scale;
			}
			else if(operation == FAST_MATH_OPERATION_ADD)
			{
				out += operand*scale;
			}

			if(out <= 0.0 && i_abort_zero == true)
			{
				return 0.0;
			}
		}
	}

	return out;
}


void BA_fast_math(
	float i_input1;
	float i_input2;
	float i_intensity2;
	float i_operation2;
	float i_input3;
	float i_intensity3;
	float i_operation3;
	float i_input4;
	float i_intensity4;
	float i_operation4;
	float i_input5;
	float i_intensity5;
	float i_operation5;
	float i_input6;
	float i_intensity6;
	float i_operation6;
	float i_input7;
	float i_intensity7;
	float i_operation7;
	float i_input8;
	float i_intensity8;
	float i_operation8;
	float i_clamp_min;
	float i_clamp_max;
	bool i_subtract_optimize;
	bool i_abort_zero;
	output float o_result)
{
	float operands[7] =
	{
		i_input2, i_input3, i_input4, i_input5,
		i_input6, i_input7, i_input8
	};
	float scales[7] =
	{
		i_intensity2, i_intensity3, i_intensity4, i_intensity5,
		i_intensity6, i_intensity7, i_intensity8
	};

	float operations[7] =
	{
		i_operation2, i_operation3, i_operation4, i_operation5,
		i_operation6, i_operation7, i_operation8
	};

	o_result =
		clamp(
			BA_fast_math_array(
				i_input1,
				operands,
				scales,
				operations,
				i_subtract_optimize,
				i_abort_zero),
			i_clamp_min,
			i_clamp_max);
}

#endif

