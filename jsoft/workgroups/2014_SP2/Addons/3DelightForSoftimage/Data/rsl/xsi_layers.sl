/*
	Copyright (c) 2009 TAARNA Studios International.
*/

#ifndef __xsi_layers_sl
#define __xsi_layers_sl

#define XSI_LAYERS_MODE_OVER 0
#define XSI_LAYERS_MODE_IN 1
#define XSI_LAYERS_MODE_OUT 2
#define XSI_LAYERS_MODE_PLUS 3
#define XSI_LAYERS_MODE_BOUNDED_PLUS 4
#define XSI_LAYERS_MODE_MULTIPLY 5
#define XSI_LAYERS_MODE_BOUNDED_MULTIPLY 6
#define XSI_LAYERS_MODE_DIFFERENCE 7
#define XSI_LAYERS_MODE_DARKEN 8
#define XSI_LAYERS_MODE_LIGHTEN 9
#define XSI_LAYERS_MODE_HARD_LIGHT 10
#define XSI_LAYERS_MODE_SOFT_LIGHT 11
#define XSI_LAYERS_MODE_SCREEN 12
#define XSI_LAYERS_MODE_OVERLAY 13
#define XSI_LAYERS_MODE_BLEND 14

#define XSI_LAYERS_MASK_MODE_NONE 0
#define XSI_LAYERS_MASK_MODE_CONNECTION 1
#define XSI_LAYERS_MASK_MODE_LAYER_ALPHA 2
#define XSI_LAYERS_MASK_MODE_LAYER_INTENSITY 3
#define XSI_LAYERS_MASK_MODE_LAYER_THRESHOLD 4

float xsi_layers_hardlight(float i_front; float i_back)
{
	return i_front < 0.5
		? 2 * i_front * i_back
		: 1 - 2 * (1 - i_front) * (1 - i_back);
}

float xsi_layers_softlight(float i_front; float i_back)
{
	return i_front < 0.5
		? 2 * i_front * (i_back * 0.5 + 0.25)
		: 1 - 2 * (1 - i_front) * (1 - (i_back * 0.5 + 0.25));
}

float xsi_layers_overlay(float i_front; float i_back)
{
	return xsi_layers_hardlight(i_back, i_front);
}

