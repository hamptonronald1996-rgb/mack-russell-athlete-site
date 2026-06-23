#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "index.html" ]; then
  echo "ERROR: Run this from inside your athlete site folder where index.html exists."
  echo "Example: cd ~/Downloads/isaiah-mack-russell-visible-media-smooth-site"
  exit 1
fi

python3 - <<'PY'
from pathlib import Path
import re
from datetime import datetime

p = Path('index.html')
s = p.read_text()
backup = Path(f"index.before-section-cleanup-v2.{datetime.now().strftime('%Y%m%d-%H%M%S')}.html")
backup.write_text(s)

# 1) Replace the Media Hub paragraph with more production-ready copy.
old_media = "A source-backed media center for fans, family, coaches, scouts and outlets tracking Isaiah Mack-Russell’s rise from Central Catholic recognition to Winton Woods production and national recruiting visibility."
new_media = "Explore verified public coverage, profile links, film and game recaps from Isaiah Mack-Russell’s rise — from All-Ohio recognition at Central Catholic to breakout production at Winton Woods and national recruiting visibility."
s = s.replace(old_media, new_media)

# Also handle straight apostrophe version just in case.
s = s.replace(old_media.replace("Mack-Russell’s", "Mack-Russell's"), new_media)

# 2) Remove the redundant audience explainer block under Media Hub.
# This removes a full card/div/article/panel/notice if it contains all three labels.
patterns = [
    r'<div[^>]*(?:class="[^"]*(?:notice|panel|cards|grid|copy|card)[^"]*"|)[^>]*>\s*.*?For fans:\s*.*?For recruiters:\s*.*?For media\s*/\s*sponsors:\s*.*?</div>',
    r'<article[^>]*>\s*.*?For fans:\s*.*?For recruiters:\s*.*?For media\s*/\s*sponsors:\s*.*?</article>',
    r'<section[^>]*>\s*.*?For fans:\s*.*?For recruiters:\s*.*?For media\s*/\s*sponsors:\s*.*?</section>',
]
for pat in patterns:
    s = re.sub(pat, '', s, flags=re.I | re.S)

# If the block survived because it was not wrapped simply, remove exact text chunks.
exact_chunks = [
    "For fans:\nUse this hub to follow public articles, video drops, big-game recaps, player profile links and the verified timeline around Isaiah’s season.",
    "For recruiters:\nUse this hub as a first-pass evidence board: production, film, rankings, articles and direct inquiry access for the family/management team.",
    "For media / sponsors:\nThe site organizes public coverage into one athlete-controlled brand destination, making it easier to reference Isaiah accurately.",
]
for chunk in exact_chunks:
    s = s.replace(chunk, '')
    s = s.replace(chunk.replace('\n', ' '), '')
    s = s.replace(chunk.replace('Isaiah’s', "Isaiah's"), '')

# 3) Remove duplicate upper 55 Club and Recruiter sections while keeping the bottom/latest version.
# We collect real <section> blocks containing those labels. If duplicates exist, remove all but the last.
def keep_last_section_containing(html, labels):
    matches = []
    for m in re.finditer(r'<section\b[^>]*>.*?</section>', html, flags=re.I | re.S):
        block = m.group(0)
        normalized = re.sub(r'\s+', ' ', block).lower()
        if any(label.lower() in normalized for label in labels):
            matches.append((m.start(), m.end(), block))
    if len(matches) <= 1:
        return html, 0
    keep_start, keep_end, keep_block = matches[-1]
    remove_spans = [(a,b) for a,b,_ in matches[:-1]]
    out = []
    last = 0
    for a,b in remove_spans:
        out.append(html[last:a])
        last = b
    out.append(html[last:])
    return ''.join(out), len(remove_spans)

# Keep last 55 section, then keep last recruiter/contact section.
s, removed_55 = keep_last_section_containing(s, ["the 55 club", "join the 55 club", "55 club"])
s, removed_rec = keep_last_section_containing(s, ["recruiter contact", "recruiter inquiry"])

