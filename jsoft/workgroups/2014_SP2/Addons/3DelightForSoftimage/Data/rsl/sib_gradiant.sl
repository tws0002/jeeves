/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_gradiant_sl
#define __sib_gradiant_sl

#define SIB_GRADIANT_PARAMS \
	float i_mode; \
	float i_x_offset; \
	float i_y_offset

#define SIB_GRADIANT_PARAMS_LIST \
	i_mode, i_x_offset, i_y_offset

void sib_gradiant(
	point i_input;
	SIB_GRADIANT_PARAMS;
	output float o_result; )
{
	if( i_mode == 0 ) /* Linear */
		o_result = i_input[0] + ( i_x_offset - 0.5 );
	else if( i_mode == 1 ) /* Centric wave */
	{
		o_result =
			sqrt( sqr(i_x_offset-i_input[0]) +
					sqr(i_y_offset-i_input[1])) / sqrt(0.5);
	}
	else if( i_mode == 2 ) /* Centric Rainbow */
	{
		float delta_x = i_x_offset - i_input[0];
		float delta_y = i_y_offset - i_input[1];
		
		float denominator = sqrt( sqr(delta_x) + sqr(delta_y) );

		if( denominator == 0 || abs(denominator)<=EPS )
			o_result = 1;
		else
			o_result = acos( delta_y / denominator ) / PI;
	}
}
#endif
