.PHONY: build

newpost:
	./bin/newpost $(TITLE)

setup:
	docker compose run app bundle install

shell:
	docker compose run app bash

server:
	docker compose up

build:
	docker compose run -e NO_CONTRACTS=true app bundle exec middleman build

deploy: build
	rm -rf /tmp/shiroyasha.github.io
	git clone git@github.com:shiroyasha/shiroyasha.github.io.git /tmp/shiroyasha.github.io
	rm -rf /tmp/shiroyasha.github.io/*
	cp -r build/* /tmp/shiroyasha.github.io
	cd /tmp/shiroyasha.github.io && git add . && git commit -m "Update from $(shell git rev-parse --short HEAD) at $(shell date)" && git push
