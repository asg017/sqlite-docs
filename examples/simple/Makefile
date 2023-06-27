students.db: schema.sql
	rm $@ || true
	sqlite3 $@ < $<
	sqlite3 $@ 'insert into students select "S10483", "Alex Garcia", "1970-01-01", 62.5;'

metadata.json: students.db
	../../target/debug/sqlite-docs-cli generate-datasette $< > $@

docs.md: students.db
	../../target/debug/sqlite-docs-cli generate-markdown $< > $@

all: metadata.json docs.md

clean:
	rm metadata.json docs.md

datasette: students.db metadata.json
	datasette serve students.db -m metadata.json

.PHONY: datasette all clean
