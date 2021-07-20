test-swift:
	@swift test \
		--verbose
	
test-linux:
	@docker run \
		--rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		swift:5.4 \
		bash -c 'apt-get update && apt-get -y install openssl libssl-dev libz-dev make && make test-swift'

test-linux-arm:
	@docker run \
		--rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		--network host \
		swiftarm/swift:latest \
		bash -c 'apt-get update && apt-get -y install openssl libssl-dev libz-dev make && make test-swift'

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

.PHONY: test-all test-swift test-linux test-linux-arm
