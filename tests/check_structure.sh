#!/usr/bin/env bash
# Sanity check for luci-proto-wireguard-ip6prefix layout.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

required=(
	Makefile.build
	VERSION
	CHANGES.md
	LICENSE
	README.md
	README.ru.md
	README.de.md
	wireguard-ip6prefix.patch
	scripts/build-apk-mkpkg.sh
	scripts/install-apk.sh
	scripts/patch-wireguard-js.py
	scripts/test-wireguard-patch.sh
)

for f in "${required[@]}"; do
	[ -f "$f" ] || {
		echo "missing: $f" >&2
		exit 1
	}
done

python3 scripts/patch-wireguard-js.py wireguard.js.orig /tmp/wg-patched-test.js
grep -q "taboption('general',form.DynamicList,'ip6prefix'" /tmp/wg-patched-test.js
rm -f /tmp/wg-patched-test.js

echo "structure OK"
