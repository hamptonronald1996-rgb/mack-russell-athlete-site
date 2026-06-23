#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "index.html" ]; then
  echo "ERROR: Run this from inside the athlete site folder where index.html exists."
  echo "Example: cd ~/Downloads/isaiah-mack-russell-visible-media-smooth-site"
  exit 1
fi

python3 - <<'PY'
from pathlib import Path
import re, base64, mimetypes, datetime

p = Path('index.html')
s = p.read_text()
backup = Path('index.before-mediahub-55club-polish.html')
backup.write_text(s)

# Add CSS for fan/recruiter sections if not already present.
css = r'''
.fan-recruit-wrap{display:grid;grid-template-columns:1fr 1fr;gap:18px;align-items:start}.signal-panel{border:1px solid rgba(255,255,255,.14);background:rgba(255,255,255,.062);border-radius:28px;padding:24px;box-shadow:0 28px 90px rgba(0,0,0,.35);backdrop-filter:blur(18px)}.signal-panel h3{margin:0 0 10px;text-transform:uppercase;letter-spacing:.04em;font-size:clamp(24px,3vw,44px);line-height:.92}.signal-panel p{color:#c8d5ef;line-height:1.55}.signal-list{display:grid;gap:10px;margin-top:18px}.signal-list div{border:1px solid rgba(255,255,255,.12);background:rgba(0,0,0,.20);border-radius:18px;padding:13px;color:#dce8ff;font-size:14px;line-height:1.42}.site-form{display:grid;gap:12px}.site-form label{display:grid;gap:7px;color:#93a6ca;font-size:10px;text-transform:uppercase;letter-spacing:.14em;font-weight:950}.site-form input,.site-form select,.site-form textarea{width:100%;border:1px solid rgba(255,255,255,.16);background:rgba(0,0,0,.28);color:white;border-radius:16px;padding:13px 14px;font:600 14px Inter,system-ui,sans-serif;outline:none}.site-form textarea{min-height:118px;resize:vertical}.site-form input:focus,.site-form select:focus,.site-form textarea:focus{border-color:rgba(86,240,255,.72);box-shadow:0 0 0 3px rgba(86,240,255,.12)}.form-grid-2{display:grid;grid-template-columns:1fr 1fr;gap:12px}.form-note{font-size:12px;color:#93a6ca;line-height:1.45}.tiny-ledger{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:10px;margin-top:18px}.tiny-ledger span{border:1px solid rgba(255,255,255,.12);border-radius:16px;padding:12px;text-transform:uppercase;letter-spacing:.11em;font-size:10px;color:#f7faff;background:rgba(255,255,255,.055)}.media-context{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:14px;margin-top:18px}.media-context .notice{min-height:160px}.success-toast{position:fixed;left:50%;bottom:84px;transform:translateX(-50%) translateY(18px);opacity:0;pointer-events:none;z-index:999999;border:1px solid rgba(86,240,255,.55);background:rgba(2,3,10,.86);backdrop-filter:blur(18px);color:white;border-radius:999px;padding:12px 16px;font-weight:900;font-size:12px;text-transform:uppercase;letter-spacing:.12em;transition:.25s}.success-toast.show{opacity:1;transform:translateX(-50%) translateY(0)}@media(max-width:1000px){.fan-recruit-wrap,.form-grid-2,.tiny-ledger,.media-context{grid-template-columns:1fr}}
'''
if '.fan-recruit-wrap' not in s:
    s = s.replace('</style>', css + '\n</style>')

# Improve nav links.
nav_match = re.search(r'<nav class="nav">(.*?)</nav>', s, re.S)
if nav_match:
    nav = nav_match.group(1)
    if '#fanclub' not in nav:
        nav = nav.replace('<a href="#stats">Stats</a>', '<a href="#stats">Stats</a><a href="#fanclub">55 Club</a><a href="#recruiters">Recruiters</a>')
    s = s[:nav_match.start(1)] + nav + s[nav_match.end(1):]

