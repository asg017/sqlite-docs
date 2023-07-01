mod datasette;
mod markdown;

use std::io::Write;

use anyhow::{anyhow, Context, Result};
use clap::{Arg, ArgMatches, Command};
use rusqlite::{ffi::sqlite3_auto_extension, Connection};
use sqlite_docs_core::TableDocs;
use sqlite_docs_extension::sqlite3_docs_init;

fn command() -> Command {
    Command::new("sqlite-docs")
        .version(env!("CARGO_PKG_VERSION"))
        .author("Alex Garcia")
        .about("Documentation for SQLite tables, comments, and extensions")
        .subcommand(
            Command::new("generate-datasette")
                .about("Generate a metadata.json for Datasette")
                .arg(Arg::new("db").required(true))
                .arg(Arg::new("output").alias("o").required(false)),
        )
        .subcommand(
            Command::new("generate-markdown")
                .about("Generate a markdown-formatted data dictionary")
                .arg(Arg::new("db").required(true))
                .arg(Arg::new("output").alias("o").required(false)),
        )
}

fn execute_matches(matches: &ArgMatches) -> Result<()> {
    match matches.subcommand() {
        Some(("generate-datasette", matches)) => {
            let db_path = matches
                .get_one::<String>("db")
                .context("db is a required argument")?;
            let db = Connection::open(db_path)?;
            let tables = table_docs_from(&db)?;
            let metadata = datasette::generate_metadata(
                &std::path::Path::new(db_path)
                    .file_stem()
                    .unwrap()
                    .to_string_lossy(),
                tables,
            );
            let mut w: Box<dyn Write> = match matches.get_one::<String>("output") {
                Some(output_path) => Box::new(std::fs::File::open(output_path)?),
                None => Box::new(std::io::stdout()),
            };

            writeln!(w, "{}", serde_json::to_string_pretty(&metadata)?)?;
            Ok(())
        }
        Some(("generate-markdown", matches)) => {
            let db_path = matches
                .get_one::<String>("db")
                .context("db is a required argument")?;
            let db = Connection::open(db_path)?;
            let tables = table_docs_from(&db)?;
            let markdown = markdown::generate_markdown(tables)?;

            let mut w: Box<dyn Write> = match matches.get_one::<String>("output") {
                Some(output_path) => Box::new(std::fs::File::open(output_path)?),
                None => Box::new(std::io::stdout()),
            };

            writeln!(w, "{}", markdown)?;
            Ok(())
        }
        Some((cmd, _matches)) => Err(anyhow!("unknown subcommand {cmd}")),
        None => Ok(()),
    }
}

fn table_docs_from(db: &Connection) -> Result<Vec<TableDocs>> {
    let mut stmt = db
        .prepare("select name, docs, columns from sqlite_docs_tables;")
        .unwrap();
    let tables: Vec<TableDocs> = stmt
        .query_map([], |row| {
            Ok(TableDocs {
                name: row.get(0)?,
                table_level: row.get(1)?,
                columns: serde_json::from_str(&row.get::<usize, String>(2)?).unwrap(),
            })
        })?
        .collect::<Result<Vec<_>, _>>()?;
    Ok(tables)
}

fn main() -> Result<()> {
    unsafe {
        sqlite3_auto_extension(Some(std::mem::transmute(sqlite3_docs_init as *const ())));
    }
    let command = command();
    let result = execute_matches(&command.get_matches());
    if result.is_err() {
        println!("{:?}", result);
        std::process::exit(1);
    }
    Ok(())
}
