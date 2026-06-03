#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="${0:A:h}"
PLIST_NAME="com.local.quit-open-apps-on-login.plist"
SOURCE_PLIST="${SCRIPT_DIR}/${PLIST_NAME}"
TARGET_DIR="${HOME}/Library/LaunchAgents"
TARGET_PLIST="${TARGET_DIR}/${PLIST_NAME}"
LABEL="com.local.quit-open-apps-on-login"

/bin/chmod +x "${SCRIPT_DIR}/quit-open-apps-on-login.zsh"
/bin/mkdir -p "${TARGET_DIR}"
/bin/cp "${SOURCE_PLIST}" "${TARGET_PLIST}"

/usr/bin/defaults write com.apple.loginwindow TALLogoutSavesState -bool false
/usr/bin/defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false
/usr/bin/defaults write -g NSQuitAlwaysKeepsWindows -bool false
/usr/bin/defaults write -g ApplePersistence -bool false

/bin/echo "Installed ${LABEL}"
/bin/echo "It will run at the next login and macOS Resume relaunch has been disabled."
/bin/echo "To test it manually, run the script directly, but it will quit foreground apps:"
/bin/echo "  ${SCRIPT_DIR}/quit-open-apps-on-login.zsh"
