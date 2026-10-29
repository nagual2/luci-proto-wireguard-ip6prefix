# Changelog

## 1.0.0 (2026-06-06)

- Project layout aligned with nagual2 packages (Makefile.build, APK/IPK, CI).
- Package name: `luci-proto-wireguard-ip6prefix` (overlay, does not replace stock `luci-proto-wireguard`).
- Installs patched `wireguard.js` to `/usr/share/luci-proto-wireguard-ip6prefix/` and copies to LuCI path on install.
- `ip6prefix` field in **General Settings** tab (Prefix Delegation for WireGuard).
- Build: `make -f Makefile.build all` → `dist/*.apk` + `dist/*.ipk`.
- Install: `./scripts/install-apk.sh <router>` with world pin via `apk add --allow-untrusted`.

## 1.0.1-r1 (2026-10-29)

Rebased the patch onto LuCI 26.288.56989~75a306d (OpenWrt 25.12.6):

- `wireguard.js.orig` replaced with the formatted source snapshot of
  commit 75a306d — the 25.12.6 LuCI snapshot ships readable source, not a
  minified build.
- `scripts/patch-wireguard-js.py` rewritten for the formatted layout
  (asserted anchors, idempotent).
- `LUCI_WG_VERSION` pin: 26.143.25613~74927c2 → 26.288.56989~75a306d.
  Fixes the pin mismatch that kept the 1.0.0-r1/r2 packages off
  OpenWrt 25.12.6.
