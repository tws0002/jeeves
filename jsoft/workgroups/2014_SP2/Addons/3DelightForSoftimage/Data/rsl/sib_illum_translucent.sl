#ifndef __sib_illum_translucent_sl
#define __sib_illum_translucent_sl

void sib_illum_translucent(
	RGBA_DECLARE(i_diffuse);
	RGBA_DECLARE_OUTPUT(o_result); )
{
	extern normal N;
	normal Nf = ShadingNormal( normalize(N) );

	o_result = (i_diffuse != 0) ? i_diffuse * diffuse( -Nf ) : 0;	
	o_result_a = 1;
}
#endif
