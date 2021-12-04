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