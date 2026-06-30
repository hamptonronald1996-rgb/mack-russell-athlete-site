import { put, list } from '@vercel/blob';

const LEADS_PREFIX = 'leads/';
const ADMIN_TOKEN = process.env.ADMIN_TOKEN || '';
const ALERT_EMAIL = process.env.ALERT_EMAIL || '';
const RESEND_API_KEY = process.env.RESEND_API_KEY || '';
const FROM_EMAIL = process.env.FROM_EMAIL || 'Isaiah Mack-Russell Site <onboarding@resend.dev>';

function sendJson(res, status, payload) {
  res.status(status);
  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Cache-Control', 'no-store');
  res.end(JSON.stringify(payload));
}

function clean(value) {
  return String(value || '').trim();
}

function buildLead(body = {}, req) {
  return {
    id: `${Date.now()}-${Math.random().toString(36).slice(2, 9)}`,
    createdAt: new Date().toISOString(),
    leadType: clean(body.leadType || body.type || 'Website Lead'),
    name: clean(body.name || body.fullName || body.full_name),
    email: clean(body.email),
    phone: clean(body.phone),
    organization: clean(body.organization || body.school || body.company || body.team),
    role: clean(body.role || body.fanType || body.recruiterRole),
    interest: clean(body.interest || body.interestLevel),
    message: clean(body.message || body.notes),
    sourcePage: clean(body.sourcePage || body.page || body.url || req.headers.referer),
    status: 'New',
    notes: ''
  };
}

async function sendAlert(lead) {
  if (!RESEND_API_KEY || !ALERT_EMAIL) return { skipped: true };

  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${RESEND_API_KEY}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      from: FROM_EMAIL,
      to: [ALERT_EMAIL],
      subject: `[Isaiah Mack-Russell Site] New ${lead.leadType}`,
      html: `
        <div style="font-family:Arial,sans-serif;line-height:1.5">
          <h2>New ${lead.leadType}</h2>
          <p><strong>Name:</strong> ${lead.name}</p>
          <p><strong>Email:</strong> ${lead.email}</p>
          <p><strong>Phone:</strong> ${lead.phone}</p>
          <p><strong>Organization:</strong> ${lead.organization}</p>
          <p><strong>Role:</strong> ${lead.role}</p>
          <p><strong>Interest:</strong> ${lead.interest}</p>
          <p><strong>Message:</strong><br>${String(lead.message || '').replace(/\n/g, '<br>')}</p>
          <p><strong>Source:</strong> ${lead.sourcePage}</p>
        </div>
      `
    })
  });

  if (!response.ok) {
    return { ok: false, error: await response.text() };
  }

  return { ok: true };
}

async function readAllLeads() {
  const found = await list({ prefix: LEADS_PREFIX, limit: 1000 });
  const blobs = found.blobs || [];

  const leads = await Promise.all(
    blobs.map(async (blob) => {
      try {
        const response = await fetch(blob.url + `?t=${Date.now()}`, { cache: 'no-store' });
        if (!response.ok) return null;
        return await response.json();
      } catch {
        return null;
      }
    })
  );

  return leads
    .filter(Boolean)
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
}

function buildCounts(leads) {
  return {
    total: leads.length,
    fans: leads.filter(x => /55|fan|supporter/i.test(x.leadType || '')).length,
    recruiters: leads.filter(x => /recruit|coach/i.test(x.leadType || '')).length,
    media: leads.filter(x => /media/i.test(x.leadType || '')).length,
    sponsors: leads.filter(x => /sponsor|partner/i.test(x.leadType || '')).length,
    new: leads.filter(x => String(x.status || '').toLowerCase() === 'new').length
  };
}

export default async function handler(req, res) {
  try {
    if (req.method === 'POST') {
      const lead = buildLead(req.body || {}, req);

      if (!lead.name && !lead.email && !lead.phone) {
        return sendJson(res, 400, { ok: false, error: 'Missing contact information.' });
      }

      await put(`${LEADS_PREFIX}${lead.createdAt}-${lead.id}.json`, JSON.stringify(lead, null, 2), {
        access: 'public',
        contentType: 'application/json',
        addRandomSuffix: false
      });

      const email = await sendAlert(lead);

      return sendJson(res, 200, {
        ok: true,
        message: 'Lead saved.',
        lead,
        email
      });
    }

    if (req.method === 'GET') {
      const token = clean(req.query.token || req.headers['x-admin-token']);

      if (!ADMIN_TOKEN || token !== ADMIN_TOKEN) {
        return sendJson(res, 401, { ok: false, error: 'Unauthorized.' });
      }

      const leads = await readAllLeads();

      return sendJson(res, 200, {
        ok: true,
        leads,
        counts: buildCounts(leads)
      });
    }

    return sendJson(res, 405, { ok: false, error: 'Method not allowed.' });
  } catch (error) {
    return sendJson(res, 500, {
      ok: false,
      error: String(error.message || error)
    });
  }
}
