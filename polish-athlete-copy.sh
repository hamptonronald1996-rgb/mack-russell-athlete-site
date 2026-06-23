#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "index.html" ]; then
  echo "ERROR: Run this from inside the athlete site folder where index.html exists."
  echo "Example: cd ~/Downloads/isaiah-mack-russell-visible-media-smooth-site"
  exit 1
fi

cp index.html "index.before-athlete-copy-polish.html"

python3 - <<'PY'
from pathlib import Path
from datetime import datetime
import re

p = Path('index.html')
html = p.read_text()

replacements = {
    'A futuristic athlete hub built around public media, film, recruiting profiles, articles, stats and social links — now with a visible media-first layout instead of hidden placeholder sections.':
    'Isaiah Mack-Russell is a nationally recognized 2027 Winton Woods guard from Ohio with a public résumé that already includes a 247Sports 4-star rating, a Pangos All-American Camp invitation, a 23.7-point scoring season, a 43-point playoff eruption, and scholarship interest from high-major programs.',

    'This section is intentionally near the top so the family immediately sees pictures, article buttons and links.':
    'Start here for the public-facing archive: feature photos, verified articles, recruiting profiles, film links and source-backed moments from Isaiah’s rise.',

    'Some publishers block hotlinked images. When that happens, the card and button still remain visible and clickable. The permanent fix is to add family-owned or photographer-approved image files directly into the project.':
    'Photo and article cards are connected to public coverage, while this build uses local/embedded image assets for dependable loading on Vercel. Tap any card to open the original source.',

    'Isaiah Mack-Russell received an invitation to the Pangos All-American Camp in Las Vegas. Tap to open the full public article.':
    'WCPO reported that Isaiah Mack-Russell received an invitation to the Pangos All-American Camp in Las Vegas, one of the top national exposure camps for elite high-school prospects.',

    'Public WCPO coverage of the Warriors’ historic start.':
    'WCPO covered Winton Woods’ undefeated start and the momentum around a Warriors team powered by elite guard production.',

    'Freshman All-Ohio recognition and early production.':
    'Central Catholic documented Isaiah’s early All-Ohio recognition before his move into the Winton Woods spotlight.',

    'Public recruiting profile listing Winton Woods, class 2027, SG, 6-4/180, rating/rankings and offers.':
    '247Sports lists Isaiah Mack-Russell as a Winton Woods 2027 shooting guard at 6-4 and 180 pounds, with a 90 rating, national top-100 placement, Ohio top-10 placement and 16 public offers.',

    'Public recruiting database profile and ranking context.':
    'Recruiting database profile for current ranking context, evaluation links and national exposure tracking.',

    'Public high-school basketball profile and club/team context.':
    'High-school basketball profile context for position, class year, team background and club exposure tracking.',

    'Public Hudl film embed with a direct profile link above.':
    'Recruiters can start with the public Hudl film link, then use the recruiter inquiry form to request the full athlete package from the family/management team.',

    'Embedded public YouTube video.':
    'Public YouTube coverage is embedded for quick viewing alongside the main film room.',

    'Public video embed used as part of the media archive.':
    'Additional public video coverage supports the media archive and gives fans/recruiters more context beyond the box score.',

    'Camp invitation, offer mentions, season production and Winton Woods context.':
    'WCPO reported the Pangos invite, a 22-3 Winton Woods season, 23.7 PPG, 7.5 RPG, 1.2 SPG, 1.1 APG and offers including Virginia, Nebraska, Cincinnati, Ohio State, Arizona State, Xavier and Creighton.',

    'Winton Woods’ historic start and Isaiah’s scoring/rebounding production.':
    'Coverage of Winton Woods’ 12-0 start and the high-level guard play that made the Warriors one of Ohio’s most watched teams.',

    'Winton Woods recap of 43 points and 10 threes in the district semifinal.':
    'Winton Woods credited Isaiah with 43 points and 10 made threes in an 82-26 district semifinal win — one of the loudest scoring performances of his public résumé.',

    'Additional Winton Woods postseason coverage.':
    'Postseason coverage from the Warriors’ regional run, giving recruiters and fans a look at how Winton Woods advanced under tournament pressure.',

    'Central Catholic coverage of honorable mention All-Ohio recognition.':
    'Central Catholic coverage from Isaiah’s early rise, including Division II honorable mention All-Ohio recognition as part of his freshman résumé.',

    'Central Catholic coverage of sophomore All-Ohio and District 7 honors.':
    'Central Catholic reported that Isaiah earned Division III second-team All-Ohio, Division III first-team All-Northwest District, Division III All-District 7 Player of the Year and CHSL All-Catholic honors in 2024-25.',

    'Central Catholic reported honorable mention All-Ohio and freshman production.':
    'As a freshman at Central Catholic, Isaiah earned Division II honorable mention All-Ohio, Division II second-team All-Northwest District, Division II first-team All-District 7 and CHSL All-League recognition.',

    'Central Catholic reported 18.8 PPG, 6.3 RPG, 2.0 APG and 1.3 SPG.':
    'As a sophomore at Central Catholic, he averaged 18.8 points, 6.3 rebounds, 2.0 assists and 1.3 steals per game while earning Division III second-team All-Ohio and District 7 Player of the Year honors.',

    'WCPO reported major production, a 22-3 season, regional final context and high-major offers.':
    'At Winton Woods, WCPO reported that he helped lead a 22-3 season and Division II regional-final run while averaging 23.7 points, 7.5 rebounds, 1.2 steals and 1.1 assists per game.',

    'Winton Woods credited Isaiah Mack-Russell with a dominant district semifinal performance.':
    'Winton Woods credited him with 43 points and 10 made threes in a district semifinal victory, matching the second-most made threes in a single game in program history.',

    'WCPO reported the invitation to the national exposure camp in Las Vegas.':
    'WCPO reported that Isaiah was invited to the Pangos All-American Camp, a national exposure event attended by major media, scouts and NBA personnel.',

    'Replace with approved inbox':
    'Family / management contact inbox',

    'Join Isaiah Mack-Russell’s official fanbase to keep up with public game updates, highlights, camp news, rankings, community moments and future athlete-brand announcements.':
    'Join The 55 Club to follow Isaiah’s public journey: Winton Woods updates, game results, highlight drops, feature articles, camp news, rankings movement and future athlete-brand announcements.',

    'College coaches, recruiting staff and verified basketball contacts can leave contact information for Isaiah’s family/management to follow up with the athlete package, film links and updated academic/athletic information.':
    'College coaches, recruiting staff, scouts and verified basketball contacts can leave information for Isaiah’s family/management to follow up with film links, schedule details, updated academic/athletic information and the full athlete package.'
}

