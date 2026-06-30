import { put, list } from '@vercel/blob';

const LEADS_PREFIX = 'leads/';
const ADMIN_TOKEN = process.env.ADMIN_TOKEN || '';
const ALERT_EMAIL = process.env.ALERT_EMAIL || '';
const RESEND_API_KEY = process.env.RESEND_API_KEY || '';
const FROM_EMAIL = process.env.FROM_EMAIL || 'Isaiah Mack-Russell Site <onboarding@resend.dev>';

function json(res, status, payload) {
  res.status(status).setHeader('Content-Type', 'application/json');
  res.setHeader('Cache-Control', 'no-store');
  res.end(JSON.stringify(payload));
}

function normalize(value) {
  return String(value || '').trim();
}

function cleanLead(body = {}, req) {
  const leadType = normalize(body.leadType || body.type || 'Website Lead');
  const name = normalize(body.name || body.fullName || body.full_name);
  const email = normalize(body.email);
  const phone = normalize(body.phone);
  const organization = normalize(body.organization || body.school || body.company || body.team);
  const role = normalize(body.role || body.fanType || body.recruiterRole);
  const interest = normalize(body.interest || body.interestLevel);
  const message = normalize(body.message || body.notes);
  const sourcePage = normalize(body.sourcePage || body.page || body.url || req.headers.referer);

  return {
    id: `${Date.now()}-${Math.random().toString(36).slice(2, 9)}`,
    createdAt: new Date().toISOString(),
    leadType,
    name,
    email,
    phone,
    organization,
    role,
    interest,
    message,
    sourcePage,
    status: 'New',
    notes: ''
  };
}

async function sendAlert(lead) {
  if (!RESEND_API_KEY || !ALERT_EMAIL) return { skipped: true };

  const subject = `[Isaiah Mack-Russell Site] New ${lead.leadType}`;
  const html = `
    <div style="font-family:Arial,sans-serif;line-height:1.5">
      <h2>New ${lead.leadType}</h2>
      <p><strong>Name:</strong> ${lead.name || ''}</p>
      <p><strong>Email:</strong> ${lead.email || ''}</p>
      <p><strong>Phone:</strong> ${lead.phone || ''}</p>
      <p><strong>Organization:</strong> ${lead.organization || ''}</p>
      <p><strong>Role:</strong> ${lead.role || ''}</p>
      <p><strong>Interest:</strong> ${lead.interest || ''}</p>
      <p><strong>Message:</strong><br>${(lead.message || '').replace(/\n/g, '<br>')}</p>
      <p><strong>Source:</strong> ${lead.sourcePage || ''}</p>
      <p>Open the management dashboard on the website to review all leads.</p>
    </div>
  `;

  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${RESEND_API_KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      from: FROM_EMAIL,
      to: [ALERT_EMAIL],
      subject,
      html
    })
  });

  if (!response.ok) {
    const text = await response.text();
    return { ok: false, error: text };
  }

  return { ok: true };
}

async function readAllLeads() {
  const found = await list({ prefix: LEADS_PREFIX, limit: 1000 });
  const blobs = found.blobs || [];

  const leads = await Promise.all(
    blobs.map(async (blob) => {
      try {
        const res = await fetch(blob.url + `?v=${Date.now()}`, { cache: 'no-store' });
        return await res.json();
      } catch (err) {
        return null;
      }
    })
  );

  return leads.filter(Boolean).sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
}

function counts(leads) {
  return {
    total: leads.length,
    fans: leads.filter(x => /55|fan/i.test(x.leadType || '')).length,
    recruiters: leads.filter(x => /recruit/i.test(x.leadType || '')).length,
    media: leads.filter(x => /media/i.test(x.leadType || '')).length,
    sponsors: leads.filter(x => /sponsor/i.test(x.leadType || '')).length,
    new: leads.filter(x => String(x.status || '').toLowerCase() === 'new').length
  };
}

export default async function handler(req, res) {
  try {
    if (req.method === 'POST') {
      const lead = cleanLead(req.body || {}, req);

      if (!lead.name && !lead.email && !lead.phone) {
        return json(res, 400, { ok: false, error: 'Missing contact info.' });
      }

      await put(`${LEADS_PREFIX}${lead.createdAt}-${lead.id}.json`, JSON.stringify(lead, null, 2), {
        access: 'private',
        contentType: 'application/json',
        addRandomSuffix: false
      });

      const email = await sendAlert(lead);
      return json(res, 200, { ok: true, lead, email });
    }

    if (req.method === 'GET') {
      const token = normalize(req.query.token || req.headers['x-admin-token']);
      if (!ADMIN_TOKEN || token !== ADMIN_TOKEN) {
        return json(res, 401, { ok: false, error: 'Unauthorized.' });
      }

      const leads = await readAllLeads();
      return json(res, 200, { ok: true, leads, counts: counts(leads) });
    }

    return json(res, 405, { ok: false, error: 'Method not allowed.' });
  } catch (err) {
    return json(res, 500, { ok: false, error: String(err.message || err) });
  }
}
