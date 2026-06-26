#!/usr/bin/env bash
set -e

if [ ! -f "index.html" ]; then
  echo "ERROR: Run this from inside your site folder where index.html exists."
  exit 1
fi

mkdir -p assets/media
cp "$(dirname "$0")/isaiah-header-hero-replacement.png" assets/media/isaiah-header-hero-replacement.png 2>/dev/null || cp ./isaiah-header-hero-replacement.png assets/media/isaiah-header-hero-replacement.png

python3 - <<'PY'
from pathlib import Path
import base64, re

p = Path('index.html')
html = p.read_text()
Path('index.before-header-photo-swap.html').write_text(html)
img = Path('assets/media/isaiah-header-hero-replacement.png')
if not img.exists():
    raise SystemExit('ERROR: assets/media/isaiah-header-hero-replacement.png not found.')

data_uri = 'data:image/png;base64,' + base64.b64encode(img.read_bytes()).decode('ascii')

replaced = False
patterns = [
    r'(<section[^>]*class="[^"]*(?:humble-top-hero|winton-top-hero|uc-top-hero|uc-hero-photo-section|top-mack-photo|hero)[^"]*"[^>]*>.*?<img[^>]*src=")([^"]+)(")',
    r'(<div[^>]*class="[^"]*(?:humble-top-hero-card|winton-top-hero-card|uc-top-hero-card|uc-hero-photo-wrap|top-mack-photo-frame|hero-card)[^"]*"[^>]*>.*?<img[^>]*src=")([^"]+)(")',
]
for pat in patterns:
    new_html, count = re.subn(pat, r'\1' + data_uri + r'\3', html, count=1, flags=re.I|re.S)
    if count:
        html = new_html
        replaced = True
        break

# Update the first relevant alt if present
html = re.sub(r'alt="[^"]*(?:Isaiah|Mack-Russell|Cincinnati|basketball|photo)[^"]*"', 'alt="Isaiah Mack-Russell smiling portrait"', html, count=1, flags=re.I)

# Keep existing headline/header/copy; only add lightweight crop tuning.
css = '''
<style id="header-photo-swap-crop-css">
.humble-top-hero-card img,
.winton-top-hero-card img,
.uc-top-hero-card img,
.uc-hero-photo-wrap img,
.top-mack-photo-frame img,
.hero-card img,
.hero-main-photo{
  object-fit:cover!important;
  object-position:center 22%!important;
  opacity:1!important;
}
</style>
'''
if '<style id="header-photo-swap-crop-css">' in html:
    html = re.sub(r'<style id="header-photo-swap-crop-css">.*?</style>', css, html, flags=re.S)
else:
    html = html.replace('</head>', css + '\n</head>')

p.write_text(html)
print('DONE: Swapped the current top hero photo only. Header copy and layout were left intact.')
print('Backup saved: index.before-header-photo-swap.html')
if not replaced:
    print('WARNING: No known hero image pattern matched. The file was backed up, but the hero photo may not have changed.')
PY

echo "DONE: Header-version photo swap applied."
