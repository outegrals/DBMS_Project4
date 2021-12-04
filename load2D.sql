DROP TABLE points2d CASCADE;

CREATE TABLE points2d( p point );

\copy points2d FROM short_output_format2D.txt;

CREATE INDEX points_quad_indx ON points2d USING spgist(p);

-- working to this to calculate the distance

CREATE OR REPLACE FUNCTION DIS(float4, float4, float4, float4) RETURNS float4 AS 'qt_2dp.so', 'distance2d' LANGUAGE C STRICT IMMUTABLE;

SELECT  t1.p as point1, 
        t2.p as point2, 
        DIS(    cast(t1.p[0] as float4), 
                cast(t1.p[1] as float4), 
                cast(t2.p[0] as float4), 
                cast(t2.p[1] as float4) ) AS dis 
FROM    points2d t1, 
        points2d t2
WHERE t1.p != t2.p;

