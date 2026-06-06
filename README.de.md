# luci-proto-wireguard-ip6prefix

[English](README.md) | [Русский](README.ru.md) | **Deutsch**

LuCI-Overlay für OpenWrt: fügt **IPv6 routed prefix** (`ip6prefix`) im Tab **General Settings** der WireGuard-Schnittstelle hinzu.

Paketname `luci-proto-wireguard-ip6prefix` — ersetzt **nicht** das Stock-Paket `luci-proto-wireguard`; beim Installieren wird eine gepatchte `wireguard.js` kopiert.

## Warum

Stock-`luci-proto-wireguard` versteckt `ip6prefix` unter Advanced oder nutzt nicht standardisierte Felder. Dieses Overlay entspricht anderen Protokollen (z. B. 6in4) für Prefix Delegation und IPv6-Routing über WireGuard.

## Build

```bash
make -f Makefile.build all
# dist/luci-proto-wireguard-ip6prefix-1.0.0-r1.apk
# dist/luci-proto-wireguard-ip6prefix_1.0.0-1_all.ipk
```

Voraussetzungen: `python3`, OpenWrt-SDK-Tool `apk` (wird beim ersten Build automatisch geladen).

## Installation (OpenWrt 25.12+, apk)

```bash
./scripts/install-apk.sh root@192.168.35.1
./scripts/verify-apk-pins.sh 192.168.35.1
```

Manuell:

```bash
scp dist/luci-proto-wireguard-ip6prefix-*.apk root@router:/tmp/
ssh root@router 'apk add --allow-untrusted /tmp/luci-proto-wireguard-ip6prefix-*.apk'
```

### r1 vs r2 (LuCI-Version)

Das APK hängt von der installierten `luci-proto-wireguard`-Version ab (`LUCI_WG_VERSION` in `scripts/build-apk-mkpkg.sh`):

| Router-LuCI | APK-Release |
|-------------|-------------|
| ~26.143 | `1.0.0-r1` (dev) |
| ~26.138 | `1.0.0-r2` (prod mediatek) |

Prüfen: `apk policy luci-proto-wireguard`

## Verwendung

**Netzwerk → Schnittstellen → [WireGuard] → Bearbeiten → General Settings → IPv6 routed prefix**

Beispiel: `2001:db8::/56`

## Releases

Fertige Pakete: [GitHub Releases](https://github.com/nagual2/luci-proto-wireguard-ip6prefix/releases)

## Dateien

| Pfad | Rolle |
|------|-------|
| `wireguard.js.orig` | Upstream LuCI `wireguard.js` |
| `wireguard-ip6prefix.patch` | Referenz-Patch |
| `scripts/patch-wireguard-js.py` | Build-Zeit-Patcher |
| `scripts/build-apk-mkpkg.sh` | APK-Builder |
| `Makefile.build` | APK- und IPK-Targets |

## Kompatibilität

- OpenWrt 25.12+ (apk) — primäres Ziel
- OpenWrt 23.x (opkg) — IPK in `dist/`
- Abhängigkeit: `luci-proto-wireguard` (Version im APK-Metadaten gepinnt)

## Lizenz

Apache-2.0 (wie upstream LuCI wireguard.js)

## Autor

Max <nahual15@gmail.com>
