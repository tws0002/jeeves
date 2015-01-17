
#include <xsi_application.h>
#include <xsi_context.h>
#include <xsi_pluginregistrar.h>
#include <xsi_status.h>

#include <xsi_icenodecontext.h>
#include <xsi_icenodedef.h>
#include <xsi_icenode.h>
#include <xsi_icenodeport.h>
#include <xsi_icenodeoutputport.h>
#include <xsi_command.h>
#include <xsi_factory.h>
#include <xsi_math.h>
#include <xsi_vector2f.h>
#include <xsi_vector3f.h>
#include <xsi_vector4f.h>
#include <xsi_matrix3f.h>
#include <xsi_matrix4f.h>
#include <xsi_rotationf.h>
#include <xsi_quaternionf.h>
#include <xsi_color4f.h>
#include <xsi_shape.h>
#include <xsi_indexset.h>
#include <xsi_dataarray.h>
#include <xsi_dataarray2D.h>
#include <xsi_icegeometry.h>
#include <xsi_doublearray.h>
#include <xsi_random.h>
#include <xsi_progressbar.h>
#include <xsi_uitoolkit.h>
#include <vector>
#include <map>
#include <xsi_iceportstate.h>
#include <algorithm>
#include <cmath>

// Defines port, group and map identifiers used for registering the ICENode
enum IDs
{
	ID_IN_geometry = 0,
	ID_IN_size_array = 2,
	ID_IN_variance = 3,
	ID_IN_iterations = 4,
	ID_IN_randomise = 5,
	ID_IN_seed,
	ID_IN_max_size,
	ID_IN_spacing,
	ID_IN_iteration_abort,
	ID_IN_erase,
	ID_IN_erasethreshold,
	ID_IN_size_map_absolute,
	ID_IN_random_absolute,
	ID_IN_min_size,
	ID_G_101 = 101,
	ID_OUT_sample_points = 200,
	ID_OUT_sizes = 201,
	ID_OUT_indices,
	ID_TYPE_CNS = 400,
	ID_STRUCT_CNS,
	ID_CTXT_CNS,
	ID_UNDEF = ULONG_MAX
};

XSI::CStatus RegisterDart_Throw_Version_3( XSI::PluginRegistrar& in_reg );

using namespace XSI;
using namespace std;

class CData
{
public:
	CData(): spacing_dirty(0) {}
	vector<MATH::CVector3f> v;
	vector<float> size;
	vector<long> indices;
	XSI::MATH::CMatrix4f transfo;
	
	int validgeom;
	float spacing_sum;
	float erase_sum;
	int spacing_dirty;
	int erase_dirty;
};


//set up the pair mapping variables and comparator
typedef std::pair<float,long> mypair;

bool comparator ( const mypair& l, const mypair& r)
   { return l.first < r.first; }

XSIPLUGINCALLBACK CStatus XSILoadPlugin( PluginRegistrar& in_reg )
{
	in_reg.PutAuthor(L"jj");
	in_reg.PutName(L"Dart_Throw_Version_3 Plugin");
	in_reg.PutVersion(3,0);

	RegisterDart_Throw_Version_3( in_reg );

	return CStatus::OK;
}

