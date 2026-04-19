#!/usr/bin/env node
/**
 * Einmaliges Script um den Google OAuth Refresh Token zu generieren.
 *
 * Voraussetzungen:
 *   node get-google-token.js
 *
 * Du brauchst GOOGLE_CLIENT_ID und GOOGLE_CLIENT_SECRET aus der
 * Google Cloud Console (OAuth 2.0 Client für "Desktop App").
 */

const http = require("http");
const https = require("https");
const readline = require("readline");
const { URL } = require("url");

const SCOPES = [
  "https://www.googleapis.com/auth/gmail.modify",
  "https://www.googleapis.com/auth/calendar",
  "https://www.googleapis.com/auth/drive",
].join(" ");

const REDIRECT_URI = "http://localhost:4242/callback";

function ask(question) {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  return new Promise((resolve) => rl.question(question, (ans) => { rl.close(); resolve(ans.trim()); }));
}

async function exchangeCode(clientId, clientSecret, code) {
  const body = new URLSearchParams({
    code,
    client_id: clientId,
    client_secret: clientSecret,
    redirect_uri: REDIRECT_URI,
    grant_type: "authorization_code",
  }).toString();

  return new Promise((resolve, reject) => {
    const req = https.request(
      {
        hostname: "oauth2.googleapis.com",
        path: "/token",
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Content-Length": Buffer.byteLength(body),
        },
      },
      (res) => {
        let data = "";
        res.on("data", (chunk) => (data += chunk));
        res.on("end", () => resolve(JSON.parse(data)));
      }
    );
    req.on("error", reject);
    req.write(body);
    req.end();
  });
}

async function waitForCode() {
  return new Promise((resolve, reject) => {
    const server = http.createServer((req, res) => {
      const url = new URL(req.url, "http://localhost:4242");
      const code = url.searchParams.get("code");
      const error = url.searchParams.get("error");

      res.writeHead(200, { "Content-Type": "text/html; charset=utf-8" });
      if (code) {
        res.end("<h2>✅ Erfolgreich! Du kannst dieses Fenster schließen.</h2>");
        server.close();
        resolve(code);
      } else {
        res.end(`<h2>❌ Fehler: ${error}</h2>`);
        server.close();
        reject(new Error(error));
      }
    });
    server.listen(4242, () => {});
    server.on("error", reject);
  });
}

async function main() {
  console.log("\n=== Google Refresh Token Generator ===\n");
  console.log("Öffne die Google Cloud Console:");
  console.log("https://console.cloud.google.com/apis/credentials\n");
  console.log("Erstelle einen OAuth 2.0 Client (Typ: Desktop App) und kopiere die Daten.\n");

  const clientId = await ask("GOOGLE_CLIENT_ID: ");
  const clientSecret = await ask("GOOGLE_CLIENT_SECRET: ");

  const authUrl =
    "https://accounts.google.com/o/oauth2/v2/auth?" +
    new URLSearchParams({
      client_id: clientId,
      redirect_uri: REDIRECT_URI,
      response_type: "code",
      scope: SCOPES,
      access_type: "offline",
      prompt: "consent",
    }).toString();

  console.log("\n📋 Öffne diese URL im Browser:\n");
  console.log(authUrl);
  console.log("\nWarte auf Autorisierung...");

  const code = await waitForCode();
  console.log("\n🔄 Tausche Code gegen Token...");

  const tokens = await exchangeCode(clientId, clientSecret, code);

  if (tokens.error) {
    console.error("\n❌ Fehler:", tokens.error_description || tokens.error);
    process.exit(1);
  }

  console.log("\n✅ Erfolgreich! Füge diese Werte als GitHub Secrets hinzu:\n");
  console.log(`GOOGLE_CLIENT_ID=${clientId}`);
  console.log(`GOOGLE_CLIENT_SECRET=${clientSecret}`);
  console.log(`GOOGLE_REFRESH_TOKEN=${tokens.refresh_token}`);
  console.log("\n⚠️  Speichere den Refresh Token sicher – er wird nur einmal angezeigt.");
}

main().catch((err) => {
  console.error("Fehler:", err.message);
  process.exit(1);
});
