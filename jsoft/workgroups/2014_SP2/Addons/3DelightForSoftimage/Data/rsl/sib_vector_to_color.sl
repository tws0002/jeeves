/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_vector_to_color_sl
#define __sib_vector_to_color_sl

void sib_vector_to_color(
	point i_input;
	float i_modeX, i_modeY, i_modeZ;
	float i_math_op;

	output color o_result;
	output float o_result_a; )
{
	float cumulatedR = 0.0, cumulatedG = 0.0, cumulatedB = 0.0, cumulatedA = 0.0;
	float modeX = mod(i_modeX, 5 );
	float modeY = mod(i_modeY, 5 );
	float modeZ = mod(i_modeZ, 5 );
	float math_op = mod(i_math_op, 4 );

#define ACCUM( mode, comp ) \
		if( mode == 1 ) /* put in output R */ \
			cumulatedR = SCALAR_MATH_OPER(math_op, comp, cumulatedR); \
		else if( mode == 2 ) /* put in output G */ \
			cumulatedG = SCALAR_MATH_OPER(math_op, comp, cumulatedG); \
		else if( mode == 3 ) /* put in output B */ \
			cumulatedB = SCALAR_MATH_OPER(math_op, comp, cumulatedB); \
		else if( mode == 4 ) /* put in output A */ \
			cumulatedA = SCALAR_MATH_OPER(math_op, comp, cumulatedA);

	ACCUM( modeX, xcomp(i_input) );
	ACCUM( modeY, ycomp(i_input) );
	ACCUM( modeZ, zcomp(i_input) );
#undef ACCUM
	/* return cumulated results */
	o_result = color( cumulatedR, cumulatedG, cumulatedB );
	o_result_a = cumulatedA;
}

/* XSI 7.0 signature */
void sib_vector_to_color(
	point i_input;

	float i_method;
	float i_scale;

	output color o_res;
	output float o_res_a; )
{
	vector input = vector i_input;

	if( i_scale > miSCALAR_EPSILON )
		input /= i_scale;

	if( i_method == 1 )
	{
		// [-1, 1] -> [0,1]
		o_res = color ( (input+1) * 0.5 );
	}
	else
		o_res = color input;

	o_res_a = 1;
}

#endif