CStatus RegisterDart_Throw_Version_3( PluginRegistrar& in_reg )
{
	ICENodeDef nodeDef;
	nodeDef = Application().GetFactory().CreateICENodeDef(L"Dart_Throw_Version_3",L"Dart_Throw_Version_3");

	nodeDef.PutThreadingModel(XSI::siICENodeMultiEvaluationPhase);

	nodeDef.AddPortGroup(ID_G_101);

	nodeDef.AddInputPort(	ID_IN_geometry, ID_G_101,
		siICENodeDataGeometry,siICENodeStructureSingle,siICENodeContextSingleton,
		L"Geometry",L"Geometry" );

	nodeDef.AddInputPort(	ID_IN_size_array, ID_G_101,
		siICENodeDataFloat,siICENodeStructureAny,siICENodeContextSingleton,
		L"Size",L"Size");

	nodeDef.AddInputPort(	ID_IN_iterations,ID_G_101,
		siICENodeDataLong,siICENodeStructureSingle,siICENodeContextSingleton,
		L"Iterations",L"Iterations",(LONG)5);

	nodeDef.AddInputPort(	ID_IN_iteration_abort,ID_G_101,
		siICENodeDataFloat,siICENodeStructureSingle,siICENodeContextSingleton,
		L"Iteration Abort Threshold",L"Iteration Abort Threshold",float(1.0), float(0), float(1), ULONG_MAX,ULONG_MAX,ULONG_MAX);

	nodeDef.AddInputPort(	ID_IN_size_map_absolute, ID_G_101,
		siICENodeDataBool,siICENodeStructureSingle,siICENodeContextSingleton,
		L"Use Absolute Size",L"Use Absolute Size",0);

	nodeDef.AddInputPort(	ID_IN_spacing,ID_G_101,
		siICENodeDataFloat,siICENodeStructureSingle,siICENodeContextAny,
		L"Size Map",L"Size Map",float(0.0));

	nodeDef.AddInputPort(	ID_IN_max_size,ID_G_101,
		siICENodeDataFloat,siICENodeStructureSingle,siICENodeContextSingleton,
		L"Adjusted Size",L"Adjusted Size",float(1.0),float(0.000001), float(ULONG_MAX), ULONG_MAX, ULONG_MAX,ULONG_MAX);

	nodeDef.AddInputPort(	ID_IN_erase,ID_G_101,
		siICENodeDataFloat,siICENodeStructureSingle,siICENodeContextAny,
		L"Erase Map",L"Erase Map",float(0.0));

	nodeDef.AddInputPort(	ID_IN_erasethreshold,ID_G_101,
		siICENodeDataFloat,siICENodeStructureSingle,siICENodeContextAny,
		L"Erase Threshold",L"Erase Threshold",float(1.0), float(0), float(1), ULONG_MAX, ULONG_MAX, ULONG_MAX);

	nodeDef.AddInputPort(	ID_IN_randomise, ID_G_101,
		siICENodeDataBool,siICENodeStructureSingle,siICENodeContextSingleton,
		L"Randomise",L"Randomise",0);

	nodeDef.AddInputPort(	ID_IN_random_absolute, ID_G_101,
		siICENodeDataBool,siICENodeStructureSingle,siICENodeContextSingleton,
		L"Use Absolute Random",L"Use Absolute Random",0);

	nodeDef.AddInputPort(	ID_IN_variance,ID_G_101,
		siICENodeDataFloat,siICENodeStructureSingle,siICENodeContextSingleton,
		L"Variance",L"Variance",float(0.0), float(0.000001), float(ULONG_MAX), ULONG_MAX, ULONG_MAX, ULONG_MAX);

	nodeDef.AddInputPort(	ID_IN_seed,ID_G_101,
		siICENodeDataLong,siICENodeStructureSingle,siICENodeContextSingleton,
		L"Seed",L"Seed",(LONG)1);

	nodeDef.AddInputPort(	ID_IN_min_size, ID_G_101,
		siICENodeDataFloat,siICENodeStructureSingle,siICENodeContextSingleton, 
		L"Min Size",L"Min Size", float(0.01));

	// Add output ports.
	nodeDef.AddOutputPort(	ID_OUT_sample_points,
		siICENodeDataVector3,siICENodeStructureSingle,siICENodeContextElementGenerator,
		L"Points",L"Points");

	nodeDef.AddOutputPort(	ID_OUT_sizes,
		siICENodeDataFloat,siICENodeStructureArray,siICENodeContextSingleton,
		L"Sizes",L"Sizes");

	nodeDef.AddOutputPort(	ID_OUT_indices,
		siICENodeDataLong,siICENodeStructureArray,siICENodeContextSingleton,
		L"Indices",L"Indices");

	PluginItem nodeItem = in_reg.RegisterICENode(nodeDef);
	//nodeItem.PutCategories(L"Custom ICENode");

	return CStatus::OK;
}

XSIPLUGINCALLBACK CStatus Dart_Throw_Version_3_SubmitEvaluationPhaseInfo( ICENodeContext& in_ctxt )
{
	ULONG nPhase = in_ctxt.GetEvaluationPhaseIndex( );
	switch( nPhase )
	{
	case 0:
		{
			in_ctxt.AddEvaluationPhaseInputPort( ID_IN_spacing );
			in_ctxt.AddEvaluationPhaseInputPort( ID_IN_erase );
			in_ctxt.AddEvaluationPhaseInputPort( ID_IN_size_array );
		}
		break;
	case 1:
		{
			in_ctxt.AddEvaluationPhaseInputPort( ID_IN_geometry );
			in_ctxt.AddEvaluationPhaseInputPort( ID_IN_variance );
			in_ctxt.AddEvaluationPhaseInputPort( ID_IN_iterations );
			in_ctxt.AddEvaluationPhaseInputPort( ID_IN_randomise );
			in_ctxt.AddEvaluationPhaseInputPort( ID_IN_seed );
			in_ctxt.AddEvaluationPhaseInputPort( ID_IN_max_size );
			in_ctxt.AddEvaluationPhaseInputPort( ID_IN_iteration_abort );
			in_ctxt.AddEvaluationPhaseInputPort( ID_IN_erasethreshold );
			in_ctxt.AddEvaluationPhaseInputPort( ID_IN_size_map_absolute);
			in_ctxt.AddEvaluationPhaseInputPort( ID_IN_random_absolute);
			in_ctxt.AddEvaluationPhaseInputPort( ID_IN_min_size);
			// This phase is the last one. All ports specified for phase 1 will be evaluated in multi-threaded batches.
			in_ctxt.SetLastEvaluationPhase();
		}
		break;
	}
	return CStatus::OK;
}

