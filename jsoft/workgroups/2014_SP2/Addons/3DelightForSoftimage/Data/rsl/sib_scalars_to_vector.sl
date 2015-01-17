
#ifndef __sib_scalars_to_vector_sl
#define __sib_scalars_to_vector_sl

#include "xsi_math.h"

/* operator: 0=add , 1=sub, 2=multiply , 3=replace*/

void sib_scalars_to_vector(
	float i_mode_x, i_mode_y, i_mode_z;
	float i_math_op;

	float i_x, i_y, i_z;

	output point o_result; )
{
	float cumul_x = 0, cumul_y = 0, cumul_z = 0;

	float mode_x = mod(i_mode_x, 4);
	float mode_y = mod(i_mode_y, 4);
	float mode_z = mod(i_mode_z, 4);
	float math_op = mod( i_math_op, 4 );

	if( mode_x == 1 ) /* put in ouput X */
		cumul_x = SCALAR_MATH_OPER( math_op, i_x, cumul_x );
	else if( mode_x == 2 )
		cumul_y = SCALAR_MATH_OPER( math_op, i_x, cumul_y );
	else if( mode_x == 3 )
		cumul_z = SCALAR_MATH_OPER( math_op, i_x, cumul_z );

	if( mode_y == 1 ) /* put in ouput X */
		cumul_x = SCALAR_MATH_OPER( math_op, i_y, cumul_x );
	else if( mode_y == 2 )
		cumul_y = SCALAR_MATH_OPER( math_op, i_y, cumul_y );
	else if( mode_y == 3 )
		cumul_z = SCALAR_MATH_OPER( math_op, i_y, cumul_z );

	if( mode_z == 1 ) /* put in ouput X */
		cumul_x = SCALAR_MATH_OPER( math_op, i_z, cumul_x );
	else if( mode_z == 2 )
		cumul_y = SCALAR_MATH_OPER( math_op, i_z, cumul_y );
	else if( mode_z == 3 )
		cumul_z = SCALAR_MATH_OPER( math_op, i_z, cumul_z );

	/* return cumulated results */
	o_result = point( cumul_x, cumul_y, cumul_z );
} 
#endif