for old, new in replacements.items():
    if old in html:
        html = html.replace(old, new)

# Replace any remaining obvious placeholder language without disturbing useful developer comments.
html = html.replace('placeholder sections', 'public media sections')
html = html.replace('Drop approved Hudl, YouTube or Instagram embeds here.', 'Watch public film, feature clips and verified video coverage in one place.')
html = html.replace('Approved media folders are included.', 'Media, articles and film links are organized for family, fans and recruiters.')

# Add a real biography/overview section after the hero if it does not exist yet.
overview_css = r'''

/* === Research-backed athlete copy section === */
.athlete-overview-grid{display:grid;grid-template-columns:1.05fr .95fr;gap:18px;align-items:stretch}.bio-panel{border:1px solid rgba(255,255,255,.14);background:rgba(255,255,255,.065);border-radius:30px;padding:24px;box-shadow:0 26px 90px rgba(0,0,0,.34);backdrop-filter:blur(18px)}.bio-panel h3{font-size:clamp(28px,3.4vw,54px);line-height:.94;letter-spacing:-.055em;text-transform:uppercase;margin:0 0 14px}.bio-panel p{color:#c8d5ef;line-height:1.62;margin:0 0 14px}.bio-list{display:grid;gap:12px}.bio-list div{border:1px solid rgba(255,255,255,.12);border-radius:22px;background:rgba(0,0,0,.22);padding:16px}.bio-list b{display:block;text-transform:uppercase;letter-spacing:.08em;color:#fff}.bio-list span{display:block;color:#aebddd;line-height:1.5;margin-top:6px}@media(max-width:1000px){.athlete-overview-grid{grid-template-columns:1fr}.bio-panel{padding:20px}}
'''
if '/* === Research-backed athlete copy section === */' not in html:
    html = html.replace('</style>', overview_css + '\n</style>', 1)

overview_section = r'''

  <section id="athlete-overview">
    <div class="section-head reveal"><div><div class="kicker">Verified athlete profile</div><h2 class="section-title">Built On <span>Real Production</span></h2></div></div>
    <div class="athlete-overview-grid reveal">
      <article class="bio-panel">
        <h3>Ohio guard with national attention.</h3>
        <p>Isaiah Mack-Russell is a 2027 guard at Winton Woods whose public profile has moved beyond local buzz into national recruiting visibility. 247Sports lists him as a Winton Woods shooting guard at 6-4 and 180 pounds with a 90 rating, national top-100 placement and 16 public offers.</p>
        <p>WCPO reported that he helped lead Winton Woods to a 22-3 season and a Division II regional final while averaging 23.7 points, 7.5 rebounds, 1.2 steals and 1.1 assists per game. The same report noted scholarship offers including Virginia, Nebraska, Cincinnati, Ohio State, Arizona State, Xavier and Creighton.</p>
        <p>His public résumé also includes a Pangos All-American Camp invitation and a 43-point, 10-three playoff performance credited by Winton Woods — the kind of production that gives recruiters, fans and media a clear story to follow.</p>
      </article>
      <aside class="bio-panel bio-list">
        <div><b>Current school</b><span>Winton Woods High School, Cincinnati-area program with public 2025-26 regional-final coverage.</span></div>
        <div><b>Position / class</b><span>Class of 2027 guard / shooting guard. 247Sports lists him at 6-4 and 180 pounds.</span></div>
        <div><b>Signature season</b><span>WCPO reported 23.7 PPG, 7.5 RPG, 1.2 SPG and 1.1 APG during Winton Woods’ 22-3 run.</span></div>
        <div><b>Recruiting signal</b><span>247Sports lists a 90 rating, top-100 national ranking, Ohio top-10 ranking and 16 public offers.</span></div>
      </aside>
    </div>
  </section>
'''
if 'id="athlete-overview"' not in html and "id='athlete-overview'" not in html:
    # Insert after closing hero section: first occurrence of </section> after <section class="hero">
    hero_match = re.search(r'(<section class="hero">.*?</section>)', html, flags=re.S)
    if hero_match:
        html = html[:hero_match.end()] + overview_section + html[hero_match.end():]

