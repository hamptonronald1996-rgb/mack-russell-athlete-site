#!/usr/bin/env bash
set -e

if [ ! -f "index.html" ]; then
  echo "ERROR: Run this from inside your athlete site folder where index.html exists."
  exit 1
fi

cp "$(dirname "$0")/management.html" ./management.html

python3 - <<'PY'
from pathlib import Path
import re

p = Path("index.html")
html = p.read_text()
Path("index.before-parent-friendly-dashboard.html").write_text(html)

# Keep/add Management nav link.
if 'href="management.html"' not in html:
    html = re.sub(
        r'(<nav[^>]*class="[^"]*\bnav\b[^"]*"[^>]*>)',
        r'\1\n        <a href="management.html">Family Login</a>',
        html,
        count=1,
        flags=re.I
    )
else:
    html = html.replace('>Management<', '>Family Login<')

# Update existing dashboard CTA wording if present.
html = html.replace('Open Management Dashboard', 'Family Login')
html = html.replace('Family and management can review 55 Club signups, recruiter inquiries, media contacts and sponsor interest from one private dashboard powered by this website.',
                    'Family and management can log in privately to review 55 Club signups, recruiter inquiries, media contacts and sponsor interest.')
html = html.replace('Family and management can review 55 Club signups, recruiter inquiries, media contacts and sponsor interest from one private dashboard.',
                    'Family and management can log in privately to review 55 Club signups, recruiter inquiries, media contacts and sponsor interest.')

p.write_text(html)
print("DONE: Replaced dashboard with parent-friendly login experience.")
print("Backup saved: index.before-parent-friendly-dashboard.html")
PY
