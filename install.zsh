#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="${0:A:h}"
PLIST_NAME="com.local.quit-open-apps-on-login.plist"
TARGET_DIR="${HOME}/Library/LaunchAgents"
TARGET_PLIST="${TARGET_DIR}/${PLIST_NAME}"
LABEL="com.local.quit-open-apps-on-login"
MAIN_SCRIPT="${SCRIPT_DIR}/quit-open-apps-on-login.zsh"

/bin/chmod +x "${MAIN_SCRIPT}"
/bin/mkdir -p "${TARGET_DIR}"

/bin/cat > "${TARGET_PLIST}" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${LABEL}</string>

  <key>ProgramArguments</key>
  <array>
    <string>${MAIN_SCRIPT}</string>
  </array>

  <key>RunAtLoad</key>
  <true/>

  <key>StandardOutPath</key>
  <string>${HOME}/Library/Logs/quit-open-apps-on-login.stdout.log</string>

  <key>StandardErrorPath</key>
  <string>${HOME}/Library/Logs/quit-open-apps-on-login.stderr.log</string>
</dict>
</plist>
PLIST

/usr/bin/plutil -lint "${TARGET_PLIST}" >/dev/null

/usr/bin/defaults write com.apple.loginwindow TALLogoutSavesState -bool false
/usr/bin/defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false
/usr/bin/defaults write -g NSQuitAlwaysKeepsWindows -bool false
/usr/bin/defaults write -g ApplePersistence -bool false

/bin/echo "Installed ${LABEL}"
/bin/echo "It will run at the next login and macOS Resume relaunch has been disabled."
/bin/echo "To test it manually, run the script directly, but it will quit foreground apps:"
/bin/echo "  ${MAIN_SCRIPT}"
