/*
	Copyright (c) 2010 TAARNA Studios International.
*/

#ifndef __BA_particle_gradientcontrol_sl
#define __BA_particle_gradientcontrol_sl

#define bool float

void BA_particle_gradientcontrol(
	uniform float i_start1;
	uniform float i_end1;
	float i_intensity1;
	float i_start2;
	float i_end2;
	float i_intensity2;
	uniform bool i_enable3;
	float i_input3;
	uniform float i_start3;
	uniform float i_end3;
	float i_intensity3;
	uniform bool i_enable4;
	float i_input4;
	uniform float i_start4;
	uniform float i_end4;
	float i_intensity4;
	uniform bool i_enable5;
	float i_input5;
	uniform float i_start5;
	uniform float i_end5;
	float i_intensity5;
	uniform bool i_enable6;
	float i_input6;
	uniform float i_start6;
	uniform float i_end6;
	float i_intensity6;
	uniform bool i_adjust1; /* unused */
	uniform bool i_adjust2; /* unused */
	uniform bool i_adjust3;
	uniform bool i_adjust4;
	uniform bool i_adjust5;
	uniform bool i_adjust6;
	output float o_result)
{
	extern float Particle_Shading_in_total_alpha;
	extern float Particle_Shading_in_age_percent;

	o_result = 0;

	uniform bool enable[6] = { true, true, i_enable3, i_enable4, i_enable5, i_enable6 };
	float input[6] = { Particle_Shading_in_total_alpha, Particle_Shading_in_age_percent, i_input3, i_input4, i_input5, i_input6 };
	uniform float start[6] = { i_start1, i_start2, i_start3, i_start4, i_start5, i_start6 };
	uniform float end[6] = { i_end1, i_end2, i_end3, i_end4, i_end5, i_end6 };
	float intensity[6] = { i_intensity1, i_intensity2, i_intensity3, i_intensity4, i_intensity5, i_intensity6 };
	uniform bool adjust[6] = { false, false, i_adjust3, i_adjust4, i_adjust5, i_adjust6 };

	float i;
	float maxIntensity = 0.0;
	for(i = 0; i < 6; i += 1)
	{
		if(enable[i] == true)
		{
			float inputRange = end[i] - start[i];
			if(inputRange == 0.0 || intensity[i] <= 0.0)
			{
				continue;
			}

			float normalizedInput = clamp((input[i] - start[i]) / inputRange, 0.0, 1.0);
			if(adjust[i])
			{
				float signedNormalizedInput = 2*normalizedInput - 1;
				o_result += signedNormalizedInput * intensity[i];
			}
			else
			{
				o_result += normalizedInput * intensity[i];
				maxIntensity += intensity[i];
			}
		}
	}
	
	if(maxIntensity > 0.0)
	{
		o_result /= maxIntensity;
	}

	o_result = clamp(o_result, 0.0, 1.0);
}

#endif
