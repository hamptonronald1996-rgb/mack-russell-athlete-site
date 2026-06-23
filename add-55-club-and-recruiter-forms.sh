#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "index.html" ]; then
  echo "ERROR: Run this from inside the athlete site folder where index.html exists."
  echo "Example: cd ~/Downloads/isaiah-mack-russell-visible-media-smooth-site"
  exit 1
fi

cp index.html "index.before-55-club-recruiter-forms.html"

python3 - <<'PY'
from pathlib import Path
from datetime import datetime

p = Path('index.html')
html = p.read_text()

css = r'''

/* === 55 Club + Recruiter Inquiry Upgrade === */
.club-recruit-wrapper{padding:92px 6vw;position:relative;overflow:hidden}
.club-recruit-wrapper:before{content:"";position:absolute;inset:8% 4%;border:1px solid rgba(86,240,255,.12);border-radius:42px;background:radial-gradient(circle at 16% 20%,rgba(86,240,255,.16),transparent 28%),radial-gradient(circle at 80% 75%,rgba(255,214,110,.12),transparent 30%);pointer-events:none}
.club-recruit-grid{position:relative;z-index:2;display:grid;grid-template-columns:1fr 1fr;gap:20px;align-items:stretch}
.club-card{border:1px solid rgba(255,255,255,.14);border-radius:34px;background:rgba(255,255,255,.065);backdrop-filter:blur(18px);box-shadow:0 35px 110px rgba(0,0,0,.42);padding:26px;overflow:hidden;position:relative}
.club-card:after{content:"";position:absolute;right:-80px;top:-80px;width:220px;height:220px;border-radius:999px;background:radial-gradient(circle,rgba(86,240,255,.23),transparent 67%);filter:blur(2px);pointer-events:none}
.club-card.gold:after{background:radial-gradient(circle,rgba(255,214,110,.24),transparent 67%)}
.club-eyebrow{color:#56f0ff;text-transform:uppercase;letter-spacing:.18em;font-size:11px;font-weight:1000;margin-bottom:10px}
.club-card.gold .club-eyebrow{color:#ffd66e}
.club-card h2{font-size:clamp(34px,4.8vw,78px);line-height:.9;letter-spacing:-.07em;text-transform:uppercase;margin:0 0 14px}
.club-card h2 span{color:transparent;-webkit-text-stroke:1px rgba(255,255,255,.7)}
.club-card p{color:#c8d5ef;line-height:1.55;margin:0 0 18px}
.club-benefits{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px;margin:18px 0 20px}
.club-benefits span{border:1px solid rgba(255,255,255,.13);border-radius:18px;background:rgba(0,0,0,.22);padding:11px;color:#edf5ff;font-size:12px;line-height:1.35}
.athlete-form{display:grid;gap:12px;margin-top:18px}
.form-row{display:grid;grid-template-columns:1fr 1fr;gap:12px}
.athlete-form label{display:grid;gap:6px;color:#dce8ff;font-size:10px;text-transform:uppercase;letter-spacing:.12em;font-weight:900}
.athlete-form input,.athlete-form select,.athlete-form textarea{width:100%;border:1px solid rgba(255,255,255,.14);border-radius:16px;background:rgba(2,3,10,.62);color:#fff;padding:13px 13px;font:600 14px Inter,ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",Arial,sans-serif;outline:none;transition:.2s}
.athlete-form textarea{min-height:112px;resize:vertical}
.athlete-form input:focus,.athlete-form select:focus,.athlete-form textarea:focus{border-color:rgba(86,240,255,.78);box-shadow:0 0 0 4px rgba(86,240,255,.08)}
.athlete-form button{cursor:pointer;border:1px solid rgba(86,240,255,.68);border-radius:999px;padding:14px 18px;background:linear-gradient(135deg,rgba(86,240,255,.22),rgba(75,99,255,.14));color:#fff;text-transform:uppercase;letter-spacing:.12em;font-weight:1000;font-size:11px;transition:.22s}
.club-card.gold .athlete-form button{border-color:rgba(255,214,110,.72);background:linear-gradient(135deg,rgba(255,214,110,.24),rgba(255,93,170,.09))}
.athlete-form button:hover{transform:translateY(-2px);box-shadow:0 22px 60px rgba(0,0,0,.36),0 0 22px rgba(86,240,255,.15)}
.form-note{font-size:11px;color:#91a0bf;line-height:1.45;margin-top:4px}.form-status{display:none;margin-top:12px;border:1px solid rgba(86,240,255,.28);border-radius:16px;padding:12px;background:rgba(86,240,255,.07);color:#dffcff;font-size:13px;line-height:1.45}.form-status.show{display:block}.mini-ledger{display:flex;gap:10px;flex-wrap:wrap;margin-top:16px}.mini-ledger span{border:1px solid rgba(255,255,255,.13);border-radius:999px;padding:8px 10px;background:rgba(0,0,0,.24);font-size:10px;text-transform:uppercase;letter-spacing:.12em;color:#dce8ff}
@media (max-width:1000px){.club-recruit-wrapper{padding:68px 18px}.club-recruit-grid,.form-row,.club-benefits{grid-template-columns:1fr}.club-card{padding:20px;border-radius:26px}}
'''

