use sqlite_docs_core::TableDocs;
//use std::io::{Result, Write};
use anyhow::Result;
use std::fmt::Write;

pub fn generate_markdown(tables: Vec<TableDocs>) -> Result<String> {
    let mut md = String::new();
    for table in tables {
        writeln!(md, "## {}", table.name)?;
        writeln!(md,)?;
        writeln!(md, "{}", table.table_level.unwrap_or_else(|| "".to_owned()))?;
        writeln!(md,)?;
        writeln!(md, "| Column | Description")?;
        writeln!(md, "|-|-")?;
        for column in table.columns {
            write!(md, "|{}", column.name)?;
            write!(md, "|{}", column.contents.unwrap_or_else(|| "".to_owned()))?;
            writeln!(md,)?;
        }
        writeln!(md,)?;
    }
    Ok(md)
}
