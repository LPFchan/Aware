#!/usr/bin/env python3
"""Convert a Markdown file to a minimal HTML page for Sparkle release notes (hosted on GitHub Pages)."""

from __future__ import annotations

import argparse
import html
import re


def _inline(s: str) -> str:
    parts = re.split(r"(\*\*.+?\*\*)", s)
    chunks: list[str] = []
    for p in parts:
        if len(p) >= 4 and p.startswith("**") and p.endswith("**"):
            inner = html.escape(p[2:-2])
            chunks.append(f"<strong>{inner}</strong>")
        else:
            chunks.append(html.escape(p))
    out = "".join(chunks)
    out = re.sub(
        r"\[([^\]]+)\]\((https?://[^)]+)\)",
        r'<a href="\2">\1</a>',
        out,
    )
    return out


def _md_to_html_basic(text: str) -> str:
    """Headings (##), lists (-), paragraphs, **bold**, [text](url)."""
    lines = text.splitlines()
    out: list[str] = []
    in_ul = False

    for line in lines:
        if line.startswith("## "):
            if in_ul:
                out.append("</ul>")
                in_ul = False
            out.append(f"<h2>{_inline(line[3:])}</h2>")
        elif line.startswith("- "):
            if not in_ul:
                out.append("<ul>")
                in_ul = True
            out.append(f"<li>{_inline(line[2:])}</li>")
        elif not line.strip():
            if in_ul:
                out.append("</ul>")
                in_ul = False
        else:
            if in_ul:
                out.append("</ul>")
                in_ul = False
            out.append(f"<p>{_inline(line)}</p>")
    if in_ul:
        out.append("</ul>")
    return "\n".join(out)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("input_md", help="Path to input .md file")
    parser.add_argument("output_html", help="Path to output .html file")
    parser.add_argument(
        "lang",
        nargs="?",
        default="en",
        help="HTML lang attribute (e.g. en, ko)",
    )
    args = parser.parse_args()

    with open(args.input_md, encoding="utf-8") as f:
        body = _md_to_html_basic(f.read())

    doc = f"""<!DOCTYPE html>
<html lang="{args.lang}">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<title>Aware release notes</title>
<style>
body {{ font: 13px -apple-system, BlinkMacSystemFont, sans-serif; padding: 1em 1.25em; max-width: 720px; margin: 0 auto; line-height: 1.45; }}
code {{ background: rgba(127,127,127,0.15); padding: 0.1em 0.35em; border-radius: 3px; font-size: 0.92em; }}
a {{ color: #0969da; }}
ul {{ padding-left: 1.25em; }}
</style>
</head>
<body>
{body}
</body>
</html>
"""

    with open(args.output_html, "w", encoding="utf-8") as f:
        f.write(doc)


if __name__ == "__main__":
    main()
