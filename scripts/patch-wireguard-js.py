#!/usr/bin/env python3
"""Patch minified wireguard.js: move ip6prefix from advanced to general tab."""

from __future__ import annotations

import sys
from pathlib import Path


def patch(content: str) -> str:
    advanced = (
        "o=s.taboption('advanced',form.DynamicList,'ip6prefix',"
        "_('IPv6 routed prefix'),"
        "_('This is the prefix routed to you by your provider for use by clients'));"
        "o.datatype='cidr6';"
    )
    general = (
        "o=s.taboption('general',form.DynamicList,'ip6prefix',"
        "_('IPv6 routed prefix'),"
        "_('IPv6 prefix routed to this interface for use by clients. "
        "Use this for Prefix Delegation.'));"
        "o.datatype='cidr6';"
        "o.optional=true;"
    )

    if general in content:
        print("Already patched", file=sys.stderr)
        return content

    if advanced not in content:
        raise SystemExit("advanced ip6prefix block not found — wireguard.js layout changed")

    content = content.replace(advanced, "", 1)

    marker = "o.datatype='ipaddr';o.optional=true;"
    if marker not in content:
        raise SystemExit("general tab insertion marker not found")

    return content.replace(marker, marker + general, 1)


def main() -> None:
    src = Path(sys.argv[1] if len(sys.argv) > 1 else "wireguard.js.orig")
    dst = Path(sys.argv[2] if len(sys.argv) > 2 else "htdocs/luci-static/resources/protocol/wireguard.js")
    dst.parent.mkdir(parents=True, exist_ok=True)
    patched = patch(src.read_text(encoding="utf-8"))
    dst.write_text(patched, encoding="utf-8")
    print(f"Patched -> {dst} ({len(patched)} bytes)")


if __name__ == "__main__":
    main()
