VERSION=$(shell cat VERSION)

ifeq ($(shell uname -s),Darwin)
CONFIG_DARWIN=y
else ifeq ($(OS),Windows_NT)
CONFIG_WINDOWS=y
else
CONFIG_LINUX=y
endif

LIBRARY_PREFIX=lib
ifdef CONFIG_DARWIN
LOADABLE_EXTENSION=dylib
endif

ifdef CONFIG_LINUX
LOADABLE_EXTENSION=so
endif


ifdef CONFIG_WINDOWS
LOADABLE_EXTENSION=dll
LIBRARY_PREFIX=
endif

prefix=dist
TARGET_LOADABLE=$(prefix)/debug/docs0.$(LOADABLE_EXTENSION)
TARGET_LOADABLE_RELEASE=$(prefix)/release/docs0.$(LOADABLE_EXTENSION)

TARGET_STATIC=$(prefix)/debug/docs0.a
TARGET_STATIC_RELEASE=$(prefix)/release/docs0.a

TARGET_CLI=$(prefix)/debug/sqlite-docs
TARGET_CLI_RELEASE=$(prefix)/release/sqlite-docs

TARGET_WHEELS=$(prefix)/debug/wheels
TARGET_WHEELS_RELEASE=$(prefix)/release/wheels

INTERMEDIATE_PYPACKAGE_EXTENSION=python/sqlite_docs/sqlite_docs/docs0.$(LOADABLE_EXTENSION)

ifdef target
CARGO_TARGET=--target=$(target)
BUILT_LOCATION=target/$(target)/debug/$(LIBRARY_PREFIX)sqlite_docs.$(LOADABLE_EXTENSION)
BUILT_LOCATION_RELEASE=target/$(target)/release/$(LIBRARY_PREFIX)sqlite_docs.$(LOADABLE_EXTENSION)
BUILT_CLI=target/$(target)/debug/sqlite-docs-cli
BUILT_CLI_RELEASE=target/$(target)/release/sqlite-docs-cli
else
CARGO_TARGET=
BUILT_LOCATION=target/debug/$(LIBRARY_PREFIX)sqlite_docs.$(LOADABLE_EXTENSION)
BUILT_LOCATION_RELEASE=target/release/$(LIBRARY_PREFIX)sqlite_docs.$(LOADABLE_EXTENSION)
BUILT_CLI=target/debug/sqlite-docs-cli
BUILT_CLI_RELEASE=target/release/sqlite-docs-cli
endif

ifdef python
PYTHON=$(python)
else
PYTHON=python3
endif

ifdef IS_MACOS_ARM
RENAME_WHEELS_ARGS=--is-macos-arm
else
RENAME_WHEELS_ARGS=
endif

$(prefix):
	mkdir -p $(prefix)/debug
	mkdir -p $(prefix)/release

$(TARGET_WHEELS): $(prefix)
	mkdir -p $(TARGET_WHEELS)

$(TARGET_WHEELS_RELEASE): $(prefix)
	mkdir -p $(TARGET_WHEELS_RELEASE)

$(TARGET_LOADABLE): $(prefix) $(shell find . -type f -name '*.rs')
	cargo build $(CARGO_TARGET)
	cp $(BUILT_LOCATION) $@

$(TARGET_LOADABLE_RELEASE): $(prefix) $(shell find . -type f -name '*.rs')
	cargo build --release $(CARGO_TARGET)
	cp $(BUILT_LOCATION_RELEASE) $@

$(TARGET_CLI): $(prefix) $(shell find . -type f -name '*.rs')
	cargo build $(CARGO_TARGET)
	cp $(BUILT_CLI) $@

$(TARGET_CLI_RELEASE): $(prefix) $(shell find . -type f -name '*.rs')
	cargo build --release $(CARGO_TARGET)
	cp $(BUILT_CLI_RELEASE) $@

python: $(TARGET_WHEELS) $(TARGET_LOADABLE) python/sqlite_docs/setup.py python/sqlite_docs/sqlite_docs/__init__.py .github/workflows/rename-wheels.py
	cp $(TARGET_LOADABLE) $(INTERMEDIATE_PYPACKAGE_EXTENSION)
	rm $(TARGET_WHEELS)/sqlite_docs* || true
	pip3 wheel python/sqlite_docs/ -w $(TARGET_WHEELS)
	python3 .github/workflows/rename-wheels.py $(TARGET_WHEELS) $(RENAME_WHEELS_ARGS)

