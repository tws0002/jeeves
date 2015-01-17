#ifndef __sib_atten_linear_sl
#define __sib_atten_linear_sl

/* FIXME: when we will have generated light shaders, make sure we take
   "L" and not "I". */

void sib_atten_linear(
	float i_start, i_end;
	output float o_result )
{
	extern vector I;

	vector w_I = transform( "world", I );
	float distance = length( w_I );
	
	if( distance < i_start )
		o_result = 1;
	else if( distance > i_end )
		o_result = 0;
	else
	{
		/* `distance` is in the allowed range. */
		o_result = (i_end-distance) / (i_end-i_start);
	}
}
#endif
