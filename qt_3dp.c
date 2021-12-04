/* Header files
// Postgres.h should always be included first in any source file, because it declares a number of things that you will need from now.
// Definitions for the Postgres function manager and function-call interface. 
// The file fmgr.h must be included by all Postgres modules that either define or call fmgr-callable functions.
// We calculate distance between particles and we need some mathematical operations to be done. Hence math.h is added 
*/
#include "postgres.h"
#include "fmgr.h"
#include "funcapi.h"
#include "executor/executor.h"
#include <string.h>
#include <math.h>

/* To ensure that a dynamically loaded object file is not loaded into an incompatible server, we add a magic block.
// This allows the server to detect obvious incompatibilities, such as code compiled for a different major version of PostgreSQL 
*/
PG_MODULE_MAGIC;


/*****************************************************************************
 * Input/Output functions
 *****************************************************************************/

typedef struct Point3D
{
	float4 x;
	float4 y;
	float4 z;
} Point3D;

Datum point3d_in_function(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(point3d_in_function);

Datum point3d_in_function(PG_FUNCTION_ARGS)
{
    char * str = PG_GETARG_CSTRING(0);
	float4 x, y, z;
	Point3D * result;
    
    // check whether sql input format has 3 numbers
	if (sscanf(str, " ( %f , %f, %f )", &x, &y, &z) != 3) {
		ereport(
			ERROR,
			(
				errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
				errmsg(
					"invalid input syntax for type %s: \"%s\"",
					"point3d", str
				)
			)
		);
	}

	// save user entered coordinates
	result = (Point3D *) palloc(sizeof(Point3D));
	result->x = x;
	result->y = y;
	result->z = z;
	PG_RETURN_POINTER(result);
}

Datum point3d_out_function(PG_FUNCTION_ARGS);

PG_FUNCTION_INFO_V1(point3d_out_function);

Datum point3d_out_function(PG_FUNCTION_ARGS)
{
	Point3D * point3d = (Point3D *) PG_GETARG_POINTER(0);
	char * result;

	result = psprintf("(%g,%g,%g)", point3d->x, point3d->y, point3d->z);
	PG_RETURN_CSTRING(result);
}

/* A macro is created. The calling convention relies on macros to suppress most of the complexity of passing arguments and results. */
Datum distance3d(PG_FUNCTION_ARGS);

/* The macro call is done in the name of the source file. It is generally written just before the function itself. */
PG_FUNCTION_INFO_V1(distance3d);

/* The actual function starts here. The function name is distance2d.
// PG_FUNCTION_ARGS accepts the runtime arguments given by the user. 
// We calculate the distance of two points that are given 
*/
Datum distance3d(PG_FUNCTION_ARGS){

    float4   p1_x = PG_GETARG_FLOAT4(0);
    float4   p1_y = PG_GETARG_FLOAT4(1);
    float4   p1_z = PG_GETARG_FLOAT4(2);
    float4   p2_x = PG_GETARG_FLOAT4(3);
    float4   p2_y = PG_GETARG_FLOAT4(4);
    float4   p2_z = PG_GETARG_FLOAT4(5);
    float4   distance;

    distance =  sqrt( 
                      ( (p1_x - p2_x) * (p1_x - p2_x) )
                    + ( (p1_y - p2_y) * (p1_y - p2_y) )
                    + ( (p1_z - p2_z) * (p1_z - p2_z) )
                    );

    PG_RETURN_FLOAT4( distance );
}