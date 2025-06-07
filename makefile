build:
	docker compose build
bash:
	docker compose run --rm app bash
specs:
	docker compose run --rm app bundle exec rspec
