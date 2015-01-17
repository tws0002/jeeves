/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __xsi_texture_h
#define __xsi_texture_h

#define XSI_TEXTURE_DECLARE(texture)\
	uniform string texture##_name;\
	uniform float texture##_flipX;\
	uniform float texture##_flipY;\
	uniform float texture##_cropXMin;\
	uniform float texture##_cropXMax;\
	uniform float texture##_cropYMin;\
	uniform float texture##_cropYMax;\
	uniform float texture##_exposure;\
	uniform float texture##_gamma;\
	uniform float texture##_hue;\
	uniform float texture##_saturation;\
	uniform float texture##_gain;\
	uniform float texture##_brightness;\
	uniform float texture##_grayscale;\
	uniform float texture##_blurX;\
	uniform float texture##_blurY;\
	uniform float texture##_blurAmount;\
	uniform float texture##_blurAlpha

#define XSI_TEXTURE_DECLARE_INIT( \
	texture, name, \
	flipX, flipY, cropXMin, cropXMax, cropYMin, cropYMax, \
	exposure, gamma, hue, saturation, gain, brightness, grayscale, \
	blurX, blurY, blurAmount, blurAlpha )\
	uniform string texture##_name = name;\
	uniform float texture##_flipX = flipX;\
	uniform float texture##_flipY = flipY;\
	uniform float texture##_cropXMin = cropXMin;\
	uniform float texture##_cropXMax = cropXMax;\
	uniform float texture##_cropYMin = cropYMin;\
	uniform float texture##_cropYMax = cropYMax;\
	uniform float texture##_exposure = exposure;\
	uniform float texture##_gamma = gamma;\
	uniform float texture##_hue = hue;\
	uniform float texture##_saturation = saturation;\
	uniform float texture##_gain = gain;\
	uniform float texture##_brightness = brightness;\
	uniform float texture##_grayscale = grayscale;\
	uniform float texture##_blurX = blurX;\
	uniform float texture##_blurY = blurY;\
	uniform float texture##_blurAmount = blurAmount;\
	uniform float texture##_blurAlpha = blurAlpha

#define XSI_TEXTURE_DECLARE_INIT0(texture)\
	uniform string texture##_name = "";\
	uniform float texture##_flipX = false;\
	uniform float texture##_flipY = false;\
	uniform float texture##_cropXMin = 0;\
	uniform float texture##_cropXMax = 1;\
	uniform float texture##_cropYMin = 0;\
	uniform float texture##_cropYMax = 1;\
	uniform float texture##_exposure = 0.0;\
	uniform float texture##_gamma = 1.0;\
	uniform float texture##_hue = 0;\
	uniform float texture##_saturation = 100;\
	uniform float texture##_gain = 100;\
	uniform float texture##_brightness = 0;\
	uniform float texture##_grayscale = false;\
	uniform float texture##_blurX = 0;\
	uniform float texture##_blurY = 0;\
	uniform float texture##_blurAmount = 0;\
	uniform float texture##_blurAlpha = false

#define XSI_TEXTURE_USE(texture)\
	texture##_name,\
	texture##_flipX,\
	texture##_flipY,\
	texture##_cropXMin,\
	texture##_cropXMax,\
	texture##_cropYMin,\
	texture##_cropYMax,\
	texture##_exposure,\
	texture##_gamma,\
	texture##_hue,\
	texture##_saturation,\
	texture##_gain,\
	texture##_brightness,\
	texture##_grayscale,\
	texture##_blurX,\
	texture##_blurY,\
	texture##_blurAmount,\
	texture##_blurAlpha

#define XSI_TEXTURE_ASSIGN(out, in) \
	out##_name = in##_name;\
	out##_flipX = in##_flipX;\
	out##_flipY = in##_flipY;\
	out##_cropXMin = in##_cropXMin;\
	out##_cropXMax = in##_cropXMax;\
	out##_cropYMin = in##_cropYMin;\
	out##_cropYMax = in##_cropYMax;\
	out##_exposure = in##_exposure;\
	out##_gamma = in##_gamma;\
	out##_hue = in##_hue;\
	out##_saturation = in##_saturation;\
	out##_gain = in##_gain;\
	out##_brightness = in##_brightness;\
	out##_grayscale = in##_grayscale;\
	out##_blurX = in##_blurX;\
	out##_blurY = in##_blurY;\
	out##_blurAmount = in##_blurAmount;\
	out##_blurAlpha = in##_blurAlpha

#define UNDEFINED_UV_VALUE -10000000
#define UNDEFINED_UV(st) (abs(st) > 10000)
#define OUTSIDE(s, t) (s<0 || s>1 || t<0 || t>1)

float wrap_texture_scalar(bool i_wrap; float i_tex)
{
	if( i_wrap==false || (i_tex >= 0 && i_tex <= 1) )
	{
		return i_tex;
	}

	return SLICE(i_tex);
}

void wrap_texture(bool i_wrap; output float io_tex)
{
	io_tex = wrap_texture_scalar(i_wrap, io_tex);
}

