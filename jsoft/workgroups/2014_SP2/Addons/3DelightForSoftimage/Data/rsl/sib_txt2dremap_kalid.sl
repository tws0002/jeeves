/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __sib_txt2dremap_kalid_sl
#define __sib_txt2dremap_kalid_sl

void sib_txt2dremap_kalid(
	point i_coord;
	float i_angle;
	float i_num_reflections;
	output point o_result;)
{
	float spacing_angle=2*PI / (i_num_reflections*2);

	o_result = i_coord;

	o_result[0] += -0.5;
	o_result[1] += -0.5;

	float distance = sqrt( sqr(o_result[0])+sqr(o_result[1]) );
	float the_angle = atan( o_result[1]/o_result[0] );

	if( o_result[0]<0 )
		the_angle += PI;

	if( the_angle<0 )
		the_angle += 2.0*PI;

	float cur_angle;

	if( mod(floor(abs(the_angle/spacing_angle)),2)!=0 )
		cur_angle=the_angle-floor(abs(the_angle/spacing_angle))*
			  spacing_angle+i_angle;
	else
		cur_angle=ceil(abs(the_angle/spacing_angle))*
			  spacing_angle-the_angle+i_angle;

	o_result[0] = distance*cos(cur_angle)+0.5;
	o_result[1] = distance*sin(cur_angle)+0.5;
}
#endif
