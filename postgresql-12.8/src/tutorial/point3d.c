/*
 * src/tutorial/point3d.c
 *
 ******************************************************************************
	This file contains routines that can be bound to a Postgres backend and
	called by the backend in the process of processing queries. The calling
	format for these routines is dictated by Postgres architecture.
******************************************************************************/

#include "postgres.h"

#include "fmgr.h"

PG_MODULE_MAGIC;

typedef struct Point3D
{
	double x;
	double y;
	double z;
} Point3D;

/*****************************************************************************
 * Input/Output functions
 *****************************************************************************/

PG_FUNCTION_INFO_V1(point3d_in);

Datum
point3d_in(PG_FUNCTION_ARGS)
{
	char *str = PG_GETARG_CSTRING(0);
	double x, y, z;
	Point3D * result;

	// check whether sql input format has 3 numbers
	if (sscanf(str, " ( %lf , %lf, %lf )", &x, &y, &z) != 3)
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_TEXT_REPRESENTATION),
				 errmsg("invalid input syntax for type %s: \"%s\"",
						"point3d", str)));

	// save user entered coordinates
	result = (Point3D *) palloc(sizeof(Point3D));
	result->x = x;
	result->y = y;
	result->z = z;
	PG_RETURN_POINTER(result);
}

PG_FUNCTION_INFO_V1(point3d_out);

Datum
point3d_out(PG_FUNCTION_ARGS)
{
	Point3D * point3d = (Point3D *) PG_GETARG_POINTER(0);
	char * result;

	result = psprintf("(%g,%g,%g)", point3d->x, point3d->y, point3d->z);
	PG_RETURN_CSTRING(result);
}

