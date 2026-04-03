# LuCI WireGuard IPv6 Routed Prefix Support

Патч для LuCI (OpenWrt Web Interface), добавляющий поддержку поля **IPv6 routed prefix** (`ip6prefix`) для WireGuard интерфейсов.

## Описание

Стандартный `luci-proto-wireguard` не предоставляет удобного способа настроить IPv6 префикс для WireGuard интерфейсов через веб-интерфейс. Этот патч добавляет поле "IPv6 routed prefix" в раздел **General Settings**, аналогично другим протоколам (например, 6in4).

Это необходимо для:
- **Prefix Delegation** — делегирования IPv6 префиксов клиентам
- **Маршрутизации IPv6** — корректной работы IPv6 через WireGuard туннель
- **SLAAC** — автоматической конфигурации адресов клиентами

## Файлы

| Файл | Описание |
|------|----------|
| `wireguard-ip6prefix.patch` | Патч для `wireguard.js` |
| `test-wireguard-patch.sh` | Скрипт тестирования на OpenWrt |
| `luci-proto-wireguard_26.088.70222-1_all.ipk` | Готовый бинарный пакет |

## Установка

### Способ 1: Установка готового пакета (рекомендуется)

```bash
# Скопируйте .ipk на роутер
scp luci-proto-wireguard_26.088.70222-1_all.ipk root@openwrt:/tmp/

# Установите
ssh root@openwrt 'opkg install /tmp/luci-proto-wireguard_26.088.70222-1_all.ipk'

# Перезагрузите веб-интерфейс
/etc/init.d/uhttpd restart
```

### Способ 2: Ручное применение патча

```bash
# Скопируйте патч на роутер
scp wireguard-ip6prefix.patch root@openwrt:/tmp/

# Примените
ssh root@openwrt '
    cd /usr/share/luci/resources/protocol/
    cp wireguard.js wireguard.js.backup
    patch -p3 < /tmp/wireguard-ip6prefix.patch
    /etc/init.d/uhttpd restart
'
```

## Использование

После установки откройте:
```
Network → Interfaces → [Ваш WireGuard интерфейс] → Edit
```

В разделе **General Settings** появится поле:
- **IPv6 routed prefix** — введите префикс (например, `2001:db8::/56`)

## Тестирование

Используйте скрипт `test-wireguard-patch.sh` для автоматической проверки на OpenWrt:

```bash
scp wireguard-ip6prefix.patch test-wireguard-patch.sh root@openwrt:/tmp/
ssh root@openwrt 'sh /tmp/test-wireguard-patch.sh'
```

Скрипт проверит:
- Синтаксис JavaScript
- Наличие поля `ip6prefix`
- Корректную работу UCI конфигурации

## Технические детали

Патч изменяет файл `protocols/luci-proto-wireguard/htdocs/luci-static/resources/protocol/wireguard.js`:

- Добавляет `ip6prefix` как `DynamicList` в таб **general**
- Удаляет дублирующуюся запись из таба **advanced**
- Заменяет нестандартное `pd_prefix` на стандартное `ip6prefix`

## Совместимость

- OpenWrt 23.05+
- LuCI (любая современная версия с `luci-proto-wireguard`)
- Требует `kmod-wireguard` и `wireguard-tools`

## Лицензия

Как и оригинальный LuCI — Apache-2.0

## Автор

Max <nahual15@gmail.com>
