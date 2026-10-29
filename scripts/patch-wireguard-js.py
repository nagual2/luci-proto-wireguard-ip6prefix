#!/usr/bin/env python3
"""Patch wireguard.js: move ip6prefix from advanced to general tab.

Base: formatted source from OpenWrt LuCI commit
75a306df84a020c57a631ef5b4c02ace56d93387 (LuCI 26.288, OpenWrt 25.12.6).
Earlier releases (1.0.0-r1/r2) were patched from the minified 25.12.4 build;
the 26.288 snapshot ships as readable source, so this patcher matches the
formatted layout with assertions on every anchor."""

import sys
from pathlib import Path

ADVANCED_BLOCK = """\t\to = s.taboption('advanced', form.DynamicList, 'ip6prefix', _('IPv6 routed prefix'), _('This is the prefix routed to you by your provider for use by clients'));
\t\to.datatype = 'cidr6';
"""

GENERAL_ANCHOR = """\t\to = s.taboption('general', form.DynamicList, 'addresses', _('IP Addresses'), _('Recommended. IP addresses of the WireGuard interface.'));
\t\to.datatype = 'ipaddr';
\t\to.optional = true;
"""

GENERAL_BLOCK = """\t\to = s.taboption('general', form.DynamicList, 'ip6prefix', _('IPv6 routed prefix'), _('IPv6 prefix routed to this interface for use by clients. Use this for Prefix Delegation.'));
\t\to.datatype = 'cidr6';
\t\to.optional = true;
"""


def patch(content: str) -> str:
    if GENERAL_BLOCK in content:
        print("Already patched", file=sys.stderr)
        return content

    if ADVANCED_BLOCK not in content:
        raise SystemExit(
            "advanced ip6prefix block not found — wireguard.js layout "
            "changed, rebase patch against the new upstream snapshot"
        )
    content = content.replace(ADVANCED_BLOCK, "", 1)

    if GENERAL_ANCHOR not in content:
        raise SystemExit("general 'addresses' anchor not found")

    return content.replace(GENERAL_ANCHOR, GENERAL_ANCHOR + GENERAL_BLOCK, 1)


def main() -> None:
    src = Path(sys.argv[1] if len(sys.argv) > 1 else "wireguard.js.orig")
    dst = Path(sys.argv[2] if len(sys.argv) > 2 else "htdocs/luci-static/resources/protocol/wireguard.js")
    dst.parent.mkdir(parents=True, exist_ok=True)
    patched = patch(src.read_text(encoding="utf-8"))
    dst.write_text(patched, encoding="utf-8", newline="\n")
    print(f"Patched -> {dst} ({len(patched)} bytes)")


if __name__ == "__main__":
    main()
