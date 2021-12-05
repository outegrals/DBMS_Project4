-- this file tries to create the points as 3 different fields in a table
-- without creating a custom type. This way, we can perform sql queries
-- directly on this table. However, I am still trying to figure out how to
-- return a set of data as a function result and as such can now only output
-- the distances calculated as an array string

-- TODO: add references in paper
-- TODO: talk about SDH distribution
-- TODO: explain how quad tree could be used (luis)
-- TODO: add image for point-to-point distance calculation
-- TODO: add image for histogram index calculation
-- TODO: have bucket width be user input
-- TODO: don't hardcode points table and column names
-- TODO: make it work with custom point type

-- clean up
drop type if exists state cascade;
drop table if exists points cascade;
drop function if exists one_to_all_following cascade;
drop function if exists stfunc cascade;
drop function if exists calc_histogram;
drop function if exists ffunc;
drop aggregate if exists cagg (numeric, numeric, numeric) cascade;

-- intermediary state to save between rows
create type state as (res numeric[], n integer);

-- create table of separate x,y,z coordinates as columns
create table points (
	x numeric,
	y numeric,
	z numeric
);

-- populate table. NOTE: check path
\copy points from '/home/mushfiq/proj4/points.txt' with delimiter ',';

-- this function calculates the distances of the point at row n to all other
-- points that comes after it and calculates the histogram positional index
-- that distance should belong to given the bucket width
-- TODO: potentially use the distance function here?
create or replace function one_to_all_following (
	_table regclass,
	_x varchar,
	_y varchar,
	_z varchar,
	bucketWidth integer,
	n integer
)
returns table(foo numeric)
language plpgsql
as $$
begin
	return query execute
		'select floor(
			sqrt(
				power('||_x||' - nth_value('||_x||','||n||') over w, 2)
				+ power('||_y||' - nth_value('||_y||','||n||') over w, 2)
				+ power('||_z||' - nth_value('||_z||','||n||') over w, 2)
			) / '||bucketWidth||'
		)
		from '||_table||'
		window w as (order by '||_x||','||_y||','||_z||')
		offset '||n||'';
end;
$$;
select input('points', 'x', 'y', 'z', 88, 10);

-- state transition function: passed from row to row
create or replace function stfunc (
	s state,
	_table regclass,
	_x varchar,
	_y varchar,
	_z varchar,
	bucketWidth integer
)
returns state
language plpgsql
as $$
declare
	sn state;
	query numeric[];
begin
	-- TODO: pass in bucket width as a parameter
	query = (select array(select one_to_all_following('points', 'x', 'y', 'z', bucketWidth, s.n + 1)));
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
create or replace function sdh()
returns table (foo integer)
language plpgsql
as $$
begin
	return query (
		select * from unnest(array(
			-- calculate the histogram
			select calc_histogram(array(
				-- calculate point-to-point distance of all points
				-- and find histogram indices
				select cagg(x,y,z) from points
			))
		)) as SDH
	);
end;
$$;

select sdh();
