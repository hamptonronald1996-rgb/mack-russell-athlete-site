#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "index.html" ]; then
  echo "ERROR: Run this from inside the athlete site folder where index.html exists."
  echo "Example: cd ~/Downloads/isaiah-mack-russell-visible-media-smooth-site"
  exit 1
fi

python3 - <<'PY'
from pathlib import Path
import re

p = Path('index.html')
s = p.read_text()
backup = Path('index.before-clean-redundant-sections.html')
backup.write_text(s)

# 1) Remove the three-audience Media Hub explanatory block the client requested removed.
patterns = [
    r'\n\s*<div class="media-context reveal">\s*<div class="notice"><b>For fans:</b><br>Use this hub to follow public articles, video drops, big-game recaps, player profile links and the verified timeline around Isaiah’s season\.</div>\s*<div class="notice"><b>For recruiters:</b><br>Use this hub as a first-pass evidence board: production, film, rankings, articles and direct inquiry access for the family/management team\.</div>\s*<div class="notice"><b>For media / sponsors:</b><br>The site organizes public coverage into one athlete-controlled brand destination, making it easier to reference Isaiah accurately\.</div>\s*</div>\s*',
    r'\n\s*<div class="media-context reveal">.*?For fans:.*?For recruiters:.*?For media / sponsors:.*?</div>\s*',
]
removed_context = 0
for pat in patterns:
    s2, n = re.subn(pat, '\n', s, count=1, flags=re.S)
    if n:
        s = s2
        removed_context += n
        break

# Also remove the same copy if it exists without the exact wrapper.
exact_copy = '''For fans:\nUse this hub to follow public articles, video drops, big-game recaps, player profile links and the verified timeline around Isaiah’s season.\nFor recruiters:\nUse this hub as a first-pass evidence board: production, film, rankings, articles and direct inquiry access for the family/management team.\nFor media / sponsors:\nThe site organizes public coverage into one athlete-controlled brand destination, making it easier to reference Isaiah accurately.'''
s = s.replace(exact_copy, '')

# 2) Keep only the LAST Join The 55 Club and LAST Recruiter Inquiry sections.
# This removes redundant upper duplicates while keeping the bottom sections.
def section_span(text, start_idx):
    next_match = re.search(r'\n\s*<section\b', text[start_idx + 1:], re.S)
    if next_match:
        return (start_idx, start_idx + 1 + next_match.start())
    main_end = text.find('</main>', start_idx)
    if main_end != -1:
        return (start_idx, main_end)
    body_end = text.find('</body>', start_idx)
    if body_end != -1:
        return (start_idx, body_end)
    return (start_idx, len(text))

spans_to_remove = []
for sec_id in ['fanclub', 'recruiters']:
    starts = [m.start() for m in re.finditer(r'<section\s+id=["\']' + sec_id + r'["\']', s)]
    if len(starts) > 1:
        for st in starts[:-1]:
            spans_to_remove.append(section_span(s, st))

# Remove from the end backward so indexes stay valid.
for a, b in sorted(spans_to_remove, reverse=True):
    s = s[:a] + '\n' + s[b:]

# 3) Clean excess blank lines.
s = re.sub(r'\n{4,}', '\n\n\n', s)

p.write_text(s)
print(f'Removed Media Hub audience block count: {removed_context}')
print(f'Removed duplicate upper fan/recruiter sections count: {len(spans_to_remove)}')
print('Backup saved as index.before-clean-redundant-sections.html')
PY

echo ""
echo "Verification:"
grep -n "For fans:\|For recruiters:\|For media / sponsors:\|section id=\"fanclub\"\|section id=\"recruiters\"\|Join The 55 Club\|Recruiter Inquiry" index.html | head -80 || true