void wrap_texture(bool i_wrap[3]; output float io_tex)
{
	wrap_texture(i_wrap[0], io_tex);
}

void wrap_texture(bool i_wrap; output point io_tex)
{
	io_tex[0] = wrap_texture_scalar(i_wrap, io_tex[0]);
	io_tex[1] = wrap_texture_scalar(i_wrap, io_tex[1]);
	io_tex[2] = wrap_texture_scalar(i_wrap, io_tex[2]);
}

void wrap_texture(bool i_wrap; output color io_tex)
{
	point tex = point(io_tex[0], io_tex[1], io_tex[2]);
	wrap_texture(i_wrap, tex);
	io_tex = color(tex[0], tex[1], tex[2]);
}

void wrap_texture(bool i_wrap[3]; output point io_tex)
{
	io_tex[0] = wrap_texture_scalar(i_wrap[0], io_tex[0]);
	io_tex[1] = wrap_texture_scalar(i_wrap[1], io_tex[1]);
	io_tex[2] = wrap_texture_scalar(i_wrap[2], io_tex[2]);
}

void wrap_texture(bool i_wrap[3]; output color io_tex)
{
	point tex = point(io_tex[0], io_tex[1], io_tex[2]);
	wrap_texture(i_wrap, tex);
	io_tex = color(tex[0], tex[1], tex[2]);
}

void transform_texture(float i_transform[16]; output point io_tex)
{
	matrix transformmatrix = matrix(
		i_transform[0], i_transform[1], i_transform[2], i_transform[3],
		i_transform[4], i_transform[5], i_transform[6], i_transform[7],
		i_transform[8], i_transform[9], i_transform[10], i_transform[11],
		i_transform[12], i_transform[13], i_transform[14], i_transform[15]);
	
	io_tex = transform( transformmatrix, io_tex );
}

void transform_texture(float i_transform[16]; output color io_tex)
{
	point tex = point(io_tex[0], io_tex[1], io_tex[2]);
	transform_texture(i_transform, tex);
	io_tex = color(tex[0], tex[1], tex[2]);
}

void xsi_textureTransform(
	float i_s;
	float i_t;
	float i_flipX;
	float i_flipY;
	float i_cropXMin;
	float i_cropXMax;
	float i_cropYMin;
	float i_cropYMax;
	output float o_s;
	output float o_t; )
{
	if(i_flipX == true)
	{
		o_s = 1.0 - i_s;
	}
	else
	{
		o_s = i_s;
	}

	/* Our T is in the opposite direction of MR's T */
	if(i_flipY == true)
	{
		o_t = i_t;
	}
	else
	{
		o_t = 1.0 - i_t;
	}

	float w = i_cropXMax - i_cropXMin;
	float h = i_cropYMax - i_cropYMin;
	o_s = o_s * w + i_cropXMin;
	o_t = o_t * h + (1-i_cropYMax);
}

color xsi_textureCorrect(
	color i_color;
	uniform float i_exposure;
	uniform float i_gamma;
	uniform float i_hue;
	uniform float i_saturation;
	uniform float i_gain;
	uniform float i_brightness;
	uniform float i_grayscale; )
{
	color rgb = sibu_gamma(i_color, i_gamma);

	color hsy = ctransform("rgb", "hsy", rgb);

	hsy[0] += i_hue / 360.0;
	if(hsy[0] < 0.0)
	{
		hsy[0] += 1.0;
	}
	else if(hsy[0] > 1.0)
	{
		hsy[0] -= 1.0;
	}
	hsy[1] *= clamp(i_saturation/100.0, 0.0, 1.0);

	rgb = ctransform("hsy", "rgb", hsy);

	rgb *= pow(2, i_exposure) * i_gain/100.0;
	rgb += color(i_brightness/100.0);

	if(i_grayscale == true)
	{
		rgb[2] = rgb[1] = rgb[0] = RGB_INT(rgb);
	}

	return rgb;
}

color xsi_textureBlurredLookupRGB(
	uniform string i_tex_name;
	uniform float i_tex_blurX;
	uniform float i_tex_blurY;
	uniform float i_tex_blurAmount;
	uniform float i_nbChannels;
	float i_transformedS;
	float i_transformedT; )
{
	if( OUTSIDE(i_transformedS, i_transformedT) )
		return 0;

	/* Get the blurred texture color. */
	color blurred = 0;
	float blurredWeight = 0.0;
	if(i_tex_blurAmount > 0.0 && (i_tex_blurX  > 0.0 || i_tex_blurY > 0.0))
	{
		blurred =
			texture(
				i_tex_name,
				i_transformedS, i_transformedT,
				"sblur", i_tex_blurX,
				"tblur", i_tex_blurY);
		blurredWeight = i_tex_blurAmount;

		/* Ensure that all channels are initialized. */
		if(i_nbChannels < 3)
		{
			blurred[2] = blurred[1] = blurred[0];
		}
	}

	/* Get the sharp texture color. */
	color sharp = 0;
	if(blurredWeight < 1.0)
	{
		sharp = texture(i_tex_name, i_transformedS, i_transformedT);

		/* Ensure that all channels are initialized. */
		if(i_nbChannels < 3)
		{
			sharp[2] = sharp[1] = sharp[0];
		}
	}

	/* Mix the blurred and sharp color according to the blur amount. */
	return mix(sharp, blurred, blurredWeight);
}

