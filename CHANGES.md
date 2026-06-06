# Changelog

## 1.0.0 (2026-06-06)

- Project layout aligned with nagual2 packages (Makefile.build, APK/IPK, CI).
- Package name: `luci-proto-wireguard-ip6prefix` (overlay, does not replace stock `luci-proto-wireguard`).
- Installs patched `wireguard.js` to `/usr/share/luci-proto-wireguard-ip6prefix/` and copies to LuCI path on install.
- `ip6prefix` field in **General Settings** tab (Prefix Delegation for WireGuard).
- Build: `make -f Makefile.build all` → `dist/*.apk` + `dist/*.ipk`.
- Install: `./scripts/install-apk.sh <router>` with world pin via `apk add --allow-untrusted`.
