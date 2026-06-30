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

function isAuthorized(req) {
  const token = clean(req.query?.token || req.headers['x-admin-token'] || req.body?.token);
  return ADMIN_TOKEN && token === ADMIN_TOKEN;
}

function buildLead(body = {}, req) {
  return {
    id: `${Date.now()}-${Math.random().toString(36).slice(2, 9)}`,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
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

  if (!response.ok) return { ok: false, error: await response.text() };
  return { ok: true };
}

async function readLeadFromBlob(blob) {
  try {
    const token = process.env.BLOB_READ_WRITE_TOKEN || '';
    const url = blob.downloadUrl || blob.url;
    if (!url) return null;

    const response = await fetch(url + `?t=${Date.now()}`, {
      cache: 'no-store',
      headers: token ? { Authorization: `Bearer ${token}` } : {}
    });

    if (!response.ok) return null;

    const lead = await response.json();
    lead._pathname = blob.pathname;
    lead._url = blob.url;
    return lead;
  } catch {
    return null;
  }
}

async function readAllLeadsWithPath() {
  const found = await list({ prefix: LEADS_PREFIX, limit: 1000 });
  const blobs = found.blobs || [];

  const leads = await Promise.all(blobs.map(readLeadFromBlob));

  return leads
    .filter(Boolean)
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
}

async function findLeadById(id) {
  const leads = await readAllLeadsWithPath();
  return leads.find(lead => lead.id === id) || null;
}

async function saveExistingLead(lead) {
  if (!lead || !lead._pathname) throw new Error('Lead pathname missing.');

  const pathname = lead._pathname;
  const cleanLead = { ...lead };

  delete cleanLead._pathname;
  delete cleanLead._url;

  await put(pathname, JSON.stringify(cleanLead, null, 2), {
    access: 'private',
    contentType: 'application/json',
    addRandomSuffix: false
  });

  return cleanLead;
}

function buildCounts(leads) {
  const active = leads.filter(x => !/archived|deleted/i.test(x.status || ''));

  return {
    total: active.length,
    all: leads.length,
    fans: active.filter(x => /55|fan|supporter/i.test(x.leadType || '')).length,
    recruiters: active.filter(x => /recruit|coach/i.test(x.leadType || '')).length,
    media: active.filter(x => /media/i.test(x.leadType || '')).length,
    sponsors: active.filter(x => /sponsor|partner/i.test(x.leadType || '')).length,
    new: active.filter(x => String(x.status || '').toLowerCase() === 'new').length,
    done: leads.filter(x => String(x.status || '').toLowerCase() === 'done').length,
    archived: leads.filter(x => String(x.status || '').toLowerCase() === 'archived').length,
    deleted: leads.filter(x => String(x.status || '').toLowerCase() === 'deleted').length
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
        access: 'private',
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
      if (!isAuthorized(req)) {
        return sendJson(res, 401, { ok: false, error: 'Unauthorized.' });
      }

      const leads = await readAllLeadsWithPath();
      const publicLeads = leads.map(lead => {
        const copy = { ...lead };
        delete copy._pathname;
        delete copy._url;
        return copy;
      });

      return sendJson(res, 200, {
        ok: true,
        leads: publicLeads,
        counts: buildCounts(publicLeads)
      });
    }

    if (req.method === 'PATCH') {
      if (!isAuthorized(req)) {
        return sendJson(res, 401, { ok: false, error: 'Unauthorized.' });
      }

      const id = clean(req.body?.id);
      const status = clean(req.body?.status);
      const notes = typeof req.body?.notes === 'string' ? req.body.notes : undefined;

      const allowedStatuses = ['New', 'In Progress', 'Done', 'Archived', 'Deleted'];

      if (!id) return sendJson(res, 400, { ok: false, error: 'Missing lead id.' });
      if (status && !allowedStatuses.includes(status)) {
        return sendJson(res, 400, { ok: false, error: 'Invalid status.' });
      }

      const lead = await findLeadById(id);
      if (!lead) return sendJson(res, 404, { ok: false, error: 'Lead not found.' });

      if (status) lead.status = status;
      if (notes !== undefined) lead.notes = notes;

      lead.updatedAt = new Date().toISOString();

      const saved = await saveExistingLead(lead);

      return sendJson(res, 200, {
        ok: true,
        message: 'Lead updated.',
        lead: saved
      });
    }

    if (req.method === 'DELETE') {
      if (!isAuthorized(req)) {
        return sendJson(res, 401, { ok: false, error: 'Unauthorized.' });
      }

      const id = clean(req.query?.id || req.body?.id);
      if (!id) return sendJson(res, 400, { ok: false, error: 'Missing lead id.' });

      const lead = await findLeadById(id);
      if (!lead) return sendJson(res, 404, { ok: false, error: 'Lead not found.' });

      lead.status = 'Deleted';
      lead.updatedAt = new Date().toISOString();

      const saved = await saveExistingLead(lead);

      return sendJson(res, 200, {
        ok: true,
        message: 'Lead moved to trash.',
        lead: saved
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