void xsi_layers_apply(
	RGBA_DECLARE_OUTPUT(io_back);
	RGBA_DECLARE(i_front);
	float i_mode; )
{
	if(i_mode == XSI_LAYERS_MODE_OVER)
	{
		float a = 1-i_front_a;
		io_back = i_front + io_back*a;
		io_back_a = i_front_a + io_back_a*a;
	}
	else if(i_mode == XSI_LAYERS_MODE_IN)
	{
		io_back = i_front * io_back_a;
		io_back_a = i_front_a * io_back_a;
	}
	else if(i_mode == XSI_LAYERS_MODE_OUT)
	{
		float a = 1-i_front_a;
		io_back = i_front * a;
		io_back_a = i_front_a * a;
	}
	else if(i_mode == XSI_LAYERS_MODE_PLUS)
	{
		io_back += i_front;
		io_back_a += i_front_a;
	}
	else if(i_mode == XSI_LAYERS_MODE_BOUNDED_PLUS)
	{
		io_back = clamp(io_back + i_front, 0, 1);
		io_back_a = clamp(io_back_a + i_front_a, 0, 1);
	}
	else if(i_mode == XSI_LAYERS_MODE_MULTIPLY)
	{
		io_back *= i_front;
		io_back_a *= i_front_a;
	}
	else if(i_mode == XSI_LAYERS_MODE_BOUNDED_MULTIPLY)
	{
		io_back = clamp(io_back * i_front, 0, 1);
		io_back_a = clamp(io_back_a * i_front_a, 0, 1);
	}
	else if(i_mode == XSI_LAYERS_MODE_DIFFERENCE)
	{
		io_back[0] = abs(io_back[0]-i_front[0]);
		io_back[1] = abs(io_back[1]-i_front[1]);
		io_back[2] = abs(io_back[2]-i_front[2]);
		io_back_a = abs(io_back_a-i_front_a);
	}
	else if(i_mode == XSI_LAYERS_MODE_DARKEN)
	{
		io_back[0] = min(io_back[0], i_front[0]);
		io_back[1] = min(io_back[1], i_front[1]);
		io_back[2] = min(io_back[2], i_front[2]);
		io_back_a = min(io_back_a, i_front_a);
	}
	else if(i_mode == XSI_LAYERS_MODE_LIGHTEN)
	{
		io_back[0] = max(io_back[0], i_front[0]);
		io_back[1] = max(io_back[1], i_front[1]);
		io_back[2] = max(io_back[2], i_front[2]);
		io_back_a = max(io_back_a, i_front_a);
	}
	else if(i_mode == XSI_LAYERS_MODE_HARD_LIGHT)
	{
		io_back[0] = xsi_layers_hardlight(i_front[0], io_back[0]);
		io_back[1] = xsi_layers_hardlight(i_front[1], io_back[1]);
		io_back[2] = xsi_layers_hardlight(i_front[2], io_back[2]);
		io_back_a = xsi_layers_hardlight(i_front_a, io_back_a);
	}
	else if(i_mode == XSI_LAYERS_MODE_SOFT_LIGHT)
	{
		io_back[0] = xsi_layers_softlight(i_front[0], io_back[0]);
		io_back[1] = xsi_layers_softlight(i_front[1], io_back[1]);
		io_back[2] = xsi_layers_softlight(i_front[2], io_back[2]);
		io_back_a = xsi_layers_softlight(i_front_a, io_back_a);
	}
	else if(i_mode == XSI_LAYERS_MODE_SCREEN)
	{
		io_back += i_front - io_back*i_front;
		io_back_a += i_front_a - io_back_a*i_front_a;
	}
	else if(i_mode == XSI_LAYERS_MODE_OVERLAY)
	{
		io_back[0] = xsi_layers_overlay(i_front[0], io_back[0]);
		io_back[1] = xsi_layers_overlay(i_front[1], io_back[1]);
		io_back[2] = xsi_layers_overlay(i_front[2], io_back[2]);
		io_back_a = xsi_layers_overlay(i_front_a, io_back_a);
	}
	else if(i_mode == XSI_LAYERS_MODE_BLEND)
	{
		io_back = i_front + io_back*(color(1)-i_front);
		io_back_a = i_front_a + io_back_a*(1-i_front_a);
	}
}