# Better hero CTA copy if present.
s = s.replace('A futuristic athlete hub built around public media, film, recruiting profiles, articles, stats and social links — now with a visible media-first layout instead of hidden placeholder sections.',
'''Isaiah Mack-Russell is a nationally tracked class of 2027 guard at Winton Woods — a high-production scorer, deep-range shot-maker and rising recruitment name with public coverage from 247Sports, WCPO, Winton Woods athletics and Central Catholic.''')
if '#fanclub' not in s[s.find('<div class="actions">'):s.find('</div>', s.find('<div class="actions">'))+6]:
    s = s.replace('<a class="btn gold" href="#articles">Open Articles</a>', '<a class="btn gold" href="#articles">Open Articles</a>\n        <a class="btn" href="#fanclub">Join The 55 Club</a>\n        <a class="btn" href="#recruiters">Recruiter Inquiry</a>')

media_section = r'''
<section id="media" class="media-hub">
    <div class="section-head reveal"><div><div class="kicker">Verified public media / article archive / film access</div><h2 class="section-title">Media <span>Hub</span></h2></div><p class="muted">A source-backed media center for fans, family, coaches, scouts and outlets tracking Isaiah Mack-Russell’s rise from Central Catholic recognition to Winton Woods production and national recruiting visibility.</p></div>
    <div class="hub-grid reveal">
      <a class="feature-card" href="https://www.wcpo.com/sports/high-school-sports/winton-woods-basketball-star-invited-to-prestigious-pangos-all-american-camp" target="_blank" rel="noopener">
        <img src="assets/media/isaiah-wcpo-pangos.jpg" alt="Isaiah Mack-Russell WCPO Pangos feature image" onerror="this.closest('.media-card,.feature-card,.hero-card')?.classList.add('image-failed')">
        <div class="card-body"><h3>Pangos All-American Camp Spotlight</h3><p>WCPO reported Isaiah’s invitation to the Pangos All-American Camp in Las Vegas after a major Winton Woods season. The article also framed him as one of the Cincinnati-area names college programs are actively tracking.</p><div class="sourcebar"><strong>Feature source: WCPO</strong><span>Open article ↗</span></div></div>
      </a>
      <div class="media-stack">
        <a class="media-card" href="https://www.wcpo.com/sports/high-school-sports/a-lot-of-fun-winton-woods-boys-hoops-team-has-12-0-record-for-first-time-since-2000-01" target="_blank" rel="noopener"><img src="assets/media/winton-woods-wcpo-team.webp" alt="Winton Woods 12-0 WCPO article image" onerror="this.closest('.media-card,.feature-card,.hero-card')?.classList.add('image-failed')"><div class="card-body"><h3>Winton Woods Surge</h3><p>Public WCPO coverage of the Warriors’ unbeaten start and team momentum, with Isaiah’s scoring and rebounding production central to the story.</p><div class="sourcebar"><span>Open WCPO ↗</span></div></div></a>
        <a class="media-card" href="https://www.centralcatholic.org/news/fighting-irish-duo-collect-all-ohio-recognition" target="_blank" rel="noopener"><img src="assets/media/isaiah-central-catholic-all-ohio.jpg" alt="Isaiah Mack-Russell Central Catholic All-Ohio recognition" onerror="this.closest('.media-card,.feature-card,.hero-card')?.classList.add('image-failed')"><div class="card-body"><h3>All-Ohio Foundation</h3><p>Central Catholic documented Isaiah’s All-Ohio and District 7 résumé before the Winton Woods breakout chapter.</p><div class="sourcebar"><span>Open CCHS ↗</span></div></div></a>
      </div>
    </div>

    <div class="media-context reveal">
      <div class="notice"><b>For fans:</b><br>Use this hub to follow public articles, video drops, big-game recaps, player profile links and the verified timeline around Isaiah’s season.</div>
      <div class="notice"><b>For recruiters:</b><br>Use this hub as a first-pass evidence board: production, film, rankings, articles and direct inquiry access for the family/management team.</div>
      <div class="notice"><b>For media / sponsors:</b><br>The site organizes public coverage into one athlete-controlled brand destination, making it easier to reference Isaiah accurately.</div>
    </div>

    <div class="cards reveal" style="margin-top:18px">
      <a class="media-card" href="https://www.wcpo.com/sports/high-school-sports/winton-woods-basketball-star-invited-to-prestigious-pangos-all-american-camp" target="_blank" rel="noopener"><img src="assets/media/isaiah-wcpo-pangos.jpg" alt="Isaiah Mack-Russell WCPO Pangos feature"><div class="card-body"><h3>National Exposure</h3><p>Pangos invite coverage and recruiting visibility.</p><div class="sourcebar"><span>Open Article ↗</span></div></div></a>
      <a class="media-card" href="https://warriornation.fans/news/2026/3/3/boys-basketball-withrow-recap.aspx" target="_blank" rel="noopener"><img src="assets/media/winton-district-champions.jpeg" alt="Winton Woods district champions"><div class="card-body"><h3>43 + 10 Threes</h3><p>Winton Woods credited Isaiah with 43 points and 10 made threes in a district semifinal.</p><div class="sourcebar"><span>Open Recap ↗</span></div></div></a>
      <a class="media-card" href="https://warriornation.fans/news/2026/3/6/boys-basketball-vs-anderson-playoffs-enquirer-photos.aspx" target="_blank" rel="noopener"><img src="assets/media/winton-anderson-enquirer.jpg" alt="Winton Woods Anderson playoff media"><div class="card-body"><h3>Playoff Gallery</h3><p>Public postseason gallery coverage connected to the Warriors’ tournament run.</p><div class="sourcebar"><span>Open Photos ↗</span></div></div></a>
    </div>
  </section>
'''
# Replace media section from id media to id stats.
s = re.sub(r'<section id="media" class="media-hub">.*?(?=\n\s*<section id="stats">)', media_section + '\n', s, flags=re.S)

