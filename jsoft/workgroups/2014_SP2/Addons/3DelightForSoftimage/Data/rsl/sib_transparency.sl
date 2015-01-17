#ifndef __sib_transparency_sl
#define __sib_transparency_sl

void sib_transparency(
	RGBA_DECLARE(i_input);
	RGBA_DECLARE(i_trans);
	RGBA_DECLARE_OUTPUT(o_result); )
{
	extern color Oi;

	color opacity = 1-i_trans;

	o_result = i_input*opacity;	
	o_result_a = 1;

	Oi *= opacity;		
}
#endif
