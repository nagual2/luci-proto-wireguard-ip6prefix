#!/bin/sh
# Verify luci-proto-wireguard-ip6prefix is pinned in /etc/apk/world.
# Usage: ./scripts/verify-apk-pins.sh [router_host]
set -eu

HOST="${1:-}"
SSH_KEY="${SSH_KEY:-${HOME}/.ssh/id_ed25519_openwrt}"
PKG="luci-proto-wireguard-ip6prefix"

REMOTE_SCRIPT='
PKG="luci-proto-wireguard-ip6prefix"
if grep -q "^${PKG}><" /etc/apk/world 2>/dev/null; then
	printf "OK   %s pinned\n" "$PKG"
elif apk info -e "$PKG" >/dev/null 2>&1; then
	printf "WARN %s installed but NOT pinned\n" "$PKG"
	exit 1
else
	printf "SKIP %s not installed\n" "$PKG"
fi
apk policy "$PKG" 2>&1 | grep -v "^WARNING:" || true
'

if [ -n "$HOST" ]; then
	ssh -i "$SSH_KEY" "root@${HOST}" "$REMOTE_SCRIPT"
else
	eval "$REMOTE_SCRIPT"
fi
