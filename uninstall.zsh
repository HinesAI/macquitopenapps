#!/bin/zsh

set -euo pipefail

PLIST_NAME="com.local.quit-open-apps-on-login.plist"
TARGET_PLIST="${HOME}/Library/LaunchAgents/${PLIST_NAME}"
LABEL="com.local.quit-open-apps-on-login"

/bin/launchctl bootout "gui/$UID" "${TARGET_PLIST}" 2>/dev/null || true
/bin/rm -f "${TARGET_PLIST}"

/bin/echo "Uninstalled ${LABEL}"
