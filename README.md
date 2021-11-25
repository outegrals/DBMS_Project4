# COP6712 Final Project - Aggregates in PostgreSql

### Group Members
- Tommy Truong
- Mushfiq Mahmud
- Luis Quezada

## Custom PostgreSQL Type: Point3D

[reference](https://www.postgresql.org/docs/current/xtypes.html)

* save changes to custom user type file (`point3d.c` in this case) in
	`src/tutorial`.
* run `make` at `src/tutorial`. this will create the `.o` and `.so` files.
* `chown` these files for the `postgres` user (you might have to move these
	files into a non-privileged directory first)
* make note of the absolute path to these files
* start up postgresql and run `point3d.sql` to test the output

