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
 * Functions for 2D points
 *****************************************************************************/

/* A macro is created. The calling convention relies on macros to suppress most of the complexity of passing arguments and results. */
Datum distance2d(PG_FUNCTION_ARGS);

/* The macro call is done in the name of the source file. It is generally written just before the function itself. */
PG_FUNCTION_INFO_V1(distance2d);

/* The actual function starts here. The function name is distance2d.
// PG_FUNCTION_ARGS has the point values. 
// We calculate the distance of two points that are given 
*/
Datum distance2d(PG_FUNCTION_ARGS){

    // Stores the values of the points to float4 types
    float4   p1_x = PG_GETARG_FLOAT4(0);
    float4   p1_y = PG_GETARG_FLOAT4(1);
    float4   p2_x = PG_GETARG_FLOAT4(2);
    float4   p2_y = PG_GETARG_FLOAT4(3);

    // Will store the distance after calculation
    float4   distance;  

    // The calculation of the distance value
    distance =  sqrt( 
                      ( (p1_x - p2_x) * (p1_x - p2_x) )
                    + ( (p1_y - p2_y) * (p1_y - p2_y) )
                    );

    // Returns the distance as a type float4
    PG_RETURN_FLOAT4( distance );
}

/*****************************************************************************
 * Functions for 3D points
 *****************************************************************************/

typedef struct Point3D
{
    float4 x;
	float4 y;
	float4 z;
} Point3D;

/* A macro is created. The calling convention relies on macros to suppress most of the complexity of passing arguments and results. */
Datum point3d_in(PG_FUNCTION_ARGS);

/* The macro call is done in the name of the source file. It is generally written just before the function itself. */
PG_FUNCTION_INFO_V1(point3d_in);

/* The actual function starts here. The function name is point3d_in.
// PG_FUNCTION_ARGS has the point values. 
// We store the values to a type of point3d 
*/
Datum point3d_in(PG_FUNCTION_ARGS)
{
    char * str = PG_GETARG_CSTRING(0);
	float4 x;
    float4 y;
    float4 z;
	Point3D * result;
    
    // Check whether sql input format has 3 numbers
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

	// Save user entered coordinates
	result = (Point3D *) palloc(sizeof(Point3D));
	result->x = x;
	result->y = y;
	result->z = z;

    // Return the pointer of the point3d
	PG_RETURN_POINTER(result);
}

/* A macro is created. The calling convention relies on macros to suppress most of the complexity of passing arguments and results. */
Datum point3d_out(PG_FUNCTION_ARGS);

/* The macro call is done in the name of the source file. It is generally written just before the function itself. */
PG_FUNCTION_INFO_V1(point3d_out);

/* The actual function starts here. The function name is point3d_out.
// PG_FUNCTION_ARGS has the point3d pointer. 
// We return the values of the point3d as a string
*/
Datum point3d_out(PG_FUNCTION_ARGS)
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

    // Stores the values of the points to float4 types
    float4   p1_x = PG_GETARG_FLOAT4(0);
    float4   p1_y = PG_GETARG_FLOAT4(1);
    float4   p1_z = PG_GETARG_FLOAT4(2);
    float4   p2_x = PG_GETARG_FLOAT4(3);
    float4   p2_y = PG_GETARG_FLOAT4(4);
    float4   p2_z = PG_GETARG_FLOAT4(5);

    // Will store the distance after calculation
    float4   distance;

    // The calculation of the distance value
    distance =  sqrt( 
                      ( (p1_x - p2_x) * (p1_x - p2_x) )
                    + ( (p1_y - p2_y) * (p1_y - p2_y) )
                    + ( (p1_z - p2_z) * (p1_z - p2_z) )
                    );

    // Returns the distance as a type float4
    PG_RETURN_FLOAT4( distance );
}