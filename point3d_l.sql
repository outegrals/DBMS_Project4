-- Drops necessary tables and functions for 2D points
DROP FUNCTION IF EXISTS DIS2D CASCADE;
DROP FUNCTION IF EXISTS distance2d CASCADE;

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

-- Drops necessary tables and functions for 3D points
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

-- Drops necessary tables and functions for the Histogram
DROP FUNCTION IF EXISTS SDH CASCADE;
DROP procedure IF EXISTS createHistogram cascade;
DROP function IF EXISTS calculateIndex cascade;

CREATE OR REPLACE procedure createHistogram()
AS
$func$
BEGIN
CREATE TABLE if NOT EXISTS histogram(i int, count int);
END
$func$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calculateIndex(distance float, bucketWidth integer)
RETURNS INT as
$func$
BEGIN
RETURN FLOOR(distance / bucketWidth);
end
$func$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION SDH(distance float, bucketWidth integer, tbl anyelement) 
RETURNS INT AS 
$func$
DECLARE bucket INT;
BEGIN

EXECUTE
'
insert into  ' || pg_typeof(tbl) || ' (i,count)
select calculateIndex( ' || distance || ', ' || bucketWidth ||' ) , 0 
where not exists (select * from ' || pg_typeof(tbl) || ' where i = calculateIndex( ' || distance || ' , ' || bucketWidth ||' ));

update ' || pg_typeof(tbl) || '
set count = (select count from ' || pg_typeof(tbl) || ' where i = calculateIndex( ' || distance || ', ' || bucketWidth || ')) + 1
where i = calculateIndex( ' || distance || ', ' || bucketWidth || ');
';

RETURN 0;
END
$func$ LANGUAGE plpgsql;