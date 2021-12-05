# COP6712 Final Project - Aggregates in PostgreSql

### Group Members
- Tommy Truong - U08939516
- Mushfiq Mahmud - U32950410
- Luis Quezada - U29144164

## Custom PostgreSQL Type: Point3D

[reference](https://www.postgresql.org/docs/current/xtypes.html)

* save changes to custom user type file (`point3d.c` in this case) in
	`src/tutorial`.
* run `make` at `src/tutorial`. this will create the `.o` and `.so` files.
* `chown` these files for the `postgres` user (you might have to move these
	files into a non-privileged directory first)
* make note of the absolute path to these files
* start up postgresql and run `point3d.sql` to test the output

## commands

```sh
cd /root/downloads/postgresql-12.8/src/tutorial/
make
rm /home/mushfiq/proj4/*
cp point3d.* /home/mushfiq/proj4/
cd /home/mushfiq/proj4
su - postgres
PATH=$PATH:/usr/local/pgsql/bin
psql test
```

## Methodology

We start by creating a table to store all our 3D points. The table has 3
columns to store each of our 3 dimensions. We can then insert our points into
this table one at a time to store the dimensional data.

* create table to house points
* fill it up with 3d points
* we need to be able to perform a nested loop over the entire table to be able
	to calculate the point-to-point distance of each point to every other point.
* inner loop implemented using the function `one_to_all_following`.
	* the inner loop needs to be able to traverse a point and calculate the
		distance from it to all other points that come after it. It is important
		to only calculate distance to points *after* the given point because
		otherwise we would be calculating redundant distances which points
		previous to the given point might have already calculated. As long as we
		follow a specific order, we should be able to just get by using
		calculations done between a certain point and all points after it giving
		us an $n!$ runtime for calculating distance where $n-1$ is the number of
		input points since the first point will have to calculate $n-1$ distances
		to each of the $n-1$ points after it, the second will have to calculate
		$n-2$ distances and so on.
	* our inner loop is designed by using a sql query execution. We make use of
		a PostgreSQL window function [REFERENCE] called `nth_value` which takes
		in a column name and a row number. The column name will be traversed and
		every row value will be compared with the value at the row number given
		for that column. This way every row can be compared with a specific row
		value. This is exactly what we need. One important thing to conssider is
		that window functions need an order to be supplied using the `OVER` clause
		which makes sure the row number supplied always points to the same row
		since the ordering is specified. For our purposes, we use `ORDER BY x, y,
		z` to keep things consistent. And lastly, we also perform an `OFFSET` to
		denote that we only want values after the current $n$th row.
	* overall, our query returns a table of point-to-point distances of the
		given row number to every other points that come after it (in the
		previously mentioned order).
	* our inner loop function also takes a bukcet width which is used to
		calculate the SDH indices by using the calculation

		```
		index = floor ( distance / bucketWidth )
		```

	* the final query looks like the following.

		```sql
		select
			-- divide this distance by the bucketWidth and round down
			floor(
				sqrt(
					-- calculate the spatial distance between a row in points to the nth
					-- row in points with an offset of n
					power(x - nth_value(x,n) over w, 2)
					+ power(y - nth_value(y,n) over w, 2)
					+ power(z - nth_value(z,n) over w, 2)
				) / bucketWidth
			)
		from points
		-- specify window ordering
		window w as (order by x,y,z)
		offset n
		```
	
	* this will return a table of indices for the histogram which we can use to
		build the histogram.
* the outer loop can now perform the inner loop over all rows in the table.
	* our outer loop is designed as a custom aggregate called `cagg` which gets
	passed around to each row of any input relation.
	* It does this by taking in a state transition function [REFERENCE],
		`stfunc` in our case, to determine what values should be passed through to
		the next row and what to do with these values every iteration.
	* We create a custom type to hold our intermediary state values, aptly named
		`state` in our case. This has a numeric array `res[]` which is used to
		hold all the values returned and an integer `n` to store the count of
		points calculated thus far. When using the aggregate we provide the
		initial conditions by using `initcond` [REFERENCE] property and initialize
		an empty array and the count to `0`. At every iteration, we call the inner
		loop function which returns a table of histogram indices. We convert this
		table into an array and append all the values into `res` and pass `res`
		over to the next iteration. We also increment the value of `n`.
	* This aggregate also optionally takes in a final function [REFERENCE],
		`ffunc` in our case, which is often used to dress the output since we are
		passing and returning multiple parameters that we might not necessarily
		want to return at the very end. We use this function to return `res` at
		the very end of our aggregate to output the final array of histogram
		indices.
* At this point, we have a numeric array of histogram indices that we can use
	to calculate the histogram. We do this by one final custom function
	`calc_histogram`.
	* this function takes in takes in the numeric array and does a loop over
		each of these indices. A temporary array `s` is declared at the start of
		the function and initialized to all zeroes. Whenever an index value is
		encountered, the corresponding index of `s` is incremented. The return
		value of this function is the final SDH which holds the information of
		how many distances fall into which bucket of the histogram according to
		our algorithm.

## Performance


## Figures/Tables

### input points

```
db=# select * from points limit 20;
   x    |   y    |   z
--------+--------+--------
 -63.91 |   0.51 | -20.28
  57.07 | -72.70 |  -1.19
 -35.25 |  12.16 |  41.00
 -23.34 |  48.44 |  31.09
  36.10 | -75.22 |  -1.79
 -63.71 |  94.41 | -65.74
 -73.50 |  58.67 | -71.96
 -21.95 |  84.23 | -60.07
 -37.91 |  -5.07 |  63.12
 -55.53 |  94.17 | -78.86
 -33.87 |  27.29 |  50.70
  99.98 |  68.64 |   4.55
 -96.53 |  55.92 | -68.24
 -26.10 |  44.95 |  37.59
  74.76 | -28.64 | -92.08
 -55.42 | -96.73 |  21.50
 -54.24 |  25.24 | -48.78
   5.59 | -74.44 |  81.68
  15.06 | -16.35 |  34.61
   7.36 | -64.62 |  61.37
(20 rows)
```

### point-to-point distances

```

```

### histogram indices

```

```

### final sdh output

```
db=# select sdh();
 sdh
-----
   5
  17
  37
  76
  97
 144
 149
 203
 248
 282
 277
 325
 323
 316
 361
 335
 356
 334
 291
 235
 165
 136
 110
  49
  36
  24
  11
   7
   1
(29 rows)
```
