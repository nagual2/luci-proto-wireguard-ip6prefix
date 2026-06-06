#!/usr/bin/env bash
# Build luci-proto-wireguard-ip6prefix .apk for OpenWrt 25.12+ (apk package manager).
#
# Usage:
#   ./scripts/build-apk-mkpkg.sh
#   LUCI_WG_VERSION=26.143.25613~74927c2 ./scripts/build-apk-mkpkg.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT/dist}"
SDK_DIR="${SDK_DIR:-$ROOT/build/sdk}"
APK_TOOL="${APK_TOOL:-$SDK_DIR/staging_dir/host/bin/apk}"

PROJECT_VERSION="${PROJECT_VERSION:-1.0.0}"
PKG_RELEASE="${PKG_RELEASE:-1}"
LUCI_WG_VERSION="${LUCI_WG_VERSION:-26.143.25613~74927c2}"
PKG_VERSION="${PROJECT_VERSION}-r${PKG_RELEASE}"

log() { printf '[build-apk-mkpkg] %s\n' "$*"; }

ensure_apk_tool() {
	if [ -x "$APK_TOOL" ]; then
		return 0
	fi

	local archive url
	url="${SDK_URL:-https://downloads.openwrt.org/releases/25.12.0/targets/x86/64/openwrt-sdk-25.12.0-x86-64_gcc-14.3.0_musl.Linux-x86_64.tar.zst}"
	archive="$ROOT/build/$(basename "$url")"

	log "Extracting apk host tool from OpenWrt SDK..."
	mkdir -p "$ROOT/build"
	[ -f "$archive" ] || wget -O "$archive" "$url"
	rm -rf "$SDK_DIR"
	mkdir -p "$SDK_DIR"
	tar --zstd -xf "$archive" -C "$SDK_DIR" --strip-components=1
	APK_TOOL="$SDK_DIR/staging_dir/host/bin/apk"
	[ -x "$APK_TOOL" ] || {
		echo "apk tool not found after SDK extract: $APK_TOOL" >&2
		exit 1
	}
}

ensure_wireguard_js() {
	local patched="$ROOT/htdocs/luci-static/resources/protocol/wireguard.js"
	if [ -f "$patched" ]; then
		return 0
	fi
	[ -f "$ROOT/wireguard.js.orig" ] || {
		echo "wireguard.js.orig missing — copy from router first" >&2
		exit 1
	}
	python3 "$ROOT/scripts/patch-wireguard-js.py" \
		"$ROOT/wireguard.js.orig" "$patched"
}

ensure_apk_tool
ensure_wireguard_js

STAGE="$(mktemp -d)"
POSTINST="$(mktemp)"
trap 'rm -rf "$STAGE" "$POSTINST"' EXIT

log "Staging files in $STAGE"
install -d "$STAGE/usr/share/luci-proto-wireguard-ip6prefix"
install -m 0644 "$ROOT/htdocs/luci-static/resources/protocol/wireguard.js" \
	"$STAGE/usr/share/luci-proto-wireguard-ip6prefix/wireguard.js"

cat >"$POSTINST" <<'EOF'
#!/bin/sh
[ -n "${IPKG_INSTROOT}" ] && exit 0
SRC=/usr/share/luci-proto-wireguard-ip6prefix/wireguard.js
DST=/www/luci-static/resources/protocol/wireguard.js
[ -f "$SRC" ] || exit 1
mkdir -p "$(dirname "$DST")"
cp -f "$SRC" "$DST"
rm -f /tmp/luci-indexcache.*
rm -rf /tmp/luci-modulecache/
/etc/init.d/rpcd reload 2>/dev/null
/etc/init.d/uhttpd restart 2>/dev/null
exit 0
EOF
chmod 0755 "$POSTINST"

mkdir -p "$OUTPUT_DIR"
OUT_APK="$OUTPUT_DIR/luci-proto-wireguard-ip6prefix-${PKG_VERSION}.apk"

log "Creating $OUT_APK (built for luci-proto-wireguard ${LUCI_WG_VERSION})"
"$APK_TOOL" mkpkg \
	--compat 3.0.0_pre1 \
	--files "$STAGE" \
	--info "name:luci-proto-wireguard-ip6prefix" \
	--info "version:${PKG_VERSION}" \
	--info "arch:noarch" \
	--info "license:Apache-2.0" \
	--info "maintainer:Max <nahual15@gmail.com>" \
	--info "depends:luci-proto-wireguard~${LUCI_WG_VERSION}" \
	--info "description:LuCI WireGuard IPv6 routed prefix (ip6prefix) in General Settings tab" \
	--script "post-install:$POSTINST" \
	--output "$OUT_APK"

log "Built: $OUT_APK ($(wc -c <"$OUT_APK") bytes)"
