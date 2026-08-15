// share-plan email sender (used by skills/share-plan.md).
// Attaches a formatted PDF + the .md source and emails it via MS Graph.
//
// RUN FROM the emed_app directory with NODE_PATH set, e.g.:
//   cd <path>/emed_app
//   NODE_PATH="$PWD/node_modules" TO_EMAIL=.. TO_NAME=.. FROM_EMAIL="$(git config user.email)" \
//   FROM_NAME="$(git config user.name)" REPLY_TO="$(git config user.email)" \
//   PLAN_FILE="../ai_info/plans/<slug>.md" PLAN_TITLE=".." NOTE=".." \
//   node ../ai_info/skills/share_plan_send.js
//
// cwd MUST be emed_app: dotenv loads emed_app/.env, and pdf_html is required from there.
// NODE_PATH lets the bare requires below resolve against emed_app/node_modules.
const path = require('path');
const APP = process.cwd();                 // emed_app
require('dotenv').config();                // loads emed_app/.env for AZURE_* creds
require('isomorphic-fetch');
const fs = require('fs');
const { ClientSecretCredential } = require('@azure/identity');
const { Client } = require('@microsoft/microsoft-graph-client');
const pdfLib = require(path.join(APP, 'server', 'pdf_html.js'));   // to_base64_pdf(html) via html-pdf

const esc = s => String(s == null ? '' : s).replace(/[&<>]/g, c => ({ '&':'&amp;','<':'&lt;','>':'&gt;' }[c]));
function inline(s){
  s = esc(s);
  s = s.replace(/`([^`]+)`/g, '<code>$1</code>');
  s = s.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
  s = s.replace(/(^|[^*])\*([^*]+)\*(?!\*)/g, '$1<em>$2</em>');
  s = s.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>');
  return s;
}
// Compact markdown -> HTML for the plan-template subset (no markdown lib is installed in emed_app).
function mdToHtml(md){
  let front = '', body = md;
  const fm = md.match(/^---\r?\n([\s\S]*?)\r?\n---\r?\n?/);
  if (fm){ front = fm[1]; body = md.slice(fm[0].length); }
  const out = []; let listType = null, inCode = false, code = [], inTable = false, trows = [];
  const closeList = () => { if (listType){ out.push('</' + listType + '>'); listType = null; } };
  const closeTable = () => {
    if (!inTable) return;
    const head = trows[0] || [], rows = trows.slice(2);
    out.push('<table><thead><tr>' + head.map(c => '<th>' + inline(c.trim()) + '</th>').join('') + '</tr></thead><tbody>');
    rows.forEach(r => out.push('<tr>' + r.map(c => '<td>' + inline(c.trim()) + '</td>').join('') + '</tr>'));
    out.push('</tbody></table>'); inTable = false; trows = [];
  };
  body.split(/\r?\n/).forEach(line => {
    if (/^```/.test(line)){ if (!inCode){ closeList(); closeTable(); inCode = true; code = []; }
      else { out.push('<pre><code>' + esc(code.join('\n')) + '</code></pre>'); inCode = false; } return; }
    if (inCode){ code.push(line); return; }
    if (/^\s*\|.*\|\s*$/.test(line)){ closeList(); inTable = true;
      trows.push(line.trim().replace(/^\|/, '').replace(/\|$/, '').split('|')); return; }
    if (inTable) closeTable();
    if (/^\s*$/.test(line)){ closeList(); return; }
    if (/^(-{3,}|\*{3,})\s*$/.test(line)){ closeList(); out.push('<hr>'); return; }
    const h = line.match(/^(#{1,6})\s+(.*)$/);
    if (h){ closeList(); out.push('<h' + h[1].length + '>' + inline(h[2]) + '</h' + h[1].length + '>'); return; }
    const bq = line.match(/^>\s?(.*)$/);
    if (bq){ closeList(); out.push('<blockquote>' + inline(bq[1]) + '</blockquote>'); return; }
    const ul = line.match(/^\s*[-*]\s+(.*)$/);
    if (ul){ if (listType !== 'ul'){ closeList(); out.push('<ul>'); listType = 'ul'; } out.push('<li>' + inline(ul[1]) + '</li>'); return; }
    const ol = line.match(/^\s*\d+\.\s+(.*)$/);
    if (ol){ if (listType !== 'ol'){ closeList(); out.push('<ol>'); listType = 'ol'; } out.push('<li>' + inline(ol[1]) + '</li>'); return; }
    closeList(); out.push('<p>' + inline(line) + '</p>');
  });
  if (inCode) out.push('<pre><code>' + esc(code.join('\n')) + '</code></pre>');
  closeList(); closeTable();
  return (front ? '<div class="meta"><pre>' + esc(front) + '</pre></div>' : '') + out.join('\n');
}
const CSS = '<style>'
  + 'body{font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#222;line-height:1.5;margin:0}'
  + '.doc{max-width:860px}'
  + 'h1{font-size:22px;border-bottom:2px solid #333;padding-bottom:6px;margin:0 0 12px}'
  + 'h2{font-size:17px;margin:20px 0 8px;border-bottom:1px solid #ddd;padding-bottom:3px}'
  + 'h3{font-size:14px;margin:16px 0 6px}'
  + 'p{margin:8px 0}ul,ol{margin:8px 0 8px 22px;padding:0}li{margin:3px 0}'
  + 'code{font-family:Consolas,"Courier New",monospace;background:#f2f2f2;padding:1px 4px;border-radius:3px;font-size:11px}'
  + 'pre{background:#f6f6f6;border:1px solid #e2e2e2;border-radius:5px;padding:10px;white-space:pre-wrap;word-break:break-word}'
  + 'pre code{background:none;padding:0}'
  + 'table{border-collapse:collapse;width:100%;margin:10px 0;font-size:11px}'
  + 'th,td{border:1px solid #ccc;padding:5px 8px;text-align:left;vertical-align:top}th{background:#f0f0f0}'
  + 'blockquote{border-left:4px solid #ccc;margin:8px 0;padding:4px 12px;color:#555;background:#fafafa}'
  + 'hr{border:none;border-top:1px solid #ddd;margin:14px 0}a{color:#1155cc}'
  + '.meta{background:#f7f9fb;border:1px solid #e0e6ec;border-radius:5px;padding:8px 10px;margin:0 0 14px}'
  + '.meta pre{background:none;border:none;padding:0;font-size:10px;color:#555}'
  + '.foot{color:#888;font-size:11px;margin-top:16px}'
  + '</style>';

