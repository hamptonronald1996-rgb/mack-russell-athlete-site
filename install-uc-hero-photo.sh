#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "index.html" ]; then
  echo "ERROR: Run this script from inside your site folder where index.html exists."
  echo "Example: cd ~/Downloads/isaiah-mack-russell-visible-media-smooth-site"
  exit 1
fi

mkdir -p assets/media
cp "$(dirname "$0")/isaiah-uc-hero.jpg" assets/media/isaiah-uc-hero.jpg

python3 - <<'PY'
from pathlib import Path
import base64, mimetypes, re

p = Path('index.html')
html = p.read_text()
Path('index.before-uc-hero-photo.html').write_text(html)

photo = Path('assets/media/isaiah-uc-hero.jpg')
if not photo.exists():
    raise SystemExit('ERROR: assets/media/isaiah-uc-hero.jpg not found.')

mime = mimetypes.guess_type(str(photo))[0] or 'image/jpeg'
data_uri = 'data:%s;base64,%s' % (mime, base64.b64encode(photo.read_bytes()).decode('ascii'))

# Remove earlier forced hero/photo experiments to avoid duplicates.
html = re.sub(r'<!-- FORCE_TOP_MACK_PHOTO_START -->.*?<!-- FORCE_TOP_MACK_PHOTO_END -->', '', html, flags=re.S)
html = re.sub(r'<style id="force-top-mack-photo-css">.*?</style>', '', html, flags=re.S)
html = re.sub(r'<style id="hero-photo-polish">.*?</style>', '', html, flags=re.S)

# Remove any previous UC hero install block.
html = re.sub(r'<!-- UC_HERO_PHOTO_START -->.*?<!-- UC_HERO_PHOTO_END -->', '', html, flags=re.S)
html = re.sub(r'<style id="uc-hero-photo-css">.*?</style>', '', html, flags=re.S)

uc_block = f'''
<!-- UC_HERO_PHOTO_START -->
<section id="home" class="uc-hero-photo-section" aria-label="Isaiah Mack-Russell hero photo">
  <div class="uc-hero-shell">
    <figure class="uc-hero-photo-card">
      <img src="{data_uri}" alt="Isaiah Mack-Russell in a Cincinnati uniform holding a basketball">
    </figure>
    <div class="uc-hero-copy">
      <p class="uc-hero-kicker">Isaiah Mack-Russell · Winton Woods · Class of 2027</p>
      <h1>Isaiah<br><span>Mack-Russell</span></h1>
      <p class="uc-hero-lede">A national 2027 guard with verified production, public film, recruiting visibility and a growing athlete brand.</p>
      <div class="uc-hero-actions">
        <a href="#media" class="btn primary">Explore Media Hub</a>
        <a href="#film" class="btn">Watch Film</a>
        <a href="#recruiters" class="btn gold">Recruiter Contact</a>
      </div>
    </div>
  </div>
</section>
<!-- UC_HERO_PHOTO_END -->
'''

css = '''
<style id="uc-hero-photo-css">
.uc-hero-photo-section{
  min-height:100svh!important;
  padding:118px 6vw 64px!important;
  position:relative!important;
  z-index:7!important;
  display:grid!important;
  align-items:center!important;
}
.uc-hero-shell{
  width:100%!important;
  max-width:1480px!important;
  margin:0 auto!important;
  display:grid!important;
  grid-template-columns:minmax(340px,.78fr) minmax(420px,1fr)!important;
  gap:clamp(24px,5vw,74px)!important;
  align-items:center!important;
}
.uc-hero-photo-card{
  position:relative!important;
  margin:0!important;
  min-height:clamp(560px,78vh,880px)!important;
  border-radius:38px!important;
  overflow:hidden!important;
  border:1px solid rgba(255,255,255,.20)!important;
  background:#06070d!important;
  box-shadow:0 45px 150px rgba(0,0,0,.66), 0 0 60px rgba(86,240,255,.20)!important;
}
.uc-hero-photo-card img{
  width:100%!important;
  height:100%!important;
  position:absolute!important;
  inset:0!important;
  object-fit:cover!important;
  object-position:center top!important;
  opacity:1!important;
  filter:none!important;
  transform:none!important;
  display:block!important;
}
.uc-hero-photo-card:before{
  content:""!important;
  position:absolute!important;
  inset:0!important;
  z-index:2!important;
  pointer-events:none!important;
  border:1px solid rgba(86,240,255,.28)!important;
  border-radius:38px!important;
  box-shadow:inset 0 0 0 1px rgba(255,255,255,.07), inset 0 -120px 120px rgba(0,0,0,.28)!important;
}
.uc-hero-copy{
  position:relative!important;
  z-index:4!important;
  color:white!important;
}
.uc-hero-kicker{
  margin:0 0 18px!important;
  color:#56f0ff!important;
  font-size:12px!important;
  text-transform:uppercase!important;
  letter-spacing:.19em!important;
  font-weight:1000!important;
}
.uc-hero-copy h1{
  margin:0!important;
  color:#f7fbff!important;
  font-size:clamp(62px,10vw,164px)!important;
  line-height:.78!important;
  letter-spacing:-.09em!important;
  text-transform:uppercase!important;
  font-weight:1000!important;
  text-shadow:0 24px 90px rgba(0,0,0,.48)!important;
}
.uc-hero-copy h1 span{
  color:transparent!important;
  -webkit-text-stroke:1.2px rgba(255,255,255,.78)!important;
  text-shadow:none!important;
}
.uc-hero-lede{
  max-width:780px!important;
  margin:24px 0 0!important;
  color:#dce8ff!important;
  font-size:clamp(18px,2.1vw,28px)!important;
  line-height:1.22!important;
}
.uc-hero-actions{
  display:flex!important;
  flex-wrap:wrap!important;
  gap:12px!important;
  margin-top:28px!important;
}
/* Keep the original hero from competing with the new photo-led entry. */
body > .hero{display:none!important;}
@media(max-width:980px){
  .uc-hero-photo-section{padding:92px 18px 44px!important;min-height:auto!important;}
  .uc-hero-shell{grid-template-columns:1fr!important;gap:26px!important;}
  .uc-hero-photo-card{min-height:620px!important;border-radius:28px!important;}
  .uc-hero-photo-card:before{border-radius:28px!important;}
}
@media(max-width:560px){
  .uc-hero-photo-card{min-height:540px!important;}
  .uc-hero-copy h1{font-size:clamp(48px,15vw,86px)!important;}
}
</style>
'''

html = html.replace('</head>', css + '\n</head>')
html = re.sub(r'(<body[^>]*>)', r'\1\n' + uc_block, html, count=1, flags=re.I)
p.write_text(html)
print('DONE: Installed UC hero photo at the top and hid competing original hero.')
print('Backup saved: index.before-uc-hero-photo.html')
PY

printf '\nInstalled files:\n'
ls -lh assets/media/isaiah-uc-hero.jpg
