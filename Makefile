all: build preview

preview:
	mkdocs serve

build:
	mkdocs build

clean:
	rm -rf site