fan_recruit_sections = r'''
  <section id="fanclub">
    <div class="section-head reveal"><div><div class="kicker">Fanbase / updates / public schedule alerts</div><h2 class="section-title">Join The <span>55 Club</span></h2></div><p class="muted">The 55 Club is the official fan-update lane for people who want to follow Isaiah Mack-Russell’s public journey — game reminders, article drops, film updates, camp news, rankings movement and major recruitment milestones.</p></div>
    <div class="fan-recruit-wrap reveal">
      <div class="signal-panel">
        <h3>Built for supporters who want to follow the rise.</h3>
        <p>Isaiah’s public story is moving fast: Winton Woods production, postseason moments, national camp exposure, recruiting coverage and film updates. The 55 Club gives fans one place to stay connected without hunting across every platform.</p>
        <div class="signal-list">
          <div><b>Game-day updates:</b> public schedule reminders, tournament notes and major event announcements.</div>
          <div><b>Media alerts:</b> new articles, highlight posts, Hudl/YouTube drops and public interviews.</div>
          <div><b>Recruiting milestones:</b> camp invites, profile updates, offer/ranking movement and verified public news.</div>
          <div><b>Community energy:</b> a clean fanbase list the family can use for support, announcements and future events.</div>
        </div>
        <div class="tiny-ledger"><span>Game Alerts</span><span>Film Drops</span><span>Article Links</span><span>Event News</span></div>
      </div>
      <div class="signal-panel">
        <form class="site-form" data-form-type="55 Club Fan Signup">
          <div class="form-grid-2"><label>First Name<input name="firstName" required autocomplete="given-name"></label><label>Last Name<input name="lastName" autocomplete="family-name"></label></div>
          <label>Email<input type="email" name="email" required autocomplete="email"></label>
          <label>Phone / Text Updates<input name="phone" autocomplete="tel" placeholder="Optional"></label>
          <div class="form-grid-2"><label>Fan Type<select name="fanType"><option>Family / Friend</option><option>Winton Woods Supporter</option><option>Basketball Fan</option><option>Media / Content Creator</option><option>Sponsor / Brand</option></select></label><label>Update Interest<select name="interest"><option>All public updates</option><option>Game schedule only</option><option>Film and highlights</option><option>Articles and rankings</option><option>Events / appearances</option></select></label></div>
          <label>Message<textarea name="message" placeholder="Tell the family how you know Isaiah or what updates you want most."></textarea></label>
          <button class="btn primary" type="submit">Join The 55 Club</button>
          <p class="form-note">Submissions are saved in the browser and opened as a prepared email for the family/management team. Connect this later to Formspree, Airtable, Google Sheets or a full CRM when ready.</p>
        </form>
      </div>
    </div>
  </section>

  <section id="recruiters">
    <div class="section-head reveal"><div><div class="kicker">Recruiting / scouting / athlete package requests</div><h2 class="section-title">Recruiter <span>Inquiry</span></h2></div><p class="muted">A direct intake lane for college coaches, recruiting staff, scouts and media contacts who want the family/management team to follow up with Isaiah’s athlete package, film, transcripts/contact direction and verified recruitment materials.</p></div>
    <div class="fan-recruit-wrap reveal">
      <div class="signal-panel">
        <h3>Recruiting profile snapshot.</h3>
        <p>Public sources identify Isaiah Mack-Russell as a class of 2027 Winton Woods guard with high-major attention, a 247Sports four-star profile, national camp exposure and major production. This form is designed to make serious outreach easier for the family to qualify and respond to.</p>
        <div class="signal-list">
          <div><b>Current school:</b> Winton Woods High School.</div>
          <div><b>Class / position:</b> 2027 guard / shooting guard profile.</div>
          <div><b>Public production:</b> WCPO reported 23.7 PPG, 7.5 RPG, 1.2 SPG and 1.1 APG.</div>
          <div><b>Recruiting context:</b> 247Sports lists him as a four-star prospect with public profile rankings and offers.</div>
          <div><b>Signature moment:</b> Winton Woods credited 43 points and 10 made threes in district semifinal coverage.</div>
        </div>
      </div>
      <div class="signal-panel">
        <form class="site-form" data-form-type="Recruiter Inquiry">
          <div class="form-grid-2"><label>Name<input name="name" required autocomplete="name"></label><label>Role<select name="role"><option>College Coach</option><option>Recruiting Coordinator</option><option>Scout</option><option>Media</option><option>Event Director</option><option>Other</option></select></label></div>
          <div class="form-grid-2"><label>School / Organization<input name="organization" required></label><label>Division / Level<input name="level" placeholder="NCAA D1, D2, NAIA, Prep, Media, etc."></label></div>
          <div class="form-grid-2"><label>Email<input type="email" name="email" required autocomplete="email"></label><label>Phone<input name="phone" autocomplete="tel"></label></div>
          <div class="form-grid-2"><label>Interest Level<select name="interestLevel"><option>Request athlete package</option><option>Request film / schedule</option><option>Request family contact</option><option>Invite to camp/event</option><option>Media interview request</option></select></label><label>Preferred Follow-Up<select name="followUp"><option>Email</option><option>Phone call</option><option>Text</option><option>Zoom / virtual meeting</option></select></label></div>
          <label>Recruiting Notes<textarea name="notes" placeholder="Include what you are requesting, timeline, event/camp details, or what materials you need."></textarea></label>
          <button class="btn gold" type="submit">Request Athlete Package</button>
          <p class="form-note">This static-site version prepares the inquiry for email and stores a browser backup. For production, connect it to the family’s preferred inbox/CRM.</p>
        </form>
      </div>
    </div>
  </section>
'''
# Remove old fanclub/recruiter sections if present, then insert before contact.
s = re.sub(r'\n\s*<section id="fanclub">.*?(?=\n\s*<section id="recruiters">)', '\n', s, flags=re.S)
s = re.sub(r'\n\s*<section id="recruiters">.*?(?=\n\s*<section id="contact">)', '\n', s, flags=re.S)
if '<section id="contact">' in s:
    s = s.replace('  <section id="contact">', fan_recruit_sections + '\n  <section id="contact">', 1)