void xsi_layers(
	float i_scalarBases[];
	RGBA_ARRAY_DECLARE(i_colorBases);
	RGBA_ARRAY_DECLARE(i_layerColors);
	float i_layerColorsPremultiplied[];
	bool i_layerUseColorAlphas[];
	bool i_layerIgnoreColorAlphas[];
	bool i_layerInvertColorAlphas[];
	float i_layerMasks[];
	bool i_layerInvertMasks[];
	float i_layerMaskModes[];
	float i_layerMaskThresholds[];
	bool i_layerMutes[];
	bool i_layerSolos[];
	float i_layerWeights[];
	float i_layerModes[];
	float i_portInputLayers[];
	float i_portOutputChannels[];
	float i_portScales[];
	float i_portInvert[];
	float i_portUseAlphas[];
	output float o_scalarChannels[];
	RGBA_ARRAY_DECLARE_OUTPUT(o_colorChannels); )
{
	float nbLayers = arraylength(i_layerColors);
	float nbScalarChannels = arraylength(o_scalarChannels);
	float nbColorChannels = arraylength(o_colorChannels);
	float nbChannels = nbScalarChannels + nbColorChannels;
	float nbPorts = arraylength(i_portInputLayers);

	/* Determine whether some layers are soloed or muted */
	bool mute = false;
	bool solo = false;
	float y;
	for(y = 0; y < nbLayers; y += 1)
	{
		if(i_layerMutes[y])
		{
			mute = true;
		}
		if(i_layerSolos[y])
		{
			solo = true;
			break;
		}
	}

	/* Determine which layers are to be used */
	float layerWeights[nbLayers];
	if(solo)
	{
		layerWeights = i_layerSolos;
	}
	else if(mute)
	{
		for(y = 0; y < nbLayers; y += 1)
		{
			layerWeights[y] = 1 - i_layerMutes[y];
		}
	}
	else
	{
		for(y = 0; y < nbLayers; y += 1)
		{
			layerWeights[y] = 1;
		}
	}

	/* Compute the effective weight of each layer */
	for(y = 0; y < nbLayers; y += 1)
	{
		float maskMode = i_layerMaskModes[y];
		float layerMask = 0;
		if(maskMode == XSI_LAYERS_MASK_MODE_NONE)
		{
			layerMask = 1;
		}
		else
		{
			if(maskMode == XSI_LAYERS_MASK_MODE_CONNECTION)
			{
				layerMask = i_layerMasks[y];
			}
			else if(maskMode == XSI_LAYERS_MASK_MODE_LAYER_ALPHA)
			{
				layerMask = i_layerColors_a[y];
			}
			else if(maskMode == XSI_LAYERS_MASK_MODE_LAYER_INTENSITY)
			{
				layerMask = RGB_INT(i_layerColors[y]);
			}
			else if(maskMode == XSI_LAYERS_MASK_MODE_LAYER_THRESHOLD)
			{
				layerMask = RGB_INT(i_layerColors[y]) < i_layerMaskThresholds[y] ? 0 : 1;
			}

			if(i_layerInvertMasks[y])
			{
				layerMask = 1 - layerMask;
			}
		}
		layerWeights[y] *= i_layerWeights[y] * layerMask;
	}
	
	/* Initialize local color ouput channels with their respective base color */
	RGBA_ARRAY_DECLARE_SIZED(channels, nbChannels);
	float c;
	for(c = 0; c < nbScalarChannels; c += 1)
	{
		channels[c] = color(i_scalarBases[c]);
		channels_a[c] = 1;
	}
	for(c = nbScalarChannels; c < nbChannels; c += 1)
	{
		float cc = c - nbScalarChannels;
		channels[c] = i_colorBases[cc];
		channels_a[c] = i_colorBases_a[cc];
	}

	/* Compute the influence of each port on the output channels */
	float p;
	for(p = 0; p < nbPorts; p += 1)
	{
		float y = i_portInputLayers[p];
		float c = i_portOutputChannels[p];
		bool premultiplied = i_layerColorsPremultiplied[y];

		RGBA_DECLARE_INIT2(front, i_layerColors[y], i_layerColors_a[y]);
		if(i_layerIgnoreColorAlphas[y])
		{
			if(premultiplied)
			{
				if(front_a < -1e-6 || front_a > 1e6)
				{
					front /= front_a;
					front_a = 0;
				}
				else
				{
					front = 0;
				}
			}
			front_a = 1;
			premultiplied = true;
		}

		if(i_layerInvertColorAlphas[y])
		{
			if(premultiplied)
			{
				if(front_a < -1e-6 || front_a > 1e6)
				{
					front /= front_a;
					front_a = 0;
				}
				else
				{
					front = 0;
				}
			}
			front_a = 1-front_a;
			premultiplied = false;
		}

		if(i_portUseAlphas[p] != 0 || i_layerUseColorAlphas[y] != 0)
		{
			front = color(front_a);
			front_a = 1;
			premultiplied = true;
		}
		if(i_portInvert[p])
		{
			front = color(front_a) - front;
		}

		if(premultiplied == 0)
		{
			front *= front_a;
		}

		RGBA_DECLARE_INIT2(back, channels[c], channels_a[c]);
		xsi_layers_apply(RGBA_USE(back), RGBA_USE(front), i_layerModes[y]);
		
		float weight = layerWeights[y] * i_portScales[p];
		channels[c] = mix(channels[c], back, weight);
		channels_a[c] = mix(channels_a[c], back_a, weight);
	}

	/*
		Copy the local color output channels back to their corresponding (scalar
		or color) output parameters.
	*/
	for(c = 0; c < nbScalarChannels; c += 1)
	{
		o_scalarChannels[c] = RGB_INT(channels[c]);
	}
	for(c = nbScalarChannels; c < nbChannels; c += 1)
	{
		float cc = c - nbScalarChannels;
		o_colorChannels[cc] = channels[c];
		o_colorChannels_a[cc] = channels_a[c];
	}
}

