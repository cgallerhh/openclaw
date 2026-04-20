#!/usr/bin/env node
// Minimal Google Calendar MCP Server (stdio transport)

const { google } = require('googleapis');
const readline = require('readline');

const oauth2Client = new google.auth.OAuth2(
  process.env.GOOGLE_CLIENT_ID,
  process.env.GOOGLE_CLIENT_SECRET
);
oauth2Client.setCredentials({ refresh_token: process.env.GOOGLE_REFRESH_TOKEN });

const calendar = google.calendar({ version: 'v3', auth: oauth2Client });

const TOOLS = [
  {
    name: 'list_calendar_events',
    description: 'Liste bevorstehende Termine aus Google Calendar auf',
    inputSchema: {
      type: 'object',
      properties: {
        maxResults: { type: 'number', description: 'Max. Anzahl Termine (Standard: 10)' },
        timeMin: { type: 'string', description: 'Startzeit ISO 8601 (Standard: jetzt)' },
        timeMax: { type: 'string', description: 'Endzeit ISO 8601 (optional)' }
      }
    }
  },
  {
    name: 'create_calendar_event',
    description: 'Erstelle einen neuen Termin in Google Calendar',
    inputSchema: {
      type: 'object',
      required: ['summary', 'start', 'end'],
      properties: {
        summary:     { type: 'string', description: 'Titel des Termins' },
        start:       { type: 'string', description: 'Startzeit ISO 8601' },
        end:         { type: 'string', description: 'Endzeit ISO 8601' },
        description: { type: 'string', description: 'Beschreibung (optional)' },
        location:    { type: 'string', description: 'Ort (optional)' }
      }
    }
  }
];

async function callTool(name, args) {
  if (name === 'list_calendar_events') {
    const res = await calendar.events.list({
      calendarId: 'primary',
      timeMin: args.timeMin || new Date().toISOString(),
      timeMax: args.timeMax,
      maxResults: args.maxResults || 10,
      singleEvents: true,
      orderBy: 'startTime'
    });
    const events = res.data.items || [];
    const text = events.length === 0
      ? 'Keine Termine gefunden.'
      : events.map(e => {
          const start = e.start.dateTime || e.start.date;
          return `• ${e.summary} – ${start}${e.location ? ' @ ' + e.location : ''}`;
        }).join('\n');
    return { content: [{ type: 'text', text }] };
  }

  if (name === 'create_calendar_event') {
    const res = await calendar.events.insert({
      calendarId: 'primary',
      requestBody: {
        summary: args.summary,
        description: args.description || '',
        location: args.location || '',
        start: { dateTime: args.start, timeZone: 'Europe/Berlin' },
        end:   { dateTime: args.end,   timeZone: 'Europe/Berlin' }
      }
    });
    return { content: [{ type: 'text', text: `Termin erstellt: ${res.data.htmlLink}` }] };
  }

  throw new Error(`Unbekanntes Tool: ${name}`);
}

function send(obj) {
  process.stdout.write(JSON.stringify(obj) + '\n');
}

const rl = readline.createInterface({ input: process.stdin });
rl.on('line', async (line) => {
  let id;
  try {
    const req = JSON.parse(line);
    id = req.id;
    const { method, params } = req;

    if (method === 'initialize') {
      send({ jsonrpc: '2.0', id, result: {
        protocolVersion: '2024-11-05',
        capabilities: { tools: {} },
        serverInfo: { name: 'google-calendar', version: '1.0.0' }
      }});
    } else if (method === 'notifications/initialized') {
      // no response needed
    } else if (method === 'tools/list') {
      send({ jsonrpc: '2.0', id, result: { tools: TOOLS } });
    } else if (method === 'tools/call') {
      const result = await callTool(params.name, params.arguments || {});
      send({ jsonrpc: '2.0', id, result });
    } else {
      send({ jsonrpc: '2.0', id, result: {} });
    }
  } catch (err) {
    send({ jsonrpc: '2.0', id, error: { code: -32000, message: err.message } });
  }
});