(async () => {
  const e = process.env;
  if (!e.AZURE_TENANT_ID || !e.AZURE_CLIENT_ID || !e.AZURE_CLIENT_SECRET) { console.error('MISSING_AZURE_CREDS: run from emed_app with AZURE_* in .env'); process.exit(2); }
  if (!e.TO_EMAIL || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e.TO_EMAIL)) { console.error('BAD_RECIPIENT: ' + e.TO_EMAIL); process.exit(2); }
  if (!e.PLAN_FILE || !fs.existsSync(e.PLAN_FILE)) { console.error('PLAN_FILE_NOT_FOUND: ' + e.PLAN_FILE); process.exit(2); }
  const md = fs.readFileSync(e.PLAN_FILE, 'utf8');
  const fname = e.PLAN_FILE.split(/[\\/]/).pop();
  const pdfname = fname.replace(/\.md$/i, '') + '.pdf';
  const title = e.PLAN_TITLE || fname;
  const bodyHtml = mdToHtml(md);

  const attachments = [{ '@odata.type': '#microsoft.graph.fileAttachment', name: fname, contentType: 'text/markdown', contentBytes: Buffer.from(md, 'utf8').toString('base64') }];
  let pdfNote = '';
  try {
    const pdfDoc = '<!DOCTYPE html><html><head><meta charset="utf-8">' + CSS + '</head><body><div class="doc">' + bodyHtml + '</div></body></html>';
    const pdfB64 = await pdfLib.to_base64_pdf(pdfDoc, false, { format: 'Letter', border: '12mm' });
    attachments.unshift({ '@odata.type': '#microsoft.graph.fileAttachment', name: pdfname, contentType: 'application/pdf', contentBytes: pdfB64 });
  } catch (pe) { pdfNote = 'PDF generation failed (' + (pe.message || pe) + ') — sent .md only'; console.error('PDF_WARN: ' + (pe.message || pe)); }

  const html = CSS + '<div class="doc">'
    + '<p><strong>' + esc(e.FROM_NAME || 'A teammate') + '</strong> shared an eMed plan with you via Claude Code.</p>'
    + (e.NOTE ? '<p>' + esc(e.NOTE) + '</p>' : '')
    + '<p><strong>Attached:</strong> a formatted PDF (' + esc(pdfname) + ') for reading'
    + (pdfNote ? ' <em>[' + esc(pdfNote) + ']</em>' : '') + ' and the Markdown source (' + esc(fname) + ') to hand to Claude.</p>'
    + '<hr>' + bodyHtml
    + '<p class="foot">Sent by the eMed &quot;share plan&quot; skill. Reply goes to ' + esc(e.REPLY_TO || e.FROM_NAME || 'the sender') + '.</p></div>';

  const cred = new ClientSecretCredential(e.AZURE_TENANT_ID, e.AZURE_CLIENT_ID, e.AZURE_CLIENT_SECRET);
  const client = Client.initWithMiddleware({ authProvider: { getAccessToken: async () => (await cred.getToken('https://graph.microsoft.com/.default')).token } });
  const msg = (sender) => ({ message: {
    subject: '[eMed Plan] ' + title + ' — shared by ' + (e.FROM_NAME || 'a teammate'),
    body: { contentType: 'HTML', content: html },
    toRecipients: [{ emailAddress: { address: e.TO_EMAIL, name: e.TO_NAME || undefined } }],
    from: { emailAddress: { address: sender } },
    replyTo: e.REPLY_TO ? [{ emailAddress: { address: e.REPLY_TO, name: e.FROM_NAME || undefined } }] : undefined,
    attachments
  }, saveToSentItems: 'true' });
  const SYSTEM = 'noreply@rxcompoundstore.com';
  const primary = e.FROM_EMAIL || SYSTEM;   // send from the dev's own mailbox when the tenant allows it
  try {
    await client.api('/users/' + primary + '/sendMail').post(msg(primary));
    console.log(JSON.stringify({ success: true, from: primary, to: e.TO_EMAIL, attachments: attachments.map(a => a.name), pdfNote: pdfNote || undefined }));
  } catch (err) {
    const denied = err.statusCode === 403 || /access|denied|ErrorAccessDenied/i.test(err.message || '');
    if (denied && primary !== SYSTEM) {           // no send-as rights → fall back to the proven system mailbox
      try { await client.api('/users/' + SYSTEM + '/sendMail').post(msg(SYSTEM));
        console.log(JSON.stringify({ success: true, from: SYSTEM, to: e.TO_EMAIL, attachments: attachments.map(a => a.name), note: 'fell back to system sender (no send-as for ' + primary + ')' })); }
      catch (err2) { console.error('SEND_FAILED_FALLBACK: ' + (err2.message || err2)); process.exit(1); }
    } else { console.error('SEND_FAILED: ' + (err.message || err)); process.exit(1); }
  }
})();
