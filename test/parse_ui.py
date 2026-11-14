import xml.etree.ElementTree as ET
import sys

filename = sys.argv[1] if len(sys.argv) > 1 else 'test/screenshots/ui.xml'
try:
    tree = ET.parse(filename)
    for elem in tree.iter():
        desc = elem.attrib.get('content-desc', '')
        text = elem.attrib.get('text', '')
        bounds = elem.attrib.get('bounds', '')
        cls = elem.attrib.get('class', '')
        if desc or text:
            print(f"[{cls}] text='{text}' desc='{desc}' bounds={bounds}")
except Exception as e:
    print(f"Error: {e}")