if '/* === 55 Club + Recruiter Inquiry Upgrade === */' not in html:
    html = html.replace('</style>', css + '\n</style>', 1)

section = r'''
<section id="fan-club" class="club-recruit-wrapper">
  <div class="section-head reveal"><div><div class="kicker">Fanbase + recruiting pipeline</div><h2 class="section-title">Join <span>The 55 Club</span></h2></div><p class="muted">A clean athlete-brand system for fans, family, supporters, coaches, recruiters, media and sponsors.</p></div>
  <div class="club-recruit-grid">
    <article class="club-card reveal">
      <div class="club-eyebrow">Fan access</div>
      <h2>The <span>55 Club</span></h2>
      <p>Join Isaiah Mack-Russell’s official fanbase to keep up with public game updates, highlights, camp news, rankings, community moments and future athlete-brand announcements.</p>
      <div class="club-benefits">
        <span>Game and event updates</span><span>Highlight drops</span><span>Camp and recruiting news</span><span>Community moments</span>
      </div>
      <form class="athlete-form" id="fanClubForm" data-form-type="55 Club Fan Signup">
        <div class="form-row">
          <label>Full Name<input name="name" required placeholder="Your name"></label>
          <label>Email<input name="email" type="email" required placeholder="you@example.com"></label>
        </div>
        <div class="form-row">
          <label>Phone<input name="phone" placeholder="Optional"></label>
          <label>Fan Type<select name="fanType"><option>Fan / Supporter</option><option>Family / Friend</option><option>Student / Classmate</option><option>Media</option><option>Sponsor / Brand</option></select></label>
        </div>
        <label>What updates do you want?<textarea name="message" placeholder="Example: game schedule, highlight drops, college recruitment news, community events..."></textarea></label>
        <button type="submit">Join The 55 Club</button>
        <div class="form-note">This static version opens a prepared email and also saves a local backup in this browser. Connect to Formspree, Airtable or a database later for automatic list management.</div>
        <div class="form-status"></div>
      </form>
      <div class="mini-ledger"><span>Fans</span><span>Updates</span><span>Highlights</span><span>Events</span></div>
    </article>

    <article id="recruiters" class="club-card gold reveal">
      <div class="club-eyebrow">Recruiter inquiry</div>
      <h2>Recruiter <span>Contact</span></h2>
      <p>College coaches, recruiting staff and verified basketball contacts can leave contact information for Isaiah’s family/management to follow up with the athlete package, film links and updated academic/athletic information.</p>
      <div class="club-benefits">
        <span>Coach contact info</span><span>Program details</span><span>Recruiting interest level</span><span>Athlete package request</span>
      </div>
      <form class="athlete-form" id="recruiterForm" data-form-type="Recruiter Inquiry">
        <div class="form-row">
          <label>Coach / Staff Name<input name="name" required placeholder="Full name"></label>
          <label>Program / School<input name="program" required placeholder="College / program"></label>
        </div>
        <div class="form-row">
          <label>Email<input name="email" type="email" required placeholder="coach@school.edu"></label>
          <label>Phone<input name="phone" placeholder="Office or mobile"></label>
        </div>
        <div class="form-row">
          <label>Role<select name="role"><option>Head Coach</option><option>Assistant Coach</option><option>Recruiting Coordinator</option><option>Director of Player Personnel</option><option>Media / Scout</option><option>Other</option></select></label>
          <label>Interest Level<select name="interest"><option>Request athlete package</option><option>Evaluation / follow-up</option><option>Camp / event invite</option><option>Offer / serious recruiting interest</option><option>Media request</option></select></label>
        </div>
        <label>Message<textarea name="message" placeholder="Tell the family/management what you need: film, transcript process, schedule, camp invite, call request, etc."></textarea></label>
        <button type="submit">Send Recruiter Inquiry</button>
        <div class="form-note">For NCAA compliance, recruiting communication should be handled by the family/management and verified school/program contacts.</div>
        <div class="form-status"></div>
      </form>
      <div class="mini-ledger"><span>Recruiters</span><span>Coaches</span><span>Media</span><span>Package Request</span></div>
    </article>
  </div>
</section>
'''