# Improve nav if available.
if 'href="#athlete-overview"' not in html and '<nav class="nav">' in html:
    html = html.replace('<nav class="nav">', '<nav class="nav"><a href="#athlete-overview">Profile</a>', 1)

# Add source-backed notes near source wall if not present.
source_note = r'''
    <div class="notice reveal" style="margin-top:18px">Website copy is based on public reporting and recruiting profiles: 247Sports for profile/rankings/offers, WCPO for Pangos invite and Winton Woods season production, Winton Woods athletics for the 43-point playoff recap, and Central Catholic for earlier All-Ohio/District honors.</div>
'''
if 'Website copy is based on public reporting and recruiting profiles' not in html and 'id="articles"' in html:
    html = html.replace('</section>\n\n  <section id="timeline">', source_note + '</section>\n\n  <section id="timeline">', 1)

# Make meta description more specific.
html = re.sub(r'<meta name="description" content="[^"]*"\s*/?>', '<meta name="description" content="Isaiah Mack-Russell athlete hub: Winton Woods 2027 guard, 247Sports 4-star, Pangos invitee, public film, stats, rankings, articles, fan club and recruiter contact." />', html)
html = re.sub(r'<meta property="og:description" content="[^"]*"\s*/?>', '<meta property="og:description" content="Follow Isaiah Mack-Russell: public film, photos, stats, rankings, articles, The 55 Club fanbase and recruiter inquiry access." />', html)

stamp = f'<!-- Athlete copy polished with sourced public information {datetime.now().isoformat(timespec="seconds")} -->'
if 'Athlete copy polished with sourced public information' not in html:
    html += '\n' + stamp + '\n'

p.write_text(html)

copy_deck = Path('ATHLETE-COPY-DECK.md')
copy_deck.write_text('''# Isaiah Mack-Russell — Website Copy Deck\n\n## Hero Bio\nIsaiah Mack-Russell is a 2027 Winton Woods guard from Ohio with a public résumé that already includes a 247Sports 4-star rating, Pangos All-American Camp invitation, a 23.7-point scoring season, a 43-point playoff eruption, and high-major recruiting attention.\n\n## Recruiter Snapshot\n247Sports lists Isaiah Mack-Russell as a Winton Woods shooting guard at 6-4 and 180 pounds with a 90 rating, national top-100 placement, Ohio top-10 placement and 16 public offers. WCPO reported that he helped lead Winton Woods to a 22-3 season and a Division II regional final while averaging 23.7 points, 7.5 rebounds, 1.2 steals and 1.1 assists per game.\n\n## Story Timeline\n- 2023-24: Central Catholic All-Ohio / All-District recognition.\n- 2024-25: Division III second-team All-Ohio and District 7 Player of the Year recognition at Central Catholic.\n- 2025-26: Winton Woods breakout season with 23.7 PPG and 7.5 RPG reported by WCPO.\n- March 2026: Winton Woods credited him with 43 points and 10 threes in a district semifinal win.\n- May/June 2026: WCPO reported his Pangos All-American Camp invitation.\n\n## Sources To Keep Linked On Site\n- 247Sports profile: https://247sports.com/player/isaiah-mack-russell-46158608/\n- WCPO Pangos feature: https://www.wcpo.com/sports/high-school-sports/winton-woods-basketball-star-invited-to-prestigious-pangos-all-american-camp\n- Winton Woods 43-point recap: https://warriornation.fans/news/2026/3/3/boys-basketball-withrow-recap.aspx\n- Central Catholic All-Ohio article: https://www.centralcatholic.org/news/fighting-irish-duo-collect-all-ohio-recognition\n''')

print('Updated index.html with research-backed athlete copy.')
print('Created ATHLETE-COPY-DECK.md')
print('Backup: index.before-athlete-copy-polish.html')
PY

echo ""
echo "=== CHECK FOR REMAINING PLACEHOLDER WORDS ==="
grep -n "placeholder\|Drop approved\|Replace with approved\|family@example.com" index.html || true

echo ""
echo "=== NEW COPY CHECK ==="
grep -n "Built On\|Ohio guard\|23.7\|Pangos\|43-point\|The 55 Club\|Recruiter" index.html | head -80
