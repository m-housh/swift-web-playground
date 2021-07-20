test-swift:
	@swift test

test-linux:
	@docker run \
		--rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		--platform linux/amd64 \
		swift:5.3 \
		bash Bootstrap/test.sh

test-all: test-swift test-linux

db:
	@createuser --superuser playground || true
	@psql template1 -c "ALTER USER playground PASSWORD 'playground';"
	@createdb --owner playground playground_development || true
	@createdb --owner playground playground_test || true
	
clean-db:
	@dropdb --username playground playground_development || true
	@dropdb --username playground playground_test || true
	@dropuser playground || true

run-server-linux:
	@docker-compose \
		--file Bootstrap/docker-compose.yml \
		--project-directory . \
		up \
		--build