else:
    s = s.replace('</main>', fan_recruit_sections + '\n</main>')

# Add JS for forms before existing script end/body. Avoid duplicate.
form_js = r'''
<script>
(function(){
  const toast = document.createElement('div');
  toast.className = 'success-toast';
  toast.textContent = 'Saved — opening email draft';
  document.body.appendChild(toast);

  function showToast(message){
    toast.textContent = message;
    toast.classList.add('show');
    setTimeout(()=>toast.classList.remove('show'), 2800);
  }

  function serialize(form){
    return Object.fromEntries(new FormData(form).entries());
  }

  function saveLead(type, data){
    const key = 'isaiah_mack_russell_leads';
    const list = JSON.parse(localStorage.getItem(key) || '[]');
    list.push({type, data, createdAt:new Date().toISOString()});
    localStorage.setItem(key, JSON.stringify(list));
  }

  function buildBody(type, data){
    const lines = [`${type}`, 'Isaiah Mack-Russell Website Inquiry', '', ...Object.entries(data).map(([k,v]) => `${k}: ${v || ''}`), '', `Source: ${location.href}`];
    return lines.join('\n');
  }

  document.querySelectorAll('form[data-form-type]').forEach(form=>{
    form.addEventListener('submit', event=>{
      event.preventDefault();
      const type = form.dataset.formType || 'Website Inquiry';
      const data = serialize(form);
      saveLead(type, data);
      showToast(type + ' saved');
      const subject = encodeURIComponent(type + ' — Isaiah Mack-Russell');
      const body = encodeURIComponent(buildBody(type, data));
      window.location.href = `mailto:?subject=${subject}&body=${body}`;
    });
  });
})();
</script>
'''
if 'isaiah_mack_russell_leads' not in s:
    s = s.replace('</body>', form_js + '\n</body>')

