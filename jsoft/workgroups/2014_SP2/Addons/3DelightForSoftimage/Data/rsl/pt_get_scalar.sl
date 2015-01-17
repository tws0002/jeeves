/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __pt_get_scalar_sl
#define __pt_get_scalar_sl

#define bool float
#define enum float

#define SCALAR_ID 0
#define SCALAR_RADIUS 1
#define SCALAR_BILLBOARD_ROTATION_ANGLE 2
#define SCALAR_BILLBOARD_ROTATION_ANGLE_SPEED 3
#define SCALAR_PATH_LENGTH 4
#define SCALAR_PRESSURE 5
#define SCALAR_DENSITY 6
#define SCALAR_AGE 7
#define SCALAR_AGE_LIMIT 8
#define SCALAR_SEED 9
#define SCALAR_SPRITE_FRAME 10
#define SCALAR_PARTICLE_TYPE_ID 11
#define SCALAR_GLOBAL_TIME 12
#define SCALAR_GLOBAL_SHUTTER_TIME 13
#define SCALAR_SPEED 14

void pt_get_scalar(
	enum i_dataType;
	bool i_normalize;
	output float o_result; )
{
	extern varying float xsi_particle_id;
	extern varying float xsi_particle_radius;
	extern varying float xsi_particle_billboard_rotation_angle;
	extern varying float xsi_particle_path_length;
	extern varying float xsi_particle_pressure;
	extern varying float xsi_particle_density;
	extern varying float xsi_particle_age;
	extern varying float xsi_particle_age_limit;
	extern varying float xsi_particle_seed;
	extern varying float xsi_particle_sprite_frame;
	extern varying float xsi_particle_particle_type_id;
	extern varying float xsi_particle_velocity[3];
	extern uniform float time;

	if(i_dataType == SCALAR_ID)
	{
		o_result = xsi_particle_id;
	}
	else if(i_dataType == SCALAR_RADIUS)
	{
		o_result = xsi_particle_radius;
	}
	else if(i_dataType == SCALAR_BILLBOARD_ROTATION_ANGLE)
	{
		/* We could also probably use xsi_particle_rotation instead. */
		o_result = xsi_particle_billboard_rotation_angle;
		if(i_normalize)
		{
			o_result /= 2.0 * PI;
		}
	}
	else if(i_dataType == SCALAR_BILLBOARD_ROTATION_ANGLE_SPEED)
	{
		/* This parameter is not available from the XSI SDK. */
		/* We could probably use xsi_particle_rotation_speed instead. */
		o_result = 0;
		if(i_normalize)
		{
			o_result = 0;
		}
	}
	else if(i_dataType == SCALAR_PATH_LENGTH)
	{
		o_result = xsi_particle_path_length;
	}
	else if(i_dataType == SCALAR_PRESSURE)
	{
		o_result = xsi_particle_pressure;
	}
	else if(i_dataType == SCALAR_DENSITY)
	{
		o_result = xsi_particle_density;
	}
	else if(i_dataType == SCALAR_AGE)
	{
		o_result = xsi_particle_age;
		if(i_normalize)
		{
			if(xsi_particle_age_limit == 0)
			{
				o_result = 0;
			}
			else
			{
				o_result /= xsi_particle_age_limit;
			}
		}
	}
	else if(i_dataType == SCALAR_AGE_LIMIT)
	{
		o_result = xsi_particle_age_limit;
	}
	else if(i_dataType == SCALAR_SEED)
	{
		o_result = xsi_particle_seed;
	}
	else if(i_dataType == SCALAR_SPRITE_FRAME)
	{
		o_result = xsi_particle_sprite_frame;
	}
	else if(i_dataType == SCALAR_PARTICLE_TYPE_ID)
	{
		o_result = xsi_particle_particle_type_id;
	}
	else if(i_dataType == SCALAR_GLOBAL_TIME)
	{
		o_result = time;
	}
	else if(i_dataType == SCALAR_GLOBAL_SHUTTER_TIME)
	{
		float shutter[2];
		option("Shutter", shutter);
		o_result = time - shutter[0];
		if(i_normalize)
		{
			o_result /= (shutter[1] - shutter[0]);
		}
	}
	else if(i_dataType == SCALAR_SPEED)
	{
		vector speed =
			vector(
				xsi_particle_velocity[0],
				xsi_particle_velocity[1],
				xsi_particle_velocity[2]);
		o_result = length(speed);
	}
}

void pt_get_scalar(
	enum i_dataType;
	output float o_result; )
{
	pt_get_scalar(i_dataType, false, o_result);
}

#undef SCALAR_ID
#undef SCALAR_RADIUS
#undef SCALAR_BILLBOARD_ROTATION_ANGLE
#undef SCALAR_BILLBOARD_ROTATION_ANGLE_SPEED
#undef SCALAR_PATH_LENGTH
#undef SCALAR_PRESSURE
#undef SCALAR_AGE
#undef SCALAR_AGE_LIMIT
#undef SCALAR_SEED
#undef SCALAR_SPRITE_FRAME
#undef SCALAR_PARTICLE_TYPE_ID
#undef SCALAR_GLOBAL_TIME
#undef SCALAR_GLOBAL_SHUTTER_TIME
#undef SCALAR_SPEED

#endif