# 4) If the 55/recruiter sections are duplicated as cards/divs instead of full sections, remove earlier full blocks conservatively.
def keep_last_block_containing(html, tag, labels):
    matches = []
    pat = rf'<{tag}\b[^>]*>.*?</{tag}>'
    for m in re.finditer(pat, html, flags=re.I | re.S):
        block = m.group(0)
        normalized = re.sub(r'\s+', ' ', block).lower()
        # Only remove fairly large blocks that look like whole form/feature cards, not nav buttons.
        if len(block) > 700 and any(label.lower() in normalized for label in labels):
            matches.append((m.start(), m.end(), block))
    if len(matches) <= 1:
        return html, 0
    out=[]; last=0
    for a,b,_ in matches[:-1]:
        out.append(html[last:a]); last=b
    out.append(html[last:])
    return ''.join(out), len(matches)-1

# Only use this pass if section pass did not remove duplicates and duplicate headings still appear more than once.
if len(re.findall(r'Join\s+The\s+55\s+Club|THE\s+55\s+CLUB', s, flags=re.I)) > 1:
    s, extra55 = keep_last_block_containing(s, 'div', ["the 55 club", "join the 55 club"])
else:
    extra55 = 0
if len(re.findall(r'Recruiter\s+(?:Inquiry|Contact)', s, flags=re.I)) > 1:
    s, extrarec = keep_last_block_containing(s, 'div', ["recruiter contact", "recruiter inquiry"])
else:
    extrarec = 0

# 5) Deduplicate top nav links by href+text so the two 55 Club / Recruiters buttons don't repeat.
nav_match = re.search(r'<nav\b[^>]*class="[^"]*nav[^"]*"[^>]*>(.*?)</nav>', s, flags=re.I|re.S)
if nav_match:
    nav_inner = nav_match.group(1)
    anchors = re.findall(r'<a\b[^>]*href="([^"]*)"[^>]*>(.*?)</a>', nav_inner, flags=re.I|re.S)
    seen = set()
    rebuilt = []
    for href, text in anchors:
        text_clean = re.sub(r'<[^>]+>', '', text).strip().lower()
        key = (href.strip().lower(), text_clean)
        if key in seen:
            continue
        seen.add(key)
        # get original complete anchor via sequential search
    # Simpler: remove consecutive/any duplicate exact anchor tags.
    seen_tags = set()
    rebuilt_tags=[]
    for am in re.finditer(r'<a\b[^>]*>.*?</a>', nav_inner, flags=re.I|re.S):
        tag = am.group(0)
        hrefm = re.search(r'href="([^"]*)"', tag, flags=re.I)
        text_clean = re.sub(r'<[^>]+>', '', tag).strip().lower()
        key = ((hrefm.group(1).lower() if hrefm else ''), text_clean)
        if key in seen_tags:
            continue
        seen_tags.add(key)
        rebuilt_tags.append(tag)
    new_nav = ''.join(rebuilt_tags)
    s = s[:nav_match.start(1)] + new_nav + s[nav_match.end(1):]

# 6) Add a visible build badge so Ronald can prove the cleanup deployed.
stamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
badge = f'''\n<div style="position:fixed;right:12px;bottom:72px;z-index:99999;padding:8px 10px;border:1px solid rgba(255,214,110,.55);border-radius:999px;background:rgba(2,3,10,.78);color:#ffd66e;font:800 10px system-ui;text-transform:uppercase;letter-spacing:.12em;backdrop-filter:blur(12px)">Cleaned sections · {stamp}</div>\n'''
# Remove older cleanup badge if present
s = re.sub(r'\n?<div style="position:fixed;right:12px;bottom:72px;z-index:99999;.*?Cleaned sections.*?</div>\n?', '\n', s, flags=re.I|re.S)
s = s.replace('</body>', badge + '</body>')

p.write_text(s)

print('Cleanup complete.')
print(f'Backup: {backup}')
print(f'Removed duplicate 55 sections: {removed_55 + extra55}')
print(f'Removed duplicate recruiter sections: {removed_rec + extrarec}')
print('Media Hub paragraph updated.')
PY

echo ""
echo "Verification:"
grep -n "For fans:\|For recruiters:\|For media / sponsors:\|A source-backed media center\|Explore verified public coverage\|THE 55 CLUB\|Recruiter Contact\|Recruiter Inquiry" index.html | head -80 || true
