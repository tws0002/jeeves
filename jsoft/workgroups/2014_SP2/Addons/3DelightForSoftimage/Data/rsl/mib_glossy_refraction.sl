/*
 * Copyright (c) DNA Research
*/

#ifndef __mib_glossy_refraction_h
#define __mib_glossy_refraction_h

#include "shading_utils.h"

void mib_glossy_refraction (
	color i_top_material; bool i_top_material_connected;
	color i_deep_material; bool i_deep_material_connected;
	color i_back_material; bool i_back_material_connected;
	bool i_render_reverse_of_back_material;
	color i_refraction_color;
	float i_max_distance;
	float i_falloff;
	float i_refraction_base_weight;
	float i_refraction_edge_weight;
	float i_edge_factor;
	float i_ior;
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
	
	extern normal N;
	extern vector I;
	extern point P;
	
	point z = point (0,0,0);
	
	normal Nn = normalize(N);
	vector In = normalize(I);
	normal Ns = faceforward(Nn, In);
	
	float flf = -In.Nn;	
	float backface = flf>0?0:1;
	
	if(backface == 1 && i_back_material_connected == true)
	{
		if(i_render_reverse_of_back_material == 1)
			o_result = 0;
		else
			o_result = i_back_material;
	}
	else
	{	
		vector T;
		float eta = 1/i_ior;
		
		color b_refr = 0;
		float b_dist = 0;
		color b_trs = 0;
		
		float dist;
		color trs;
		
		vector u_axis;
		if(vector(i_u_axis) == vector(0,0,0))
			u_axis = vtransform("world", "current", vector(1.0, 0.0, 0.0) );
		else
			u_axis = vtransform("world", "current", vector(i_u_axis) );
		
		u_axis = normalize(u_axis);
		
		vector v_axis;
		if(vector(i_v_axis) == vector(0,0,0))
			v_axis = vtransform("world", "current", vector(0.0, 0.0, 1.0) );
		else
			v_axis = vtransform("world", "current", vector(i_v_axis) );
		
		v_axis = normalize(v_axis);
		
		// this constants is HSV (n * 360/7, 1, 1)
		// it is necessary to choose constants more precisely
		
		color rainbow[] = {
			color(1,0,0),
			color(1,0.85,0),
			color(0.2833, 1.0, 0.0),
			color(0,1,0.5667),
			color(0,0.5667,1),
			color(0.2833,0,1),
		color(1,0,0.85) };
		
		float al = arraylength(rainbow);
		
		// Close to mi implementation. In mi documentation other information.	
		if(al <= 0 || al > 7)
			al = 7;
		
		float spread_correct = 0.75;
		float i; for(i=0; i<i_samples; i+=1)
		{
			// http://img176.imageshack.us/img176/5514/glossyrefraction.jpg
			// first of all we ned axis to rotate surface normal
			// cross product of two vectors is vector which is perpendicular
			//   to plane containing the two input vectors
			vector Vr = normalize(Ns^u_axis);
			// random value to rotate surface normal 
			// random value in range [-1..1]
			float rru = (random()-0.5)*2;
			// rotating surface normal in the plane
			vector Nt =
				normalize(rotate(Ns,
					rru * i_u_spread * spread_correct, 
					z, point(Vr) ));
			// rotating surface normal in plane containing v_axis
			Vr = normalize(Ns^v_axis);
			float rrv = (random()-0.5)*2;
			Nt =
			// spread multipled by sqrt(1-rru*rru) because section of spread is ellipse
			normalize(
				rotate(
					Nt,
					rrv * sqrt(1-rru*rru) * i_v_spread * spread_correct, 
					z, point(Vr) ));
			
			// refract, trace
			T = refract(In, Nt, backface==0?eta:1/eta);
			b_refr += trace(
				P, T, dist,
				"transmission", trs,
				"maxdist", i_max_distance) *
				// and mutiply by dispersion
				mix(
					color(1),
					(myspline(rru/2+0.5, al, rainbow) +
					myspline(rrv/2+0.5, al, rainbow))*0.75,
					i_dispersion);
			b_dist += dist;
			b_trs += trs;
		}
		
		b_refr /= i_samples;
		b_dist /= i_samples;
		b_trs /= i_samples;
		
		b_refr *= b_refr;
		
		float deepmult = pow(clamp(1 - b_dist/i_max_distance, 0, 1), i_falloff);
		if(i_max_distance > 0.0)
		{
			b_refr *= deepmult;
			b_refr += i_deep_material*(1-deepmult);
		}
		
		o_result = b_refr * i_refraction_color;
		o_result *= mix(i_refraction_edge_weight, i_refraction_base_weight,
						pow(flf, 1/i_edge_factor));

		XSI_MATERIAL_SET_OUTPUT( Refraction, o_result);
		
		o_result += i_top_material;
	}
}

#endif /* __mib_glossy_refraction_h */

