create or replace function dist_3d (
	x1 integer,
	y1 integer,
	z1 integer,
	x2 integer,
	y2 integer,
	z2 integer
)
returns float
language sql
as 'select sqrt( pow(x1-x2,2) + pow(y1-y2,2) + pow(z1-z2,2));'
immutable
returns null on null input;

create or replace function test (
	p point3d
)
returns integer
language sql
as 'select 2+2;'
immutable
returns null on null input;