void ClearDirtyStates(ICENodeContext& in_ctxt)
{
	CICEPortState geoport(in_ctxt, ID_IN_geometry);
	CICEPortState size_arrayport(in_ctxt, ID_IN_size_array);
	CICEPortState varianceport(in_ctxt, ID_IN_variance);
	CICEPortState iterationsport(in_ctxt, ID_IN_iterations);
	CICEPortState randomise(in_ctxt, ID_IN_randomise);
	CICEPortState seed(in_ctxt, ID_IN_seed);
	CICEPortState max_size(in_ctxt, ID_IN_max_size);
	CICEPortState spacing(in_ctxt, ID_IN_spacing);
	CICEPortState iteration_abort(in_ctxt, ID_IN_iteration_abort);
	CICEPortState erase_threshold(in_ctxt, ID_IN_erasethreshold);
	CICEPortState size_map_absolute(in_ctxt,ID_IN_size_map_absolute);
	CICEPortState random_absolute(in_ctxt,ID_IN_random_absolute);
	CICEPortState min_size(in_ctxt,ID_IN_min_size);

	geoport.ClearState();
	size_arrayport.ClearState();
	varianceport.ClearState();
	iterationsport.ClearState();
	randomise.ClearState();
	seed.ClearState();
	max_size.ClearState();
	spacing.ClearState();
	iteration_abort.ClearState();
	erase_threshold.ClearState();
	size_map_absolute.ClearState();
	random_absolute.ClearState();
	min_size.ClearState();
}

