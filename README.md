# Domoticz scripts
Collection of domoticz lua and shell scripts.

### Lua:
- `script_time_radar.lua`: Radar detection and alerting on specified roads (Netherlands only)
- `script_time_traffic.lua`: Traffic jam detection and alerting on specified routes

### Shell
Collection of domoticz lua scripts, currently consisting of:

- `message.sh`: Send a text message using a Telegram bot
- `snapshot.sh`: Send a photo using a Telegram bot

## Installation:
Put the scripts you want inside your domoticz scripts folders:

`domoticz/scripts/lua`
`domoticz/scripts/shell`

Keep the name of the lua script filenames the same, and they will be 
triggered every minute (actual code execution every x minutes can 
be set inside every script).