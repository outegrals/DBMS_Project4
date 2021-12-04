-- this file tries to create the points as 3 different fields in a table
-- without creating a custom type. This way, we can perform sql queries
-- directly on this table. However, I am still trying to figure out how to
-- return a set of data as a function result and as such can now only output
-- the distances calculated as an array string

-- clean up
drop type if exists state cascade;

drop table if exists points cascade;
drop table if exists sdh cascade;

drop function if exists one_to_all_others cascade;
drop function if exists stfunc cascade;

drop aggregate if exists cagg (numeric, numeric, numeric) cascade;


-- intermediary state to save between rows
create type state as (res numeric[], n integer);

-- histogram type
create type histogram as (points numeric[]);

-- create table of separate x,y,z coordinates as columns
create table points (
	x numeric,
	y numeric,
	z numeric
);

-- table to output histogram to
create table sdh (
	bIndex integer,
	bPointCnt integer,
);

-- populate table
insert into points
values
(  -63.91 , 0.51   , -20.28 ),
(  57.07  , -72.70 , -1.19  ),
(  -35.25 , 12.16  , 41.00  ),
(  -23.34 , 48.44  , 31.09  ),
(  36.10  , -75.22 , -1.79  ),
(  -63.71 , 94.41  , -65.74 ),
(  -73.50 , 58.67  , -71.96 ),
(  -21.95 , 84.23  , -60.07 ),
(  -37.91 , -5.07  , 63.12  ),
(  -55.53 , 94.17  , -78.86 ),
(  -33.87 , 27.29  , 50.70  ),
(  99.98  , 68.64  , 4.55   ),
(  -96.53 , 55.92  , -68.24 ),
(  -26.10 , 44.95  , 37.59  ),
(  74.76  , -28.64 , -92.08 ),
(  -55.42 , -96.73 , 21.50  ),
(  -54.24 , 25.24  , -48.78 ),
(  5.59   , -74.44 , 81.68  ),
(  15.06  , -16.35 , 34.61  ),
(  7.36   , -64.62 , 61.37  ),
(  91.58  , -36.22 , 26.51  ),
(  93.26  , -16.11 , 51.45  ),
(  88.85  , 91.26  , -74.16 ),
(  55.90  , 61.25  , -91.26 ),
(  -50.65 , -73.45 , -10.38 ),
(  45.87  , -33.76 , -42.62 ),
(  15.50  , 60.82  , -9.20  ),
(  30.75  , -10.43 , 24.18  ),
(  -90.66 , 37.86  , 97.71  ),
(  61.70  , -67.00 , -0.34  ),
(  47.41  , 47.54  , -98.78 ),
(  -47.34 , 37.85  , -82.35 ),
(  -67.93 , 45.78  , 62.64  ),
(  88.03  , 21.26  , 50.15  ),
(  38.52  , 54.81  , -7.52  ),
(  77.33  , 72.35  , 15.19  ),
(  99.04  , -36.15 , -20.89 ),
(  -81.25 , 0.32   , 77.57  ),
(  57.51  , 76.95  , 60.77  ),
(  29.02  , -54.37 , -29.85 ),
(  -15.85 , -4.15  , -95.38 ),
(  72.95  , 45.15  , -51.95 ),
(  82.81  , 81.32  , -16.62 ),
(  -51.40 , 64.65  , 28.60  ),
(  -19.90 , -93.14 , -68.85 ),
(  -85.97 , 98.70  , -10.82 ),
(  17.01  , 73.97  , 81.20  ),
(  9.20   , -45.25 , -84.35 ),
(  -73.79 , -69.84 , -37.24 ),
(  69.89  , 52.49  , -4.99  ),
(  24.02  , 12.34  , 91.66  ),
(  76.04  , 77.72  , 12.39  ),
(  6.10   , -85.73 , 84.39  ),
(  87.75  , -19.24 , -52.06 ),
(  91.68  , 66.16  , -7.39  ),
(  -61.01 , -67.95 , 63.78  ),
(  -94.68 , -29.01 , -64.56 ),
(  75.63  , -35.32 , 44.54  ),
(  98.03  , -51.61 , -57.20 ),
(  16.41  , -18.59 , -68.25 ),
(  -84.42 , 32.25  , -75.46 ),
(  14.76  , -4.72  , 49.74  ),
(  66.52  , -16.36 , 22.27  ),
(  94.09  , 34.28  , -82.25 ),
(  55.06  , -15.30 , 56.60  ),
(  -82.83 , -34.40 , 86.23  ),
(  -6.46  , 30.25  , 73.74  ),
(  -72.05 , -22.35 , 12.24  ),
(  77.17  , -4.64  , -89.43 ),
(  -86.37 , -60.14 , 79.92  ),
(  -70.48 , -8.33  , -76.66 ),
(  -11.78 , -23.61 , 94.43  ),
(  -87.54 , 49.79  , -37.43 ),
(  -71.42 , 74.18  , -97.68 ),
(  -97.06 , -21.52 , 26.66  ),
(  33.62  , 8.11   , 92.21  ),
(  -82.55 , 94.60  , 76.31  ),
(  8.24   , -26.21 , 19.14  ),
(  60.98  , 74.97  , 20.67  ),
(  -34.23 , -13.10 , -79.82 ),
(  17.34  , -96.08 , -66.14 ),
(  88.04  , -72.97 , 47.46  ),
(  -66.08 , 47.84  , 67.84  ),
(  17.43  , -0.62  , 87.77  ),
(  -56.34 , -14.31 , -31.46 ),
(  65.64  , -1.03  , -26.06 ),
(  30.70  , -33.84 , 28.30  ),
(  59.53  , -81.63 , 84.88  ),
(  80.03  , -98.27 , 71.44  ),
(  -75.83 , 74.53  , -25.15 ),
(  -60.36 , 17.18  , 23.79  ),
(  -48.26 , 30.15  , 69.15  ),
(  -86.64 , -60.06 , -74.26 ),
(  -85.19 , 91.92  , 80.12  ),
(  51.27  , -30.19 , 75.80  ),
(  64.20  , -87.88 , 22.66  ),
(  -93.46 , -47.28 , -67.43 ),
(  73.38  , 42.97  , 3.22   ),
(  36.53  , 22.53  , 74.29  ),
(  -32.36 , 51.16  , -36.57 ),
(  -50.96 , -18.45 , -36.99 );

