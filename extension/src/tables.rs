use sqlite_docs_core::TableDocs;
use sqlite_loadable::prelude::*;
use sqlite_loadable::{
    api,
    table::{BestIndexError, IndexInfo, VTab, VTabArguments, VTabCursor},
    Result,
};

use std::{mem, os::raw::c_int};

static CREATE_SQL: &str = "CREATE TABLE x(name, docs, columns)";
enum Columns {
    Name,
    Docs,
    Columns,
}
fn column(index: i32) -> Option<Columns> {
    match index {
        0 => Some(Columns::Name),
        1 => Some(Columns::Docs),
        2 => Some(Columns::Columns),
        _ => None,
    }
}

#[repr(C)]
pub struct DocsTablesTable {
    /// must be first
    base: sqlite3_vtab,
    db: *mut sqlite3,
}

impl<'vtab> VTab<'vtab> for DocsTablesTable {
    type Aux = ();
    type Cursor = DocsTablesCursor;

    fn connect(
        db: *mut sqlite3,
        _aux: Option<&Self::Aux>,
        _args: VTabArguments,
    ) -> Result<(String, DocsTablesTable)> {
        let base: sqlite3_vtab = unsafe { mem::zeroed() };
        let vtab = DocsTablesTable { base, db };
        // TODO db.config(VTabConfig::Innocuous)?;
        Ok((CREATE_SQL.to_owned(), vtab))
    }
    fn destroy(&self) -> Result<()> {
        Ok(())
    }

    fn best_index(&self, mut info: IndexInfo) -> core::result::Result<(), BestIndexError> {
        info.set_estimated_cost(100000.0);
        info.set_estimated_rows(100000);
        info.set_idxnum(1);
        Ok(())
    }

    fn open(&mut self) -> Result<DocsTablesCursor> {
        Ok(DocsTablesCursor::new(self.db))
    }
}

#[repr(C)]
pub struct DocsTablesCursor {
    /// Base class. Must be first
    base: sqlite3_vtab_cursor,
    db: *mut sqlite3,
    tables: Option<Vec<TableDocs>>,
    rowid: i64,
}
impl DocsTablesCursor {
    fn new(db: *mut sqlite3) -> DocsTablesCursor {
        let base: sqlite3_vtab_cursor = unsafe { mem::zeroed() };
        DocsTablesCursor {
            base,
            db,
            tables: None,
            rowid: 0,
        }
    }
}

impl VTabCursor for DocsTablesCursor {
    fn filter(
        &mut self,
        _idx_num: c_int,
        _idx_str: Option<&str>,
        _values: &[*mut sqlite3_value],
    ) -> Result<()> {
        let tables = crate::all_tables(self.db)?;
        let docs: Vec<TableDocs> = tables
            .iter()
            .map(|(name, sql)| TableDocs::from_sql(sql, name))
            .collect();
        self.tables = Some(docs);
        self.rowid = 0;
        Ok(())
    }

    fn next(&mut self) -> Result<()> {
        self.rowid += 1;
        Ok(())
    }

    fn eof(&self) -> bool {
        self.tables
            .as_ref()
            .unwrap()
            .get(self.rowid as usize)
            .is_none()
    }

    fn column(&self, context: *mut sqlite3_context, i: c_int) -> Result<()> {
        let table = self
            .tables
            .as_ref()
            .unwrap()
            .get(self.rowid as usize)
            .unwrap();
        match column(i) {
            Some(Columns::Name) => {
                api::result_text(context, table.name.clone())?;
            }
            Some(Columns::Docs) => match &table.table_level {
                Some(docs) => api::result_text(context, docs)?,
                None => api::result_null(context),
            },
            Some(Columns::Columns) => {
                api::result_json(context, serde_json::to_value(&table.columns).unwrap())?
            }
            _ => (),
        }
        Ok(())
    }

    fn rowid(&self) -> Result<i64> {
        Ok(self.rowid)
    }
}