XSIPLUGINCALLBACK CStatus Dart_Throw_Version_3_BeginEvaluate( ICENodeContext& in_ctxt )
{	
	/*NOTE---------------------------------------------------------------------
	This is an 'early out' in case there is no geometry connected. Geometry 
	IsValid doesn't test for the existence of points i.e. an empty pointcloud
	is valid geo. Since we do the geometry validation at in Begin Evaluate
	we might as well store the result in user data since the program is 
	going to go to Evaluate anyway. We can then use this 'validgeom' flag
	to tell Evaluate what to do i.e. don't process any elements at all
	--------------------------------------------------------------------------*/
	CICEGeometry geom( in_ctxt, ID_IN_geometry );
	if (geom.GetPointPositionCount() == 0)//i.e. there is some valid geo otherwise we get crashes
	{
		if ( !in_ctxt.GetUserData().IsEmpty() )//if it's not empty, empty it
		{
			CData * pData = (CData *)(CValue::siPtrType)in_ctxt.GetUserData( );
			delete pData;
		}
		CData * pData = new CData;

		pData->validgeom = 0;
		in_ctxt.PutUserData( (CValue::siPtrType) pData );
		in_ctxt.PutNumberOfElementsToProcess( long(0) );
		ClearDirtyStates(in_ctxt);
		return CStatus::OK;//exit out of BeginEvaluate
	}

	/*NOTE---------------------------------------------------------------------
	With three output ports possible (although not necessarily used) we're going
	to get 'pulled' through Begin Evaluate up to three times sometimes. We only want to
	do heavy computation in Begin Evaluate one of these times. We use the 
	port dirty states to tell us if we need to do a 'big evaluation' and once
	we've done that we turn the dirty states off which means the second and third time
	BeginEvaluate gets called it doesn't do a full evaluation (since nothing's
	dirty).
	--------------------------------------------------------------------------*/
	
	CICEPortState geoport(in_ctxt, ID_IN_geometry);
	CICEPortState size_arrayport(in_ctxt, ID_IN_size_array);
	CICEPortState varianceport(in_ctxt, ID_IN_variance);
	CICEPortState iterationsport(in_ctxt, ID_IN_iterations);
	CICEPortState randomise(in_ctxt, ID_IN_randomise);
	CICEPortState seed(in_ctxt, ID_IN_seed);
	CICEPortState max_size(in_ctxt, ID_IN_max_size);
	CICEPortState spacing(in_ctxt, ID_IN_spacing);
	CICEPortState iteration_abort(in_ctxt, ID_IN_iteration_abort);
	CICEPortState erase_threshold(in_ctxt, ID_IN_erasethreshold);
	CICEPortState size_map_absolute(in_ctxt,ID_IN_size_map_absolute);
	CICEPortState random_absolute(in_ctxt,ID_IN_random_absolute);
	CICEPortState min_size(in_ctxt,ID_IN_min_size);

	bool geoportD = geoport.IsDirty();
	bool size_arrayportD = size_arrayport.IsDirty();
	bool varianceportD = varianceport.IsDirty();
	bool iterationsportD = iterationsport.IsDirty();
	bool randomiseD  = randomise.IsDirty();
	bool seedD  = seed.IsDirty();
	bool max_sizeD  = max_size.IsDirty();
	bool iteration_abortD  = iteration_abort.IsDirty();
	bool erase_thresholdD = erase_threshold.IsDirty();
	bool spacingD = spacing.IsDirty();
	bool size_map_absoluteD = size_map_absolute.IsDirty();
	bool random_absoluteD = random_absolute.IsDirty();
	bool min_sizeD = min_size.IsDirty();

	/*NOTE---------------------------------------------------------------------
	Store the old user data if there is some. We know that prior to getting into
	Begin Evaluate we've been through Phase O Evaluate and had some user data
	set on whether the weight maps are dirty. We cannot get to this phase without
	there being user data. 
	--------------------------------------------------------------------------*/
	CData * oldpData = NULL;
	if ( !in_ctxt.GetUserData().IsEmpty() )//if it's not empty
	{
		oldpData = (CData *)(CValue::siPtrType)in_ctxt.GetUserData( );
	}

	// if any of the ports are dirty, including the spacing map and erase map which have been checked for dirtiness in the first evaluation phase
	if (spacingD				|| 
		size_arrayportD			|| 
		erase_thresholdD		|| 
		geoportD				|| 
		varianceportD			|| 
		iterationsportD			|| 
		randomiseD				|| 
		seedD					||  
		max_sizeD				|| 
		iteration_abortD		|| 
		size_map_absoluteD		||
		random_absoluteD		||
		min_sizeD				||
		oldpData->spacing_dirty || 
		oldpData->erase_dirty	)
	{
		
		/*NOTE---------------------------------------------------------------------
		This section checks the ID_IN_size_array to see whether it is a single value
		or an array and adjusts the CDataArray/CDataArray2D accordingly
		--------------------------------------------------------------------------*/
		siICENodeDataType dt;
		siICENodeStructureType st;
		siICENodeContextType ct;

		in_ctxt.GetPortInfo(ID_IN_size_array, dt, st, ct);
		std::vector<float> in_sizes;
		
		/*NOTE---------------------------------------------------------------------
		The next couple of vectors are there to set up a mapping between the 
		unsorted input size array and the sorted size array which we have to use
		during the evaluation (like sort array with key). This way when it comes
		to outputting the size indices we can map back to their original index. This
		frees the user from worrying about setting up a size-ordered array of sizes.
		--------------------------------------------------------------------------*/
		std::vector<mypair> pairs;
		std::vector<long> pair_mapping;

		if (st == 2)
		{
			CDataArray2DFloat size_array( in_ctxt, ID_IN_size_array );
			CDataArray2DFloat::Accessor floatAccessor = size_array[0];
			for (unsigned int x = 0; x < floatAccessor.GetCount(); x++)
			{
				in_sizes.push_back(floatAccessor[x]);
				pairs.push_back( std::make_pair( floatAccessor[x], long(x) ) );
			}
			std::sort(in_sizes.begin(), in_sizes.end());
			std::sort(pairs.begin(), pairs.end(),comparator);
			
			for (std::vector<mypair>::iterator it = pairs.begin(); it != pairs.end(); ++it)
			{
				pair_mapping.push_back(it->second);
				//Application().LogMessage(CString(it->first) + " : " + CString(it->second) );   
			}
		}
		else if (st == 1)
		{
			CDataArrayFloat size_single( in_ctxt, ID_IN_size_array );
			in_sizes.push_back(size_single[0]);
			pair_mapping.push_back(0);
		}
		
		/*NOTE---------------------------------------------------------------------
		Pull the ports
		--------------------------------------------------------------------------*/
		//CDataArrayFloat size( in_ctxt, ID_IN_size );
		CDataArrayLong iterations( in_ctxt, ID_IN_iterations );
		CDataArrayLong seed( in_ctxt, ID_IN_seed );
		CDataArrayFloat variance( in_ctxt, ID_IN_variance );
		CDataArrayBool randomise( in_ctxt, ID_IN_randomise );
		CDataArrayFloat max_size( in_ctxt, ID_IN_max_size );
		CDataArrayFloat spacing( in_ctxt, ID_IN_spacing );
		CDataArrayFloat iteration_abort( in_ctxt, ID_IN_iteration_abort );
		CDataArrayFloat erase( in_ctxt, ID_IN_erase );
		CDataArrayFloat erase_threshold( in_ctxt, ID_IN_erasethreshold );
		CDataArrayBool size_map_absolute( in_ctxt, ID_IN_size_map_absolute );
		CDataArrayBool random_absolute( in_ctxt,ID_IN_random_absolute );
		CDataArrayFloat min_size( in_ctxt, ID_IN_min_size );
	
		/*NOTE---------------------------------------------------------------------
		Create new user data and start inputting some of the old variables. Remember
		if we cancel we have to restore oldPData
		--------------------------------------------------------------------------*/
		CData * pData = new CData;
		pData->spacing_dirty = 0;
		pData->spacing_sum = oldpData->spacing_sum;//store the old spacing sum so that we can compare it
		pData->erase_dirty = 0;
		pData->erase_sum = oldpData->erase_sum;

		long num_iterations = iterations[0];
		pData->v.reserve(num_iterations);
		
		/*NOTE---------------------------------------------------------------------
		CICEGeometry stuff. We should probably cache this and put it into user data 
		for reuse and only refresh if the geoport is dirty. But in terms of overall
		evaluation time is the added complexity worth it?
		--------------------------------------------------------------------------*/
		CDoubleArray points;
		geom.GetPointPositions( points ) ;

		ULONG nCount = geom.GetTriangleCount();
		CLongArray indices;
		geom.GetTrianglePointIndices( indices );

		vector< float > areas;
		vector< vector< MATH::CVector3f > > tri_vectors;
		vector< vector<int> > tri_hitindices(nCount);

		/*NOTE---------------------------------------------------------------------
		Calculate Triangle Areas
		--------------------------------------------------------------------------*/
		float area_sum = 0.0;
		ULONG nOffset = 0;
		for (unsigned int x = 0; x < nCount; x++)
		{
			MATH::CVector3f np1(	
				(float)points[ indices[nOffset]*3 ],
				(float)points[ indices[nOffset]*3+1 ],
				(float)points[ indices[nOffset]*3+2 ] );
			MATH::CVector3f np2( 	
				(float)points[ indices[nOffset+1]*3 ],
				(float)points[ indices[nOffset+1]*3+1 ],
				(float)points[ indices[nOffset+1]*3+2 ] );
			MATH::CVector3f np3( 	
				(float)points[ indices[nOffset+2]*3 ],
				(float)points[ indices[nOffset+2]*3+1 ],
				(float)points[ indices[nOffset+2]*3+2 ] );
			
			nOffset += 3;

			MATH::CVector3f p4;
			p4.Sub(np2,np1);

			MATH::CVector3f p5;
			p5.Sub(np3,np1);

			MATH::CVector3f p6;
			p6.Cross(p4,p5);

			float vLength = p6.GetLength();
			//length represents area *2
			areas.push_back(vLength);
			area_sum += vLength;

			vector< MATH::CVector3f > v;
			v.push_back(np1);
			v.push_back(p4);
			v.push_back(p5);
			tri_vectors.push_back(v);
			//tri vectors is a list of a point position and two edge vectors for each tri
			//it is used later on to compute the barycentrics to get interpolated weight map values
		}

		/*NOTE---------------------------------------------------------------------
		Divide triangle areas by area sum
		--------------------------------------------------------------------------*/
		for (unsigned long x = 0; x < areas.size(); x++) areas[x] /= area_sum;
		
		/*NOTE---------------------------------------------------------------------
		Clear the dirty states since they aren't needed any more
		--------------------------------------------------------------------------*/
		ClearDirtyStates(in_ctxt);

		/*NOTE---------------------------------------------------------------------
		Setup iteration variables like the progress bar
		--------------------------------------------------------------------------*/
		UIToolkit kit = Application().GetUIToolkit();
		ProgressBar bar = kit.GetProgressBar();
		if (num_iterations > 100)
		{
			bar.PutMaximum( 100 );
			bar.PutStep( 5 );
			bar.PutCaption( L"Dart Throwing in Progress" );
			bar.PutCancelEnabled( true );
			bar.PutVisible( true );
		}
		
		//data from input ports
		float erase_value = erase_threshold[0];
		bool r = randomise[0];
		bool size_map_absolute_switch = size_map_absolute[0];
		bool random_absolute_switch = random_absolute[0];
		float it_ab_percent = iteration_abort[0] * num_iterations;
		MATH::CRandom rand( seed[0] );

		//initialise variables
		bool cancel = false;
		unsigned int iteration_counter = 0;
		unsigned int last_successful = 0;
		unsigned int maximum[] = {0,0,0,0};
		float P, Q, S, U, V;

		/*NOTE---------------------------------------------------------------------
		MAIN ITERATION LOOP
		--------------------------------------------------------------------------*/
		for (long x = 0; x < num_iterations; x++)
		{
			if (bar.IsCancelPressed())
			{
				in_ctxt.PutUserData( (CValue::siPtrType) oldpData );
				in_ctxt.PutNumberOfElementsToProcess( (ULONG) oldpData->v.size() );
				cancel = true;
				delete pData;
				pData = NULL;
				return CStatus::OK;
				break;
			}

			if (num_iterations > 100)
			{
				if (x % (num_iterations/20) == 0) bar.Increment();
			}

			/*NOTE---------------------------------------------------------------------
			Select an individual triangle based on area
			--------------------------------------------------------------------------*/
			int tri;
			rand++;
			S = rand.GetNormalizedValue();
			tri = (int)floor(nCount * S);
			area_sum = 0.0;
			for (unsigned int o = 0; o < nCount; o++)
			{
				area_sum += areas[o];
				if (area_sum >= S)
				{
					tri = o;
					break;
				}
			}

			/*NOTE---------------------------------------------------------------------
			Random point in the selected triangle
			--------------------------------------------------------------------------*/
			rand++;
			P = rand.GetNormalizedValue();

			rand++;
			Q = rand.GetNormalizedValue();

			if (P+Q > 1.0f)
			{
				float temp = P;
				P = 1.0f - Q;
				Q = 1.0f - temp;
			}

			MATH::CVector3f v1(tri_vectors[tri][1] );
			v1 *= P;
			MATH::CVector3f v2(tri_vectors[tri][2] );
			v2 *= Q;
			MATH::CVector3f vCandidate(tri_vectors[tri][0]);
			vCandidate += v1;
			vCandidate += v2; //vCandidate now represents the point position inside the selected triangle

			/*NOTE---------------------------------------------------------------------
			Vertex Indices of the Selected Triangle
			--------------------------------------------------------------------------*/
			int adx = indices[tri*3];
			int bdx = indices[tri*3+1];
			int cdx = indices[tri*3+2];

			/*NOTE---------------------------------------------------------------------
			Erase Map Evaluation
			--------------------------------------------------------------------------*/
			if (points.GetCount() == erase.GetCount() * 3)
			{
				float erase_interpol;
				erase_interpol = (erase[adx] + P * (erase[bdx] - erase[adx]))    +    (Q * (erase[cdx] - erase[adx]));
				if (erase_interpol < erase_value)
				{
					continue;// point lies in erase map over threshold skip to next dart throw
				}
			}
			/*NOTE---------------------------------------------------------------------
			Spacing Adjustment Evaluation.
			This adjusts the sizes based on a weightmap which acts as an interpolant
			between the base size and the max_size_multiplier. v0*(1-t)+v1*t;
			--------------------------------------------------------------------------*/
			std::vector<float> temp_in_sizes = in_sizes;
			if (points.GetCount() == spacing.GetCount()*3)
			{
				float space_adjustment_interpolant = 0.0;
				space_adjustment_interpolant = (spacing[adx] + P * (spacing[bdx] - spacing[adx]))    +    (Q * (spacing[cdx] - spacing[adx]));
				float max_size_multiplier = max_size[0];
				for (std::vector<float>::iterator it = temp_in_sizes.begin(); it != temp_in_sizes.end(); ++it)
				{
					if (! size_map_absolute[0])
					{
						*it = (*it * (1.0 - space_adjustment_interpolant))    +    ((max_size_multiplier * (*it)) * space_adjustment_interpolant);
					}
					else
					{
						*it = (*it * (1.0 - space_adjustment_interpolant))    +    (max_size_multiplier * space_adjustment_interpolant);
					}
					//if (*it < min_size[0]) *it = min_size[0];//limit
				}
			}

			/*NOTE---------------------------------------------------------------------
			Randomisation
			--------------------------------------------------------------------------*/
			rand++;
			U = rand.GetNormalizedValue();
			rand++;
			V = rand.GetNormalizedValue();
			if (V >= 0.5) U *= -1.0;//negate for half the values
			if (r)//if randomisation is on
			{
				for (std::vector<float>::iterator it = temp_in_sizes.begin(); it != temp_in_sizes.end(); ++it)
				{
					if (random_absolute_switch) *it = *it + (variance[0]*U);
					else *it = *it * (variance[0]*U);
				}
			}

			/*NOTE---------------------------------------------------------------------
			Limit the min size of the particle after all the adjustments  have taken
			place
			--------------------------------------------------------------------------*/
			for (vector<float>::iterator it = temp_in_sizes.begin(); it != temp_in_sizes.end(); ++it)
			{
				if (*it < min_size[0]) *it = min_size[0];//limit
			}

			/*NOTE---------------------------------------------------------------------
			Check for points near the dart
			--------------------------------------------------------------------------*/
			int found = 0;
			float min_available_distance = std::numeric_limits<float>::max();
			float length;
			float la;//length a
			float tgt_in_tri_size;
			
			/*NOTE---------------------------------------------------------------------
			Check the tri first
			--------------------------------------------------------------------------*/
			for (vector<int>::iterator it = tri_hitindices[tri].begin(); it != tri_hitindices[tri].end();  ++it)//iterate through the tri first
			{
				/*NOTE---------------------------------------------------------------------
				All initial checking done with squared lengths
				--------------------------------------------------------------------------*/
				MATH::CVector3f vz;
				vz.Sub(pData->v[*it],vCandidate);
				length = vz.GetLengthSquared();//squared
				tgt_in_tri_size = pData->size[*it];
				
				la = temp_in_sizes[0] + tgt_in_tri_size;
					
				if ( length < la * la)//squared
				{
					found = 1;
					break;
				}
				/*NOTE---------------------------------------------------------------------
				If we have multiple sizes in the size array then we have to revert to 
				using the square root. Here we store the actual distance from the 
				dart candidate to the edge of the sphere around the closest point. We
				keep checking for this smallest 'min available distance' which we are going
				to use later to see which is the largest in our array of sizes that will
				fit in.
				--------------------------------------------------------------------------*/
				if (temp_in_sizes.size() > 1)
				{
					float sqrt_len = sqrt(length);
					if (sqrt_len - (tgt_in_tri_size) <  min_available_distance)
					{
						min_available_distance = sqrt_len - (tgt_in_tri_size);
					}
				}
			}
			/*NOTE---------------------------------------------------------------------
			Check all the other darts that have successfully landed
			--------------------------------------------------------------------------*/
			if (found != 1)
			{
				for (std::vector<MATH::CVector3f>::iterator it = pData->v.begin(); it != pData->v.end(); ++it)
				{
					MATH::CVector3f vz;
					vz.Sub(*it,vCandidate);
					length = vz.GetLengthSquared();//squared
					tgt_in_tri_size = pData->size[it - pData->v.begin()];
					la = temp_in_sizes[0] + tgt_in_tri_size;//we add the sizes of the two current points
					if ( length < la * la )//we square them
					{
						found = 1;
						break;
					}
					if (temp_in_sizes.size() > 1)
					{
						float sqrt_len = sqrt(length);
						if (sqrt_len - (tgt_in_tri_size) <  min_available_distance)
						{
							min_available_distance = sqrt_len - (tgt_in_tri_size);
						}
					}
				}
				
				/*NOTE---------------------------------------------------------------------
				At this point we have two scenarios: one where we just have a single value
				in in_sizes[0] and one where we have multiple values in in_sizes. We know
				that we can get the smallest one in the array in (i.e. in_sizes[0]) because
				we've just tested for that but we don't know at what index min_available 
				distance will yield in the list of sizes i.e. we might be able to fit
				a bigger one in.
				--------------------------------------------------------------------------*/
				float picked_size;
				long size_index;
				if (! temp_in_sizes.size() > 1)//we're dealing with a single size (not an array)
				{
					picked_size = temp_in_sizes.at(0);
					size_index = 0;
				}
				else
				{
					/*NOTE---------------------------------------------------------------------
					We have an array of sizes and we know the smallest fits.
					Check if we can get the absolute largest one in first
					--------------------------------------------------------------------------*/
					if (min_available_distance >= temp_in_sizes.back())
					{
						picked_size = temp_in_sizes.back();
						size_index = temp_in_sizes.size() -1;
					}
					/*NOTE---------------------------------------------------------------------
					If not, then iterate through the list to find the biggest one you can get in 
					--------------------------------------------------------------------------*/
					else
					{
						for (std::vector<float>::iterator it = temp_in_sizes.begin() + 1; it != temp_in_sizes.end(); ++it)
						{
							if (min_available_distance <= *it)
							{
								picked_size = *(it-1);
								size_index = (it-1) - temp_in_sizes.begin();
								break;
							}
						}
					}
				}

				/*NOTE---------------------------------------------------------------------
				At this point you have the found flag set to either 0 or 1 which is a bit
				sloppy. Need to restructure. If it's 0 it means you have found a valid
				new point.
				--------------------------------------------------------------------------*/
				if (found == 0)
				{
					pData->v.push_back(vCandidate);
					pData->size.push_back(picked_size);
					pData->indices.push_back(pair_mapping[size_index]);//pair map back to original  index
					tri_hitindices[tri].push_back(pData->v.size()-1); //index of added point
		
					unsigned int temp = max(maximum[0],iteration_counter - last_successful);
					maximum[0] = temp;
					maximum[1] = iteration_counter;
					if (maximum[0] > it_ab_percent) break;
					last_successful = iteration_counter;
				}
			}
			iteration_counter++;
		}

		Application().LogMessage(   CString("Max iterations is: ") + CString((int)maximum[0]) + CString(" at: ") + CString((int)maximum[1])   );

		XSI::MATH::CMatrix4f transform;
		geom.GetTransformation( transform );
		pData->transfo = transform;
		pData->validgeom = 1;
		in_ctxt.PutUserData( (CValue::siPtrType) pData );
		in_ctxt.PutNumberOfElementsToProcess( (ULONG) pData->v.size() );
		
		delete oldpData;
		oldpData = NULL;
	}
	/*NOTE---------------------------------------------------------------------
	This is the end of the 'if dirty' block so the else statement below will
	be called on the second Begin Evaluate. I think you still need to tell
	it how many elements to process for the second 'size' output port
	--------------------------------------------------------------------------*/
	else
	{
		CData * pData = (CData *)(CValue::siPtrType)in_ctxt.GetUserData( );
		in_ctxt.PutNumberOfElementsToProcess( (ULONG) pData->v.size() );
	}
	return CStatus::OK;
}

