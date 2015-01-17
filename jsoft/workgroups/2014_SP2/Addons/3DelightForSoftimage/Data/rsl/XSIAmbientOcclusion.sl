/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __XSIAmbientOcclusion_sl
#define __XSIAmbientOcclusion_sl

void XSIAmbientOcclusion(
	float i_samples;
	RGBA_COLOR( i_bright );
	RGBA_COLOR( i_dark );
	float i_spread;
	float i_max_distance;
	float i_reflective;
	float i_output_mode;
	float i_occlusion_in_alpha;

	output color o_result;
	output float o_result_a; )
{
	extern point P;
	extern normal N;

	normal Nf = ShadingNormal( normalize(N) );	

	float maxdist = i_max_distance == 0 ? 1e38 : i_max_distance;

	uniform float algorithm = 1; /* default is raytracing */
	uniform float maxsolidangle = 0.1;
	option( "user:xsi_cb_algorithm", algorithm );
	option( "user:xsi_ao_maxsolidangle", maxsolidangle );

	float occ;

	if( algorithm == 2 )
	{
		/* Point-based */
		uniform string bake_file = "";
		option( "user:bake_file", bake_file );

		occ = occlusion(
			P, Nf, i_samples,
			"pointbased", 1,
			"clamp", 1, 
			"filename", bake_file,
			"coordsystem", "world",
			"coneangle", i_spread * PI * 0.5,
			"maxsolidangle", maxsolidangle,
			"maxdist", maxdist );
	}
	else
	{
		/* ray-traced */
		uniform string hitmode = "primitive";
		attribute( "user:occlusion_hitmode", hitmode );

		uniform float falloff = 0;
		uniform float falloffmode = -1;
		attribute( "user:xsi_falloff_type", falloffmode );
		if( falloffmode != -1 )
			attribute( "user:xsi_falloff_exponent", falloff );

		/* Take maxdist from attribute if not 0 */
		uniform float attr_maxdist = 0;
		attribute( "user:xsi_maxdist", attr_maxdist );
		if( attr_maxdist != 0 )
			maxdist = attr_maxdist;

		occ = occlusion(
			P, Nf, i_samples,
			"coneangle", i_spread * PI * 0.5,
			"distribution", "uniform",
			"maxdist", maxdist, "hitmode", hitmode,
			"falloffmode", falloffmode, "falloff", falloff );
	}

	RGBA_MIX(o_result, i_bright, i_dark, occ);
}

/* Softimage 2013 SP1 */
void XSIAmbientOcclusion(
	float i_samples;
	RGBA_COLOR( i_bright );
	RGBA_COLOR( i_dark );
	float i_spread;
	float i_max_distance;
	float i_reflective;
	float i_output_mode;
	float i_occlusion_in_alpha;
	float i_ao_interaction;

	RGBA_DECLARE_OUTPUT( o_result ) )
{
	XSIAmbientOcclusion(
		i_samples,
		RGBA_USE( i_bright ),
		RGBA_USE( i_dark ),
		i_spread,
		i_max_distance,
		i_reflective,
		i_output_mode,
		i_occlusion_in_alpha,

		RGBA_USE( o_result ) );
}

#endif
