#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "index.html" ]; then
  echo "ERROR: Run this from inside your athlete site folder where index.html exists."
  echo "Example: cd ~/Downloads/isaiah-mack-russell-visible-media-smooth-site"
  exit 1
fi

PATCH_DIR="$HOME/Downloads/isaiah-mack-russell-uc-standout-hero-patch"
PHOTO_SRC="$PATCH_DIR/isaiah-uc-hero-cropped.jpg"

if [ ! -f "$PHOTO_SRC" ]; then
  echo "ERROR: Could not find $PHOTO_SRC"
  echo "Make sure the patch folder exists in Downloads."
  exit 1
fi

mkdir -p assets/media
cp "$PHOTO_SRC" assets/media/isaiah-uc-hero-cropped.jpg

python3 - <<'PY'
from pathlib import Path
import base64
import re

index = Path('index.html')
html = index.read_text()
Path('index.before-standout-uc-hero.html').write_text(html)

photo = Path('assets/media/isaiah-uc-hero-cropped.jpg')
if not photo.exists():
    raise SystemExit('ERROR: assets/media/isaiah-uc-hero-cropped.jpg not found.')

data_uri = 'data:image/jpeg;base64,' + base64.b64encode(photo.read_bytes()).decode('ascii')

# Remove older top hero attempts so there is only one clear hero at the top.
remove_patterns = [
    r'<!-- UC_STANDOUT_HERO_START -->.*?<!-- UC_STANDOUT_HERO_END -->',
    r'<!-- UC_TOP_HERO_START -->.*?<!-- UC_TOP_HERO_END -->',
    r'<!-- FORCE_TOP_MACK_PHOTO_START -->.*?<!-- FORCE_TOP_MACK_PHOTO_END -->',
]
for pat in remove_patterns:
    html = re.sub(pat, '', html, flags=re.S)

# Remove older injected hero CSS blocks if present.
css_remove = [
    r'<style id="uc-standout-hero-css">.*?</style>',
    r'<style id="uc-top-hero-css">.*?</style>',
    r'<style id="uc-hero-photo-direct-css">.*?</style>',
    r'<style id="force-top-mack-photo-css">.*?</style>',
    r'<style id="hero-photo-polish">.*?</style>',
]
for pat in css_remove:
    html = re.sub(pat, '', html, flags=re.S)

hero = f'''
<!-- UC_STANDOUT_HERO_START -->
<section id="home" class="uc-standout-hero" aria-label="Isaiah Mack-Russell hero photo">
  <div class="uc-standout-grid">
    <div class="uc-standout-copy">
      <p class="uc-eyebrow">Isaiah Mack-Russell · Winton Woods · Class of 2027</p>
      <h1>To God Be<br>The Glory.</h1>
      <p class="uc-standout-lede">A verified athlete brand hub for film, public media, recruiting profiles, fan updates and family-managed contact.</p>
      <div class="uc-standout-actions">
        <a href="#media">Media Hub</a>
        <a href="#film">Watch Film</a>
        <a href="#recruiters">Recruiters</a>
      </div>
    </div>
    <figure class="uc-photo-stage">
      <img src="{data_uri}" alt="Isaiah Mack-Russell in Cincinnati basketball uniform">
      <figcaption>UC re-offer post · public approved image</figcaption>
    </figure>
  </div>
</section>
<!-- UC_STANDOUT_HERO_END -->
'''

