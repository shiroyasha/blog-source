newpost:
	./bin/newpost $(TITLE)

setup:
	docker-compose run app bundle install

server:
	docker-compose run --service-ports app bundle exec middleman server --port 4000 --bind-address 0.0.0.0
