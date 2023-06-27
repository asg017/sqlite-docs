use std::vec;

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct TableDocs {
    pub name: String,
    pub table_level: Option<String>,
    pub columns: Vec<ColumnDocs>,
}
impl TableDocs {
    pub fn from_sql(sql: &str, name: &str) -> Self {
        let mut table_level = String::new();
        let mut current_column_doc = String::new();
        let mut current_column_example = String::new();
        let mut columns = vec![];

        for (line_idx, line) in sql.lines().enumerate() {
            // skip first "CREATE TABLE" line
            if line_idx == 0 {
                continue;
            }
            let line = line.trim_start();

            // table-level doc comment
            if let Some(doc_line) = line.strip_prefix("--!") {
                // empty "--! " lines should act as a line break
                if doc_line.trim().is_empty() {
                    table_level.push('\n');
                } else {
                    table_level.push_str(doc_line);
                    if !doc_line.ends_with(' ') {
                        table_level.push(' ')
                    }
                }
            }
            // column-level doc comment
            else if let Some(column_doc_line) = line.strip_prefix("--- ") {
                // empty "--- " lines should act as a line break
                if column_doc_line.trim().is_empty() {
                    current_column_doc.push('\n');
                }
                // column doc comments with "@example" tags should act as a comment
                else if let Some(example) = column_doc_line.strip_prefix("@example") {
                    current_column_example = example.to_string();
                } else if let Some(_details) = column_doc_line.strip_prefix("@details") {
                    // TODO
                } else {
                    if !current_column_doc.is_empty() && !current_column_doc.ends_with(' ') {
                        current_column_doc.push(' ')
                    }
                    current_column_doc.push_str(column_doc_line);
                }
            }
            // skip other kind of comments
            else if line.starts_with("-- ") {
                continue;
            }
            // assume this line is a SQL column definition, so just get the first "word"
            // and assume it's the column name
            else if let Some((column_name, _)) = line.split_once(' ') {
                columns.push(ColumnDocs {
                    name: column_name.to_owned(),
                    contents: if current_column_doc.is_empty() {
                        None
                    } else {
                        Some(current_column_doc.trim().to_owned())
                    },
                    example: if current_column_example.is_empty() {
                        None
                    } else {
                        Some(current_column_example.trim().to_owned())
                    },
                });
                current_column_doc.clear();
                current_column_example.clear();
            }
        }
        let table_level = if table_level.is_empty() {
            None
        } else {
            Some(table_level.trim().to_owned())
        };
        Self {
            name: name.to_owned(),
            table_level,
            columns,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ColumnDocs {
    pub name: String,
    pub contents: Option<String>,
    pub example: Option<String>,
    //pub extra_tags: HashMap<String, String>,
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn yo() {
        assert_eq!(
            TableDocs::from_sql(
                "create table x(
          a int
        )",
                "x"
            ),
            TableDocs {
                name: "x".to_owned(),
                table_level: None,
                columns: vec![ColumnDocs {
                    name: "a".to_string(),
                    contents: None,
                    example: None,
                }],
            }
        );
        assert_eq!(
            TableDocs::from_sql(
                "create table x(
                  --! doc!
                  --! doc2!
          a int
        )",
                "x"
            ),
            TableDocs {
                name: "x".to_owned(),
                table_level: Some("doc!  doc2!".to_string()),
                columns: vec![ColumnDocs {
                    name: "a".to_string(),
                    contents: None,
                    example: None,
                }],
            }
        );
        assert_eq!(
            TableDocs::from_sql(
                "create table x(
                 --- a random integer
                 --- @example 1234
                 -- not included
                  a int
                )",
                "x"
            ),
            TableDocs {
                name: "x".to_owned(),
                table_level: None,
                columns: vec![ColumnDocs {
                    name: "a".to_string(),
                    contents: Some("a random integer".to_string()),
                    example: Some("1234".to_owned()),
                }],
            }
        );
        assert_eq!(
            TableDocs::from_sql(
                "create table x(
                 --- a random integer
                 --- 2nd line
                  a int
                )",
                "x"
            ),
            TableDocs {
                name: "x".to_owned(),
                table_level: None,
                columns: vec![ColumnDocs {
                    name: "a".to_string(),
                    contents: Some("a random integer 2nd line".to_string()),
                    example: None,
                }],
            }
        );
        assert_eq!(
            TableDocs::from_sql(
                "create table x(
                 --- a random integer
                 ---
                 --- 2nd line, with line break
                  a int
                )",
                "x"
            ),
            TableDocs {
                name: "x".to_owned(),
                table_level: None,
                columns: vec![ColumnDocs {
                    name: "a".to_string(),
                    contents: Some("a random integer 2nd line, with line break".to_string()),
                    example: None,
                }],
            }
        );
    }
}