# Re-embed local pictures into HTML if assets/media exists, so the deploy is hard-forced with pictures in page.
media_dir = Path('assets/media')
if media_dir.exists():
    for img in sorted(media_dir.iterdir()):
        if not img.is_file():
            continue
        mime = mimetypes.guess_type(str(img))[0] or ('image/jpeg' if img.suffix.lower() in ['.jpg','.jpeg'] else 'image/png' if img.suffix.lower()=='.png' else 'image/webp' if img.suffix.lower()=='.webp' else None)
        if not mime or not mime.startswith('image/'):
            continue
        uri = f"data:{mime};base64," + base64.b64encode(img.read_bytes()).decode('ascii')
        for old in [f'assets/media/{img.name}', f'./assets/media/{img.name}', f'/assets/media/{img.name}']:
            s = s.replace(old, uri)

stamp = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
if 'Media + 55 Club copy build' not in s:
    badge = f'''\n<div style="position:fixed;left:12px;bottom:44px;z-index:99999;padding:8px 10px;border:1px solid rgba(255,214,110,.5);border-radius:999px;background:rgba(2,3,10,.78);color:#ffd66e;font:700 10px system-ui;text-transform:uppercase;letter-spacing:.12em;backdrop-filter:blur(12px)">Media + 55 Club copy build · {stamp}</div>\n'''
    s = s.replace('</body>', badge + '</body>')

p.write_text(s)
print('Updated Media Hub copy, 55 Club section, Recruiter Inquiry section, form behavior, and embedded local media into index.html.')
PY

echo ""
echo "Verification lines:"
grep -n "Media Hub\|Join The 55 Club\|Recruiter Inquiry\|Pangos All-American Camp Spotlight\|isaiah_mack_russell_leads\|data:image" index.html | head -40