css = '''
<style id="uc-standout-hero-css">
.uc-standout-hero{
  position:relative!important;
  z-index:20!important;
  padding:118px 6vw 34px!important;
  min-height:100svh!important;
  background:
    radial-gradient(circle at 78% 16%, rgba(86,240,255,.16), transparent 34%),
    radial-gradient(circle at 18% 78%, rgba(255,214,110,.10), transparent 30%),
    #02030a!important;
}
.uc-standout-grid{
  display:grid!important;
  grid-template-columns:minmax(0,.82fr) minmax(380px,.68fr)!important;
  align-items:center!important;
  gap:clamp(26px,4vw,64px)!important;
  max-width:1500px!important;
  margin:0 auto!important;
}
.uc-standout-copy{
  position:relative!important;
  z-index:2!important;
  color:#fff!important;
}
.uc-eyebrow{
  margin:0 0 16px!important;
  color:#56f0ff!important;
  font-size:12px!important;
  text-transform:uppercase!important;
  letter-spacing:.19em!important;
  font-weight:1000!important;
}
.uc-standout-copy h1{
  margin:0!important;
  color:#fff!important;
  font-size:clamp(58px,9vw,150px)!important;
  line-height:.82!important;
  letter-spacing:-.09em!important;
  text-transform:uppercase!important;
  font-weight:1000!important;
  text-shadow:0 24px 80px rgba(0,0,0,.55)!important;
}
.uc-standout-lede{
  max-width:760px!important;
  margin:22px 0 0!important;
  color:#dce8ff!important;
  font-size:clamp(18px,2vw,26px)!important;
  line-height:1.24!important;
}
.uc-standout-actions{
  display:flex!important;
  flex-wrap:wrap!important;
  gap:12px!important;
  margin-top:28px!important;
}
.uc-standout-actions a{
  display:inline-flex!important;
  align-items:center!important;
  justify-content:center!important;
  padding:14px 18px!important;
  border-radius:999px!important;
  border:1px solid rgba(255,255,255,.18)!important;
  background:rgba(255,255,255,.075)!important;
  color:#fff!important;
  text-decoration:none!important;
  text-transform:uppercase!important;
  letter-spacing:.12em!important;
  font-size:11px!important;
  font-weight:950!important;
  backdrop-filter:blur(16px)!important;
  transition:transform .2s ease, border-color .2s ease, background .2s ease!important;
}
.uc-standout-actions a:first-child{
  border-color:rgba(86,240,255,.72)!important;
  background:rgba(86,240,255,.17)!important;
}
.uc-standout-actions a:hover{transform:translateY(-2px)!important;border-color:rgba(255,214,110,.72)!important}
.uc-photo-stage{
  margin:0!important;
  position:relative!important;
  border-radius:38px!important;
  overflow:hidden!important;
  border:1px solid rgba(255,255,255,.20)!important;
  background:#080b13!important;
  box-shadow:0 45px 145px rgba(0,0,0,.68),0 0 90px rgba(86,240,255,.15)!important;
  min-height:clamp(650px,84vh,940px)!important;
}
.uc-photo-stage:before{
  content:""!important;
  position:absolute!important;
  inset:14px!important;
  border:1px solid rgba(255,255,255,.12)!important;
  border-radius:28px!important;
  z-index:2!important;
  pointer-events:none!important;
}
.uc-photo-stage img{
  position:absolute!important;
  inset:0!important;
  width:100%!important;
  height:100%!important;
  object-fit:cover!important;
  object-position:center top!important;
  opacity:1!important;
  display:block!important;
  filter:contrast(1.04) saturate(1.05)!important;
  transform:none!important;
}
.uc-photo-stage figcaption{
  position:absolute!important;
  left:18px!important;
  right:18px!important;
  bottom:18px!important;
  z-index:3!important;
  padding:10px 12px!important;
  border-radius:999px!important;
  border:1px solid rgba(255,255,255,.17)!important;
  background:rgba(2,3,10,.68)!important;
  color:#dce8ff!important;
  font-size:10px!important;
  text-transform:uppercase!important;
  letter-spacing:.14em!important;
  font-weight:900!important;
  backdrop-filter:blur(14px)!important;
}
@media(max-width:980px){
  .uc-standout-hero{padding:92px 16px 26px!important}
  .uc-standout-grid{grid-template-columns:1fr!important;gap:22px!important}
  .uc-photo-stage{min-height:680px!important;border-radius:28px!important;order:-1!important}
  .uc-standout-copy h1{font-size:clamp(48px,15vw,96px)!important}
}
@media(max-width:560px){
  .uc-photo-stage{min-height:590px!important}
  .uc-photo-stage img{object-position:center top!important}
}
</style>
'''

html = html.replace('</head>', css + '\n</head>')
html = re.sub(r'(<body[^>]*>)', r'\1\n' + hero, html, count=1, flags=re.I)

index.write_text(html)
print('DONE: Standout UC hero installed at the very top.')
print('Embedded cropped photo directly into index.html.')
print('Backup saved: index.before-standout-uc-hero.html')
PY
