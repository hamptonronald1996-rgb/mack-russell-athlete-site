#!/usr/bin/env bash
set -e
if [ ! -f "index.html" ]; then
  echo "ERROR: Run this from inside your athlete site folder where index.html exists."
  exit 1
fi
cp "$(dirname "$0")/management.html" ./management.html
cp "$(dirname "$0")/Code.gs" ./GOOGLE_APPS_SCRIPT_BACKEND_CODE.gs
python3 - <<'PY'
from pathlib import Path
import re
p=Path("index.html")
html=p.read_text()
Path("index.before-management-dashboard.html").write_text(html)
if 'href="management.html"' not in html:
    html=re.sub(r'(<nav[^>]*class="[^"]*\bnav\b[^"]*"[^>]*>)',r'\1\n        <a href="management.html">Management</a>',html,count=1,flags=re.I)
config='''\n<script id="lead-backend-config">\nwindow.IMR_LEAD_BACKEND_URL = "PASTE_GOOGLE_APPS_SCRIPT_WEB_APP_URL_HERE";\n</script>\n'''
if 'id="lead-backend-config"' not in html:
    html=html.replace("</head>",config+"\n</head>")
script=r'''
<script id="lead-form-backend-script">
(function(){
function guessType(form){var text=((form.closest('section')||form).innerText||'').toLowerCase();if(text.includes('recruit'))return'Recruiter Inquiry';if(text.includes('55 club')||text.includes('fan'))return'55 Club Signup';if(text.includes('sponsor'))return'Sponsor Inquiry';if(text.includes('media'))return'Media Inquiry';return'Website Lead'}
function field(form,names){for(var i=0;i<names.length;i++){var el=form.querySelector('[name="'+names[i]+'"], #'+names[i]);if(el&&el.value)return el.value.trim()}return''}
function formToPayload(form){var fd=new FormData(form);var payload={};fd.forEach(function(v,k){payload[k]=String(v||'').trim()});payload.leadType=payload.leadType||payload.type||guessType(form);payload.name=payload.name||payload.fullName||payload.full_name||field(form,['name','fullName','full_name']);payload.email=payload.email||field(form,['email']);payload.phone=payload.phone||field(form,['phone']);payload.organization=payload.organization||payload.school||payload.company||payload.team||field(form,['organization','school','company','team']);payload.role=payload.role||payload.fanType||payload.recruiterRole||field(form,['role','fanType','recruiterRole']);payload.interest=payload.interest||payload.interestLevel||field(form,['interest','interestLevel']);payload.message=payload.message||payload.notes||field(form,['message','notes']);payload.sourcePage=window.location.href;return payload}
async function submitToBackend(form,payload){var endpoint=window.IMR_LEAD_BACKEND_URL||"";if(!endpoint||endpoint.includes("PASTE_GOOGLE_APPS_SCRIPT"))throw new Error("Lead backend URL is not configured yet.");await fetch(endpoint,{method:"POST",mode:"no-cors",headers:{"Content-Type":"text/plain;charset=utf-8"},body:JSON.stringify(payload)});return true}
function install(){Array.from(document.querySelectorAll('form')).forEach(function(form){if(form.dataset.imrBackendInstalled)return;var sectionText=((form.closest('section')||form).innerText||'').toLowerCase();var looks=sectionText.includes('55 club')||sectionText.includes('recruit')||sectionText.includes('fan')||sectionText.includes('sponsor')||sectionText.includes('media');if(!looks)return;form.dataset.imrBackendInstalled='true';form.addEventListener('submit',async function(e){e.preventDefault();var payload=formToPayload(form);var btn=form.querySelector('button[type="submit"], button:not([type])');var oldText=btn?btn.textContent:'';try{if(btn){btn.disabled=true;btn.textContent='Sending...'}await submitToBackend(form,payload);var key='imr_local_submissions';var saved=JSON.parse(localStorage.getItem(key)||'[]');saved.push(Object.assign({createdAt:new Date().toISOString()},payload));localStorage.setItem(key,JSON.stringify(saved));form.reset();alert('Thank you. Your information has been sent to Isaiah Mack-Russell management.')}catch(err){console.error(err);alert('This form is not connected yet. Paste the Google Apps Script URL into index.html.')}finally{if(btn){btn.disabled=false;btn.textContent=oldText||'Submit'}}})})}
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',install);else install();
})();
</script>
'''
if 'id="lead-form-backend-script"' not in html:
    html=html.replace("</body>",script+"\n</body>")
cta='''\n<section id="management-access" class="management-access-section"><div class="panel"><div class="kicker">Private management access</div><h2 class="section-title">Lead <span>Dashboard</span></h2><p class="muted">Family and management can review 55 Club signups, recruiter inquiries, media contacts and sponsor interest from one private dashboard.</p><div class="actions"><a class="btn primary" href="management.html">Open Management Dashboard</a></div></div></section>\n'''
if 'id="management-access"' not in html:
    html=html.replace("</body>",cta+"\n</body>")
css='''\n<style id="management-dashboard-cta-css">\n.management-access-section{padding:70px 6vw!important}.management-access-section .panel{max-width:980px;margin:0 auto}\n</style>\n'''
if 'id="management-dashboard-cta-css"' not in html:
    html=html.replace("</head>",css+"\n</head>")
p.write_text(html)
print("DONE: Added management dashboard, backend config, and form submission script.")
print("Backup saved: index.before-management-dashboard.html")
PY
echo "Installed management dashboard files."
