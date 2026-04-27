#!/usr/bin/env python3
"""
tei_to_pdf.py
-------------
Transform a TEI XML file to a styled PDF using:
  1. lxml  — applies tei-to-html.xsl to produce HTML
  2. WeasyPrint — renders the HTML to PDF

Usage:
    python tei_to_pdf.py input.xml [output.pdf] [--xsl path/to/tei-to-html.xsl]

Requirements:
    pip install lxml weasyprint
"""

import argparse
import sys
from pathlib import Path

try:
    from lxml import etree
except ImportError:
    sys.exit("Missing dependency: pip install lxml")

try:
    import weasyprint
except ImportError:
    sys.exit("Missing dependency: pip install weasyprint")


DEFAULT_XSL = Path(__file__).parent / "tei-to-html.xsl"


def transform_tei_to_html(xml_path: Path, xsl_path: Path) -> str:
    """Apply the XSLT stylesheet and return the resulting HTML string."""
    xml_doc  = etree.parse(str(xml_path))
    xsl_doc  = etree.parse(str(xsl_path))
    transform = etree.XSLT(xsl_doc)
    result    = transform(xml_doc)

    if transform.error_log:
        for entry in transform.error_log:
            print(f"XSLT warning: {entry.message}", file=sys.stderr)

    return str(result)


def html_to_pdf(html_string: str, output_path: Path) -> None:
    """Render an HTML string to a PDF file using WeasyPrint."""
    document = weasyprint.HTML(string=html_string)
    document.write_pdf(str(output_path))


def main():
    parser = argparse.ArgumentParser(
        description="Convert a TEI XML file to PDF via XSLT + WeasyPrint."
    )
    parser.add_argument("input",  type=Path, help="Path to the input TEI XML file")
    parser.add_argument("output", type=Path, nargs="?",  help="Path for the output PDF (default: same name as input)")
    parser.add_argument("--xsl",  type=Path, default=DEFAULT_XSL,
                        help=f"Path to the XSLT stylesheet (default: {DEFAULT_XSL})")
    args = parser.parse_args()

    # Resolve paths
    xml_path = args.input.resolve()
    xsl_path = args.xsl.resolve()
    pdf_path = (args.output or xml_path.with_suffix(".pdf")).resolve()

    # Validate inputs
    if not xml_path.exists():
        sys.exit(f"Error: XML file not found: {xml_path}")
    if not xsl_path.exists():
        sys.exit(f"Error: XSL file not found: {xsl_path}")

    print(f"Input  : {xml_path}")
    print(f"XSL    : {xsl_path}")
    print(f"Output : {pdf_path}")

    print("Applying XSLT…")
    html = transform_tei_to_html(xml_path, xsl_path)

    print("Rendering PDF…")
    html_to_pdf(html, pdf_path)

    print(f"Done. PDF saved to: {pdf_path}")


if __name__ == "__main__":
    main()
