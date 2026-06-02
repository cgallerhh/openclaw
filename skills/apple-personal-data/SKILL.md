---
name: apple-personal-data
description: Read and manage Christian's Apple Notes, Apple Calendar and Apple Reminders through the paired macOS node.
metadata:
  {
    "openclaw":
      {
        "emoji": "🍎",
      },
  }
---

# Apple Notes, Calendar and Reminders Bridge

Use the paired node `Christians MacBook` for Apple Notes, Apple Calendar and Apple Reminders.
The VPS container cannot access these macOS apps directly.

Always use the exec tool with:

- `host=node`
- `node=Christians MacBook`
- `security=allowlist`

## Apple Calendar

```bash
apple-calendar calendars
apple-calendar upcoming
apple-calendar upcoming --days 14
apple-calendar add \
  --calendar "private Termine" --title "Appointment" \
  --start "2026-06-03T10:00:00+02:00" --end "2026-06-03T11:00:00+02:00"
```

The calendar command returns JSON. Use ISO 8601 timestamps with an explicit
timezone when creating events. Ask which calendar to use if the user has not
specified one and the correct target is unclear.

## Apple Reminders

```bash
remindctl today --json
remindctl list
remindctl add --title "Buy milk" --due tomorrow
remindctl complete <id>
```

Use Apple Reminders only when the user wants the item synced into Apple's
Reminders app. Use OpenClaw cron for chat alerts and scheduled agent work.

## Apple Notes

```bash
apple-notes folders
apple-notes list
apple-notes list --folder "Notes"
apple-notes search --query "project"
apple-notes add --folder "Notes" --title "Idea" --body "Text"
```

Ask for the target folder before adding a note if the user has not named one.
Only create or modify a note when the user explicitly requests it.

## Availability

The Mac must be powered on, logged in, and online. If the node is offline, tell
the user that Apple Notes, Calendar and Reminders are temporarily unavailable.
