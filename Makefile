DOCC_BUILD_PATH := /tmp/swift-web-playground-build
LLVM_PATH := /usr/local/opt/llvm/bin/llvm-cov
BIN_PATH = $(shell swift build --show-bin-path)
XCTEST_PATH = $(shell find $(BIN_PATH) -name '*.xctest')
COV_BIN = $(XCTEST_PATH)/Contents/MacOs/$(shell basename $(XCTEST_PATH) .xctest)
COV_OUTPUT_PATH = "/tmp/swift-web-playground.lcov"

test-swift:
	@swift test --enable-code-coverage

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
	
check-for-llvm:
	test -f $(LLVM_PATH) || brew install llvm
	
code-cov: check-for-llvm
	rm -rf $(COV_OUTPUT_PATH)
	$(LLVM_PATH) export \
		$(COV_BIN) \
		-instr-profile=.build/debug/codecov/default.profdata \
		-ignore-filename-regex=".build|Tests" \
		-format lcov > $(COV_OUTPUT_PATH)
		
	
code-cov-report:
	test -f helpers/code-cov-report.sh && . helpers/code-cov-report.sh
