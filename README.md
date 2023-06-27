# `sqlite-docs`

A SQLite extension, CLI, and library for documentating SQLite tables, columns, and extensions.

**Warning**

> `sqlite-docs` is still young and not fully developed. Watch this repo or [subscribe to my newsletter](https://buttondown.email/alexgarcia) for updates. Also consider [sponsoring my work](https://github.com/sponsors/asg017) if you want this project to release earlier!

`sqlite-docs` work with "SQLite doc comments" inside `CREATE TABLE` statements, similar to [Rust doc comments](https://doc.rust-lang.org/reference/comments.html#doc-comments), [Go Doc Comments](https://tip.golang.org/doc/comment), and [JSDoc](https://jsdoc.app/).

Single-line comments that start with an exclamation point (`--!`) are comments and descriptions for the entire table. Single line comments that start with a dash (`---`) are comments and description for the following column.

```sql
create table students(
  --! All students that attend Foo University. One row per enrolled
  --! student, active and historial.

  --- ID assigned to the student at orientation.
  --- @details https://foo.edu/students/id-format.html
  --- @example 'S10483'
  student_id text primary key,

  --- Full name of the student, includes first and last name.
  --- @example 'Alex Garcia'
  name text,

  --- Birthday of the student, in YYYY-MM-DD format.
  --- @example '1970-01-01'
  birthdate date,

  --- Number of course units the student has completed, since
  -- the last completed academic quarter.
  -- @example 62.5
  completed_units float
);
```

Once the tables in your database are documented, you can use the `sqlite-docs` CLI to generate documentation in different formats. Here's an example of generating a markdown data dictionary file:

```bash
sqlite-docs generate-markdown my.db -o README.md
```

Or a [Datasette `metadata.json`](https://docs.datasette.io/en/stable/metadata.html):

```bash
sqlite-docs generate-datasette my.db -o metadata.json
datasette my.db --metadata metadata.json
```

You'll then find the table and column descriptions in a few places in Datasette's UI.

|                                                                                                                                  |                                                                                                                                  |
| -------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| <img width="400px" src="https://user-images.githubusercontent.com/15178711/249305336-17879f9b-70a3-4654-807b-01933fec0495.png"/> | <img width="400px" src="https://user-images.githubusercontent.com/15178711/249305380-38875373-135d-4253-885e-3f53485adfe9.png"/> |

## Specification

SQLite doc comments support a few "tags", as denoted by the `@` sign at the beginning of the comment. These include:

| Tag        | Supported for   | Description                                                                                                                       |
| ---------- | --------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `@example` | Columns         | A SQLite literal of an example non-null value the column can contain.                                                             |
| `@value`   | Columns         | A possible non-null value that a column could be. Meant to exhaustively list all enum options a column has                        |
| `@details` | Columns, Tables | A link or instructions to find more information about the format/contents of a column, such as ID formats, datetime formats, etc. |
| `@source`  | Tables          | A link or instructions to the raw source of the data backing at able.                                                             |
| `@schema`  | Columns         |                                                                                                                                   |

## Limitations

### No `ALTER TABLE` support

SQLite will by persist comments in `CREATE TABLE` statements, in the `sqlite_master` table.

However, some `ALTER TABLE` statements will erase or modify these comments, such as with `ALTER TABLE x ADD COLUMN`, `ALTER TABLE x REMOVE COLUMN`, and more.

If you think your table will need `ALTER TABLE` statements in the future, then know that `sqlite-docs` comments may break. You can always create a new table with your new schema, import data from the old table to the new one, then delete the old table.

### `sqlite-docs` tools use a weak parser

`sqlite-docs` uses heuristics and simple line-by-line analysis to extract doc comments. It does not fully parse `CREATE TABLE` statements or use an AST. This means that certain valid SQL will not work with `sqlite-docs` including:

- Column names with spaces or newline characters
- Column definitions that span multiple lines
- Multi-line comments `/* ... */`
- `FOREIGN KEY` and other constraints

In the far future `sqlite-docs` will be able to handle all of these cases. If you'd like to see this happen sooner, consider [sponsoring my work](https://github.com/sponsors/asg017).

### `sqlite-docs` is early in development

It'll get better and easier to use! `sqlite-docs` will most likely be distributed as:

- A CLI for major platforms (MacOS, Linux, Windows etc.)
- A SQLite extension in the [`sqlite-ecosystem`](https://github.com/asg017/sqlite-ecosystem)
- A Datasette plugin
- A high-level Python library for parsing indivudal statements
- A low-level Rust library for parsing individual statements
