drop type if exists point3d cascade;
drop function if exists point3d_in cascade;
drop function if exists point3d_out cascade;
drop function if exists distance3d cascade;
drop table if exists test_point3d;

-- first create a skeleton type to refer to
create type point3d;

-- the input function 'point3d_in' takes a null-terminated string (the textual
-- representation of the type) and turns it into the internal (in memory)
-- representation. NOTE: check the correct path to the compiled files
create function point3d_in(cstring)
	returns point3d
	as '/home/mushfiq/proj4/point3d'
	language c immutable strict;

-- the output function 'point3d_out' takes the internal representation and
-- converts it into the textual representation. NOTE: check the correct path to
-- the compiled files
create function point3d_out(point3d)
	returns cstring
	as '/home/mushfiq/proj4/point3d'
	language c immutable strict;

-- finally create the actual type linking the input output functions and
-- stating the internal length which specifies the size of the memory block
-- required to hold the type
create type point3d (
   internallength = 24,
   input = point3d_in,
   output = point3d_out,
   alignment = double
);

-- test
create table test_point3d (
	a point3d
);

insert into test_point3d values ('(1.0, 2.5, 3.56)');
insert into test_point3d values ('(2.0, 1.7, 30.2)');

select * from test_point3d;

-- function to calculate calculate 3d spatial distance
create function distance3d(point3d, point3d)
returns cstring
as '/home/mushfiq/proj4/point3d'
language c immutable strict;

select distance3d('(2,3,4)'::point3d, '(1,2,3)'::point3d);


