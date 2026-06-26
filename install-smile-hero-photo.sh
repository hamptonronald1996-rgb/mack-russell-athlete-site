#!/usr/bin/env bash
set -e

if [ ! -f "index.html" ]; then
  echo "ERROR: Run this from inside your site folder where index.html exists."
  exit 1
fi

mkdir -p assets/media
cp "$(dirname "$0")/isaiah-smile-hero.png" assets/media/isaiah-smile-hero.png 2>/dev/null || cp ./isaiah-smile-hero.png assets/media/isaiah-smile-hero.png

python3 - <<'PY'
from pathlib import Path
import base64, re

index = Path('index.html')
html = index.read_text()
Path('index.before-smile-hero-photo.html').write_text(html)
img_path = Path('assets/media/isaiah-smile-hero.png')
if not img_path.exists():
    raise SystemExit('ERROR: assets/media/isaiah-smile-hero.png not found.')

data_uri = 'data:image/png;base64,' + base64.b64encode(img_path.read_bytes()).decode('ascii')

# Replace any current top hero image inside the common hero wrappers.
patterns = [
    r'(<section[^>]*class="[^"]*(?:humble-top-hero|winton-top-hero|uc-top-hero|uc-hero-photo-section|top-mack-photo)[^"]*"[^>]*>.*?<img\s+src=")([^"]+)(")',
    r'(<div[^>]*class="[^"]*(?:humble-top-hero-card|winton-top-hero-card|uc-top-hero-card|uc-hero-photo-wrap|top-mack-photo-frame)[^"]*"[^>]*>.*?<img\s+src=")([^"]+)(")'
]
replaced = False
for pat in patterns:
    new_html, count = re.subn(pat, r'\1' + data_uri + r'\3', html, count=1, flags=re.I | re.S)
    if count:
        html = new_html
        replaced = True
        break

# Replace any older Cincinnati alt text with new alt.
html = re.sub(r'alt="[^"]*"', lambda m: 'alt="Isaiah Mack-Russell portrait in gym"' if 'Isaiah Mack-Russell' in m.group(0) or 'Cincinnati' in m.group(0) or 'basketball' in m.group(0) else m.group(0), html, flags=re.I)

# If no hero image found, inject this image into the first custom hero section.
if not replaced:
    inject_pat = re.compile(r'(<section[^>]*class="[^"]*(?:humble-top-hero|winton-top-hero|uc-top-hero)[^"]*"[^>]*>\s*<div[^>]*class="[^"]*(?:humble-top-hero-card|winton-top-hero-card|uc-top-hero-card)[^"]*"[^>]*>)', re.I | re.S)
    m = inject_pat.search(html)
    if m:
        html = html[:m.end()] + f'\n<img src="{data_uri}" alt="Isaiah Mack-Russell portrait in gym">' + html[m.end():]
        replaced = True

# Gentle image positioning for this portrait.
css = '''
<style id="smile-hero-photo-css">
.humble-top-hero-card img,
.winton-top-hero-card img,
.uc-top-hero-card img,
.uc-hero-photo-wrap img,
.top-mack-photo-frame img{
  object-fit:cover!important;
  object-position:center 18%!important;
  opacity:1!important;
  filter:contrast(1.02) saturate(1.02)!important;
}
</style>
'''
if '<style id="smile-hero-photo-css">' in html:
    html = re.sub(r'<style id="smile-hero-photo-css">.*?</style>', css, html, flags=re.S)
else:
    html = html.replace('</head>', css + '\n</head>')

index.write_text(html)
print('DONE: Replaced the top hero photo with the new smiling portrait.')
print('Backup saved: index.before-smile-hero-photo.html')
PY

echo "DONE: New smile hero image installed."
