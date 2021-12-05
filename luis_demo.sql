DROP TABLE IF EXISTS points2d CASCADE;

-- Creates the table of 2D points
CREATE TABLE points2d( p point );

-- Populates the table with data
\copy points2d FROM short_output_format2D.txt;

-- Creates a quadtree index of the 2D points table
CREATE INDEX points_quad_indx ON points2d USING spgist(p);

-- A call of the distance function for 2D points
SELECT * FROM DIS2D(NULL::points2d);

-- strictly below
SELECT p strictlyBelow FROM points2d WHERE p >^ point '(-23.34,48.44)';
-- strictly above
SELECT p AS strictlyAbove FROM points2d WHERE p <^ point '(-23.34,48.44)';
-- strictly right
SELECT p strictlyRight FROM points2d WHERE p >> point '(-23.34,48.44)';
-- strictly left
SELECT p AS strictlyLeft FROM points2d WHERE p << point '(-23.34,48.44)';

DROP TABLE IF EXISTS points3d CASCADE;
DROP TABLE IF EXISTS distance3d CASCADE;

-- Creates the table of 3D points
CREATE TABLE points3d( p point3d );

-- Populates the table with data
\copy points3d FROM short_output_format3D.txt;

/* CANNOT create index with the data type point3d
   Get this error "HINT:  You must specify an operator class for the index or define a default operator class for the data type."
-- Creates a quadtree index of the 3D points table
CREATE INDEX points_quad_indx ON points3d USING spgist(p);
*/
-- A call of the function
CREATE TEMP TABLE distance3d AS SELECT * FROM DIS3D(NULL::points3d);

DROP TABLE IF EXISTS histogram CASCADE;

CREATE TABLE histogram(i int, count int);

SELECT sdh(dis, 5, NULL::histogram) FROM distance3d ;

SELECT * FROM histogram ORDER BY i;

