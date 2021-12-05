-- Drops necessary tables and functions
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

-- A call of the 
SELECT * FROM DIS2D(NULL::points2d);

