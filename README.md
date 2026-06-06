# luci-proto-wireguard-ip6prefix

**English** | [Русский](README.ru.md) | [Deutsch](README.de.md)

LuCI overlay for OpenWrt: adds **IPv6 routed prefix** (`ip6prefix`) to the WireGuard interface **General Settings** tab.

Package name `luci-proto-wireguard-ip6prefix` — does **not** replace stock `luci-proto-wireguard`; it installs a patched `wireguard.js` copy on post-install.

## Why

Stock `luci-proto-wireguard` hides `ip6prefix` in Advanced or uses non-standard fields. This overlay matches other protocols (e.g. 6in4) for Prefix Delegation and IPv6 routing over WireGuard.

## Build

```bash
make -f Makefile.build all
# dist/luci-proto-wireguard-ip6prefix-1.0.0-r1.apk
# dist/luci-proto-wireguard-ip6prefix_1.0.0-1_all.ipk
```

Prerequisites: `python3`, OpenWrt SDK `apk` tool (auto-downloaded on first build).

## Install (OpenWrt 25.12+, apk)

```bash
./scripts/install-apk.sh root@192.168.35.1
./scripts/verify-apk-pins.sh 192.168.35.1
```

### r1 vs r2 (LuCI version)

APK depends on installed `luci-proto-wireguard` version (`LUCI_WG_VERSION` in build script):

| Router LuCI | APK release |
|-------------|-------------|
| ~26.143 | `1.0.0-r1` (dev) |
| ~26.138 | `1.0.0-r2` (prod mediatek) |

Check: `apk policy luci-proto-wireguard`

Manual:

```bash
scp dist/luci-proto-wireguard-ip6prefix-*.apk root@router:/tmp/
ssh root@router 'apk add --allow-untrusted /tmp/luci-proto-wireguard-ip6prefix-*.apk'
```

## Usage

**Network → Interfaces → [WireGuard] → Edit → General Settings → IPv6 routed prefix**

Example: `2001:db8::/56`

## Releases

Pre-built packages: [GitHub Releases](https://github.com/nagual2/luci-proto-wireguard-ip6prefix/releases)

## Files

| Path | Role |
|------|------|
| `wireguard.js.orig` | Upstream LuCI `wireguard.js` baseline |
| `wireguard-ip6prefix.patch` | Reference patch |
| `scripts/patch-wireguard-js.py` | Build-time patcher |
| `scripts/build-apk-mkpkg.sh` | APK builder |
| `Makefile.build` | APK + IPK targets |

## Compatibility

- OpenWrt 25.12+ (apk) — primary target
- OpenWrt 23.x (opkg) — IPK in `dist/`
- Depends on `luci-proto-wireguard` (version pinned in APK metadata)

## License

Apache-2.0 (same as upstream LuCI wireguard.js)

## Author

Max <nahual15@gmail.com>

Русская документация: [README.ru.md](README.ru.md)
