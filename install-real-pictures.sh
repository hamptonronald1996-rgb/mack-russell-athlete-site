#!/usr/bin/env bash
set -euo pipefail

if [ ! -f "index.html" ]; then
  echo "ERROR: Run this script from inside your athlete site folder where index.html exists."
  echo "Example: cd ~/Downloads/isaiah-mack-russell-visible-media-smooth-site"
  exit 1
fi

mkdir -p assets/media

download() {
  local url="$1"
  local out="$2"
  echo "Downloading $out"
  curl -L --retry 3 --fail --silent --show-error \
    -H "User-Agent: Mozilla/5.0" \
    -H "Accept: image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8" \
    "$url" -o "assets/media/$out" || echo "WARNING: failed to download $out"
}

# WCPO Pangos feature image
download "https://ewscripps.brightspotcdn.com/dims4/default/22ed6f8/2147483647/strip/true/crop/1085x610%2B0%2B0/resize/1280x720%21/quality/90/?url=http%3A%2F%2Fewscripps-brightspot.s3.amazonaws.com%2Fb4%2Fc5%2Ff7e549c94c318f448f22409c027e%2Fscreenshot-2026-05-22-at-9-47-09-am.png" "isaiah-wcpo-pangos.jpg"

# Winton Woods / WCPO team feature image via Winton Woods athletics
download "https://images.sidearmdev.com/convert?type=webp&url=https%3A%2F%2Fdbukjj6eu5tsf.cloudfront.net%2Fsidearm.sites%2Fwintonwoods.sidearmsports.com%2Fimages%2F2026%2F1%2F30%2F2025-26_Boys_Basketball-WCPO_nB4wZ.jpg" "winton-woods-wcpo-team.webp"

# Central Catholic All-Ohio image
download "https://images.squarespace-cdn.com/content/v1/5d9649a96fdee6211956bd14/ed24c62f-1a50-4416-89ab-d157661d5261/Isaiah%2BMack%2BRussell-Insta.jpg" "isaiah-central-catholic-all-ohio.jpg"

# Winton Woods related thumbnails from public athletics source
download "https://dbukjj6eu5tsf.cloudfront.net/sidearm.sites/wintonwoods.sidearmsports.com/images/2026/3/12/2025-26_Boys_Basketball-Northmont_DDN.jpeg?anchor=topcenter&height=600&mode=crop&quality=85&width=900" "winton-northmont-ddn.jpeg"
download "https://dbukjj6eu5tsf.cloudfront.net/sidearm.sites/wintonwoods.sidearmsports.com/images/2026/3/9/2025-26_Boys_Basketball-Anderson_Enquirer.jpg?anchor=topcenter&height=600&mode=crop&quality=85&width=900" "winton-anderson-enquirer.jpg"
download "https://dbukjj6eu5tsf.cloudfront.net/sidearm.sites/wintonwoods.sidearmsports.com/images/2026/3/7/2025-26_Boys_Basketball-District_Champions.jpeg?anchor=topcenter&height=600&mode=crop&quality=85&width=900" "winton-district-champions.jpeg"