XSIPLUGINCALLBACK CStatus Dart_Throw_Version_3_Evaluate( ICENodeContext& in_ctxt )
{
	ULONG nPhase = in_ctxt.GetEvaluationPhaseIndex( );

	/*NOTE---------------------------------------------------------------------
	Every time the plugin calls evaluate, even in the first phase where it
	collects the weight map data it instantiates a new pData pointer which seems
	OK. In order to see whether the weight maps are dirty we have to persist the
	user data and NOT destroy it in EndEvaluate since we're comparing the previous
	summed values of the weight map with the current ones. This seems contrary
	to all the examples in the documentation where the user data is released
	in EndEvaluate. We don't release the user data until term.
	--------------------------------------------------------------------------*/
	CData * pData = new CData;
	switch( nPhase )
	{
	case 0:
		{
			/*NOTE---------------------------------------------------------------------
			because there doesn't seem to be a method to check whether the input
			erase map or spacing map has been changed (i.e. I don't think the
			port dirty states get updated automatically or at least didn't for
			the version of Softimage this was aimed at (2011 sp1) I had to do
			a simple sum on all the weight map values. That is, if the overall
			sum of values was different then you could assume the map(s) had
			changed. So, I put the sum into user data for comparison purposes
			and compare before and afters. If there's a difference I manually
			create an IsDirty variable in my user data which I then use in
			BeginEvaluate. This forces me to store the user data from frame
			to frame (i.e. permanently throughout the whole session). I don't
			think there's any other way of checking if a weight map value
			attached to a port has been modified.
			--------------------------------------------------------------------------*/
			float summation = 0.0;
			CDataArrayFloat spacing_array( in_ctxt, ID_IN_spacing );
			float erasemapsum = 0.0;
			CDataArrayFloat erase_array( in_ctxt, ID_IN_erase );
			for(unsigned int i = 0; i < spacing_array.GetCount(); i++)		{ summation += spacing_array[i]; }
			for(unsigned int i = 0; i < erase_array.GetCount(); i++)		{ erasemapsum += erase_array[i]; }

			if ( in_ctxt.GetUserData().IsEmpty() )
			{
				pData->spacing_sum = summation;
				pData->erase_sum = erasemapsum;
				in_ctxt.PutUserData( (CValue::siPtrType) pData );
			}
			else
			{
				pData = (CData *)(CValue::siPtrType)in_ctxt.GetUserData( );
				if (abs(pData->spacing_sum - summation) > .001)
				{
					pData->spacing_dirty = 1;
					pData->spacing_sum = summation;
				}
				else
				{
					pData->spacing_dirty = 0;
				}

				if (abs(pData->erase_sum - erasemapsum) > .001)
				{
					pData->erase_dirty = 1;
					pData->erase_sum = erasemapsum;
				}
				else
				{
					pData->erase_dirty = 0;
				}
				return CStatus::OK;
			}
		}
		break;
	case -1:
		{
			pData = (CData *)(CValue::siPtrType)in_ctxt.GetUserData( );
			CIndexSet indexSet( in_ctxt );
			ULONG out_portID = in_ctxt.GetEvaluatedOutputPortID( );

			if (pData->validgeom)
			{
				switch( out_portID )
				{
				case ID_OUT_sample_points:
					{
						CDataArrayVector3f outData( in_ctxt );
						for(CIndexSet::Iterator it = indexSet.Begin(); it.HasNext(); it.Next())
						{
							outData[it] = pData->v[it.GetAbsoluteIndex()].MulByMatrix4InPlace(pData->transfo);
						}
					}
					break;
				case ID_OUT_sizes:
					{
						CDataArray2DFloat outData( in_ctxt );
						CDataArray2DFloat::Accessor outSubArray = outData.Resize(0, in_ctxt.GetNumberOfElementsToProcess() );
						for (unsigned int it = 0; it < in_ctxt.GetNumberOfElementsToProcess(); it++)
						{
							outSubArray[it] = pData->size[it];
						}
					}
				break;
				case ID_OUT_indices:
				{
					CDataArray2DLong outData( in_ctxt );
					CDataArray2DLong::Accessor outSubArray = outData.Resize(0, in_ctxt.GetNumberOfElementsToProcess() );
					for (unsigned int it = 0; it < in_ctxt.GetNumberOfElementsToProcess(); it++)
					{
						outSubArray[it] = pData->indices[it];
					}
				}
				break;
				};
			}
			else//in case there is no valid geo just but a single vector and a single size
			{
				switch( out_portID )
				{
				case ID_OUT_sample_points:
					{
						CDataArrayVector3f outData( in_ctxt );
						CIndexSet indexSet( in_ctxt );
						MATH::CVector3f singlevec(0.0,0.0,0.0);

						for(CIndexSet::Iterator it = indexSet.Begin(); it.HasNext(); it.Next())
						{
							outData[it] = singlevec;
						}
					}
					break;
				case ID_OUT_sizes:
					{
						CDataArray2DFloat outData( in_ctxt );
						CDataArray2DFloat::Accessor outSubArray = outData.Resize(0, in_ctxt.GetNumberOfElementsToProcess() );

						for (unsigned int it = 0; it < in_ctxt.GetNumberOfElementsToProcess(); it++)
						{
							outSubArray[it] = 1.0;
						}
					}
					break;
				case ID_OUT_indices:
				{
					CDataArray2DLong outData( in_ctxt );
					CDataArray2DLong::Accessor outSubArray = outData.Resize(0, in_ctxt.GetNumberOfElementsToProcess() );

					for (unsigned int it = 0; it < in_ctxt.GetNumberOfElementsToProcess(); it++)
					{
						outSubArray[it] = 0;
					}
				}
				break;
				};//end switch
			}//end else
		}//end valid geo
	};
	return CStatus::OK;
}

SICALLBACK MyCustomICENode_Term( CRef& in_ctxt )
{
	Context ctxt( in_ctxt );
	CValue userData = ctxt.GetUserData( );
	if ( userData.IsEmpty() )
	{
		return CStatus::OK;
	}
	CData *pData = (CData*)(CValue::siPtrType)ctxt.GetUserData( );

	pData->size.clear();
	pData->v.clear();
	delete pData;

	// Clear user data
	ctxt.PutUserData( CValue() );

	return CStatus::OK;

}
