# Quit Open Apps on Login

A small macOS LaunchAgent helper that reduces the chance of a machine locking up
after login because macOS tries to restore apps from the previous session.

It was written for macOS Sonoma, especially for older Macs or patched systems
where some GUI apps can cause display glitches, GPU issues, or freezes when they
automatically reopen after a restart or power loss.

## What It Does

- Disables common macOS Resume settings for the current user.
- Clears per-app saved window/session state from:

  ```text
  ~/Library/Saved Application State
  ```

- Runs at login through a user LaunchAgent.
- For a short window after login, repeatedly quits normal foreground GUI apps
  that manage to reopen anyway.
- Leaves core macOS UI processes alone, including Finder, Dock, Control Center,
  Notification Center, and SystemUIServer.

## What It Does Not Do

- It does not delete installed applications.
- It does not delete documents, wallets, browser profiles, or app data.
- It does not disable system daemons or background services.
- It does not permanently block an app from launching later.
- It does not replace proper troubleshooting for failing GPUs, bad drivers, or
  broken app installs.

This is a practical guardrail for login-time stability, not a security sandbox.

## Files

```text
quit-open-apps-on-login.zsh   Main login cleanup script
install.zsh                   Installs the LaunchAgent for the current user
uninstall.zsh                 Removes the LaunchAgent
com.local.quit-open-apps-on-login.plist
                              Example LaunchAgent plist
```

The installer generates the active plist with your actual local path, so the
folder can be cloned or copied anywhere before installation.

## Install

Clone or copy this folder, then run:

```zsh
cd quit-login-apps
./install.zsh
```

The helper will run the next time you log in.

The installer also applies these current-user macOS defaults:

```zsh
defaults write com.apple.loginwindow TALLogoutSavesState -bool false
defaults write com.apple.loginwindow LoginwindowLaunchesRelaunchApps -bool false
defaults write -g NSQuitAlwaysKeepsWindows -bool false
defaults write -g ApplePersistence -bool false
```

## Test Manually

You can run the main script directly:

```zsh
./quit-open-apps-on-login.zsh
```

Be careful: it will quit foreground GUI apps for the configured time window.
Save work first.

## Configure

Edit `quit-open-apps-on-login.zsh`.

How long the quit loop runs after login:

```zsh
RUN_FOR_SECONDS="${RUN_FOR_SECONDS:-120}"
```

How often it checks:

```zsh
SLEEP_SECONDS="${SLEEP_SECONDS:-3}"
```

Whether to clear saved app state:

```zsh
CLEAR_SAVED_APP_STATE="${CLEAR_SAVED_APP_STATE:-true}"
```

Apps that should not be quit:

```zsh
EXCLUDED_APPS=(
  "Control Center"
  "Dock"
  "Finder"
  "Notification Center"
  "SystemUIServer"
)
```

Add any app you want to preserve during login to `EXCLUDED_APPS`.

## Logs

Main activity log:

```text
~/Library/Logs/quit-open-apps-on-login.log
```

LaunchAgent stdout and stderr logs:

```text
~/Library/Logs/quit-open-apps-on-login.stdout.log
~/Library/Logs/quit-open-apps-on-login.stderr.log
```

## Uninstall

```zsh
cd quit-login-apps
./uninstall.zsh
```

This removes the LaunchAgent from:

```text
~/Library/LaunchAgents/com.local.quit-open-apps-on-login.plist
```

It does not automatically restore the macOS Resume defaults. To re-enable app
and window restoration behavior, run:

```zsh
defaults delete com.apple.loginwindow TALLogoutSavesState 2>/dev/null
defaults delete com.apple.loginwindow LoginwindowLaunchesRelaunchApps 2>/dev/null
defaults delete -g NSQuitAlwaysKeepsWindows 2>/dev/null
defaults delete -g ApplePersistence 2>/dev/null
```

## Compatibility

Tested for a macOS Sonoma-style user LaunchAgent workflow. It should also work
on nearby macOS versions that support the same `launchctl`, `defaults`, and
AppleScript behavior.

## Safety Notes

- Save work before manual testing.
- Review the script before installing.
- Keep a Terminal window available the first time you test.
- If you depend on apps reopening after login, add them to `EXCLUDED_APPS` or do not use this helper.

## Attribution

Created by HinesAI.

