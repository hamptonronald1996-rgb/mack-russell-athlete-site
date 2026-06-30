#!/usr/bin/env bash
set -e
if [ ! -f "index.html" ]; then
  echo "ERROR: Run this from inside your athlete site folder where index.html exists."
  exit 1
fi
mkdir -p api
cp "$(dirname "$0")/api/leads.js" ./api/leads.js
cp "$(dirname "$0")/management.html" ./management.html

if [ ! -f package.json ]; then
cat > package.json <<'JSON'
{
  "name": "mack-russell-athlete-site",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "@vercel/blob": "latest"
  }
}
JSON
else
node - <<'NODE'
const fs = require('fs');
const p = 'package.json';
const pkg = JSON.parse(fs.readFileSync(p, 'utf8'));
pkg.dependencies = pkg.dependencies || {};
pkg.dependencies['@vercel/blob'] = pkg.dependencies['@vercel/blob'] || 'latest';
fs.writeFileSync(p, JSON.stringify(pkg, null, 2));
NODE
fi

python3 - <<'PY'
from pathlib import Path
import re
p=Path("index.html")
html=p.read_text()
Path("index.before-vercel-native-dashboard.html").write_text(html)

if 'href="management.html"' not in html:
    html=re.sub(r'(<nav[^>]*class="[^"]*\bnav\b[^"]*"[^>]*>)',r'\1\n        <a href="management.html">Management</a>',html,count=1,flags=re.I)

script=r'''
<script id="vercel-native-lead-form-script">
(function(){
function guessType(form){var text=((form.closest('section')||form).innerText||'').toLowerCase();if(text.includes('recruit'))return'Recruiter Inquiry';if(text.includes('55 club')||text.includes('fan'))return'55 Club Signup';if(text.includes('sponsor'))return'Sponsor Inquiry';if(text.includes('media'))return'Media Inquiry';return'Website Lead'}
function field(form,names){for(var i=0;i<names.length;i++){var el=form.querySelector('[name="'+names[i]+'"], #'+names[i]);if(el&&el.value)return el.value.trim()}return''}
function payload(form){var fd=new FormData(form);var p={};fd.forEach(function(v,k){p[k]=String(v||'').trim()});p.leadType=p.leadType||p.type||guessType(form);p.name=p.name||p.fullName||p.full_name||field(form,['name','fullName','full_name']);p.email=p.email||field(form,['email']);p.phone=p.phone||field(form,['phone']);p.organization=p.organization||p.school||p.company||p.team||field(form,['organization','school','company','team']);p.role=p.role||p.fanType||p.recruiterRole||field(form,['role','fanType','recruiterRole']);p.interest=p.interest||p.interestLevel||field(form,['interest','interestLevel']);p.message=p.message||p.notes||field(form,['message','notes']);p.sourcePage=window.location.href;return p}
function install(){Array.from(document.querySelectorAll('form')).forEach(function(form){if(form.dataset.vercelLeadInstalled)return;var txt=((form.closest('section')||form).innerText||'').toLowerCase();var looks=txt.includes('55 club')||txt.includes('recruit')||txt.includes('fan')||txt.includes('sponsor')||txt.includes('media');if(!looks)return;form.dataset.vercelLeadInstalled='true';form.addEventListener('submit',async function(e){e.preventDefault();var data=payload(form);var btn=form.querySelector('button[type="submit"], button:not([type])');var old=btn?btn.textContent:'';try{if(btn){btn.disabled=true;btn.textContent='Sending...'}var res=await fetch('/api/leads',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data)});var json=await res.json();if(!json.ok)throw new Error(json.error||'Submission failed');form.reset();alert('Thank you. Your information has been sent to Isaiah Mack-Russell management.')}catch(err){console.error(err);alert('Could not send yet: '+err.message)}finally{if(btn){btn.disabled=false;btn.textContent=old||'Submit'}}})})}
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',install);else install();
})();
</script>
'''
if 'id="vercel-native-lead-form-script"' not in html:
    # Remove old Google script if present to avoid duplicate submit handlers.
    html=re.sub(r'<script id="lead-backend-config">.*?</script>\s*','',html,flags=re.S)
    html=re.sub(r'<script id="lead-form-backend-script">.*?</script>\s*','',html,flags=re.S)
    html=html.replace("</body>",script+"\n</body>")

cta='''\n<section id="management-access" class="management-access-section"><div class="panel"><div class="kicker">Private management access</div><h2 class="section-title">Lead <span>Dashboard</span></h2><p class="muted">Family and management can review 55 Club signups, recruiter inquiries, media contacts and sponsor interest from one private dashboard powered by this website.</p><div class="actions"><a class="btn primary" href="management.html">Open Management Dashboard</a></div></div></section>\n'''
if 'id="management-access"' not in html:
    html=html.replace("</body>",cta+"\n</body>")
css='''\n<style id="management-dashboard-cta-css">\n.management-access-section{padding:70px 6vw!important}.management-access-section .panel{max-width:980px;margin:0 auto}\n</style>\n'''
if 'id="management-dashboard-cta-css"' not in html:
    html=html.replace("</head>",css+"\n</head>")
p.write_text(html)
print("DONE: Added Vercel-native dashboard/API and connected public forms.")
print("Backup saved: index.before-vercel-native-dashboard.html")
PY
echo ""
echo "Installed Vercel-native dashboard."
echo "Next: add Vercel Blob storage and env vars: ADMIN_TOKEN, BLOB_READ_WRITE_TOKEN, ALERT_EMAIL, RESEND_API_KEY, FROM_EMAIL."
