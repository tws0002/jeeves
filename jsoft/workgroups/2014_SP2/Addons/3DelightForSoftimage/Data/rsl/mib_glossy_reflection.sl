/*
 * Copyright (c) 2010 DNA Research
*/

#ifndef __mib_glossy_reflection_h
#define __mib_glossy_reflection_h

color myspline(float value; float al; color acolors[])
{
	float clength = al;
	float j = value*(clength-1);
	j = j<(clength-1)?j:clength-1.0001;
	if(clength == 1)
		return acolors[0];
	else
		return mix(
			acolors[floor(j)],
			acolors[floor(j+1)],
			mod(j, 1) );
}

void mib_glossy_reflection(
	color i_base_material; bool i_base_material_connected;
	RGBA_COLOR( i_reflection_color);
	float i_max_distance;
	float i_falloff;
	RGBA_COLOR( i_environment_color );
	float i_reflection_base_weight;
	float i_reflection_edge_weight;
	float i_edge_factor;
	color i_environment; bool i_environment_connected;
	bool i_single_env_sample;
	float i_samples;
	float i_u_spread;
	float i_v_spread;
	point i_u_axis;
	point i_v_axis;
	float i_dispersion;

	output color o_result;
	output float o_result_a;
	)
{
	extern normal N;
	extern vector I;
	extern point P;

	point z = point (0,0,0);

	normal Nn = normalize(N);
	vector In = normalize(I);

	vector Rn = normalize( reflect(In, Nn) );

	color b_refl = 0;
	float b_dist = 0;
	color b_trs = 0;
	color b_disp = 0;

	float dist;
	color trs;

	float flf = -In.Nn;

	vector u_axis;
	if(vector(i_u_axis) == vector(0,0,0))
		u_axis = vtransform("object", "current", vector(1.0, 0.0, 0.0) );
	else
		u_axis = vtransform("object", "current", vector(i_u_axis) );

	u_axis = normalize(u_axis);

	vector v_axis;
	if(vector(i_v_axis) == vector(0,0,0))
		v_axis = vtransform("object", "current", vector(0.0, 0.0, 1.0) );
	else
		v_axis = vtransform("object", "current", vector(i_v_axis) );

	v_axis = normalize(v_axis);

	color rainbow[] = {
		color(1,0,0),
		color(1,0.85,0),
		color(0.2833, 1.0, 0.0),
		color(0,1,0.5667),
		color(0,0.5667,1),
		color(0.2833,0,1),
		color(1,0,0.85) };

	float al = arraylength(rainbow);

	if(al <= 0 || al > 7)
		al = 7;

	float i; for(i=0; i<i_samples; i+=1)
	{
		vector myrotatev = normalize(Nn^u_axis);
		float rru = (random()-0.5)*2;
		vector tNn =
			normalize(rotate(vector(Nn),
			rru * i_u_spread, 
			z, point(myrotatev)));
		myrotatev = normalize(Nn^v_axis);
		float rrv = (random()-0.5)*2;
		tNn =
			normalize(rotate(vector(tNn),
			rrv * sqrt(1-rru*rru) * i_v_spread, 
			z, point(myrotatev)));
		vector R = reflect(In, tNn);
		b_refl += trace(P, R, dist, "transmission", trs, "maxdist", i_max_distance) *
			mix(color(1),(myspline(rru/2+0.5, al, rainbow)+
				myspline(rrv/2+0.5, al, rainbow))*0.75, i_dispersion);
		b_dist += dist;
		b_trs  += trs;
	}

	b_refl /= i_samples;
	b_dist /= i_samples;
	b_trs  /= i_samples;

	float distance_multiplier = 1;
	if(i_max_distance > 0.0)
		distance_multiplier = pow(clamp(1 - b_dist/i_max_distance, 0, 1), i_falloff);
	b_refl *= distance_multiplier;
	
	o_result = b_refl*i_reflection_color;
	o_result *= mix(i_reflection_edge_weight, i_reflection_base_weight,
		pow(flf, 1/i_edge_factor));

	XSI_MATERIAL_SET_OUTPUT( Reflection, o_result);

	o_result += i_base_material;
}
#endif /* __mib_glossy_reflection_h */
