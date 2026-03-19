import { NextResponse } from "next/server";

const MAIL_SERVER = "mail.inst.sa";
const IMAP_PORT = 993;
const SMTP_PORT = 465;

function generateMobileConfig(email: string): string {
  const uuid1 = crypto.randomUUID();
  const uuid2 = crypto.randomUUID();

  return `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>PayloadContent</key>
  <array>
    <dict>
      <key>EmailAccountDescription</key>
      <string>InST Mail - ${email}</string>
      <key>EmailAccountName</key>
      <string>InST</string>
      <key>EmailAccountType</key>
      <string>EmailTypeIMAP</string>
      <key>EmailAddress</key>
      <string>${email}</string>
      <key>IncomingMailServerAuthentication</key>
      <string>EmailAuthPassword</string>
      <key>IncomingMailServerHostName</key>
      <string>${MAIL_SERVER}</string>
      <key>IncomingMailServerPortNumber</key>
      <integer>${IMAP_PORT}</integer>
      <key>IncomingMailServerUseSSL</key>
      <true/>
      <key>IncomingMailServerUsername</key>
      <string>${email}</string>
      <key>OutgoingMailServerAuthentication</key>
      <string>EmailAuthPassword</string>
      <key>OutgoingMailServerHostName</key>
      <string>${MAIL_SERVER}</string>
      <key>OutgoingMailServerPortNumber</key>
      <integer>${SMTP_PORT}</integer>
      <key>OutgoingMailServerUseSSL</key>
      <true/>
      <key>OutgoingMailServerUsername</key>
      <string>${email}</string>
      <key>PayloadDescription</key>
      <string>Configure ${email} on your device</string>
      <key>PayloadDisplayName</key>
      <string>InST Mail - ${email}</string>
      <key>PayloadIdentifier</key>
      <string>sa.inst.mail.${email.replace("@", ".at.")}</string>
      <key>PayloadType</key>
      <string>com.apple.mail.managed</string>
      <key>PayloadUUID</key>
      <string>${uuid1}</string>
      <key>PayloadVersion</key>
      <integer>1</integer>
    </dict>
  </array>
  <key>PayloadDisplayName</key>
  <string>InST Email - ${email}</string>
  <key>PayloadIdentifier</key>
  <string>sa.inst.mail.profile.${email.replace("@", ".at.")}</string>
  <key>PayloadRemovalDisallowed</key>
  <false/>
  <key>PayloadType</key>
  <string>Configuration</string>
  <key>PayloadUUID</key>
  <string>${uuid2}</string>
  <key>PayloadVersion</key>
  <integer>1</integer>
</dict>
</plist>`;
}

function generateAndroidIntent(email: string): string {
  return JSON.stringify({
    email,
    server: MAIL_SERVER,
    imap: { host: MAIL_SERVER, port: IMAP_PORT, security: "SSL/TLS" },
    smtp: { host: MAIL_SERVER, port: SMTP_PORT, security: "SSL/TLS" },
    instructions: {
      gmail: `Open Gmail → Settings → Add Account → Other → Enter ${email} → IMAP → Server: ${MAIL_SERVER}, Port: ${IMAP_PORT}, Security: SSL/TLS → Outgoing: ${MAIL_SERVER}, Port: ${SMTP_PORT}, Security: SSL/TLS`,
      outlook: `Open Outlook → Add Account → IMAP → Email: ${email} → Server: ${MAIL_SERVER} → Port: ${IMAP_PORT} (IMAP) / ${SMTP_PORT} (SMTP) → Security: SSL/TLS`,
    },
  });
}

export async function GET(request: Request) {
  const url = new URL(request.url);
  const email = url.searchParams.get("email");
  const type = url.searchParams.get("type") || "ios";

  if (!email || !email.includes("@")) {
    return NextResponse.json({ error: "Email parameter required" }, { status: 400 });
  }

  if (type === "ios") {
    const config = generateMobileConfig(email);
    return new NextResponse(config, {
      headers: {
        "Content-Type": "application/x-apple-aspen-config",
        "Content-Disposition": `attachment; filename="inst-mail-${email.split("@")[0]}.mobileconfig"`,
      },
    });
  }

  if (type === "android") {
    const config = generateAndroidIntent(email);
    return new NextResponse(config, {
      headers: {
        "Content-Type": "application/json",
        "Content-Disposition": `attachment; filename="inst-mail-${email.split("@")[0]}.json"`,
      },
    });
  }

  // Setup instructions page
  const html = `<!DOCTYPE html>
<html>
<head><title>InST Email Setup</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  body { font-family: -apple-system, sans-serif; max-width: 500px; margin: 40px auto; padding: 20px; background: #0B0F19; color: #F9FAFB; }
  h1 { color: #00C896; }
  .card { background: rgba(17,24,39,0.85); border: 1px solid rgba(255,255,255,0.06); border-radius: 16px; padding: 20px; margin: 16px 0; }
  .btn { display: block; text-align: center; padding: 14px; border-radius: 12px; text-decoration: none; font-weight: 600; margin: 10px 0; }
  .btn-ios { background: linear-gradient(135deg, #00C896, #2563EB); color: white; }
  .btn-android { background: rgba(255,255,255,0.1); color: #00C896; border: 1px solid #00C896; }
  table { width: 100%; border-collapse: collapse; }
  td { padding: 8px; border-bottom: 1px solid rgba(255,255,255,0.06); }
  td:first-child { color: #9CA3AF; }
  code { background: rgba(0,200,150,0.1); padding: 2px 6px; border-radius: 4px; color: #00C896; }
</style>
</head>
<body>
  <h1>InST Email Setup</h1>
  <p>Configure <strong>${email}</strong> on your device:</p>

  <a href="/api/email-setup?email=${email}&type=ios" class="btn btn-ios">Download iOS Profile</a>

  <div class="card">
    <h3>Manual Setup (Android / Gmail / Outlook)</h3>
    <table>
      <tr><td>Email</td><td><code>${email}</code></td></tr>
      <tr><td>IMAP Server</td><td><code>${MAIL_SERVER}</code></td></tr>
      <tr><td>IMAP Port</td><td><code>${IMAP_PORT}</code></td></tr>
      <tr><td>IMAP Security</td><td><code>SSL/TLS</code></td></tr>
      <tr><td>SMTP Server</td><td><code>${MAIL_SERVER}</code></td></tr>
      <tr><td>SMTP Port</td><td><code>${SMTP_PORT}</code></td></tr>
      <tr><td>SMTP Security</td><td><code>SSL/TLS</code></td></tr>
      <tr><td>Username</td><td><code>${email}</code></td></tr>
    </table>
  </div>

  <p style="color:#6B7280;font-size:12px;text-align:center;">Innovative Solutions Tech</p>
</body>
</html>`;

  return new NextResponse(html, {
    headers: { "Content-Type": "text/html" },
  });
}
