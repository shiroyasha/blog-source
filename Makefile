newpost:
	./bin/newpost $(TITLE)

setup:
	docker compose run app bundle install

server:
	docker compose up
