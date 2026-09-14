(() => {
  const config = window.ATHLETE_SITE || {};
  document.querySelectorAll('[data-field]').forEach(el => {
    const value = config[el.dataset.field];
    if (value !== undefined && value !== '') el.textContent = value;
  });
  document.querySelectorAll('[data-link]').forEach(el => {
    const value = config[el.dataset.link];
    if (value) el.href = value;
  });
  document.querySelectorAll('[data-image]').forEach(el => {
    const value = config[el.dataset.image];
    if (!value) return;
    el.style.backgroundImage = `linear-gradient(180deg,transparent 35%,rgba(3,7,18,.88)),url("${String(value).replace(/\"/g, '%22')}")`;
    el.classList.add('has-image');
  });
  document.title = `${config.fullName || 'Athlete Spotlight'} | Recruiting Profile`;
  const filmGrid = document.getElementById('filmGrid');
  (config.film || []).forEach((item, i) => {
    const card = document.createElement('a');
    card.className = 'film-card'; card.href = item.url || '#';
    card.innerHTML = `<span>0${i + 1}</span><div><small>${escapeHtml(item.label)}</small><h3>${escapeHtml(item.title)}</h3></div><b>Play ↗</b>`;
    filmGrid.appendChild(card);
  });
  const achievementGrid = document.getElementById('achievementGrid');
  (config.achievements || []).forEach(item => {
    const card = document.createElement('article'); card.className = 'achievement';
    card.innerHTML = `<strong>${escapeHtml(item.year)}</strong><h3>${escapeHtml(item.title)}</h3><p>${escapeHtml(item.detail)}</p>`;
    achievementGrid.appendChild(card);
  });
  const form = document.getElementById('leadForm');
  const status = document.getElementById('formStatus');
  form.addEventListener('submit', async event => {
    event.preventDefault(); status.textContent = 'Sending…';
    const payload = Object.fromEntries(new FormData(form).entries());
    try {
      const response = await fetch('/api/leads', { method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(payload) });
      const data = await response.json();
      if (!response.ok || !data.ok) throw new Error(data.error || 'Unable to send');
      form.reset(); status.textContent = 'Inquiry sent. The management team will follow up.';
    } catch (_) { status.textContent = 'The form is not connected yet. Please contact the athlete directly.'; }
  });
  function escapeHtml(value) {
    return String(value || '').replace(/[&<>\"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','\"':'&quot;'}[c]));
  }
})();
