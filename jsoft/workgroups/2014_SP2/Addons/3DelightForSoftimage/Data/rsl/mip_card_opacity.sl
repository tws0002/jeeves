/*
	Yet another *fucked up* shader to deal with shortcomings of
	opacity in MR.
*/

#ifndef __mip_card_opacity_sl
#define __mip_card_opacity_sl

void mip_card_opacity(
	RGBA_DECLARE(i_input);
	uniform bool i_opacity_in_alpha;
	float i_opacity;
	uniform bool i_opacity_is_premultiplied;
	float i_opacity_threshold;	

	RGBA_DECLARE_OUTPUT(o_res); )
{
	/* Get the opacity from whatever the fucked up user wants. */
	float opacity = (i_opacity_in_alpha!=0) ? i_input_a : i_opacity;

	o_res = i_input;	
	o_res_a = i_input_a;

	if( i_opacity_is_premultiplied==false )
		o_res *= opacity;

	extern color Oi;
	Oi = opacity;
}
#endif
