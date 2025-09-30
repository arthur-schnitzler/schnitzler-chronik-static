#!/usr/bin/env python3
"""
Generate sitemap.xml for Arthur Schnitzler Chronik
"""
import os
from datetime import datetime
from pathlib import Path
import xml.etree.ElementTree as ET
from xml.dom import minidom

# Configuration
BASE_URL = "https://schnitzler-chronik.acdh.oeaw.ac.at"
HTML_DIR = "./html"
OUTPUT_FILE = "./html/sitemap.xml"

# Priority and change frequency for different page types
PAGE_CONFIG = {
    "index.html": {"priority": "1.0", "changefreq": "weekly"},
    "calendar.html": {"priority": "0.9", "changefreq": "monthly"},
    "search.html": {"priority": "0.8", "changefreq": "monthly"},
    "imprint.html": {"priority": "0.3", "changefreq": "yearly"},
    "default": {"priority": "0.7", "changefreq": "monthly"}  # for date pages
}


def get_file_lastmod(filepath):
    """Get last modification time of file in W3C format"""
    mtime = os.path.getmtime(filepath)
    return datetime.fromtimestamp(mtime).strftime('%Y-%m-%d')


def prettify_xml(elem):
    """Return a pretty-printed XML string"""
    rough_string = ET.tostring(elem, encoding='utf-8')
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent="  ", encoding='utf-8')


def generate_sitemap():
    """Generate sitemap.xml from HTML files"""

    # Create root element with namespace
    urlset = ET.Element('urlset')
    urlset.set('xmlns', 'http://www.sitemaps.org/schemas/sitemap/0.9')

    html_path = Path(HTML_DIR)

    if not html_path.exists():
        print(f"Error: {HTML_DIR} directory not found!")
        return

    # Collect all HTML files
    html_files = sorted(html_path.glob('*.html'))

    print(f"Found {len(html_files)} HTML files")

    for html_file in html_files:
        filename = html_file.name

        # Skip certain files if needed
        if filename.startswith('_'):
            continue

        # Create URL entry
        url = ET.SubElement(urlset, 'url')

        # Add location
        loc = ET.SubElement(url, 'loc')
        loc.text = f"{BASE_URL}/{filename}"

        # Add last modified date
        lastmod = ET.SubElement(url, 'lastmod')
        lastmod.text = get_file_lastmod(html_file)

        # Get config for this page type
        if filename in PAGE_CONFIG:
            config = PAGE_CONFIG[filename]
        else:
            config = PAGE_CONFIG["default"]

        # Add change frequency
        changefreq = ET.SubElement(url, 'changefreq')
        changefreq.text = config["changefreq"]

        # Add priority
        priority = ET.SubElement(url, 'priority')
        priority.text = config["priority"]

    # Write to file with pretty formatting
    xml_string = prettify_xml(urlset)

    with open(OUTPUT_FILE, 'wb') as f:
        f.write(xml_string)

    print(f"✓ Sitemap generated: {OUTPUT_FILE}")
    print(f"  Total URLs: {len(html_files)}")


if __name__ == "__main__":
    generate_sitemap()
