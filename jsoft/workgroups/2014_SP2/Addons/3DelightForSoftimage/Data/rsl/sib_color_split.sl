#ifndef __sib_color_split_sl
#define __sib_color_split_sl

void sib_color_split(
	RGBA_DECLARE_OUTPUT(o_combined);
	RGBA_DECLARE_OUTPUT(o_rgb);
	output float o_alpha; 

	RGBA_DECLARE(i_input); )
{
	o_combined = o_rgb = i_input;

	o_combined_a = i_input_a;
	o_rgb_a = 1.0;

	o_alpha = i_input_a;
}

void sib_color_split(
	RGBA_DECLARE(i_input);
	RGBA_DECLARE_OUTPUT(o_combined);
	RGBA_DECLARE_OUTPUT(o_rgb);
	output float o_alpha; )
{
	sib_color_split(
		RGBA_USE(o_combined),
		RGBA_USE(o_rgb),
		o_alpha,
		RGBA_USE(i_input));
}
#endif
