# luci-proto-wireguard-ip6prefix

Оверлей для LuCI (OpenWrt): поле **IPv6 routed prefix** (`ip6prefix`) в разделе **General Settings** интерфейса WireGuard.

Отдельный пакет `luci-proto-wireguard-ip6prefix` — не заменяет stock `luci-proto-wireguard`, а копирует патченный `wireguard.js` при установке.

## Сборка

```bash
make -f Makefile.build all
# dist/luci-proto-wireguard-ip6prefix-1.0.0-r1.apk
# dist/luci-proto-wireguard-ip6prefix_1.0.0-1_all.ipk
```

## Установка (OpenWrt 25.12+, apk)

```bash
./scripts/install-apk.sh root@192.168.35.1
./scripts/verify-apk-pins.sh 192.168.35.1
```

Или вручную:

```bash
scp dist/luci-proto-wireguard-ip6prefix-*.apk root@router:/tmp/
ssh root@router 'apk add --allow-untrusted /tmp/luci-proto-wireguard-ip6prefix-*.apk'
```

## Использование

**Network → Interfaces → [WireGuard] → Edit → General Settings → IPv6 routed prefix**

Пример: `2001:db8::/56`

## Релизы

Скачать готовые пакеты: [GitHub Releases](https://github.com/nagual2/luci-proto-wireguard-ip6prefix/releases)

## Совместимость

- OpenWrt 25.12+ (apk)
- Зависимость: `luci-proto-wireguard` той же версии LuCI (см. `LUCI_WG_VERSION` в Makefile.build)

## Автор

Max <nahual15@gmail.com>