float xsi_textureBlurredLookupA(
	uniform string i_tex_name;
	uniform float i_tex_blurX;
	uniform float i_tex_blurY;
	uniform float i_tex_blurAmount;
	uniform float i_nbChannels;
	float i_transformedS;
	float i_transformedT; )
{
	/* Compute the index of the alpha channel. */
	float channelIndex = -1;
   	if(i_nbChannels == 2 || i_nbChannels >= 4)
	{
		channelIndex = max(4, i_nbChannels) - 1;
	}

	float a = 1.0;
	if(channelIndex >= 0)
	{
		/* Get the blurred texture alpha. */
		float blurred = 1.0;
		float blurredWeight = 0.0;
		if(i_tex_blurAmount > 0.0 && (i_tex_blurX  > 0.0 || i_tex_blurY > 0.0))
		{
			blurred =
				texture(
					i_tex_name[channelIndex],
					i_transformedS, i_transformedT,
					"sblur", i_tex_blurX,
					"tblur", i_tex_blurY);
			blurredWeight = i_tex_blurAmount;
		}

		/* Get the sharp texture alpha. */
		float sharp = 1.0;
		if(blurredWeight < 1.0)
		{
			sharp = texture(i_tex_name[channelIndex], i_transformedS, i_transformedT);
		}

		/* Mix the blurred and sharp alpha according to the blur amount. */
		a = mix(sharp, blurred, blurredWeight);
	}

	return a;
}
	
color xsi_textureLookupRGB(
	XSI_TEXTURE_DECLARE(i_tex);
	float i_s;
	float i_t; )
{
	if( OUTSIDE(i_s, i_t) )
	{
		return 0;
	}

	float transformedS, transformedT;
	xsi_textureTransform(
		i_s, i_t,
		i_tex_flipX, i_tex_flipY,
		i_tex_cropXMin, i_tex_cropXMax,
		i_tex_cropYMin, i_tex_cropYMax,
		transformedS, transformedT);

	uniform float nbChannels = 3;
	textureinfo(i_tex_name, "channels", nbChannels);

	color c =
		xsi_textureBlurredLookupRGB(
			i_tex_name,
			i_tex_blurX, i_tex_blurY,
			i_tex_blurAmount,
			nbChannels,
			transformedS, transformedT);

	return xsi_textureCorrect(
		c,
		i_tex_exposure,
		i_tex_gamma,
		i_tex_hue,
		i_tex_saturation,
		i_tex_gain,
		i_tex_brightness,
		i_tex_grayscale);
}

float xsi_textureLookupA(
	XSI_TEXTURE_DECLARE(i_tex);
	float i_s;
	float i_t; )
{
	if( OUTSIDE(i_s, i_t) )
		return 0;

	float transformedS, transformedT;
	xsi_textureTransform(
		i_s, i_t,
		i_tex_flipX, i_tex_flipY,
		i_tex_cropXMin, i_tex_cropXMax,
		i_tex_cropYMin, i_tex_cropYMax,
		transformedS, transformedT);

	uniform float nbChannels = 3;
	textureinfo(i_tex_name, "channels", nbChannels);

	return xsi_textureBlurredLookupA(
		i_tex_name,
		i_tex_blurX, i_tex_blurY,
		i_tex_blurAmount * i_tex_blurAlpha,
		nbChannels,
		transformedS, transformedT);
}

void xsi_textureLookupRGBA(
	XSI_TEXTURE_DECLARE(i_tex);
	float i_s;
	float i_t;
	output color o_result;
	output float o_result_a; )
{
	if( OUTSIDE(i_s, i_t) )
	{
		o_result = 0; o_result_a = 0;		
		return;
	}

	float transformedS, transformedT;
	xsi_textureTransform(
		i_s, i_t,
		i_tex_flipX, i_tex_flipY,
		i_tex_cropXMin, i_tex_cropXMax,
		i_tex_cropYMin, i_tex_cropYMax,
		transformedS, transformedT);

	uniform float nbChannels;
	textureinfo(i_tex_name, "channels", nbChannels);

	o_result =
		xsi_textureBlurredLookupRGB(
			i_tex_name,
			i_tex_blurX, i_tex_blurY,
			i_tex_blurAmount,
			nbChannels,
			transformedS, transformedT);
	o_result_a =
		xsi_textureBlurredLookupA(
			i_tex_name,
			i_tex_blurX, i_tex_blurY,
			i_tex_blurAmount * i_tex_blurAlpha,
			nbChannels,
			transformedS, transformedT);

	o_result =
		xsi_textureCorrect(
			o_result,
			i_tex_exposure,
			i_tex_gamma,
			i_tex_hue,
			i_tex_saturation,
			i_tex_gain,
			i_tex_brightness,
			i_tex_grayscale);
}
#endif
