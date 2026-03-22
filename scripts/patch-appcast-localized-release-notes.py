#!/usr/bin/env python3
"""
Insert Sparkle sparkle:releaseNotesLink elements with xml:lang (English, plus optional
languages such as ko, ja, zh-Hans), and remove embedded per-item release note elements.

See https://sparkle-project.org/documentation/publishing/#localization
"""

from __future__ import annotations

import argparse
import sys
import xml.etree.ElementTree as ET
from typing import List, Optional, Tuple

SPARKLE_NS = "http://www.andymatuschak.org/xml-namespaces/sparkle"
XML_NS = "http://www.w3.org/XML/1998/namespace"


def _remove_sparkle_release_note_elements(item: ET.Element) -> None:
    for child in list(item):
        if not child.tag.startswith(f"{{{SPARKLE_NS}}}"):
            continue
        local = child.tag.split("}", 1)[-1]
        if local in ("releaseNotesMarkdown", "releaseNotesLink"):
            item.remove(child)


def _find_item(channel: ET.Element, short_version: str) -> Optional[ET.Element]:
    for item in channel.findall("item"):
        el = item.find(f"{{{SPARKLE_NS}}}shortVersionString")
        if el is not None and (el.text or "").strip() == short_version:
            return item
    return None


def _insert_links_after_short_version(item: ET.Element, links: List[Tuple[str, str]]) -> None:
    tag = f"{{{SPARKLE_NS}}}shortVersionString"
    insert_at = 0
    for i, child in enumerate(list(item)):
        if child.tag == tag:
            insert_at = i + 1
            break
    for lang, url in links:
        link = ET.Element(f"{{{SPARKLE_NS}}}releaseNotesLink")
        link.set(f"{{{XML_NS}}}lang", lang)
        link.text = url
        item.insert(insert_at, link)
        insert_at += 1


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("appcast_xml", help="Path to appcast.xml to patch in place")
    parser.add_argument(
        "pages_base_url",
        help="GitHub Pages root URL, e.g. https://owner.github.io/repo (no trailing slash)",
    )
    parser.add_argument("release_tag", help="Git tag with v prefix, e.g. v1.4.1")
    parser.add_argument(
        "short_version",
        help="Marketing version to match sparkle:shortVersionString, e.g. 1.4.1",
    )
    parser.add_argument(
        "extra_langs",
        nargs="*",
        metavar="LANG",
        help="Optional BCP-47 language codes with published HTML (e.g. ko ja zh-Hans)",
    )
    args = parser.parse_args()

    ET.register_namespace("sparkle", SPARKLE_NS)
    ET.register_namespace("xml", XML_NS)

    tree = ET.parse(args.appcast_xml)
    root = tree.getroot()
    channel = root.find("channel")
    if channel is None:
        print("No RSS channel in appcast", file=sys.stderr)
        sys.exit(1)

    item = _find_item(channel, args.short_version)
    if item is None:
        print(
            f"No item with sparkle:shortVersionString == {args.short_version!r}",
            file=sys.stderr,
        )
        sys.exit(1)

    _remove_sparkle_release_note_elements(item)

    base = args.pages_base_url.rstrip("/")
    tag = args.release_tag
    en_url = f"{base}/release-notes/{tag}.en.html"
    links: List[Tuple[str, str]] = [("en", en_url)]
    for lang in args.extra_langs:
        lang = lang.strip()
        if not lang:
            continue
        url = f"{base}/release-notes/{tag}.{lang}.html"
        links.append((lang, url))

    _insert_links_after_short_version(item, links)

    tree.write(
        args.appcast_xml,
        encoding="utf-8",
        xml_declaration=True,
        default_namespace=None,
    )


if __name__ == "__main__":
    main()
