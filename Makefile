DOCC_BUILD_PATH := /tmp/swift-web-playground-build

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
	
clean-db-linux:
	@docker-compose \
		--file Bootstrap/docker-compose.yml \
		--project-directory . \
		down \
		--volumes

run-server-linux:
	@docker-compose \
		--file Bootstrap/docker-compose.yml \
		--project-directory . \
		up \
		--build
		
env-example:
	@cp Bootstrap/playground-env-example .playground-env
	
format:
	@docker run \
		--rm \
		--workdir "/work" \
		--volume "$(PWD):/work" \
		--platform linux/amd64 \
		mhoush/swift-format:latest \
		format \
		--in-place \
		--recursive \
		./Package.swift \
		./Sources/

docc-docs:
	@rm -rf $(DOCC_BUILD_PATH)
	@xcodebuild docbuild \
		-scheme swift-web-playground-Package \
		-destination 'platform=OS X,arch=x86_64' \
		-toolchain 5.5 \
		-derivedDataPath $(DOCC_BUILD_PATH)
		
copy-docc-archives:
	. Bootstrap/copy-docc-archives.sh
	
