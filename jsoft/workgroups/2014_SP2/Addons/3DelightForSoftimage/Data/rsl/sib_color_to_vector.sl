/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_color_to_vector_sl
#define __sib_color_to_vector_sl

void sib_color_to_vector(
	RGBA_COLOR(i_input);
	float i_modeR, i_modeG, i_modeB, i_modeA;
	float i_math_op;
	output point o_result; )
{
	float cumulatedX = 0.0, cumulatedY = 0.0, cumulatedZ = 0.0;
	float modeR = mod(i_modeR, 4);
	float modeG = mod(i_modeG, 4);
	float modeB = mod(i_modeB, 4);
	float modeA = mod(i_modeA, 4);
	float math_op = mod(i_math_op, 4);

#define ACCUM( mode, comp ) \
		if( mode == 1 ) /* put in output R */ \
			cumulatedX = SCALAR_MATH_OPER(math_op, comp, cumulatedX); \
		else if( mode == 2 ) /* put in output G */ \
			cumulatedY = SCALAR_MATH_OPER(math_op, comp, cumulatedY); \
		else if( mode == 3 ) \
			cumulatedZ = SCALAR_MATH_OPER(math_op, comp, cumulatedZ); \
	
	ACCUM( modeR, comp(i_input, 0) );
	ACCUM( modeG, comp(i_input, 1) );
	ACCUM( modeB, comp(i_input, 2) );
	ACCUM( modeA, i_input_a );
#undef ACCUM

	/* return cumulated results */
	o_result = point( cumulatedX, cumulatedY, cumulatedZ );
}

/* XSI 7.0 signature */
void sib_color_to_vector(
	RGBA_COLOR(i_input);

	float i_method;
	float i_scale;

	output point o_res; )
{
	color input = i_input;

	if( i_method == 1 )
	{
		// [0, 1] -> [-1,1]
		o_res = point ( input*2 - 1 );
	}
	else
		o_res = point input;

	o_res *= i_scale;
}

#endif
