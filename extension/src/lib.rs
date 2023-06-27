mod tables;

use sqlite_docs_core::TableDocs;
use sqlite_loadable::prelude::*;
use sqlite_loadable::*;
use tables::DocsTablesTable;

fn all_tables(db: *mut sqlite3) -> Result<Vec<(String, String)>> {
    let mut tables = vec![];
    let mut stmt = exec::Statement::prepare(
        db,
        "select name, sql from sqlite_master where type = 'table'",
    )
    .unwrap();
    for row in stmt.execute() {
        let row = row.unwrap();
        let name = row.get::<String>(0).unwrap();
        let sql = row.get::<String>(1).unwrap();
        tables.push((name, sql));
    }
    Ok(tables)
}
fn all_tables_from_context(context: *mut sqlite3_context) -> Result<Vec<(String, String)>> {
    all_tables(api::context_db_handle(context))
}
fn columns_for(context: *mut sqlite3_context, table: &str) -> Result<Vec<(String, String)>> {
    let mut tables = vec![];
    let mut stmt = exec::Statement::prepare(
        api::context_db_handle(context),
        "select cid, name from pragma_table_xinfo(?)",
        // type, notnull, dflt_value, ok, hidden
    )
    .unwrap();
    stmt.bind_text(1, table).unwrap();
    for row in stmt.execute() {
        let row = row.unwrap();
        let name = row.get::<String>(0).unwrap();
        let sql = row.get::<String>(1).unwrap();
        tables.push((name, sql));
    }
    Ok(tables)
}

pub fn docs(context: *mut sqlite3_context, _values: &[*mut sqlite3_value]) -> Result<()> {
    let tables = all_tables_from_context(context)?;
    let docs: Vec<TableDocs> = tables
        .iter()
        .map(|(name, sql)| TableDocs::from_sql(sql, name))
        .collect();
    api::result_text(context, serde_json::to_string(&docs).unwrap())?;
    Ok(())
}
pub fn all_tables_(context: *mut sqlite3_context, _values: &[*mut sqlite3_value]) -> Result<()> {
    let tables = all_tables_from_context(context)?;
    api::result_json(context, serde_json::json!(tables))?;
    Ok(())
}
pub fn columns_for_(context: *mut sqlite3_context, values: &[*mut sqlite3_value]) -> Result<()> {
    let columns = columns_for(context, api::value_text(&values[0]).unwrap())?;
    api::result_json(context, serde_json::json!(columns))?;
    Ok(())
}

#[sqlite_entrypoint]
pub fn sqlite3_docs_init(db: *mut sqlite3) -> Result<()> {
    let flags = FunctionFlags::UTF8 | FunctionFlags::DETERMINISTIC;
    define_scalar_function(db, "all_tables", 0, all_tables_, flags)?;
    define_scalar_function(db, "columns_for", 1, columns_for_, flags)?;
    define_scalar_function(db, "docs", 0, docs, flags)?;
    define_table_function::<DocsTablesTable>(db, "sqlite_docs_tables", None)?;
    Ok(())
}
