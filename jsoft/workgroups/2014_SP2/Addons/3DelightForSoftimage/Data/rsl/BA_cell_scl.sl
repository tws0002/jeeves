/*
	Copyright (c) 2010 TAARNA Studios International.
*/

#ifndef __BA_cell_scl_sl
#define __BA_cell_scl_sl

#include "BA_utils.sl"

#define PRESCALE_BIG 0
#define PRESCALE_DEFAULT 1
#define PRESCALE_SMALL 2

#define ALIGNMENT_RANDOM_SPARSE 0
#define ALIGNMENT_RANDOM_DEFAULT 1
#define ALIGNMENT_RANDOM_DENSE 2
#define ALIGNMENT_GRID 3
#define ALIGNMENT_GRID2 4
#define ALIGNMENT_GRID4 5
#define ALIGNMENT_HONEYCOMBS 6

#define CELL_TYPE_ROUND 0
#define CELL_TYPE_FLAGSTONE 1

#define CELL_SHAPE_SQUARE 1
#define CELL_SHAPE_ROUND 2

#define CELL_SCALE_MAGIC 0.066
#define MYSTERY_MAGIC 1.38

void UpdateNeighbors(
	vector i_delta;
	float i_cellShape;
	float i_maxNeighbors;
	output float o_distance[]; // size : i_maxNeighbors
	output vector o_offset[]) // size : i_maxNeighbors
{
	float deltaLength =
		i_cellShape == CELL_SHAPE_ROUND
		? length(i_delta)
		: abs(i_delta[0]) + abs(i_delta[1]) + abs(i_delta[2]);
	float s = i_maxNeighbors;
	while(s > 0 && (o_distance[s-1] < 0.0 || deltaLength < o_distance[s-1]))
	{
		s -= 1;
	}

	if(s < i_maxNeighbors)
	{
		float t = s+1;
		while(t < i_maxNeighbors)
		{
			o_distance[t] = o_distance[t-1];
			o_offset[t] = o_offset[t-1];
			t += 1;
		}
		o_distance[s] = deltaLength;
		o_offset[s] = i_delta;
	}
}	

void MergeRandomCellPoints(
	point i_sample;
	point i_cellCoord;
	point i_cellRoot;
	float i_minNbPoints;
	float i_maxNbPoints;
	float i_cellShape;
	float i_maxNeighbors;
	output float o_distance[]; // size : i_maxNeighbors
	output vector o_offset[]) // size : i_maxNeighbors
{
	float n = cellnoise(i_cellCoord);

	float nbPoints = n * (i_maxNbPoints-i_minNbPoints+1) + i_minNbPoints;
	
	float i;
	for(i = 0; i < nbPoints; i += 1)
	{
		vector offset = cellnoise(i_cellCoord, i);
		point p = i_cellRoot + offset;
		UpdateNeighbors(p-i_sample, i_cellShape, i_maxNeighbors, o_distance, o_offset);
	}
}	

void MergeCellPoints(
	point i_sample;
	point i_cellCoord;
	point i_cellRoot;
	vector i_offsets[];
	float i_jitter;
	float i_cellShape;
	float i_maxNeighbors;
	output float o_distance[]; // size : i_maxNeighbors
	output vector o_offset[]) // size : i_maxNeighbors
{
	float f;
	for(f = 0; f < arraylength(i_offsets); f += 1)
	{
		vector n = cellnoise(i_cellCoord, f);
		vector jitter = (n - 0.5) * i_jitter;
		point p = i_cellRoot + i_offsets[f] + jitter;
		UpdateNeighbors(p - i_sample, i_cellShape, i_maxNeighbors, o_distance, o_offset);
	}
}

