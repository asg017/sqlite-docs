congress.db: congress.sql
	rm $@
	sqlite3 $@ < $<

metadata.json: congress.db
	../../target/debug/sqlite-docs-cli generate-datasette $< > $@

docs.md: congress.db
	../../target/debug/sqlite-docs-cli generate-markdown $< > $@

all: metadata.json docs.md

clean:
	rm metadata.json docs.md

datasette: congress.db metadata.json
	datasette serve congress.db -m metadata.json

.PHONY: datasette all clean
