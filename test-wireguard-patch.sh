#!/bin/bash
# Test script for WireGuard IPv6 prefix patch on OpenWrt x86_64
# Run this inside WSL or OpenWrt VM

set -e

echo "=== WireGuard IPv6 Prefix Patch Test ==="
echo ""

# Check if we're on OpenWrt
if [ -f /etc/openwrt_release ]; then
    echo "[*] Running on OpenWrt"
    
    # Check current wireguard.js
    WG_JS=/usr/share/luci/resources/protocol/wireguard.js
    
    if [ -f "$WG_JS" ]; then
        echo "[*] Found wireguard.js at $WG_JS"
        
        # Backup original
        cp "$WG_JS" "$WG_JS.backup"
        echo "[*] Backed up original to $WG_JS.backup"
        
        # Apply patch
        if [ -f /tmp/wireguard-ip6prefix.patch ]; then
            echo "[*] Applying patch..."
            cd /usr/share/luci/resources/protocol/
            patch -p3 < /tmp/wireguard-ip6prefix.patch || {
                echo "[!] Patch failed, restoring backup"
                cp "$WG_JS.backup" "$WG_JS"
                exit 1
            }
            echo "[*] Patch applied successfully"
        else
            echo "[!] Patch file not found at /tmp/wireguard-ip6prefix.patch"
            exit 1
        fi
        
        # Test JavaScript syntax
        echo "[*] Testing JavaScript syntax..."
        if ucode -c "require('luci.resources.protocol.wireguard');" 2>/dev/null; then
            echo "[*] JavaScript syntax OK"
        else
            echo "[!] JavaScript syntax check failed"
            cp "$WG_JS.backup" "$WG_JS"
            exit 1
        fi
        
        # Check if ip6prefix option is present
        echo "[*] Checking for ip6prefix option..."
        if grep -q "ip6prefix" "$WG_JS"; then
            echo "[*] ip6prefix option found in wireguard.js"
        else
            echo "[!] ip6prefix option not found!"
            cp "$WG_JS.backup" "$WG_JS"
            exit 1
        fi
        
        # Test UCI configuration
        echo ""
        echo "[*] Testing UCI configuration..."
        uci set network.wg0=interface
        uci set network.wg0.proto=wireguard
        uci set network.wg0.private_key='test'
        uci add_list network.wg0.ip6prefix='2001:db8::/56'
        uci commit network
        
        if uci get network.wg0.ip6prefix >/dev/null 2>&1; then
            echo "[*] UCI ip6prefix configuration OK"
        else
            echo "[!] UCI ip6prefix configuration failed"
        fi
        
        echo ""
        echo "=== Test completed successfully ==="
        echo "Access LuCI at http://<router-ip>/cgi-bin/luci/admin/network/network"
        echo "and check WireGuard interface settings for 'IPv6 routed prefix' field"
        
    else
        echo "[!] wireguard.js not found at $WG_JS"
        exit 1
    fi
else
    echo "[!] Not running on OpenWrt. Please copy this script to OpenWrt VM."
    echo "    Usage: scp test-wireguard-patch.sh openwrt:/tmp/"
    echo "    Then run: ssh openwrt 'sh /tmp/test-wireguard-patch.sh'"
    exit 1
fi
