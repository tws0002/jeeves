/*
	Copyright (c) 2007 TAARNA Studios International.
*/

#ifndef __pt_get_vector_sl
#define __pt_get_vector_sl

#define bool float
#define enum float

#define VECTOR_POSITION 0
#define VECTOR_COMPUTED_POSITION 1
#define VECTOR_VELOCITY 2
#define VECTOR_ROTATION 3
#define VECTOR_ROTATION_SPEED 4
#define VECTOR_UVW 5

void pt_get_vector(
	enum i_dataType;
	point i_overrideVector;
	bool i_overrideX;
	bool i_overrideY;
	bool i_overrideZ;
	bool i_normalize;
	output point o_result; )
{
	extern varying float xsi_particle_position[3];
	extern varying float xsi_particle_velocity[3];
	extern varying float xsi_particle_rotation[3];
	extern varying float xsi_particle_rotation_speed[3];
	extern varying float xsi_particle_uvw[3];

	if(i_overrideX == false || i_overrideY == false || i_overrideZ == false)
	{
		if(i_dataType == VECTOR_POSITION ||
			i_dataType == VECTOR_COMPUTED_POSITION)
		{
			o_result =
				vector(
					xsi_particle_position[0],
					xsi_particle_position[1],
					xsi_particle_position[2]);
		}
		else if(i_dataType == VECTOR_VELOCITY)
		{
			o_result =
				vector(
					xsi_particle_velocity[0],
					xsi_particle_velocity[1],
					xsi_particle_velocity[2]);
			if(i_normalize)
			{
				o_result = normalize(o_result);
			}
		}
		else if(i_dataType == VECTOR_ROTATION)
		{
			o_result =
				vector(
					xsi_particle_rotation[0],
					xsi_particle_rotation[1],
					xsi_particle_rotation[2]);
			if(i_normalize)
			{
				o_result[0] /= mod(o_result[0] / (2.0 * PI), 1.0);
				o_result[1] /= mod(o_result[1] / (2.0 * PI), 1.0);
				o_result[2] /= mod(o_result[2] / (2.0 * PI), 1.0);
			}
		}
		else if(i_dataType == VECTOR_ROTATION_SPEED)
		{
			o_result =
				vector(
					xsi_particle_rotation_speed[0],
					xsi_particle_rotation_speed[1],
					xsi_particle_rotation_speed[2]);
			if(i_normalize)
			{
				o_result[0] /= 2.0 * PI;
				o_result[1] /= 2.0 * PI;
				o_result[2] /= 2.0 * PI;
			}
		}
		else if(i_dataType == VECTOR_UVW)
		{
			o_result =
				vector(
					xsi_particle_uvw[0],
					xsi_particle_uvw[1],
					xsi_particle_uvw[2]);
		}
		else
		{
			o_result = point(0, 0, 0);
		}
	}

	if(i_overrideX)
	{
		o_result[0] = i_overrideVector[0];
	}
	if(i_overrideY)
	{
		o_result[1] = i_overrideVector[1];
	}
	if(i_overrideZ)
	{
		o_result[2] = i_overrideVector[2];
	}
}

void pt_get_vector(
	enum i_dataType;
	point i_overrideVector;
	bool i_overrideX;
	bool i_overrideY;
	bool i_overrideZ;
	output point o_result; )
{
	pt_get_vector(
		i_dataType, 
		i_overrideVector, 
		i_overrideX, 
		i_overrideY, 
		i_overrideZ, 
		false, 
		o_result);
}

#undef VECTOR_POSITION
#undef VECTOR_COMPUTED_POSITION
#undef VECTOR_VELOCITY
#undef VECTOR_ROTATION
#undef VECTOR_ROTATION_SPEED
#undef VECTOR_UVW

#endif
