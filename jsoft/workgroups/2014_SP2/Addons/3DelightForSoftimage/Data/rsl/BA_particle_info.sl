/*
	Copyright (c) 2009 TAARNA Studios International.
*/

#ifndef __BA_particle_info_sl
#define __BA_particle_info_sl

#define PARTICLE_SIZE 0
#define PARTICLE_ACE_PERCENT 1
#define PARTICLE_DENSITY_ALPHA 2
#define PARTICLE_DENSITY_AFTER_FALLOFF 3
#define PARTICLE_VELOCITY 4
#define PARTICLE_ID 5

#define bool float

void BA_particle_info(
	float i_info_type;
	float i_old_min;
	float i_old_max;
	float i_new_min; /* ignored! */
	float i_new_max;
	bool i_change_range; /* ignored! */
	bool i_clamp;
	output float o_result)
{
	if(i_old_min == i_old_max) o_result = 0.0;
	else
	{
		float value = 0.0;
		if(i_info_type == PARTICLE_SIZE)
		{
			value = Particle_Shading_in_size;
		}
		else if(i_info_type == PARTICLE_ACE_PERCENT)
		{
			value = Particle_Shading_in_age_percent;
		}
		else if(i_info_type == PARTICLE_DENSITY_ALPHA)
		{
			value = Particle_Shading_in_density_alpha;
		}
		else if(i_info_type == PARTICLE_DENSITY_AFTER_FALLOFF)
		{
			value = Particle_Shading_in_density_after_falloff;
		}
		else if(i_info_type == PARTICLE_VELOCITY)
		{
			value = Particle_Shading_in_velocity;
		}
		else if(i_info_type == PARTICLE_ID)
		{
			value = Particle_Shading_in_ID;
		}

		if(i_clamp)
		{
			value = clamp(value, i_old_min, i_old_max);
		}

		o_result = (value - i_old_min) / (i_old_max - i_old_min) * i_new_max;
	}
}

#undef PARTICLE_SIZE
#undef PARTICLE_ACE_PERCENT
#undef PARTICLE_DENSITY_ALPHA
#undef PARTICLE_DENSITY_AFTER_FALLOFF
#undef PARTICLE_VELOCITY
#undef PARTICLE_ID

#endif
