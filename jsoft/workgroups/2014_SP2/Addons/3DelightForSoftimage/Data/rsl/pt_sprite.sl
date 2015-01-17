/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __pt_sprite_sl
#define __pt_sprite_sl

#define bool float
#define enum float

#define PIXEL_INTERPOLATION_NEAREST 0
#define PIXEL_INTERPOLATION_BILINEAR 1

#define ALPHA_MODULATION_SPRITE_RGB_INTENSITY 0
#define ALPHA_MODULATION_SPRITE_ALPHA 1
#define ALPHA_MODULATION_IDENTITY 2

void pt_sprite(
	XSI_TEXTURE_DECLARE(i_sprite);
	RGBA_DECLARE(i_input);			/* used */
	float i_frame;					/* unused */
	bool i_loop;					/* unused */
	enum i_pixelInterpolation;		/* unused forever */
	bool i_frameInterpolation;		/* unused */
	bool i_useSpriteRGB;			/* used */
	enum i_alphaModulation;			/* used */
	bool i_alphaModulationInvert;	/* used */

	output color o_result;
	output float o_result_a; )
{
	RGBA_DECLARE(spriteColor);
	if(i_useSpriteRGB == true || i_alphaModulation != ALPHA_MODULATION_IDENTITY)
	{
		xsi_textureLookupRGBA(XSI_TEXTURE_USE(i_sprite), s, t, RGBA_USE(spriteColor));
	}

	if(i_useSpriteRGB == true)
	{
		o_result = spriteColor;
	}
	else
	{
		o_result = i_input;
	}
	
	if(i_alphaModulation == ALPHA_MODULATION_SPRITE_RGB_INTENSITY)
	{
		if(i_alphaModulationInvert == true)
		{
			o_result_a = i_input_a * (1.0 - RGB_INT(spriteColor));
		}
		else
		{
			o_result_a = i_input_a * RGB_INT(spriteColor);
		}
	}
	else if(i_alphaModulation == ALPHA_MODULATION_SPRITE_ALPHA)
	{
		if(i_alphaModulationInvert == true)
		{
			o_result_a = i_input_a * (1.0 - spriteColor_a);
		}
		else
		{
			o_result_a = i_input_a * spriteColor_a;
		}
	}
	else
	{
		o_result_a = i_input_a;
	}
}

#undef PIXEL_INTERPOLATION_NEAREST
#undef PIXEL_INTERPOLATION_BILINEAR

#undef ALPHA_MODULATION_SPRITE_RGB_INTENSITY
#undef ALPHA_MODULATION_SPRITE_ALPHA
#undef ALPHA_MODULATION_IDENTITY

#endif
