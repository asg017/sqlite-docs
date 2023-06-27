create table students(
  --! All students that attend Foo University. One row per enrolled
  --! student, active and historial.

  --- ID assigned to the student at orientation.
  --- @details https://foo.edu/students/id-format.html
  --- @example S10483
  student_id text primary key,

  --- Full name of the student, includes first and last name.
  --- @example "Alex Garcia"
  name text,

  --- Birthday of the student, in "YYY-MM-DD" format.
  --- @example "1970-01-01"
  birthdate date,

  --- Number of course units the student has completed, since
  -- the last completed academic quarter.
  -- @example 62.5
  completed_units float
);
