CACHE_DIR := /tmp/swift-tmp/clang-cache
SWIFT_FLAGS := --disable-sandbox -Xbuild-tools-swiftc -module-cache-path -Xbuild-tools-swiftc $(CACHE_DIR) -Xswiftc -module-cache-path -Xswiftc $(CACHE_DIR)

.PHONY: all build test app run clean

all: build

prepare:
	@mkdir -p $(CACHE_DIR)

build: prepare
	swift build $(SWIFT_FLAGS)

test: prepare
	swift run $(SWIFT_FLAGS) PomodoroTests

app: prepare
	./scripts/build_app.sh

run: build
	swift run $(SWIFT_FLAGS) PomodoroApp

clean:
	swift package clean
	rm -rf .build Pomodoro.app
