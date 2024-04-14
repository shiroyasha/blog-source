newpost:
	./bin/newpost $(TITLE)

setup:
	docker compose run app bundle install

server:
	docker compose up

build:
	docker compose run -e NO_CONTRACTS=true app bundle exec middleman build
