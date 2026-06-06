#!/usr/bin/env bash
# Install luci-proto-wireguard-ip6prefix on OpenWrt 25.12+ (apk + world pin).
# Usage: ROUTER=root@192.168.35.1 ./scripts/install-apk.sh [path/to/*.apk]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ROUTER="${ROUTER:-root@192.168.35.1}"
SSH_KEY="${SSH_KEY:-${HOME}/.ssh/id_ed25519_openwrt}"
APK="${1:-$(ls -1 "$ROOT"/dist/luci-proto-wireguard-ip6prefix-*.apk 2>/dev/null | sort -V | tail -1)}"

[ -n "$APK" ] && [ -f "$APK" ] || {
	echo "No apk found. Build first: make -f Makefile.build apk" >&2
	exit 1
}

echo "Installing $(basename "$APK") on $ROUTER"
scp -O -i "$SSH_KEY" "$APK" "$ROUTER:/tmp/luci-proto-wireguard-ip6prefix.apk"
ssh -i "$SSH_KEY" "$ROUTER" '
	set -e
	apk add --allow-untrusted /tmp/luci-proto-wireguard-ip6prefix.apk
	rm -f /tmp/luci-proto-wireguard-ip6prefix.apk
	grep "^luci-proto-wireguard-ip6prefix><" /etc/apk/world || echo "WARN: not pinned"
	ls -la /www/luci-static/resources/protocol/wireguard.js
	grep -c ip6prefix /www/luci-static/resources/protocol/wireguard.js
'
echo "Done."
