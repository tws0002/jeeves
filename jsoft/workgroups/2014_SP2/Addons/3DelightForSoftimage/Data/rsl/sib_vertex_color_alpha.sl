/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_vertex_color_alpha
#define __sib_vertex_color_alpha

/* Since most of the work for vertex colors is performed in the shade
   tree converter, this nodes is really only an assignment */

void sib_vertex_color_alpha(
	RGBA_COLOR( i_vprop );
	float i_alpha_only;

	output color o_result;
	output float o_result_a; )
{
	o_result_a = i_vprop_a;

	if( i_alpha_only != 0 )
		o_result = o_result_a;
	else
		o_result = i_vprop;
}

#endif
