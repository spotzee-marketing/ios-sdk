#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_dir="$(mktemp -d /tmp/spotzee-ios-bridge-tests.XXXXXX)"
trap 'rm -rf "$test_dir"' EXIT

swiftc -parse-as-library \
    "$repo_root/Sources/Spotzee/InAppBridgePolicy.swift" \
    "$repo_root/scripts/in-app-bridge-policy-tests.swift" \
    -o "$test_dir/in-app-bridge-policy-tests"
"$test_dir/in-app-bridge-policy-tests"

controller="$repo_root/Sources/Spotzee/InAppModalViewController.swift"
grep -Fq 'message.frameInfo.isMainFrame' "$controller"
grep -Fq 'navigationAction.sourceFrame.isMainFrame' "$controller"
grep -Fq 'InAppBridgePolicy.message' "$controller"
