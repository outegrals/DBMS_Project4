-- this file tries to create a custom type in plpgsql called point3d
-- and creates a table using that type. this way we can only access the
-- individual dimensions inside a function that takes in the custom type as an
-- argument as I have been unable to query a field in a custom type directly in
-- SQL.

-- clean up
drop type if exists point3d cascade;
drop table if exists points cascade;
drop function if exists myFunc cascade;

-- custom type
create type point3d as (
	x numeric,
	y numeric,
	z numeric
);

-- create table with custom type
create table points (p point3d);

-- populate table
insert into points
values
((-63.91,0.51,-20.28)),
((57.07,-72.70,-1.19)),
((-35.25,12.16,41.00)),
((-23.34,48.44,31.09)),
((36.10,-75.22,-1.79)),
((-63.71,94.41,-65.74)),
((-73.50,58.67,-71.96)),
((-21.95,84.23,-60.07)),
((-37.91,-5.07,63.12)),
((-55.53,94.17,-78.86)),
((-33.87,27.29,50.70)),
((99.98,68.64,4.55)),
((-96.53,55.92,-68.24)),
((-26.10,44.95,37.59)),
((74.76,-28.64,-92.08)),
((-55.42,-96.73,21.50)),
((-54.24,25.24,-48.78)),
((5.59,-74.44,81.68));

-- POC to show how to access the type fields
create or replace function myFunc (p point3d)
returns numeric
language plpgsql
as $$
declare
	result numeric = 0;
begin
	result = p.x + p.y + p.z;
	return result;
end;
$$;
