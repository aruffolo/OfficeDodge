.PHONY: build run test verify clean rules-lint

ROOT := $(CURDIR)
WORKSPACE := $(ROOT)/OfficeDodge.xcworkspace
SCHEME := OfficeDodge
DERIVED_DATA_PATH := $(ROOT)/.build/DerivedData
APP_BUNDLE_ID := com.aruffolo.officedodge
SIMULATOR ?= iPhone 16

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

build:
	xcodebuild \
		-workspace "$(WORKSPACE)" \
		-scheme "$(SCHEME)" \
		-destination 'generic/platform=iOS Simulator' \
		-derivedDataPath "$(DERIVED_DATA_PATH)" \
		build

run:
	@DEVICE_ID="$${SIMULATOR_ID:-}"; \
	if [[ -z "$$DEVICE_ID" ]]; then \
		DEVICE_ID=$$(xcrun simctl list devices booted | rg -m1 -o '[0-9A-F-]{36}' || true); \
	fi; \
	if [[ -z "$$DEVICE_ID" ]]; then \
		DEVICE_ID=$$(xcrun simctl list devices available | rg -m1 "^[[:space:]]*$(SIMULATOR) \\(" | rg -o '[0-9A-F-]{36}' || true); \
	fi; \
	if [[ -z "$$DEVICE_ID" ]]; then \
		DEVICE_ID=$$(xcrun simctl list devices available | rg -m1 -o '[0-9A-F-]{36}' || true); \
	fi; \
	if [[ -z "$$DEVICE_ID" ]]; then \
		echo "No available iOS simulator found."; \
		exit 1; \
	fi; \
	echo "Using simulator ID: $$DEVICE_ID"; \
	xcrun simctl boot "$$DEVICE_ID" >/dev/null 2>&1 || true; \
	xcrun simctl bootstatus "$$DEVICE_ID" -b; \
	xcodebuild \
		-workspace "$(WORKSPACE)" \
		-scheme "$(SCHEME)" \
		-destination "platform=iOS Simulator,id=$$DEVICE_ID" \
		-derivedDataPath "$(DERIVED_DATA_PATH)" \
		build; \
	APP_PATH="$(DERIVED_DATA_PATH)/Build/Products/Debug-iphonesimulator/OfficeDodge.app"; \
	if [[ ! -d "$$APP_PATH" ]]; then \
		echo "Built app not found at $$APP_PATH"; \
		exit 1; \
	fi; \
	xcrun simctl install "$$DEVICE_ID" "$$APP_PATH"; \
	xcrun simctl terminate "$$DEVICE_ID" "$(APP_BUNDLE_ID)" >/dev/null 2>&1 || true; \
	xcrun simctl launch "$$DEVICE_ID" "$(APP_BUNDLE_ID)"

verify:
	./verify.sh

test: verify

clean:
	rm -rf "$(DERIVED_DATA_PATH)"

rules-lint:
	scripts/lint_rules_docs.sh