float BA_worley(
	point i_coord;
	float i_maxNeighbors;
	output float o_distance[]; // size : i_maxNeighbors
	output vector o_offset[];  // size : i_maxNeighbors
	uniform float i_shape_alignment;
	float i_shape;
	float i_shape_jitter)
{
	float i;
	for(i = 0; i < i_maxNeighbors; i += 1)
	{
		o_distance[i] = -1.0;
	}

	point cellCoord = point(floor(i_coord[0]), floor(i_coord[1]), floor(i_coord[2]));
	point cellRoot = cellCoord;
	if(i_shape_alignment >= ALIGNMENT_RANDOM_SPARSE &&
		i_shape_alignment <= ALIGNMENT_RANDOM_DENSE)
	{
		float min = i_shape_alignment == ALIGNMENT_RANDOM_DENSE ? 3 : 0;
		float max = i_shape_alignment == ALIGNMENT_RANDOM_SPARSE ? 1 : 4;

// TODO : avoiding visiting outer cells when possible
		uniform float i, j, k;
		for(i = -1; i <= 1; i += 1)
		{
			for(j = -1; j <= 1; j += 1)
			{
				for(k = -1; k <= 1; k += 1)
				{
					MergeRandomCellPoints(
						i_coord, 
						cellCoord + vector(i, j, k), 
						cellRoot + vector(i, j, k), 
						min, max,
						i_shape,
						i_maxNeighbors, o_distance, o_offset);
				}
			}
		}
	}
	else if(i_shape_alignment == ALIGNMENT_GRID)
	{
		uniform vector offsets[1] = 
		{
			vector(0.15, 0.15, 0.15)
		};

// TODO : avoiding visiting outer cells when possible
		uniform float i, j, k;
		for(i = -1; i <= 1; i += 1)
		{
			for(j = -1; j <= 1; j += 1)
			{
				for(k = -1; k <= 1; k += 1)
				{
					MergeCellPoints(
						i_coord,
						cellCoord + vector(i, j, k), 
						cellRoot + vector(i, j, k), 
						offsets,
						i_shape_jitter, 
						i_shape,
						i_maxNeighbors, o_distance, o_offset);
				}
			}
		}
	}
	else if(i_shape_alignment == ALIGNMENT_GRID2)
	{
		uniform vector offsets[2] = 
		{
			vector(0.05, 0.05, 0.05),
			vector(0.55, 0.55, 0.55)
		};

// TODO : avoiding visiting outer cells when possible
		uniform float i, j, k;
		for(i = -1; i <= 1; i += 1)
		{
			for(j = -1; j <= 1; j += 1)
			{
				for(k = -1; k <= 1; k += 1)
				{
					MergeCellPoints(
						i_coord,
						cellCoord + vector(i, j, k), 
						cellRoot + vector(i, j, k), 
						offsets,
						i_shape_jitter, 
						i_shape,
						i_maxNeighbors, o_distance, o_offset);
				}
			}
		}
	}
	else if(i_shape_alignment == ALIGNMENT_GRID4)
	{
		uniform vector offsets[4] = 
		{
			vector(0.55, 0.05, 0.0),
			vector(0.05, 0.55, 0.0),
			vector(0.05, 0.05, 0.5),
			vector(0.55, 0.55, 0.5)
		};

// TODO : avoiding visiting outer cells when possible
		uniform float i, j, k;
		for(i = -1; i <= 1; i += 1)
		{
			for(j = -1; j <= 1; j += 1)
			{
				for(k = -1; k <= 1; k += 1)
				{
					MergeCellPoints(
						i_coord,
						cellCoord + vector(i, j, k), 
						cellRoot + vector(i, j, k), 
						offsets,
						i_shape_jitter, 
						i_shape,
						i_maxNeighbors, o_distance, o_offset);
				}
			}
		}
	}
	else if(i_shape_alignment == ALIGNMENT_HONEYCOMBS)
	{
// TODO : avoiding visiting outer cells when possible
		uniform float i, j, k;
		for(i = -1; i <= 1; i += 1)
		{
			for(j = -1; j <= 1; j += 1)
			{
				for(k = -1; k <= 1; k += 1)
				{
					vector offsets[] = 
					{
						vector(
							mod(cellCoord[1]+j, 2) * 0.5 + 0.05,
							mod(cellCoord[2]+k, 2) * 0.5 + 0.05,
							mod(cellCoord[0]+i, 2) * 0.5 + 0.05)
					};
					MergeCellPoints(
						i_coord,
						cellCoord + vector(i, j, k), 
						cellRoot + vector(i, j, k), 
						offsets,
						i_shape_jitter, 
						i_shape,
						i_maxNeighbors, o_distance, o_offset);
				}
			}
		}
	}
	
	for(i = 0; i < i_maxNeighbors; i += 1)
	{
		if(o_distance[i] < 0)
		{
			break;
		}
	}
	return i;
}

void BA_cell_scl(
	float i_fill;
	float i_border;
	float i_grad_min;
	float i_grad_max;
	bool i_straightborders;
	uniform float i_shape_alignment;
	float i_shape_jitter;
	float i_shape;
	float i_cell_type;
	bool i_external_coord;
	point i_coord;
	point i_ext_coord;
	point i_coord_scale;
	float i_coord_prescale;
	float i_grad_bias;
	float i_coord_scale_global;
	output float o_result)
{
	point coord_scale = i_coord_scale;
	if(i_coord_prescale == PRESCALE_BIG)
	{
		coord_scale /= 50.0;
	}
	else if(i_coord_prescale == PRESCALE_SMALL)
	{
		coord_scale *= 50.0;
	}
	
	coord_scale *= i_coord_scale_global * CELL_SCALE_MAGIC;

	point coord;
	if(i_external_coord == false)
	{
		coord = i_coord;
	}
	else if(i_ext_coord[0] != point(0))
	{
		coord = i_ext_coord;
	}
	else
	{
		coord = transform("object", P);
	}
	
	coord *= coord_scale;

	float maxNeighbors = clamp(i_cell_type, 0, 1) + 1;
	float distance[maxNeighbors];
	vector offset[maxNeighbors];
	float nbNeighbors = BA_worley(coord, maxNeighbors, distance, offset, i_shape_alignment, i_shape, i_shape_jitter);

	float a = 1.0;
	if(i_cell_type == CELL_TYPE_FLAGSTONE)
	{
		if(nbNeighbors >= 2)
		{
			a = (distance[1] - distance[0]) * MYSTERY_MAGIC;
			if(i_straightborders)
			{
				a /= length(offset[0]-offset[1]) / (length(offset[0]) + length(offset[1]));
			}
		}
	}
	else
	{
		if(nbNeighbors >= 1)
		{
			if(i_shape == CELL_SHAPE_SQUARE)
			{
				a = 1.0 - (sqrt(distance[0])*MYSTERY_MAGIC-0.1) * 0.7;
			}
			else
			{
				a = 1.0 - distance[0]*MYSTERY_MAGIC * 0.9;
			}
		}
	}

	if(i_grad_min != i_grad_max)
	{
		a = (a-i_grad_min) / (i_grad_max-i_grad_min);
	}
	a = BA_bias(a, i_grad_bias);

	o_result = mix(i_border, i_fill, a);
}

#endif
