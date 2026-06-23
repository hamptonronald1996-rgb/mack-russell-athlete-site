#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "index.html" ]; then
  echo "ERROR: index.html not found. Run this inside ~/Downloads/isaiah-mack-russell-visible-media-smooth-site"
  exit 1
fi

python3 - <<'PY'
from pathlib import Path
import re
from datetime import datetime

p = Path('index.html')
html = p.read_text()
Path('index.before-mobile-ui-polish.html').write_text(html)

# Remove prior mobile polish block so reruns are clean.
html = re.sub(r'<!-- MOBILE_UI_POLISH_START -->.*?<!-- MOBILE_UI_POLISH_END -->', '', html, flags=re.S)
html = re.sub(r'<style id="mobile-ui-polish-v1">.*?</style>', '', html, flags=re.S)
html = re.sub(r'<script id="mobile-ui-polish-js">.*?</script>', '', html, flags=re.S)

# Improve viewport for iPhone notch/safe areas if needed.
html = re.sub(r'<meta name="viewport"[^>]*>', '<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">', html, count=1, flags=re.I)
if 'name="viewport"' not in html:
    html = html.replace('<head>', '<head>\n<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">', 1)

# Mobile intro bar placed BEFORE any hero section. This fixes "nothing at top on iPhone".
mobile_intro = '''
<!-- MOBILE_UI_POLISH_START -->
<div class="mobile-entry-bar">
  <div class="mobile-entry-mark">55</div>
  <div>
    <strong>Isaiah Mack-Russell</strong>
    <span>2027 Guard · Winton Woods</span>
  </div>
</div>

<nav class="mobile-quick-nav" aria-label="Mobile quick navigation">
  <a href="#media">Media</a>
  <a href="#film">Film</a>
  <a href="#recruiters">Recruit</a>
  <a href="#club55">55 Club</a>
</nav>
<!-- MOBILE_UI_POLISH_END -->
'''

# Insert right after body, but after previous forced hero if it has already been inserted? We want it literally first visible.
html = re.sub(r'(<body[^>]*>)', r'\1\n' + mobile_intro, html, count=1, flags=re.I)

