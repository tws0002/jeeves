/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_boolean_math_logic_sl
#define __sib_boolean_math_logic_sl

#define BOOLAND 0
#define BOOLOR 1
#define BOOLEQL 2

void sib_boolean_math_logic(
	float i_input1, i_input2;
	float i_op;
	float i_negate;

	output float o_result; )
{
	if( (i_op == BOOLAND && i_input1==0) ||
		(i_op == BOOLOR && i_input1!=0) )
	{
		o_result = i_input1;
	}
	else
	{
		if( i_op == BOOLAND )
			o_result = i_input2;
		else if( i_op == BOOLOR )
			o_result = i_input2;
		else if( i_op == BOOLEQL )
			o_result = i_input1==i_input2 ? 1 : 0;
		else 
			o_result = i_input1; /* invalid */
	}

	if( i_negate )
		o_result = o_result==1 ? 0 : 1;
}
#endif