-- this function calculates the distances of the point at row n to all other
-- points that comes after it and calculates the histogram positional index
-- that distance should belong to given the bucket width
-- TODO: potentially use the distance function here?
create or replace function one_to_all_following (
	n integer,
	bucketWidth integer
)
returns table (foo numeric)
language plpgsql
as $$
begin
	return query (
		select
		floor(
			sqrt(
				power(x - nth_value(x,n) over w, 2)
				+ power(y - nth_value(y,n) over w, 2)
				+ power(z - nth_value(z,n) over w, 2)
			) / bucketWidth
		)
		from points
		window w as (order by x,y,z)
		offset n
	);
end;
$$;

-- state transition function: passed from row to row
create or replace function stfunc (
	s state,
	x numeric,
	y numeric,
	z numeric
)
returns state
language plpgsql
as $$
declare
	sn state;
	query numeric[];
begin
	query = (select array(select one_to_all_following(s.n + 1, 10)));
	sn.res = s.res || query;
	sn.n = s.n + 1;
return sn;
end;
$$;

-- state final functio: called when the aggregate is finished
-- this will be used to return the desired result
create or replace function ffunc (s state)
returns numeric[]
language plpgsql
as $$
begin
	return s.res;
end;
$$;

-- custom aggregate incorporating the above functions
create or replace aggregate cagg (numeric, numeric, numeric) (
	sfunc = stfunc,
	stype = state,
	finalfunc = ffunc,
	initcond = '({},0)'
);

-- function to calculate the count of each value in an input array
create or replace function calc_histogram (arr numeric[])
returns integer[]
language plpgsql
as $$
declare
	s integer[];
	x integer;
begin
	foreach x in array arr
	loop
		if s[x] is null then
			-- this is a new index, so update its found value to 1
			s[x] = 1;
		else
			-- this position already exists, so increment it
			s[x] = s[x] + 1;
		end if;
	end loop;
	-- replace nulls with 0
	s = array_replace(s, null, 0);
	return s;
end;
$$;

-- turn the histogram into a table
select * from unnest(array(
	-- calculate the histogram
	select calc_histogram(array(
		-- calculate point-to-point distance of all points
		-- and find histogram indices
		select cagg(x,y,z) from points
	))
)) as SDH;