python-release: $(TARGET_LOADABLE_RELEASE) $(TARGET_WHEELS_RELEASE) python/sqlite_docs/setup.py python/sqlite_docs/sqlite_docs/__init__.py .github/workflows/rename-wheels.py
	cp $(TARGET_LOADABLE_RELEASE)  $(INTERMEDIATE_PYPACKAGE_EXTENSION)
	rm $(TARGET_WHEELS_RELEASE)/sqlite_docs* || true
	pip3 wheel python/sqlite_docs/ -w $(TARGET_WHEELS_RELEASE)
	python3 .github/workflows/rename-wheels.py $(TARGET_WHEELS_RELEASE) $(RENAME_WHEELS_ARGS)

datasette: $(TARGET_WHEELS) python/datasette_sqlite_docs/setup.py python/datasette_sqlite_docs/datasette_sqlite_docs/__init__.py
	rm $(TARGET_WHEELS)/datasette* || true
	pip3 wheel python/datasette_sqlite_docs/ --no-deps -w $(TARGET_WHEELS)

datasette-release: $(TARGET_WHEELS_RELEASE) python/datasette_sqlite_docs/setup.py python/datasette_sqlite_docs/datasette_sqlite_docs/__init__.py
	rm $(TARGET_WHEELS_RELEASE)/datasette* || true
	pip3 wheel python/datasette_sqlite_docs/ --no-deps -w $(TARGET_WHEELS_RELEASE)

npm: VERSION npm/platform-package.README.md.tmpl npm/platform-package.package.json.tmpl npm/sqlite-docs/package.json.tmpl scripts/npm_generate_platform_packages.sh
	scripts/npm_generate_platform_packages.sh

deno: VERSION deno/deno.json.tmpl
	scripts/deno_generate_package.sh

Cargo.toml: VERSION
	cargo set-version `cat VERSION`

python/sqlite_docs/sqlite_docs/version.py: VERSION
	printf '__version__ = "%s"\n__version_info__ = tuple(__version__.split("."))\n' `cat VERSION` > $@

python/datasette_sqlite_docs/datasette_sqlite_docs/version.py: VERSION
	printf '__version__ = "%s"\n__version_info__ = tuple(__version__.split("."))\n' `cat VERSION` > $@

bindings/ruby/lib/version.rb: bindings/ruby/lib/version.rb.tmpl VERSION
	VERSION=$(VERSION) envsubst < $< > $@

ruby: bindings/ruby/lib/version.rb

version:
	make Cargo.toml
	make python/sqlite_docs/sqlite_docs/version.py
	make python/datasette_sqlite_docs/datasette_sqlite_docs/version.py
	make npm
	make deno
	make ruby


format:
	cargo fmt

sqlite-docs.h: cbindgen.toml
	rustup run nightly cbindgen  --config $< -o $@

release: $(TARGET_LOADABLE_RELEASE) $(TARGET_STATIC_RELEASE)

loadable: $(TARGET_LOADABLE)
loadable-release: $(TARGET_LOADABLE_RELEASE)

static: $(TARGET_STATIC)
static-release: $(TARGET_STATIC_RELEASE)

loadable: $(TARGET_CLI)
loadable-release: $(TARGET_CLI_RELEASE)

debug: loadable static python datasette
release: loadable-release static-release python-release datasette-release

clean:
	rm dist/*
	cargo clean

test-loadable:
	$(PYTHON) tests/test-loadable.py

test-python:
	$(PYTHON) tests/test-python.py

test-npm:
	node npm/sqlite-docs/test.js

test-deno:
	deno task --config deno/deno.json test

test:
	make test-loadable
	make test-python
	make test-npm
	make test-deno

publish-release:
	./scripts/publish_release.sh

.PHONY: clean \
	test test-loadable test-python test-npm test-deno \
	loadable loadable-release \
	python python-release \
	datasette datasette-release \
	static static-release \
	debug release \
	format version publish-release \
	npm deno ruby
