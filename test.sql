-- this file tries to create the points as 3 different fields in a table
-- without creating a custom type. This way, we can perform sql queries
-- directly on this table. However, I am still trying to figure out how to
-- return a set of data as a function result and as such can now only output
-- the distances calculated as an array string

-- clean up
drop table if exists points cascade;
drop function if exists one_to_all_others cascade;

-- create table of separate x,y,z coordinates as columns
create table points (
	x numeric,
	y numeric,
	z numeric
);

-- populate table
insert into points
values
(-63.91,0.51,-20.28),
(57.07,-72.70,-1.19),
(-35.25,12.16,41.00),
(-23.34,48.44,31.09),
(36.10,-75.22,-1.79),
(-63.71,94.41,-65.74),
(-73.50,58.67,-71.96),
(-21.95,84.23,-60.07),
(-37.91,-5.07,63.12),
(-55.53,94.17,-78.86),
(-33.87,27.29,50.70),
(99.98,68.64,4.55),
(-96.53,55.92,-68.24),
(-26.10,44.95,37.59),
(74.76,-28.64,-92.08),
(-55.42,-96.73,21.50),
(-54.24,25.24,-48.78),
(5.59,-74.44,81.68);

-- this function calculates the distances of the point
-- at row n to all other points that comes after it.
-- this will be useful in an aggregate function that can
-- go row by row and calculate the SDH
-- TODO: potentially use the distance function here?
-- TODO: need to find out how to return a set of values
create or replace function one_to_all_others (n integer)
returns numeric
language plpgsql
as $$
declare
	query varchar := '';
begin
	query = (select array(
		select
			sqrt(
				power(x - nth_value(x,1) over w, 2)
				+ power(y - nth_value(y,1) over w, 2)
				+ power(z - nth_value(z,1) over w, 2)
			)
		from points
		window w as (order by x,y,z)
		offset n
	));
	raise notice '%', query;
	return n;
end;
$$;

select one_to_all_others(1);

