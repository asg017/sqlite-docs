use indexmap::IndexMap;
use serde::{Deserialize, Serialize};
use sqlite_docs_core::TableDocs;

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct DatasetteMetadata {
    pub databases: IndexMap<String, DatasetteMetadataDatabase>,
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct DatasetteMetadataDatabase {
    tables: IndexMap<String, DatasetteMetadataTable>,
}

#[derive(Default, Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct DatasetteMetadataTable {
    description: Option<String>,
    columns: IndexMap<String, String>,
}

pub fn generate_metadata(database_name: &str, tables: Vec<TableDocs>) -> DatasetteMetadata {
    let mut databases = IndexMap::new();
    let database = DatasetteMetadataDatabase {
        tables: tables
            .into_iter()
            .map(|table| {
                let columns = table
                    .columns
                    .into_iter()
                    .map(|column| {
                        (
                            column.name,
                            column.contents.unwrap_or_else(|| "".to_owned()),
                        )
                    })
                    .collect();

                (
                    table.name,
                    DatasetteMetadataTable {
                        description: table.table_level,
                        columns,
                    },
                )
            })
            .collect(),
    };
    databases.insert(database_name.to_owned(), database);
    DatasetteMetadata { databases }
}