css = r'''
<style id="mobile-ui-polish-v1">
/* Mobile UI polish for Isaiah Mack-Russell site */
:root{--mobile-safe-top:env(safe-area-inset-top,0px);--mobile-safe-bottom:env(safe-area-inset-bottom,0px)}
.mobile-entry-bar,.mobile-quick-nav{display:none}

@media(max-width:820px){
  html,body{width:100%!important;max-width:100%!important;overflow-x:hidden!important;scroll-behavior:smooth!important;-webkit-text-size-adjust:100%!important}
  body{background:#02030a!important;padding-bottom:calc(76px + var(--mobile-safe-bottom))!important}

  /* The visible top identity strip */
  .mobile-entry-bar{
    display:flex!important;align-items:center!important;gap:12px!important;
    position:sticky!important;top:0!important;z-index:99990!important;
    padding:calc(10px + var(--mobile-safe-top)) 14px 10px!important;
    background:linear-gradient(180deg,rgba(2,3,10,.96),rgba(2,3,10,.78))!important;
    border-bottom:1px solid rgba(255,255,255,.12)!important;
    backdrop-filter:blur(18px)!important;-webkit-backdrop-filter:blur(18px)!important;
  }
  .mobile-entry-mark{
    width:42px!important;height:42px!important;min-width:42px!important;border-radius:14px!important;
    display:grid!important;place-items:center!important;
    border:1px solid rgba(86,240,255,.55)!important;
    color:#56f0ff!important;background:rgba(86,240,255,.12)!important;
    font-weight:1000!important;letter-spacing:-.08em!important;box-shadow:0 0 24px rgba(86,240,255,.14)!important;
  }
  .mobile-entry-bar strong{display:block!important;color:#fff!important;font-size:14px!important;line-height:1.1!important;letter-spacing:.02em!important;text-transform:uppercase!important}
  .mobile-entry-bar span{display:block!important;color:#b9c7e6!important;font-size:11px!important;line-height:1.2!important;text-transform:uppercase!important;letter-spacing:.12em!important;margin-top:4px!important}

  /* Replace cramped top nav with bottom thumb nav */
  .topbar{display:none!important}
  .mobile-quick-nav{
    display:grid!important;grid-template-columns:repeat(4,1fr)!important;gap:7px!important;
    position:fixed!important;left:10px!important;right:10px!important;bottom:calc(10px + var(--mobile-safe-bottom))!important;z-index:99991!important;
    padding:8px!important;border-radius:24px!important;
    border:1px solid rgba(255,255,255,.14)!important;background:rgba(2,3,10,.82)!important;
    backdrop-filter:blur(20px)!important;-webkit-backdrop-filter:blur(20px)!important;
    box-shadow:0 18px 70px rgba(0,0,0,.55)!important;
  }
  .mobile-quick-nav a{
    display:flex!important;align-items:center!important;justify-content:center!important;
    min-height:42px!important;border-radius:18px!important;text-decoration:none!important;
    color:#eaf2ff!important;background:rgba(255,255,255,.07)!important;border:1px solid rgba(255,255,255,.1)!important;
    font-size:10px!important;text-transform:uppercase!important;letter-spacing:.1em!important;font-weight:950!important;
  }
  .mobile-quick-nav a:first-child{border-color:rgba(86,240,255,.48)!important;background:rgba(86,240,255,.12)!important;color:#fff!important}

  /* Make the hero photo the first premium experience on iPhone */
  .uc-top-hero,.uc-hero-photo-section,.top-mack-photo{
    padding:12px 12px 18px!important;margin:0!important;background:#02030a!important;position:relative!important;z-index:5!important;
  }
  .uc-top-hero-card,.uc-hero-photo-wrap,.top-mack-photo-frame{
    min-height:calc(100svh - 152px)!important;border-radius:28px!important;
    border:1px solid rgba(255,255,255,.18)!important;box-shadow:0 30px 100px rgba(0,0,0,.58)!important;
  }
  .uc-top-hero-card img,.uc-hero-photo-wrap img,.top-mack-photo-frame img{
    object-fit:cover!important;object-position:center top!important;opacity:1!important;filter:contrast(1.04) saturate(1.06)!important;
  }
  .uc-top-hero-card:after,.uc-hero-photo-wrap:after,.top-mack-photo-frame:after{
    background:linear-gradient(180deg,rgba(2,3,10,0) 0%,rgba(2,3,10,.08) 42%,rgba(2,3,10,.92) 100%)!important;
  }
  .uc-top-hero-copy,.uc-hero-copy,.top-mack-photo-overlay{
    left:18px!important;right:18px!important;bottom:22px!important;max-width:none!important;
  }
  .uc-top-hero-copy p,.uc-hero-copy p,.top-mack-photo-overlay p,.top-mack-kicker{
    font-size:10px!important;letter-spacing:.14em!important;line-height:1.25!important;margin-bottom:10px!important;
  }
  .uc-top-hero-copy h1,.uc-hero-copy h1,.top-mack-photo-overlay h1{
    font-size:clamp(42px,15vw,72px)!important;line-height:.86!important;letter-spacing:-.075em!important;text-shadow:0 8px 34px rgba(0,0,0,.62)!important;
  }
  .uc-top-hero-copy div,.uc-hero-buttons{
    display:flex!important;gap:8px!important;overflow-x:auto!important;flex-wrap:nowrap!important;margin-top:14px!important;padding-bottom:2px!important;-webkit-overflow-scrolling:touch!important;scrollbar-width:none!important;
  }
  .uc-top-hero-copy div::-webkit-scrollbar,.uc-hero-buttons::-webkit-scrollbar{display:none!important}
  .uc-top-hero-copy a,.uc-hero-buttons a{
    flex:0 0 auto!important;min-height:42px!important;padding:12px 13px!important;font-size:10px!important;border-radius:999px!important;background:rgba(2,3,10,.64)!important;
  }

  /* Kill duplicate desktop hero if it appears immediately after forced mobile/UC hero */
  body > .hero{padding-top:28px!important;min-height:auto!important}
  .hero{display:block!important;padding:38px 16px 42px!important}
  .hero .mega{font-size:clamp(46px,16vw,78px)!important;line-height:.86!important;letter-spacing:-.075em!important;margin:10px 0!important}
  .hero .lede{font-size:17px!important;line-height:1.35!important;color:#dce8ff!important}
  .hero .actions{gap:8px!important;margin-top:18px!important;display:flex!important;overflow-x:auto!important;flex-wrap:nowrap!important;padding-bottom:4px!important;scrollbar-width:none!important}
  .hero .actions::-webkit-scrollbar{display:none!important}
  .hero .btn{flex:0 0 auto!important;min-height:42px!important;font-size:10px!important;padding:12px 13px!important}
  .hero-card{min-height:460px!important;margin-top:22px!important;border-radius:26px!important}

  /* Sections: stronger mobile rhythm */
  section{padding:54px 16px!important;scroll-margin-top:84px!important}
  .section-head{display:block!important;margin-bottom:20px!important}
  .section-title{font-size:clamp(38px,13vw,68px)!important;line-height:.9!important;letter-spacing:-.065em!important;margin:6px 0 10px!important}
  .kicker{font-size:10px!important;letter-spacing:.16em!important}
  .muted,.card-body p,.link-card p,.video-card p,.event p{font-size:14px!important;line-height:1.55!important;color:#bdc9e2!important}

  /* Cards and grids */
  .hub-grid,.cards,.video-grid,.stat-grid,.social-grid{display:grid!important;grid-template-columns:1fr!important;gap:14px!important}
  .feature-card{min-height:430px!important;border-radius:26px!important}
  .media-card{min-height:320px!important;border-radius:24px!important}
  .feature-card img,.media-card img{opacity:1!important;object-fit:cover!important;object-position:center top!important}
  .card-body{padding:18px!important}
  .card-body h3{font-size:clamp(24px,8vw,36px)!important;line-height:.95!important}
  .sourcebar{gap:7px!important;margin-top:12px!important}
  .sourcebar span,.sourcebar strong{font-size:9px!important;padding:7px 9px!important}

  .stat{min-height:auto!important;padding:16px!important;border-radius:20px!important}
  .stat b{font-size:34px!important}
  .stat span{font-size:10px!important}

  .link-card,.panel{border-radius:24px!important;padding:18px!important;min-height:auto!important}
  .link-card h3{font-size:21px!important}

  .video-card{border-radius:24px!important}
  .video-card iframe{aspect-ratio:16/9!important;min-height:210px!important}
  .video-card .copy{padding:16px!important}

  .event{display:block!important;padding:16px!important;border-radius:22px!important}
  .event time{display:block!important;margin-bottom:8px!important}

  /* Forms become premium mobile cards */
  form,input,select,textarea,button{font-size:16px!important}
  input,select,textarea{
    width:100%!important;min-height:48px!important;border-radius:16px!important;
    background:rgba(255,255,255,.075)!important;border:1px solid rgba(255,255,255,.14)!important;color:#fff!important;
  }
  textarea{min-height:120px!important}
  button,.btn{min-height:46px!important}

  /* Ticker/banner should never hide hero photo on mobile */
  .ticker{position:relative!important;z-index:1!important;bottom:auto!important;margin-top:20px!important;border-top:1px solid rgba(255,255,255,.12)!important;background:rgba(2,3,10,.72)!important}
  .ticker-track{padding:10px 0!important;animation-duration:48s!important}
  .ticker span{font-size:10px!important}

  /* Reduce motion/lag on iPhone */
  .orb{display:none!important}
  .bg:after{opacity:.25!important;background-size:58px 58px!important}
  .reveal{opacity:1!important;transform:none!important;transition:none!important}
  *{backface-visibility:hidden!important;-webkit-tap-highlight-color:rgba(86,240,255,.15)!important}
}

@media(max-width:390px){
  .uc-top-hero-card,.uc-hero-photo-wrap,.top-mack-photo-frame{min-height:calc(100svh - 138px)!important}
  .uc-top-hero-copy h1,.uc-hero-copy h1,.top-mack-photo-overlay h1{font-size:clamp(38px,14vw,58px)!important}
  .section-title{font-size:clamp(34px,12vw,58px)!important}
}
</style>
'''

js = r'''
<script id="mobile-ui-polish-js">
(function(){
  function markActive(){
    var links=[].slice.call(document.querySelectorAll('.mobile-quick-nav a'));
    if(!links.length)return;
    var y=window.scrollY+140;
    var active=null;
    links.forEach(function(a){
      var id=(a.getAttribute('href')||'').replace('#','');
      var el=document.getElementById(id);
      if(el && el.offsetTop<=y) active=a;
    });
    links.forEach(function(a){a.style.borderColor='rgba(255,255,255,.1)';a.style.background='rgba(255,255,255,.07)'});
    if(active){active.style.borderColor='rgba(86,240,255,.58)';active.style.background='rgba(86,240,255,.14)'}
  }
  window.addEventListener('scroll',markActive,{passive:true});
  window.addEventListener('load',markActive);
})();
</script>
'''

html = html.replace('</head>', css + '\n</head>')
html = html.replace('</body>', js + '\n</body>')

p.write_text(html)
print('DONE: Mobile UI polish installed.')
print('Backup saved: index.before-mobile-ui-polish.html')
PY

echo "Mobile UI polish installed. Test with: http://localhost:5173/?v=mobile-polish"
