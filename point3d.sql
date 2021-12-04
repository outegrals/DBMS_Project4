-- Drops necessary tables and functions for 2D points
DROP TABLE IF EXISTS points2d CASCADE;
DROP FUNCTION IF EXISTS DIS2D CASCADE;
DROP FUNCTION IF EXISTS distance2d CASCADE;

-- Creates the table of 2D points
CREATE TABLE points2d( p point );

-- Populates the table with data
\copy points2d FROM short_output_format2D.txt;

-- Creates a quadtree index of the 2D points table
CREATE INDEX points_quad_indx ON points2d USING spgist(p);

-- Creates the function call for calculating distance between two 2D points
CREATE OR REPLACE FUNCTION distance2d(float4, float4, float4, float4) 
RETURNS float4 AS 'point3d.so', 'distance2d' 
LANGUAGE C STRICT IMMUTABLE;

-- Creates the function to call the calculation of distance betwen two 2D points
CREATE OR REPLACE FUNCTION DIS2D(_tbl anyelement) 
RETURNS TABLE ("point1" point, "point2" point, "dis" float4) AS 
$func$
BEGIN
RETURN QUERY 
EXECUTE 
'SELECT t1.p as point1, 
        t2.p as point2, 
        distance2d( cast(t1.p[0] as float4), 
                    cast(t1.p[1] as float4), 
                    cast(t2.p[0] as float4), 
                    cast(t2.p[1] as float4) ) AS dis
FROM ' || pg_typeof(_tbl) || ' t1, ' || pg_typeof(_tbl) || ' t2
WHERE t1.p != t2.p';
END
$func$ LANGUAGE plpgsql;

-- A call of the distance function for 2D points
SELECT * FROM DIS2D(NULL::points2d);


-- Drops necessary tables and functions for 3D points
DROP TABLE IF EXISTS points3d CASCADE;
DROP FUNCTION IF EXISTS DIS3D CASCADE;
DROP FUNCTION IF EXISTS distance3d CASCADE;
DROP TYPE IF EXISTS point3d CASCADE;
DROP FUNCTION IF EXISTS point3d_in CASCADE;
DROP FUNCTION IF EXISTS point3d_out CASCADE;

-- first create a shell type to refer to
create type point3d;

-- The input function 'point3d_in' takes a null-terminated string (the textual
-- representation of the type) and turns it into the internal (in memory)
-- representation. NOTE: check the correct path to the compiled files
CREATE OR REPLACE FUNCTION point3d_in(cstring) 
RETURNS point3d AS 'point3d.so', 'point3d_in' 
LANGUAGE C STRICT IMMUTABLE;

-- The output function 'point3d_out' takes the internal representation and
-- converts it into the textual representation. NOTE: check the correct path to
-- the compiled files
CREATE OR REPLACE FUNCTION point3d_out(point3d) 
RETURNS cstring AS 'point3d.so', 'point3d_out' 
LANGUAGE C STRICT IMMUTABLE;

-- Finally create the actual type linking the input output functions and
-- stating the internal length which specifies the size of the memory block
-- required to hold the type
CREATE TYPE point3d (
    INTERNALLENGTH = 12,
    INPUT = point3d_in,
    OUTPUT = point3d_out,
    ELEMENT = float4
);

-- Creates the table of 3D points
CREATE TABLE points3d( p point3d );

-- Populates the table with data
\copy points3d FROM short_output_format3D.txt;

/* CANNOT create index with the data type point3d
   Get this error "HINT:  You must specify an operator class for the index or define a default operator class for the data type."
-- Creates a quadtree index of the 3D points table
CREATE INDEX points_quad_indx ON points3d USING spgist(p);
*/

-- Creates the function call for calculating distance between two 2D points
CREATE OR REPLACE FUNCTION distance3d(float4, float4, float4, float4, float4, float4) 
RETURNS float4 AS 'point3d.so', 'distance3d' 
LANGUAGE C STRICT IMMUTABLE;


-- Creates the function to call the calculation of distance betwen two 2D points
CREATE OR REPLACE FUNCTION DIS3D(_tbl anyelement) 
RETURNS TABLE ("point1" point3d, "point2" point3d, "dis" float4) AS 
$func$
BEGIN
RETURN QUERY 
EXECUTE 
'SELECT t1.p as point1, 
        t2.p as point2,
        distance3d( cast(t1.p[0] as float4), 
                    cast(t1.p[1] as float4),
                    cast(t1.p[2] as float4), 
                    cast(t2.p[0] as float4), 
                    cast(t2.p[1] as float4),
                    cast(t2.p[2] as float4) ) AS dis
FROM ' || pg_typeof(_tbl) || ' t1, ' || pg_typeof(_tbl) || ' t2
WHERE   t1.p[0] != t2.p[0]
        and t1.p[1] != t2.p[1]
        and t1.p[2] != t2.p[2]';
END
$func$ LANGUAGE plpgsql;

-- A call of the function
SELECT * FROM DIS3D(NULL::points3d);
