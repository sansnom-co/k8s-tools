#!/usr/bin/env bash
# Smoke-tests a built static binary.
# Usage: test-binary.sh <tool-name> <version>
#   tool-name : kubectl | helm | jq | skopeo | oras | cosign | flux
#   version   : upstream version tag (e.g. v1.36.0, jq-1.8.1)

set -euo pipefail

TOOL="${1:?Usage: test-binary.sh <tool-name> <version>}"
VERSION="${2:?Usage: test-binary.sh <tool-name> <version>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINARY="${SCRIPT_DIR}/../static_binaries/${TOOL}"

pass() { echo "  PASS: $1"; }
fail() { echo "  FAIL: $1" >&2; exit 1; }

echo ""
echo "--- Testing ${TOOL} ${VERSION} ---"
echo ""

# Bare version number (strip leading v or jq- prefix)
BARE="${VERSION#v}"
BARE="${BARE#jq-}"

# 1. Binary exists
[[ -f "$BINARY" ]] || fail "binary not found at $BINARY"
chmod +x "$BINARY"
pass "binary exists"

# 2. Static linking — ldd prints "not a dynamic executable" for static binaries
LDD_OUT=$(ldd "$BINARY" 2>&1 || true)
if echo "$LDD_OUT" | grep -q "not a dynamic executable"; then
    pass "statically linked"
else
    fail "binary has dynamic dependencies:
$LDD_OUT"
fi

# 3. Version string present in output
case "$TOOL" in
    kubectl) VERSION_OUT=$(  "$BINARY" version --client 2>&1 || true) ;;
    helm)    VERSION_OUT=$(  "$BINARY" version         2>&1 || true) ;;
    jq)      VERSION_OUT=$(  "$BINARY" --version       2>&1 || true) ;;
    skopeo)  VERSION_OUT=$(  "$BINARY" --version       2>&1 || true) ;;
    oras)    VERSION_OUT=$(  "$BINARY" version         2>&1 || true) ;;
    cosign)  VERSION_OUT=$(  "$BINARY" version         2>&1 || true) ;;
    flux)    VERSION_OUT=$(  "$BINARY" version --client 2>&1 || true) ;;
    *)       fail "unknown tool: $TOOL" ;;
esac

if echo "$VERSION_OUT" | grep -qF "$BARE"; then
    pass "version string matches ($BARE)"
else
    fail "version mismatch — expected '$BARE' in output:
$VERSION_OUT"
fi

# 4. Help text renders without crashing
"$BINARY" --help > /dev/null 2>&1 || true
pass "help text renders"

echo ""
echo "--- ${TOOL} all tests passed ---"
echo ""
