#!/bin/zsh

# Prevents macOS Resume from restoring the previous GUI session, then quits
# normal foreground GUI apps during the first moments after login.

set -u

RUN_FOR_SECONDS="${RUN_FOR_SECONDS:-120}"
SLEEP_SECONDS="${SLEEP_SECONDS:-3}"
CLEAR_SAVED_APP_STATE="${CLEAR_SAVED_APP_STATE:-true}"

LOG_FILE="${HOME}/Library/Logs/quit-open-apps-on-login.log"
SAVED_APP_STATE_DIR="${HOME}/Library/Saved Application State"

# Keep core macOS UI running. Add anything you want to preserve here.
EXCLUDED_APPS=(
  "Control Center"
  "Dock"
  "Finder"
  "Notification Center"
  "SystemUIServer"
)

log() {
  /bin/mkdir -p "$(/usr/bin/dirname "$LOG_FILE")"
  /bin/echo "$(/bin/date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG_FILE"
}

disable_macos_resume() {
  /usr/bin/defaults write com.apple.loginwindow TALLogoutSavesState -bool false
  /usr/bin/defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false
  /usr/bin/defaults write -g NSQuitAlwaysKeepsWindows -bool false
  /usr/bin/defaults write -g ApplePersistence -bool false
  log "disabled macOS login/session resume defaults"
}

clear_saved_app_state() {
  if [[ "$CLEAR_SAVED_APP_STATE" != "true" ]]; then
    return
  fi

  if [[ ! -d "$SAVED_APP_STATE_DIR" ]]; then
    return
  fi

  /usr/bin/find "$SAVED_APP_STATE_DIR" \
    -mindepth 1 \
    -maxdepth 1 \
    -name "*.savedState" \
    -exec /bin/rm -rf {} +

  log "cleared saved application state"
}

quit_foreground_apps() {
  /usr/bin/osascript - "${EXCLUDED_APPS[@]}" <<'APPLESCRIPT'
on run argv
  set excludedApps to {}

  repeat with appName in argv
    set end of excludedApps to appName as text
  end repeat

  tell application "System Events"
    set runningApps to name of every application process whose background only is false
  end tell

  repeat with appName in runningApps
    set appNameText to appName as text
    if excludedApps does not contain appNameText then
      try
        tell application appNameText to quit
      end try
    end if
  end repeat
end run
APPLESCRIPT
}

main() {
  local end_time
  end_time=$(( $(/bin/date +%s) + RUN_FOR_SECONDS ))

  log "started; preventing session restore and quitting foreground apps for ${RUN_FOR_SECONDS}s"
  disable_macos_resume
  clear_saved_app_state

  while (( $(/bin/date +%s) < end_time )); do
    quit_foreground_apps
    /bin/sleep "$SLEEP_SECONDS"
  done

  log "finished"
}

main "$@"