/* Scalar-only version */
void xsi_layers(
	float i_scalarBases[];
	RGBA_ARRAY_DECLARE(i_layerColors);
	float i_layerColorsPremultiplied[];
	bool i_layerUseColorAlphas[];
	bool i_layerIgnoreColorAlphas[];
	bool i_layerInvertColorAlphas[];
	float i_layerMasks[];
	bool i_layerInvertMasks[];
	float i_layerMaskModes[];
	float i_layerMaskThresholds[];
	bool i_layerMutes[];
	bool i_layerSolos[];
	float i_layerWeights[];
	float i_layerModes[];
	float i_portInputLayers[];
	float i_portOutputChannels[];
	float i_portScales[];
	float i_portInvert[];
	float i_portUseAlphas[];
	output float o_scalarChannels[]; )
{
	RGBA_ARRAY_DECLARE(i_colorBases);
	RGBA_ARRAY_DECLARE(o_colorChannels);
	xsi_layers(
		i_scalarBases,
		RGBA_USE(i_colorBases),
		RGBA_USE(i_layerColors),
		i_layerColorsPremultiplied,
		i_layerUseColorAlphas,
		i_layerIgnoreColorAlphas,
		i_layerInvertColorAlphas,
		i_layerMasks,
		i_layerInvertMasks,
		i_layerMaskModes,
		i_layerMaskThresholds,
		i_layerMutes,
		i_layerSolos,
		i_layerWeights,
		i_layerModes,
		i_portInputLayers,
		i_portOutputChannels,
		i_portScales,
		i_portInvert,
		i_portUseAlphas,
		o_scalarChannels,
		RGBA_USE(o_colorChannels));
}

/* Color-only version */
void xsi_layers(
	RGBA_ARRAY_DECLARE(i_colorBases);
	RGBA_ARRAY_DECLARE(i_layerColors);
	float i_layerColorsPremultiplied[];
	bool i_layerUseColorAlphas[];
	bool i_layerIgnoreColorAlphas[];
	bool i_layerInvertColorAlphas[];
	float i_layerMasks[];
	bool i_layerInvertMasks[];
	float i_layerMaskModes[];
	float i_layerMaskThresholds[];
	bool i_layerMutes[];
	bool i_layerSolos[];
	float i_layerWeights[];
	float i_layerModes[];
	float i_portInputLayers[];
	float i_portOutputChannels[];
	float i_portScales[];
	float i_portInvert[];
	float i_portUseAlphas[];
	RGBA_ARRAY_DECLARE_OUTPUT(o_colorChannels); )
{
	float i_scalarBases[];
	float o_scalarChannels[];
	xsi_layers(
		i_scalarBases,
		RGBA_USE(i_colorBases),
		RGBA_USE(i_layerColors),
		i_layerColorsPremultiplied,
		i_layerUseColorAlphas,
		i_layerIgnoreColorAlphas,
		i_layerInvertColorAlphas,
		i_layerMasks,
		i_layerInvertMasks,
		i_layerMaskModes,
		i_layerMaskThresholds,
		i_layerMutes,
		i_layerSolos,
		i_layerWeights,
		i_layerModes,
		i_portInputLayers,
		i_portOutputChannels,
		i_portScales,
		i_portInvert,
		i_portUseAlphas,
		o_scalarChannels,
		RGBA_USE(o_colorChannels));
}

#endif
