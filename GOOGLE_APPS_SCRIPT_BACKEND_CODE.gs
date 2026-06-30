/**
 * Isaiah Mack-Russell Website Lead Backend
 * Paste this into Google Apps Script attached to a Google Sheet.
 */
const ADMIN_TOKEN = "CHANGE_THIS_TO_A_PRIVATE_ADMIN_TOKEN";
const ALERT_EMAIL = "CHANGE_THIS_TO_FAMILY_OR_MANAGEMENT_EMAIL";
const SHEET_NAME = "Website Leads";

function getSheet_() {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  let sheet = ss.getSheetByName(SHEET_NAME);
  if (!sheet) sheet = ss.insertSheet(SHEET_NAME);

  const headers = ["Timestamp","Lead Type","Name","Email","Phone","Organization","Role","Interest","Message","Source Page","Status","Notes"];
  const firstRow = sheet.getRange(1, 1, 1, headers.length).getValues()[0];
  if (firstRow.every(v => !v)) {
    sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
    sheet.setFrozenRows(1);
  }
  return sheet;
}

function json_(payload) {
  return ContentService.createTextOutput(JSON.stringify(payload)).setMimeType(ContentService.MimeType.JSON);
}

function normalize_(value) {
  return String(value || "").trim();
}

function doPost(e) {
  try {
    const sheet = getSheet_();
    let data = {};
    if (e && e.postData && e.postData.contents) {
      try { data = JSON.parse(e.postData.contents); } catch (err) { data = e.parameter || {}; }
    } else {
      data = e.parameter || {};
    }

    const leadType = normalize_(data.leadType || data.type || "General");
    const name = normalize_(data.name || data.fullName);
    const email = normalize_(data.email);
    const phone = normalize_(data.phone);
    const organization = normalize_(data.organization || data.school || data.company || data.team);
    const role = normalize_(data.role || data.fanType || data.recruiterRole);
    const interest = normalize_(data.interest || data.interestLevel);
    const message = normalize_(data.message || data.notes);
    const sourcePage = normalize_(data.sourcePage || data.page || data.url);

    if (!name && !email && !phone) return json_({ ok: false, error: "Missing contact info." });

    sheet.appendRow([new Date(), leadType, name, email, phone, organization, role, interest, message, sourcePage, "New", ""]);

    if (ALERT_EMAIL && ALERT_EMAIL.includes("@") && !ALERT_EMAIL.includes("CHANGE_THIS")) {
      MailApp.sendEmail(
        ALERT_EMAIL,
        `[Isaiah Mack-Russell Site] New ${leadType} submission`,
        `New website submission\n\nLead Type: ${leadType}\nName: ${name}\nEmail: ${email}\nPhone: ${phone}\nOrganization: ${organization}\nRole: ${role}\nInterest: ${interest}\n\nMessage:\n${message}\n\nSource:\n${sourcePage}\n\nOpen the Google Sheet to manage this lead.`
      );
    }

    return json_({ ok: true, message: "Submission received." });
  } catch (err) {
    return json_({ ok: false, error: String(err) });
  }
}

function doGet(e) {
  try {
    const token = normalize_((e && e.parameter && e.parameter.token) || "");
    if (token !== ADMIN_TOKEN) return json_({ ok: false, error: "Unauthorized." });

    const sheet = getSheet_();
    const values = sheet.getDataRange().getValues();
    if (values.length <= 1) return json_({ ok: true, leads: [], counts: { total: 0, fans: 0, recruiters: 0, media: 0, sponsors: 0, new: 0 } });

    const headers = values[0];
    const rows = values.slice(1).reverse();

    const leads = rows.map((row, idx) => {
      const obj = {};
      headers.forEach((h, i) => {
        const key = String(h || "").replace(/\s+/g, "_").toLowerCase();
        const val = row[i];
        obj[key] = val instanceof Date ? val.toISOString() : val;
      });
      obj.id = rows.length - idx;
      return obj;
    });

    const counts = {
      total: leads.length,
      fans: leads.filter(x => String(x.lead_type || "").toLowerCase().includes("55") || String(x.lead_type || "").toLowerCase().includes("fan")).length,
      recruiters: leads.filter(x => String(x.lead_type || "").toLowerCase().includes("recruit")).length,
      media: leads.filter(x => String(x.lead_type || "").toLowerCase().includes("media")).length,
      sponsors: leads.filter(x => String(x.lead_type || "").toLowerCase().includes("sponsor")).length,
      new: leads.filter(x => String(x.status || "").toLowerCase() === "new").length
    };

    return json_({ ok: true, leads, counts });
  } catch (err) {
    return json_({ ok: false, error: String(err) });
  }
}
