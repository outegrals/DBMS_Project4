-- clean up
drop function show_distances(regclass,integer,integer);

create or replace function show_distances (
	_table regclass,
	bucketWidth integer,
	n integer
)
returns table (
	x1 numeric,
	y1 numeric,
	z1 numeric,
	x2 numeric,
	y2 numeric,
	z2 numeric,
	distances numeric,
	index numeric
)
language plpgsql
as $$
begin
	return query execute
	'select
	x as x1,y as y1,z as z2,
	nth_value(x,'||n||') over w as x2,
	nth_value(y,'||n||') over w as y2,
	nth_value(z,'||n||') over w as z2,
	sqrt(
		power(x - nth_value(x,'||n||') over w, 2)
		+ power(y - nth_value(y,'||n||') over w, 2)
		+ power(z - nth_value(z,'||n||') over w, 2)
	) as distance,
	floor(
		sqrt(
			power(x - nth_value(x,'||n||') over w, 2)
			+ power(y - nth_value(y,'||n||') over w, 2)
			+ power(z - nth_value(z,'||n||') over w, 2)
		) / '||bucketWidth||'
	) as hist_index
	from '||_table||'
	window w as (order by x,y,z)
	offset '||n;
end;
$$;



create or replace function rand_gen (n integer)
returns void
language plpgsql
as $$
declare
	i integer = 0;
begin
	loop
		exit when i = n + 1;
		insert into points values (random()*200-100, random()*200-100, random()*200-100);
		i = i + 1;
	end loop;
end;
$$;