if 'id="fan-club"' not in html:
    if '<div class="ticker">' in html:
        html = html.replace('<div class="ticker">', section + '\n<div class="ticker">', 1)
    else:
        html = html.replace('</body>', section + '\n</body>', 1)

# add nav links if nav exists and not already present
if 'href="#fan-club"' not in html:
    html = html.replace('</nav>', '<a href="#fan-club">55 Club</a><a href="#recruiters">Recruiters</a></nav>', 1)

# add hero buttons if actions exists and not already present in hero
if 'Join 55 Club' not in html:
    html = html.replace('</div>\n    <aside class="panel hero-card"', '<a class="btn gold" href="#fan-club">Join 55 Club</a><a class="btn" href="#recruiters">Recruiter Inquiry</a></div>\n    <aside class="panel hero-card"', 1)

js = r'''
<script>
(function(){
  const MANAGEMENT_EMAIL = "REPLACE_WITH_MANAGEMENT_EMAIL@example.com";
  const storageKey = "isaiahMackRussellLeads";
  function serialize(form){
    const data = Object.fromEntries(new FormData(form).entries());
    data.type = form.dataset.formType || form.id || "Website Form";
    data.submittedAt = new Date().toISOString();
    data.page = location.href;
    return data;
  }
  function saveLead(lead){
    try{
      const existing = JSON.parse(localStorage.getItem(storageKey) || "[]");
      existing.push(lead);
      localStorage.setItem(storageKey, JSON.stringify(existing));
    }catch(e){}
  }
  function makeBody(lead){
    return Object.entries(lead).map(([k,v]) => `${k}: ${v || ""}`).join("\n");
  }
  function attach(id){
    const form = document.getElementById(id);
    if(!form) return;
    const status = form.querySelector('.form-status');
    form.addEventListener('submit', function(e){
      e.preventDefault();
      const lead = serialize(form);
      saveLead(lead);
      const subject = encodeURIComponent(`[Isaiah Mack-Russell Website] ${lead.type} - ${lead.name || lead.program || "New Lead"}`);
      const body = encodeURIComponent(makeBody(lead));
      if(status){
        status.classList.add('show');
        status.innerHTML = `Saved. Your email app should open next. Replace the management email in the site code when ready. <br><br><strong>Lead type:</strong> ${lead.type}`;
      }
      window.location.href = `mailto:${MANAGEMENT_EMAIL}?subject=${subject}&body=${body}`;
      form.reset();
    });
  }
  attach('fanClubForm');
  attach('recruiterForm');
})();
</script>
'''

if 'isaiahMackRussellLeads' not in html:
    html = html.replace('</body>', js + '\n</body>', 1)

badge = f'\n<!-- 55 Club + Recruiter forms installed {datetime.now().isoformat(timespec="seconds")} -->\n'
if '55 Club + Recruiter forms installed' not in html:
    html += badge

p.write_text(html)
print('Added 55 Club fan signup and recruiter inquiry forms to index.html')
print('Backup: index.before-55-club-recruiter-forms.html')
PY

echo ""
echo "=== VERIFY NEW SECTIONS ==="
grep -n "Join The 55 Club\|Recruiter Inquiry\|fanClubForm\|recruiterForm\|REPLACE_WITH_MANAGEMENT_EMAIL" index.html | head -40

echo ""
echo "NEXT: replace REPLACE_WITH_MANAGEMENT_EMAIL@example.com with the real family/management email when you have it."
