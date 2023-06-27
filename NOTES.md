- doc query: table with all
  - xinfo: type, notnull, default, primary key, hidden, generated
  - foreign_key_list: FK outbound
  - foreign_key_list: FK inboud
  - doc: description, examples, source?
- generated markdown
  - primary key distiction
  - other metadata
  - tables or headings?
- examples
- core: lexer+parser

FKS:

```sql
.mode box
.header on

select name from pragma_table_list;
select * from pragma_foreign_key_list('offices');
select
  pragma_table_list.name,
  fk.[from],
  fk.[table],
  fk.[to]
from pragma_table_list
join pragma_foreign_key_list(pragma_table_list.name) as fk;
select
  pragma_table_list.name,
  fk.[from],
  fk.[table],
  fk.[to]
from pragma_table_list
full outer join pragma_foreign_key_list(pragma_table_list.name) as fk;

with tables as (
  select
    pragma_table_list.name,
    json_group_array(fk.[table]) filter (where fk.[table] is not null) as dep_tables
  from pragma_table_list
  full outer join pragma_foreign_key_list(pragma_table_list.name) as fk
  group by 1
)
select *
from tables
order by json_array_length(dep_tables), 1;


```