python3 - <<'PY'
from pathlib import Path
p=Path('index.html')
s=p.read_text()
# Replace known remote URLs with local files. Keep text/captions/links unchanged.
repls={
"https://ewscripps.brightspotcdn.com/dims4/default/22ed6f8/2147483647/strip/true/crop/1085x610%2B0%2B0/resize/1280x720%21/quality/90/?url=http%3A%2F%2Fewscripps-brightspot.s3.amazonaws.com%2Fb4%2Fc5%2Ff7e549c94c318f448f22409c027e%2Fscreenshot-2026-05-22-at-9-47-09-am.png":"assets/media/isaiah-wcpo-pangos.jpg",
"https://ewscripps.brightspotcdn.com/dims4/default/489aea8/2147483647/strip/true/crop/1199x674%2B0%2B7/resize/1280x720%21/quality/90/?url=http%3A%2F%2Fewscripps-brightspot.s3.amazonaws.com%2F8a%2F02%2Fc7f8edd448f0bf8d59b3f1644ccc%2Fscreenshot-2026-01-28-at-2-04-11-pm.png":"assets/media/winton-woods-wcpo-team.webp",
"https://images.squarespace-cdn.com/content/v1/58d8289c8419c25bd137cd72/1711574428926-9J2M9E7PCW0MNFEO6VD3/Isaiah+Mack-Russell+All-Ohio.jpg":"assets/media/isaiah-central-catholic-all-ohio.jpg",
"https://images.squarespace-cdn.com/content/v1/5d9649a96fdee6211956bd14/ed24c62f-1a50-4416-89ab-d157661d5261/Isaiah%2BMack%2BRussell-Insta.jpg":"assets/media/isaiah-central-catholic-all-ohio.jpg",
}
for a,b in repls.items(): s=s.replace(a,b)
# Inject an unmistakable real-photo gallery right after Media Hub if not already added.
if 'id="real-photos"' not in s:
    insert='''\n<section id="real-photos" class="media-hub">\n  <div class="section-head reveal visible"><div><div class="kicker">Real photos</div><h2 class="section-title">Public <span>Photo Wall</span></h2></div><a class="btn primary" href="#film">Watch Film</a></div>\n  <div class="cards" style="grid-template-columns:repeat(3,minmax(0,1fr));">\n    <a class="media-card" href="https://www.wcpo.com/sports/high-school-sports/winton-woods-basketball-star-invited-to-prestigious-pangos-all-american-camp" target="_blank" rel="noopener"><img src="assets/media/isaiah-wcpo-pangos.jpg" alt="Isaiah Mack-Russell WCPO Pangos feature"><div class="card-body"><h3>WCPO Pangos Feature</h3><p>Public feature image from WCPO coverage.</p><div class="sourcebar"><span>Open Article ↗</span></div></div></a>\n    <a class="media-card" href="https://warriornation.fans/news/2026/1/28/boys-basketball-a-lot-of-fun-winton-woods-boys-hoops-team-has-12-0-record-for-first-time-since-2000-01-wcpo.aspx" target="_blank" rel="noopener"><img src="assets/media/winton-woods-wcpo-team.webp" alt="Winton Woods public team feature"><div class="card-body"><h3>Winton Woods Feature</h3><p>Warriors public athletics media coverage.</p><div class="sourcebar"><span>Open Story ↗</span></div></div></a>\n    <a class="media-card" href="https://www.centralcatholic.org/news/isaiah-mack-russell-selected-honorable-mention-all-ohio" target="_blank" rel="noopener"><img src="assets/media/isaiah-central-catholic-all-ohio.jpg" alt="Isaiah Mack-Russell Central Catholic All-Ohio"><div class="card-body"><h3>All-Ohio Recognition</h3><p>Central Catholic public All-Ohio image.</p><div class="sourcebar"><span>Open CCHS ↗</span></div></div></a>\n    <a class="media-card" href="https://warriornation.fans/news/2026/3/12/boys-basketball-winton-woods-pulls-away-in-second-quarter-advances-to-regional-final.aspx" target="_blank" rel="noopener"><img src="assets/media/winton-northmont-ddn.jpeg" alt="Winton Woods regional run media"><div class="card-body"><h3>Regional Run</h3><p>Public Winton Woods athletics media.</p><div class="sourcebar"><span>Open Story ↗</span></div></div></a>\n    <a class="media-card" href="https://warriornation.fans/news/2026/3/6/boys-basketball-vs-anderson-playoffs-enquirer-photos.aspx" target="_blank" rel="noopener"><img src="assets/media/winton-anderson-enquirer.jpg" alt="Winton Woods Anderson playoff media"><div class="card-body"><h3>Playoff Gallery</h3><p>Public Enquirer / athletics image card.</p><div class="sourcebar"><span>Open Photos ↗</span></div></div></a>\n    <a class="media-card" href="https://warriornation.fans/news/2026/3/7/boys-basketball-district-champions.aspx" target="_blank" rel="noopener"><img src="assets/media/winton-district-champions.jpeg" alt="Winton Woods district champions"><div class="card-body"><h3>District Champions</h3><p>Public Winton Woods championship image.</p><div class="sourcebar"><span>Open Story ↗</span></div></div></a>\n  </div>\n</section>\n'''
    marker='<section id="stats"'
    if marker in s:
        s=s.replace(marker, insert+'\n'+marker,1)
    else:
        s=s.replace('</main>', insert+'\n</main>',1)
# Make missing images obvious instead of silently hidden
s=s.replace("onerror=\"this.style.display='none'\"", "onerror=\"this.closest('.media-card,.feature-card,.hero-card')?.classList.add('image-failed')\"")
s=s.replace("onerror=\"this.style.opacity='0'\"", "onerror=\"this.closest('.media-card,.feature-card,.hero-card')?.classList.add('image-failed')\"")
# Add CSS for image error notice if not present
if '.image-failed:before' not in s:
    s=s.replace('</style>', ".image-failed:before{content:'IMAGE FAILED TO LOAD — CHECK assets/media FILE';position:absolute;z-index:5;inset:18px;display:grid;place-items:center;text-align:center;border:1px solid rgba(255,214,110,.45);border-radius:20px;background:rgba(0,0,0,.7);color:#ffd66e;font-weight:1000;letter-spacing:.08em;padding:16px}</style>")
p.write_text(s)
print('Patched index.html to use local files in assets/media and added Real Photos section.')
PY

echo ""
echo "Downloaded media files:"
ls -lh assets/media || true

echo ""
echo "Checking image references inside index.html:"
grep -n "assets/media\|Public Photo Wall\|Real photos" index.html | head -40

git add .
git commit -m "Add local public photo files and visible photo wall" || true
git push -f origin main

echo ""
echo "Done. Wait for Vercel to redeploy, then open your site with ?v=photos"
