# Configuration & System Change Log

This file tracks all custom configuration changes, tweaks, and system modifications made to the environment for future reference, maintenance, and easy reverting.

---

## [2026-09-27] Niri Compositor: Window Borders & Rounded Corners

* **Target File:** `~/.config/niri/config.kdl`
* **Reason / Request:** Remove the default light blue active window border (focus ring) and enable rounded window corners (12px).

### Changes Made:

1. **Disabled Active Window Border (Focus Ring):**
   * *Location:* Line 159 inside `layout { focus-ring { ... } }`
   * *Change:* Uncommented `off`.
   ```kdl
   layout {
       focus-ring {
           off
           width 4
           active-color "#7fc8ff"
           inactive-color "#505050"
       }
   }
   ```

2. **Enabled Window Rounded Corners:**
   * *Location:* Line 344 inside `window-rule`
   * *Change:* Removed KDL node comment prefix `/-` to activate the rule with 12px radius.
   ```kdl
   window-rule {
       geometry-corner-radius 12
       clip-to-geometry true
   }
   ```

3. **Enabled `prefer-no-csd`:**
   * *Location:* Line 286
   * *Change:* Uncommented `prefer-no-csd`.
   ```kdl
   prefer-no-csd
   ```
   * *Purpose:* Instructs Wayland client applications to omit client-side decorations/borders, avoiding visual artifacts and ensuring corners clip cleanly to Niri's rounded radius.

### How to Reload / Verify:
* **Validation:** `niri validate`
* **Live Reload:** `niri msg action load-config-file`

---

## [2026-09-27] Default Terminal & Ghostty Theme Configuration

* **Target Files:**
  * `~/.config/niri/config.kdl`
  * `~/.config/ghostty/config`
  * `~/.bashrc`
* **Reason / Request:** Make Ghostty the default terminal emulator across the environment and compositor shortcuts, and apply a color theme (Catppuccin Mocha) with seamless borderless window styling.

### Changes Made:

1. **Configured Ghostty Theme & Settings:**
   * *Target File:* `~/.config/ghostty/config`
   * *Change:* Created configuration with theme `Catppuccin Mocha` and borderless styling:
   ```ini
   # Color theme
   theme = Catppuccin Mocha

   # Font settings
   font-size = 11

   # Window styling
   window-decoration = false
   window-padding-x = 12
   window-padding-y = 12
   ```

2. **Changed Default Terminal Shortcut in Niri:**
   * *Target File:* `~/.config/niri/config.kdl` (Line 365)
   * *Change:* Changed `Mod+T` spawn action from `alacritty` to `ghostty`:
   ```kdl
   Mod+T hotkey-overlay-title="Open a Terminal: ghostty" { spawn "ghostty"; }
   ```

3. **Set Default Terminal Environment Variable:**
   * *Target File:* `~/.bashrc`
   * *Change:* Added `export TERMINAL="ghostty"`.

### How to Reload / Verify:
* **Test Shortcut:** Press `Mod+T` (Super+T) to launch Ghostty.
* **Test Ghostty Config:** `ghostty +validate-config`
* **Test Shell Env:** Open a terminal and run `echo $TERMINAL` (should output `ghostty`).
* **Revert:**
  * Restore `spawn "alacritty"` in `~/.config/niri/config.kdl`.
  * Remove `export TERMINAL="ghostty"` from `~/.bashrc`.
  * Remove or edit `~/.config/ghostty/config`.

---

## [2026-09-27] Ghostty Theme: TokyoNight

* **Target File:** `~/.config/ghostty/config`
* **Reason / Request:** Switch Ghostty terminal theme from Catppuccin Mocha to TokyoNight, and trigger live config reload on the running instance.

### Changes Made:
* *Location:* Line 5 in `~/.config/ghostty/config`
* *Change:* Updated `theme` setting:
```ini
theme = TokyoNight
```
* *Colors Applied:*
  * Background: `#1a1b26` (classic TokyoNight deep blue-gray)
  * Foreground: `#c0caf5`
  * Selection: `#33467c`

### How to Reload / Verify:
* **Live Reload (Hotkeys):** Press `Ctrl+Shift+,` inside Ghostty to reload configuration.
* **DBus Trigger:** `busctl --user call com.mitchellh.ghostty /com/mitchellh/ghostty org.gtk.Actions Activate sava\{sv\} "reload-config" 0 0`
* **Verify Config:** `ghostty +show-config | grep theme`

---

## [2026-09-27] Default Shell: Fish Shell Configuration

* **Target Files:**
  * `~/.config/ghostty/config`
  * `~/.config/fish/config.fish`
* **Reason / Request:** Make Fish (`/usr/bin/fish`) the default shell for terminal sessions and configure Fish environment variables and PATH.

### Changes Made:

1. **Configured Ghostty Default Shell:**
   * *Target File:* `~/.config/ghostty/config`
   * *Change:* Added `command = /usr/bin/fish`. Every new Ghostty terminal window and tab directly opens Fish.
   ```ini
   # Default Shell
   command = /usr/bin/fish
   ```

2. **Configured Fish Environment & PATH:**
   * *Target File:* `~/.config/fish/config.fish`
   * *Change:* Added `~/.local/bin` to Fish PATH and set `TERMINAL`:
   ```fish
   # User PATH and environment
   fish_add_path /home/sudokid/.local/bin
   set -gx TERMINAL ghostty
   ```

### System-Wide Login Shell (Optional):
* To change the system login shell for all sessions (including TTY / system logins), run:
  ```bash
  chsh -s /usr/bin/fish
  ```
  *(Requires entering your user password).*

### How to Reload / Verify:
* **Verify Ghostty:** Press `Mod+T` to open a new terminal; it should immediately open into Fish (`echo $FISH_VERSION`).
* **Verify Config:** `ghostty +show-config | grep command`
* **Revert:**
  * Remove `command = /usr/bin/fish` from `~/.config/ghostty/config`.
  * If `chsh` was run, revert with `chsh -s /usr/bin/bash`.

---

## [2026-09-27] Graphical Login Screen: Greetd & DMS-Greeter Setup

* **Target Files:**
  * `/etc/greetd/config.toml`
  * `/etc/greetd/niri/config.kdl`
  * `/etc/greetd/niri/dms.kdl`
  * Systemd Service: `greetd.service`
* **Reason / Request:** Set up `greetd` and `dms-greeter` to provide a graphical login screen on boot with DankMaterial aesthetic, automatically launching Niri on successful login.

### Changes Made:

1. **Configured Greetd Default Session:**
   * *Target File:* `/etc/greetd/config.toml`
   * *Config:*
   ```toml
   [terminal]
   vt = 1

   [default_session]
   command = "/usr/bin/dms-greeter --command niri --cache-dir /var/cache/dms-greeter -C /etc/greetd/niri/config.kdl"
   user = "greeter"
   ```

2. **Generated Greeter Niri Environment:**
   * *Target Directory:* `/etc/greetd/niri/`
   * Configured lightweight compositor instance for the greeter UI with disabled hot-corners and black background.

3. **System Permissions & Cache:**
   * Added user `sudokid` to group `greeter`.
   * Ensured `/var/cache/dms-greeter` permissions and cache directories are set up.
   * Ensured `/etc/greetd/config.toml` has readable permissions (`644`).

4. **Enabled Systemd Display Manager:**
   * Enabled `greetd.service` (`systemctl is-enabled greetd.service` -> `enabled`).

### How to Reload / Verify:
* **Verify Service Status:** `systemctl is-enabled greetd.service`
* **Verify Configuration:** `dms-greeter status`
* **Reboot Test:** Reboot the PC to land directly on the graphical login screen.
* **Revert:**
  * `sudo systemctl disable greetd.service`
  * Restore `/etc/greetd/config.toml` to default `agreety`.
---

## [2026-09-29] Dedicated AI Chat Scratchpads (Claude & Gemini)

* **Target Files:**
  * `~/.local/bin/toggle-ai`
  * `~/.config/niri/config.kdl`
  * `~/.local/share/applications/google-gemini.desktop`
* **Reason / Request:** Enable instant access to Claude and Gemini from anywhere in the Niri + Dank Material Shell setup via single keybindings (`Mod+C` for Claude and `Mod+G` for Gemini), opening them as centered floating scratchpads that toggle on/off cleanly.

### Changes Made:

1. **Created Toggle Utility Script (`~/.local/bin/toggle-ai`):**
   * Built a Python script that queries Niri compositor state via `niri msg --json`:
     * If the target AI chat app is not running, it launches it (`claude-desktop` for Claude; `google-chrome-stable --user-data-dir=~/.config/gemini-app --app=https://gemini.google.com` for Gemini).
     * If the app is open and focused on the active workspace, pressing the hotkey hides it to a dedicated `"scratch"` workspace and restores focus to the previous window without closing the app or losing chat history/drafts.
     * If the app is in `"scratch"` or unfocused, pressing the hotkey summons it to the current workspace, floating and centered.
   * Made executable (`chmod +x ~/.local/bin/toggle-ai`).

2. **Configured Niri Floating Window Rules & Scratch Workspace:**
   * *Target File:* `~/.config/niri/config.kdl`
   * Added persistent `workspace "scratch"`.
   * Added floating window rules for `com.anthropic.Claude` and `chrome-gemini.google.com`:
     * `open-floating true`
     * `default-column-width { proportion 0.65; }`
     * `default-window-height { proportion 0.82; }`

3. **Configured Keybindings in Niri:**
   * *Target File:* `~/.config/niri/config.kdl`
   * Bound `Mod+C` to `spawn "toggle-ai" "claude"` with hotkey overlay description.
   * Bound `Mod+G` to `spawn "toggle-ai" "gemini"` with hotkey overlay description.
   * Remapped column centering (`center-column`) from `Mod+C` to `Mod+Shift+C`.

4. **Created Desktop Entry for Google Gemini:**
   * *Target File:* `~/.local/share/applications/google-gemini.desktop`
   * Registered Google Gemini so it appears in Dank Material Shell launcher and desktop app search.

### How to Reload / Verify:
* **Verify Claude:** Press `Mod+C` (Super+C). Claude Desktop opens as a centered floating window. Press `Mod+C` again to hide it.
* **Verify Gemini:** Press `Mod+G` (Super+G). Gemini opens as a centered floating window. Press `Mod+G` again to hide it.
* **Verify Centering:** Press `Mod+Shift+C` to center the focused column.
* **Verify Hotkey Overlay:** Press `Mod+Shift+/` to view Claude and Gemini in Niri's hotkey overlay.
* **Revert:**
  * Remove `workspace "scratch"` and window rules from `~/.config/niri/config.kdl`.
  * Restore `Mod+C { center-column; }` and remove `Mod+G` & `Mod+Shift+C`.
  * Delete `~/.local/bin/toggle-ai` and `~/.local/share/applications/google-gemini.desktop`.
  * Reload config: `niri msg action load-config-file`.
---

## [2026-09-29] Keybinding Update: Gemini Scratchpad Shortcut Changed to Mod+P

* **Target File:** `~/.config/niri/config.kdl`
* **Reason / Request:** Update Gemini AI chat toggle shortcut from `Super+G` (`Mod+G`) to `Super+P` (`Mod+P`).

### Changes Made:
* *Location:* Line 594 in `~/.config/niri/config.kdl`
* *Change:* Updated keybind for `toggle-ai gemini`:
```kdl
Mod+P hotkey-overlay-title="AI Chat: Gemini (Toggle)" { spawn "toggle-ai" "gemini"; }
```

### How to Reload / Verify:
* **Verify Gemini:** Press `Mod+P` (`Super+P`). Google Gemini toggles open/closed as a centered floating scratchpad.
* **Live Reload:** `niri msg action load-config-file`
* **Revert:** Change `Mod+P` back to `Mod+G` in `~/.config/niri/config.kdl`.
---

## [2026-09-29] Bugfix: Strict App-ID Matching for AI Scratchpad Windows

* **Target File:** `~/.local/bin/toggle-ai`
* **Reason / Request:** Fix issue where regular Chrome browser windows were being mistakenly detected and toggled into the scratchpad if an open browser tab contained "Gemini" or "Claude" in its page title.

### Changes Made:
* Removed loose window title fallback matching (`title_keyword in title.lower()`).
* Enforced strict Wayland `app_id` regex matching:
  * Claude: strictly matches `^com\.anthropic\.Claude$` (Claude Desktop app).
  * Gemini: strictly matches `^chrome-gemini\.google\.com` (standalone web app with dedicated profile).
* Regular Chrome browser windows (`app_id == "google-chrome"`) are now completely ignored regardless of tab titles.

### How to Reload / Verify:
* Open a browser tab in regular Google Chrome with Gemini or Claude.
* Press `Mod+P` or `Mod+C`.
* Verify that only the dedicated floating scratchpad windows are toggled and your normal browser window remains untouched.
* **Revert:** Re-add title keyword matching to `~/.local/bin/toggle-ai`.
---

## [2026-09-29] LeetCode: Automatic Storage & Git Sync to ~/Desktop/code/leetcode

* **Target Files:**
  * `~/.config/nvim/lua/plugins/leetcode.lua`
  * `~/.gitconfig`
* **Reason / Request:** Automatically save LeetCode problem solutions directly to the git repository at `~/Desktop/code/leetcode`, with automatic git commit and push to GitHub upon exiting LeetCode / Neovim.

### Changes Made:

1. **Configured Git User Identity (`~/.gitconfig`):**
   * Configured global git credentials (`user.name "harsh"`, `user.email "sudoharsh@gmail.com"`, `init.defaultBranch "main"`).
   * Migrated existing solutions (`112.path-sum.cpp`, `118.pascals-triangle.cpp`, `36.valid-sudoku.cpp`, `42.trapping-rain-water.cpp`) into `~/Desktop/code/leetcode` and pushed to GitHub.

2. **Configured leetcode.nvim Storage Location:**
   * *Target File:* `~/.config/nvim/lua/plugins/leetcode.lua`
   * Set `storage.home = vim.fn.expand("~/Desktop/code/leetcode")`.
   * All future problems opened or solved in `leetcode.nvim` are now directly created, edited, and saved in `~/Desktop/code/leetcode/`.

3. **Configured Automatic Git Sync on Exit:**
   * *Target File:* `~/.config/nvim/lua/plugins/leetcode.lua`
   * Added `hooks.leave` in `leetcode.nvim` and `VimLeavePre` autocmd in Neovim.
   * When exiting LeetCode or closing Neovim, if changes are detected, it automatically runs `git add .`, commits with a timestamped message, and pushes to GitHub (`git@github.com:oharsh/leetcode.git`) in the background via detached job.
   * Created manual user command `:LeetCodeSync` to trigger git sync on demand anytime.

### How to Reload / Verify:
* Open any problem in Neovim via `:LeetCode` (or solve an existing one).
* Save with `:w`. File will be present directly in `~/Desktop/code/leetcode/`.
* Exit Neovim with `:qa` (or run `:LeetCodeSync`).
* Check GitHub repository (`https://github.com/oharsh/leetcode`) or run `git -C ~/Desktop/code/leetcode status` to verify commit and push.
* **Revert:** Remove `storage` and `hooks` options from `~/.config/nvim/lua/plugins/leetcode.lua`.
---

## [2026-09-29] Neovim: Bracket Expansion & Newline Handling (<CR> inside {})

* **Target File:** `~/.config/nvim/lua/plugins/blink.lua`
* **Reason / Request:** Fix an issue where pressing `<CR>` (Enter) inside `{}` (or `()`, `[]`) occasionally failed to create an indented newline and push the closing bracket to the next line. This was caused by `blink.cmp`'s default `["<CR>"] = { "accept", "fallback" }` intercepting the Enter key whenever a completion menu or Copilot suggestion was active, as well as strict whitespace matching in `mini.pairs`.

### Changes Made:
* Created plugin specification in `~/.config/nvim/lua/plugins/blink.lua`.
* Added a custom handler to `blink.cmp`'s `["<CR>"]` keymap that runs *before* `"accept"` and `"fallback"`:
  * Detects if the cursor is between matching pairs: `{}` / `()` / `[]` (allowing for optional whitespace).
  * If inside a pair: closes any active completion popup (`cmp.cancel()`) so it does not steal the Enter key, and immediately executes `<CR><C-o>O` to open an indented newline between the braces and push the closing bracket down.
  * If outside a pair: returns `nil` so standard `blink.cmp` behavior (`accept` for autocompletions or normal `<CR>` fallback) continues untouched.

### How to Reload / Verify:
* **Verify in Neovim:**
  1. Open any C++ or code file in Neovim.
  2. In insert mode, type `{` (auto-paired to `{}`).
  3. Press `<CR>` (Enter).
  4. Verify that a new indented line is created between `{` and `}`, pushing `}` down to the following line:
     ```cpp
     {
         |
     }
     ```
  5. Test while completion suggestions/popups are showing to confirm the popup is cancelled and the brackets still expand cleanly.
* **How to Revert (In Case of Any Bug):**
  * Simply delete `~/.config/nvim/lua/plugins/blink.lua`:
    ```bash
    rm ~/.config/nvim/lua/plugins/blink.lua
    ```
  * Restart Neovim.
---

## [2026-09-29] Bugfix: AI Chat Scratchpad (Mod+P / Mod+C) Toggle Visibility & Workspace Conflict

* **Target Files:**
  * `~/.config/niri/config.kdl`
  * `~/.local/bin/toggle-ai`
* **Reason / Request:** Pressing `Mod+P` made the Google Gemini web app visible, but pressing the shortcut again failed to hide it (it remained visible on screen and merely lost focus).
* **Root Cause:**
  1. In `~/.config/niri/config.kdl`, declaring `workspace "scratch"` as the sole named workspace caused Niri to name the primary desktop (workspace 1) `"scratch"`.
  2. When `toggle-ai` attempted to hide the window by moving it to `"scratch"`, it was moving the window back to workspace 1 (the active workspace itself), leaving it on screen.
  3. Furthermore, `toggle-ai` only attempted to hide the window when `is_focused` was True; after the failed move, it transferred focus to another window, leaving the scratchpad visible but unfocused so subsequent shortcut presses only toggled focus back and forth.
* **Changes Made:**
  1. **Removed `workspace "scratch"` declaration from `~/.config/niri/config.kdl`:**
     * Prevents Niri from hijacking workspace index 1 or creating an unintended static workspace. Restores clean, standard dynamic workspaces.
  2. **Updated Hide & Summon Logic in `~/.local/bin/toggle-ai`:**
     * When hiding: moves the window to off-screen dynamic workspace `99` (which places it on the bottommost empty workspace without creating a permanent static workspace, cleanly preserving drafts and chat state in memory), and restores focus to the active window on the current workspace.
     * When summoning: references the active workspace directly by its index (`active_ws_ref = str(active_ws_idx)`), and explicitly passes `--id <win_id>` to `move-window-to-floating`, `center-window`, and `focus-window`.
     * Clean toggle check: If the window is currently visible on the active workspace (`win_ws_id == active_ws_id`), pressing the shortcut hides it immediately. If the window is off-screen (or not running), pressing the shortcut summons and focuses it.

### How to Reload / Verify:
* **Verify Gemini Toggle:**
  1. Press `Mod+P`: Google Gemini appears floating, centered, and focused in the middle of your active workspace.
  2. Press `Mod+P` again: Google Gemini immediately hides off-screen and focus is smoothly returned to your previous window (terminal/browser).
  3. Works across any workspace (e.g. Workspace 1, Workspace 2).
* **Verify Claude Toggle:**
  * Press `Mod+C` to show/hide Claude Desktop using the same mechanism.
* **Live Reload:**
  * `niri msg action load-config-file`
* **Revert:**
  * Revert `~/.local/bin/toggle-ai` to target `"scratch"` and re-add `workspace "scratch"` to `~/.config/niri/config.kdl`.
---

## [2026-09-30] NetworkManager: Wi-Fi Hotspot Band Configuration (2.4 GHz)

* **Target Connection:** NetworkManager connection profile `DankMaterialShell Hotspot`
* **Reason / Request:** Starting the Wi-Fi hotspot failed with supplicant timeout and IP configuration errors.
* **Root Causes Identified:**
  1. **Intel Wi-Fi Regulatory Constraint on 5 GHz:** The Wi-Fi adapter is an Intel AX201 (`iwlwifi` driver). In Linux, Intel firmware enforces Location-Aware Regulatory (LAR) restrictions marking 5 GHz channels as `NO-IR` (No Initiating Radiation), causing `wpa_supplicant` and the kernel to reject hosting an Access Point on 5 GHz (`band: a`, 5220 MHz), throwing `wlo1: Failed to start AP functionality`.
  2. **Missing `dnsmasq` Dependency:** NetworkManager's `ipv4.method=shared` mode relies on the `dnsmasq` binary to assign DHCP leases and route DNS for connected clients. Because `dnsmasq` was not installed, NetworkManager failed at IP configuration with `ip:shared4: could not start dnsmasq: Could not find "dnsmasq" binary`.
* **Changes Made:**
  * Updated `802-11-wireless.band` on `DankMaterialShell Hotspot` from `a` (5 GHz) to `bg` (2.4 GHz):
    ```bash
    nmcli connection modify "DankMaterialShell Hotspot" 802-11-wireless.band bg
    ```
  * Verified that on 2.4 GHz, `wpa_supplicant` successfully creates and starts the Access Point (`Started Wi-Fi Hotspot "baby"`).

### How to Complete Setup & Verify:
* **Install required DHCP dependency:**
  ```bash
  sudo pacman -S dnsmasq
  ```
  *(Note: You do not need to enable the `dnsmasq.service` systemd unit; NetworkManager invokes the binary automatically when the hotspot starts).*
* **Start Hotspot:**
  * Click the Hotspot toggle in DankMaterialShell Control Center or run:
    ```bash
    nmcli connection up "DankMaterialShell Hotspot"
    ```
* **Revert:**
  ```bash
  nmcli connection modify "DankMaterialShell Hotspot" 802-11-wireless.band a
  ```
---

## [2026-10-02] Font Installation: JetBrains Mono Nerd Font, Hack Nerd Font & Chrome Tofu Glyph Fix

* **Target Directories:**
  * `~/.local/share/fonts/JetBrainsMonoNerd/`
  * `~/.local/share/fonts/HackNerd/`
  * `~/.local/share/fonts/NotoEmoji/`
  * `~/.local/share/fonts/NotoSans/`
  * `~/.local/share/fonts/WenQuanYi/`
* **Reason / Request:**
  1. Install JetBrains Mono Nerd Font and Hack Nerd Font so the user can compare and choose the preferred coding font.
  2. Diagnose and fix character boxes ("tofu") rendering in Google Chrome.
  3. Diagnose Wi-Fi hotspot startup failure.
* **Root Causes Identified:**
  1. **Chrome Box ("Tofu") Characters:** The system initially only had basic Adwaita and Liberation fonts installed, lacking color emoji fonts (`fc-match emoji` fell back to `AdwaitaMono`), Unicode symbol fonts, and CJK fonts. When Chrome encountered emojis or multilingual/special symbols on web pages, it lacked fallback glyphs and rendered empty rectangle boxes.
  2. **Hotspot Failure:** Wi-Fi Access Point radio initialization succeeded on 2.4 GHz (`Started Wi-Fi Hotspot "baby"`), but NetworkManager's shared IPv4 mode (`ipv4.method=shared`) failed at IP configuration with `ip:shared4: could not start dnsmasq: Could not find "dnsmasq" binary` because the `dnsmasq` package is not installed on Arch Linux.
* **Changes Made:**
  1. Installed **JetBrains Mono Nerd Font** (96 variants including Mono, Propo, ligatures, and no-ligature NL styles across all weights) to `~/.local/share/fonts/JetBrainsMonoNerd/`.
  2. Installed **Hack Nerd Font** (12 variants including Regular, Bold, Italic, Bold Italic, Mono, and Propo) to `~/.local/share/fonts/HackNerd/`.
  3. Installed **Noto Color Emoji** to `~/.local/share/fonts/NotoEmoji/` to provide complete Unicode color emoji coverage.
  4. Installed **Noto Sans / Noto Serif** (621 font files) to `~/.local/share/fonts/NotoSans/` for comprehensive international Unicode and symbol glyph coverage.
  5. Installed **WenQuanYi Micro Hei** to `~/.local/share/fonts/WenQuanYi/` for CJK (Chinese, Japanese, Korean) glyph coverage.
  6. Refreshed fontconfig cache (`fc-cache -fv ~/.local/share/fonts`).
  7. Verified font matches:
     * `fc-match emoji` -> `NotoColorEmoji.ttf: "Noto Color Emoji" "Regular"`
     * `fc-match "JetBrainsMono Nerd Font"` -> `JetBrainsMonoNerdFont-Regular.ttf`
     * `fc-match "Hack Nerd Font"` -> `HackNerdFont-Regular.ttf`

### How to Verify & Use:
* **Google Chrome:** Refresh web pages or restart Chrome; emojis and special characters will now render cleanly without boxes.
* **Ghostty Terminal Font Configuration:**
  In `~/.config/ghostty/config`, set:
  ```ini
  # Option 1: JetBrains Mono Nerd Font
  font-family = "JetBrainsMono Nerd Font"

  # Option 2: Hack Nerd Font
  font-family = "Hack Nerd Font"
  ```
* **Hotspot Activation:**
  Install the missing DHCP/DNS binary:
  ```bash
  sudo pacman -S dnsmasq
  ```
  Then start the hotspot via DankMaterialShell Control Center or run:
  ```bash
  nmcli connection up "DankMaterialShell Hotspot"
  ```

### Revert:
* To remove the user-installed fonts:
  ```bash
  rm -rf ~/.local/share/fonts/{JetBrainsMonoNerd,HackNerd,NotoEmoji,NotoSans,WenQuanYi}
  fc-cache -fv
  ```
---

## [2026-10-16] Dedicated Web Scratchpad: Todoist Enhanced (Week View) on Mod+N

* **Target Files:**
  * `~/.local/bin/toggle-ai`
  * `~/.local/bin/toggle-scratchpad`
  * `~/.config/niri/config.kdl`
  * `~/.local/share/applications/todoist-enhanced.desktop`
* **Reason / Request:** Open Todoist Enhanced (`https://todoistenhanced.julesbertolino.fr/#/week`) in a separate floating window summoned/hidden by pressing `Mod+N`, matching the toggle scratchpad behavior of Gemini (`Mod+P`) and Claude (`Mod+C`).

### Changes Made:

1. **Extended Scratchpad Toggle Script (`~/.local/bin/toggle-ai`):**
   * Added target `todoist` (aliases: `todoist-enhanced`, `todoistenhanced`, `week`):
     * Runs Google Chrome in standalone web-app mode (`--app=https://todoistenhanced.julesbertolino.fr/#/week`) with a dedicated isolated profile directory (`~/.config/todoistenhanced-app`).
     * Automatically initializes Chrome first-run markers (`First Run`, `EULA Accepted`) and passes `--no-first-run --no-default-browser-check` so the web app launches directly into the week view without welcome prompts or profile setup modals.
     * Enforces strict Wayland `app_id` matching (`^chrome-todoistenhanced\.julesbertolino\.fr`) to isolate the scratchpad window from regular Chrome browser windows (`google-chrome`) and the desktop Todoist AppImage (`todoist`).
     * Added `clean_stale_singleton` helper to remove stale `SingletonLock` / `SingletonSocket` / `SingletonCookie` links when launching if Chrome had previously terminated abruptly.
   * Created symlink `~/.local/bin/toggle-scratchpad -> ~/.local/bin/toggle-ai`.

2. **Configured Niri Window Rules & Hotkey:**
   * *Target File:* `~/.config/niri/config.kdl`
   * Added window-rule for `chrome-todoistenhanced.julesbertolino.fr`:
     * `open-floating true`
     * `default-column-width { proportion 0.75; }` (wider view optimal for 7-day week schedule)
     * `default-window-height { proportion 0.85; }`
     * Corner radius (12px) automatically clipped by Niri's geometry rule.
   * Bound `Mod+N` to `spawn "toggle-ai" "todoist"` with hotkey overlay description `"Todoist: Week (Toggle)"`.
   * Reloaded Niri configuration via `niri msg action load-config-file`.

3. **Created Desktop Entry:**
   * *Target File:* `~/.local/share/applications/todoist-enhanced.desktop`
   * Allows launching or focusing Todoist Enhanced via Dank Material Shell launcher, app search, or taskbar with the Todoist icon.

### How to Reload / Verify:
* **Verify Keybind:** Press `Mod+N` (Super+N). Todoist Enhanced opens centered and floating in week view.
* **Verify Toggle:** Press `Mod+N` again while visible. It hides to the off-screen scratch workspace and restores focus to your previous window. Press `Mod+N` once more to summon it back centered and focused.
* **Verify Config & Hotkey Overlay:** Press `Mod+Shift+/` to see "Todoist: Week (Toggle)" listed in Niri's shortcuts.
* **Revert:**
  * Remove `Mod+N` and the window-rule from `~/.config/niri/config.kdl`.
  * Delete `~/.local/share/applications/todoist-enhanced.desktop` and `~/.local/bin/toggle-scratchpad`.
  * Revert `todoist` case in `~/.local/bin/toggle-ai`.
  * Reload Niri: `niri msg action load-config-file`.

---

## [2026-10-25] Fix Claude Desktop Persistent Logout (Keyring / SafeStorage Configuration)

* **Target Files:**
  * `~/.config/claude-desktop-flags.conf`
  * `~/.config/autostart/claude-desktop.desktop`
* **Reason / Request:** Fix issue where Claude Desktop constantly logs out between restarts or system reboots.

### Root Cause:
1. `~/.config/claude-desktop-flags.conf` was configured with `--password-store=basic`. Under Chromium/Electron, `basic` sets the storage backend to unencrypted `basic_text`.
2. Electron's `safeStorage.isEncryptionAvailable()` returns `false` when `basic_text` is used.
3. Claude Desktop explicitly checks `safeStorage.isEncryptionAvailable()` at startup. When `false`, it logs:
   `[safeStorage] isEncryptionAvailable=false on linux at startup (backend=basic_text) — session will not persist; app secrets fall back to plaintext`
   and prevents authentication session tokens and cookies from persisting across application restarts.
4. Additionally, `~/.config/autostart/claude-desktop.desktop` had a hardcoded `Exec="/usr/lib/claude-desktop/claude-desktop" --startup`, bypassing the `/usr/bin/claude-desktop` launcher script and its flag loader.

### Changes Made:

1. **Configured Secure Storage Flag:**
   * *Target File:* `~/.config/claude-desktop-flags.conf`
   * Replaced `--password-store=basic` with `--password-store=gnome-libsecret`:
   ```conf
   # Configuration flags for Claude Desktop on Linux
   # Use GNOME Keyring / libsecret for secure storage of session tokens and cookies.
   --password-store=gnome-libsecret
   ```
   * Enables Electron's `safeStorage` to encrypt credentials using the unlocked `gnome-keyring` Secret Service daemon (`Claude Safe Storage` entry).

2. **Updated Autostart Entry:**
   * *Target File:* `~/.config/autostart/claude-desktop.desktop`
   * Changed `Exec` command to use the launcher script:
   ```desktop
   [Desktop Entry]
   Type=Application
   Name=Claude
   Exec=claude-desktop --startup
   X-GNOME-Autostart-enabled=true
   ```

### How to Reload / Verify:
* **Verify safeStorage Status:** Check `~/.config/Claude/logs/main.log`; the warning `[safeStorage] isEncryptionAvailable=false` will no longer appear on startup.
* **Verify Persistence:**
  1. Complete login once in the Claude window.
  2. Close Claude (`pkill -f claude-desktop`) and summon it again (`Mod+C`).
  3. Claude will open directly into your authenticated session without requiring you to log in again.
* **Revert:**
  * Change `--password-store=gnome-libsecret` back to `--password-store=basic` in `~/.config/claude-desktop-flags.conf`.
  * Restore `Exec="/usr/lib/claude-desktop/claude-desktop" --startup` in `~/.config/autostart/claude-desktop.desktop`.

---

## [2026-10-30] Run-or-Raise Application Launcher for Niri (Fuzzel Integration)

* **Target Files:**
  * `~/.local/bin/niri-run-or-raise`
  * `~/.config/niri/dms/binds.kdl`
  * `~/.config/niri/config.kdl`
* **Reason / Request:** Prevent `Mod+Y` (and `Mod+D`) from opening duplicate windows when an instance of an application (such as Chrome) is already open; raise and focus the existing window instead, while allowing `Ctrl` (`Ctrl+Enter` or `Mod+Ctrl+Y`) to always force a new instance.

### Changes Made:

1. **Created `~/.local/bin/niri-run-or-raise`:**
   * Runs `fuzzel` with custom launch-prefix and custom keybinding:
     * Overrides `key-bindings.custom-1` with `Control+Return Control+KP_Enter` (exit code `10`).
     * Normal selection via `Return` (exit code `0`).
   * On normal selection (`Return`):
     * Parses the selected desktop file's ID, `StartupWMClass`, application name, and binary name.
     * Queries running Niri windows (`niri msg -j windows`) to check if a matching window exists.
     * If an existing window is found: Focuses it using `niri msg action focus-window --id <ID>` (cycling to the next instance if the window is already focused).
     * If no existing window is found: Launches a new instance.
   * On forced new instance (`Control+Return` in Fuzzel, or invoked with `--force-new`):
     * Directly spawns a fresh application instance (passing `--new-window` for browsers/editors like Chrome, Chromium, VS Code, and Nautilus).

2. **Updated Niri Keybindings:**
   * `~/.config/niri/dms/binds.kdl`:
     * Changed `Mod+Y` to spawn `niri-run-or-raise`.
     * Added `Mod+Ctrl+Y` to spawn `niri-run-or-raise --force-new`.
   * `~/.config/niri/config.kdl`:
     * Changed `Mod+D` to spawn `niri-run-or-raise`.
     * Added `Mod+Ctrl+D` to spawn `niri-run-or-raise --force-new`.

### How to Reload / Verify:
* **Reload Config:** `niri msg action load-config-file`
* **Verify Raise Behavior:**
  * Open Chrome or a terminal, switch focus elsewhere, press `Mod+Y`, type `chrome`, and press `Enter`. The running Chrome window is focused.
* **Verify Force New Instance:**
  * Press `Mod+Y`, type `chrome`, and press `Ctrl+Enter` (or press `Mod+Ctrl+Y` directly). A new Chrome window opens.
* **Revert:**
  * In `~/.config/niri/dms/binds.kdl`, restore `Mod+Y hotkey-overlay-title="Run an Application: fuzzel" { spawn "fuzzel"; }` and remove `Mod+Ctrl+Y`.
  * In `~/.config/niri/config.kdl`, restore `Mod+D hotkey-overlay-title="Run an Application: fuzzel" { spawn "fuzzel"; }` and remove `Mod+Ctrl+D`.
  * Delete `~/.local/bin/niri-run-or-raise`.

---

## [2026-11-03] NetworkManager: Wi-Fi Hotspot 5 GHz Channel Configuration

* **Target File / Setting:** NetworkManager connection profile `DankMaterialShell Hotspot` (in `/etc/NetworkManager/system-connections/`)
* **Reason / Request:** Wi-Fi hotspot was failing to activate with error `supplicant-timeout` / `Failed to start AP functionality`. Under regional regulatory rules (India / `IN`) and Intel `iwlwifi` restrictions on the AX201 card, automatic 5 GHz channel selection picked frequency 5220 MHz (channel 44) which has the `NO-IR` (No Initiating Radiation) flag.

### Changes Made:
* Configured explicit 5 GHz channel `149` (5745 MHz), which is permitted for Access Point (AP) mode on this hardware and regulatory domain:
  ```bash
  nmcli connection modify "DankMaterialShell Hotspot" 802-11-wireless.band a 802-11-wireless.channel 149
  ```

### How to Reload / Verify:
* **Verify Configuration:**
  ```bash
  nmcli -f 802-11-wireless.band,802-11-wireless.channel connection show "DankMaterialShell Hotspot"
  ```
* **Verify Status:**
  ```bash
  nmcli device status
  ```
  `wlo1` will show `connected` to `DankMaterialShell Hotspot`.
* **Revert:**
  ```bash
  nmcli connection modify "DankMaterialShell Hotspot" 802-11-wireless.band a 802-11-wireless.channel 0
  ```

---

## [2026-11-05] Ghostty: Disable Confirmation Dialog on Window/Tab Close

* **Target File:** `~/.config/ghostty/config`
* **Reason / Request:** Disable the confirmation pop-up dialog that prompts for user confirmation whenever closing a Ghostty terminal window or tab.

### Changes Made:
* Added `confirm-close-surface = false` under `# Behavior` in `~/.config/ghostty/config`:
  ```ini
  # Behavior
  confirm-close-surface = false
  ```
* Ghostty now closes terminal surfaces immediately without prompting for confirmation.

### How to Reload / Verify:
* **Verify Config:**
  ```bash
  ghostty +show-config | grep confirm-close-surface
  ```
  (Outputs `confirm-close-surface = false`).
* **Live Reload:**
  Press `Ctrl+Shift+,` inside Ghostty or run:
  ```bash
  busctl --user call com.mitchellh.ghostty /com/mitchellh/ghostty org.gtk.Actions Activate sava\{sv\} "reload-config" 0 0
  ```
* **Verify Behavior:** Close a terminal window (e.g., `Mod+B`, `Ctrl+Shift+W`, or the window close action); it closes immediately without showing a confirmation prompt.
* **Revert:**
  Remove `confirm-close-surface = false` (or set it to `true`) in `~/.config/ghostty/config`.


---

## [2026-11-07] Niri: Added Fuzzy File Search & Opener (Mod+Shift+Y / Mod+Shift+D)

* **Target Files:**
  * `~/.local/bin/niri-file-search`
  * `~/.config/niri/config.kdl`
* **Reason / Request:** Provide a direct fuzzy search shortcut to find and open files instantly without opening the file manager via `Mod+Y` and manually browsing folders.

### Changes Made:
* Created executable helper script [`~/.local/bin/niri-file-search`](file:///home/sudokid/.local/bin/niri-file-search):
  * Uses `fd` to quickly scan `$HOME` for files and folders while cleanly ignoring caches, browser profiles, build artifacts, and heavy dependency directories.
  * Launches `fuzzel --dmenu` on the currently focused Niri monitor output matching the desktop theme.
  * **Enter**: Opens the selected file or directory directly in its default application via `xdg-open`.
  * **Ctrl+Enter**: Reveals and highlights the selected file or folder in Nautilus (`nautilus --select`).
* Added keybindings in [`~/.config/niri/config.kdl`](file:///home/sudokid/.config/niri/config.kdl):
  ```kdl
  Mod+Shift+Y hotkey-overlay-title="Fuzzy Search & Open File" { spawn "niri-file-search"; }
  Mod+Shift+D hotkey-overlay-title="Fuzzy Search & Open File" { spawn "niri-file-search"; }
  ```
* Reloaded Niri configuration via `niri msg action load-config-file`.

### How to Verify or Revert:
* **Verify:**
  1. Press `Mod+Shift+Y` (or `Mod+Shift+D`).
  2. The fuzzy finder overlay will appear on your active screen.
  3. Type to search for any document, PDF, image, script, or configuration file.
  4. Press <kbd>Enter</kbd> to open directly with its default app, or <kbd>Ctrl+Enter</kbd> to reveal it in Nautilus.
* **Revert:**
  1. Remove the `Mod+Shift+Y` and `Mod+Shift+D` lines from [`~/.config/niri/config.kdl`](file:///home/sudokid/.config/niri/config.kdl).
  2. Run `niri msg action load-config-file`.
  3. Remove [`~/.local/bin/niri-file-search`](file:///home/sudokid/.local/bin/niri-file-search).


---

## [2026-11-07] Niri: Remapped Fuzzy File Search Shortcut to Mod+. (Mod+Period)

* **Target File:** `~/.config/niri/config.kdl`
* **Reason / Request:** Update shortcut for fuzzy file search (`niri-file-search`) to `Mod + .`.

### Changes Made:
* Bound `Mod+Period` to `niri-file-search`:
  ```kdl
  Mod+Period hotkey-overlay-title="Fuzzy Search & Open File" { spawn "niri-file-search"; }
  ```
* Re-mapped the previous `Mod+Period` action (`expel-window-from-column`) to `Mod+Shift+Period` to avoid key conflicts.
* Reloaded Niri configuration via `niri msg action load-config-file`.

### How to Verify or Revert:
* **Verify:** Press `Mod + .` (Super + Period). The file search overlay appears immediately.
* **Revert:** In `~/.config/niri/config.kdl`, restore `Mod+Period` to `expel-window-from-column` and remove `Mod+Period` from the program spawn section.


---

## [2026-11-10] Home Directory Reorganization

* **Target:** `~/Downloads`, `~/Documents`, `~/Pictures`, `~/builds/aur`, `~/Projects`
* **Reason / Request:** Organize files in the home directory.

### Changes Made:
* Moved AUR build dirs `~/google-chrome`, `~/paru`, `~/yay` → `~/builds/aur/` (PKGBUILDs + .git kept; `pkg/`, `src/`, built packages and source tarballs deleted, ~1.7 GB freed).
* Moved `~/report-isro.html/` (folder) → `~/Projects/report-isro/`.
* Sorted Downloads into `~/Documents/College/{Algorithms,AC,APL,CS6530,GN-Course,Final-Project}` (AlgoZenith zips → `College/Algorithms/algozenith/`).
* Personal PDFs → `~/Documents/Personal/`; `LPL_FINANCIAL.pdf` → `~/Documents/Finance/`; `tryhackme.ovpn` → `~/Documents/Security/`; `wip12-wallpaper.zip` → `~/Pictures/Wallpapers/`.
* Deleted: duplicate `DocScanner 9 Nov 2026 23-11.pdf` (same md5 as Assignment1.pdf), already-extracted CS6530 submission zip, `__MACOSX/` folders, LaTeX `.aux/.log/.out` in Final-Project.

### How to Verify or Revert:
* **Verify:** `ls ~/Documents/College ~/builds/aur`; `~/Downloads` is empty.
* **Revert:** `mv` items back to original paths. AUR artifacts can be regenerated with `makepkg` in each `~/builds/aur/<pkg>`; deleted files are not recoverable.


---

## [2026-11-15] Kitty: Matched Color Scheme to Neovim (Material Deep Ocean)

* **Target File(s):** [`~/.config/kitty/current-theme.conf`](file:///home/sudokid/.config/kitty/current-theme.conf), [`~/.config/kitty/kitty.conf`](file:///home/sudokid/.config/kitty/kitty.conf)
* **Reason / Request:** Change Kitty terminal colors to match Neovim's active colorscheme (`material.nvim` configured with the "deep ocean" style).

### Changes Made:
* Backed up previous theme (`Tokyo Night`) to [`~/.config/kitty/current-theme.conf.tokyonight.bak`](file:///home/sudokid/.config/kitty/current-theme.conf.tokyonight.bak).
* Configured [`~/.config/kitty/current-theme.conf`](file:///home/sudokid/.config/kitty/current-theme.conf) with the Material Deep Ocean palette matching Neovim:
  * **Background:** `#0f111a` (exact match to Neovim `Normal` background)
  * **Foreground:** `#a6accd` (exact match to Neovim `Normal` foreground)
  * **Cursor:** `#ffcc00` with text color `#0f111a` (matching Neovim cursor)
  * **Selection:** Background `#1f2233`, Foreground `#eeffff` (matching Neovim visual highlight)
  * **Tabs & Borders:** Active border/tab `#84ffff`, inactive `#1a1c25` / `#232637`
  * **Terminal ANSI Colors:** Full 16-color palette aligned with `material.nvim`'s terminal color mappings (Normal: dark red, dark green, dark yellow, dark blue, dark purple, dark cyan, fg; Bright: red, green, yellow, blue, purple, cyan, white).
* Updated theme comment in [`~/.config/kitty/kitty.conf`](file:///home/sudokid/.config/kitty/kitty.conf) to `Material Deep Ocean`.
* Triggered instant live reload across running Kitty instances via `pkill -USR1 kitty`.

### How to Verify or Revert:
* **Verify:**
  1. Open a new Kitty window or observe existing Kitty terminals; background and text will seamlessly blend with Neovim (`nvim`).
  2. The cursor appears in the signature Material gold/yellow (`#ffcc00`).
* **Revert:**
  1. Restore the backup: `cp ~/.config/kitty/current-theme.conf.tokyonight.bak ~/.config/kitty/current-theme.conf`
  2. Reload configuration: `pkill -USR1 kitty`


---

## [2026-11-15] Authored Self-Study Book: Linux Troubleshooting & Desktop Tools

* **Target File(s):** [`~/Documents/linux-troubleshooting-and-desktop-tools.pdf`](file:///home/sudokid/Documents/linux-troubleshooting-and-desktop-tools.pdf), [`~/Documents/linux-book-src/`](file:///home/sudokid/Documents/linux-book-src/)
* **Reason / Request:** Executed the detailed self-study guide plan defined in `~/Documents/i-want-to-try-magical-cook.md`.

### Changes Made:
* Authored a 100-page, publication-grade self-study guide (PDF) formatted for print with table of contents, code syntax blocks, callout boxes, and verified command traces.
* **Part A (The System):** Complete coverage of the Filesystem Hierarchy Standard, 6-stage boot sequence from UEFI to Wayland, init system evolution, systemd units and cgroups, process lifecycles (`fork`/`exec`/`wait`/`setsid`), IPC primitives, daemons vs. timers, kernel modules, input subsystems, system fundamentals, journald logging, hardware diagnostics, and a 5-step debugging methodology.
* **Part B (Desktop Tools):** Detailed worked case studies of four tools on this machine: prefix-free Tmux with Material Deep Ocean theme, floating `file-search` picker, Kitty graphics `app-search` launcher, and Quickshell screensaver & PAM lock screen. Includes autopsies of real bugs encountered during development.
* **Part C (The Technology):** Wayland architecture and Niri compositor, Qt 6 & QML from scratch with line-by-line code walkthroughs, layer-shell, session-lock protocol, terminal UI engineering, and PAM security.
* **Part D (Reference & Practice):** Diagnostic cheat sheets, 25 safe hands-on exercises, a 3-week holiday study plan, curated community references, complete tool source code listings, compilable C/Python examples, and an architectural glossary.
* **Runnable Code Examples:** Created and verified runnable C and Python source files in [`~/Documents/linux-book-src/examples/`](file:///home/sudokid/Documents/linux-book-src/examples/) (`fork_exec.c`, `pipe_demo.c`, `signals_demo.c`, `unix_socket_server.py`, `unix_socket_client.py`, `uinput_mouse_demo.py`, `hello_module.c`, `Makefile`, `my-backup.service`, `my-backup.timer`).
* Compiled the final PDF via Chromium headless to [`~/Documents/linux-troubleshooting-and-desktop-tools.pdf`](file:///home/sudokid/Documents/linux-troubleshooting-and-desktop-tools.pdf).

### How to Verify or Revert:
* **Verify:**
  1. Inspect the compiled PDF with `pdfinfo ~/Documents/linux-troubleshooting-and-desktop-tools.pdf` (confirms 100 pages, Skia/PDF output).
  2. Open the book in your default PDF viewer (e.g. `zathura ~/Documents/linux-troubleshooting-and-desktop-tools.pdf`).
  3. Inspect the source HTML and build script in `~/Documents/linux-book-src/`.
* **Revert:**
  1. Delete generated files: `rm -rf ~/Documents/linux-troubleshooting-and-desktop-tools.pdf ~/Documents/linux-book-src/`

---

## [2026-11-17] Niri: Shortcut Remap (Lock → Mod+', File Search → Mod+/) & Tab Navigation in Pickers

* **Files:** `~/.config/niri/dms/binds.kdl`, `~/.config/niri/config.kdl`, `~/.local/bin/file-search`, `~/.local/bin/app-search`
* **Changes:**
  * Lock screen: `Mod+/` → `Mod+'` (`Mod+Apostrophe`).
  * Fuzzy file search: `Mod+.` → `Mod+/` (`Mod+Period` is now free).
  * `file-search` (Mod+/) and `app-search` (Mod+Y): `Tab` moves selection down, `Shift+Tab` up (wraps around via `--cycle`).

* **Follow-up (2026-11-17):** `Mod+.` restored to niri default `expel-window-from-column`.

## [2026-11-17] file-search: `kind:query` filter

* **File:** `~/.local/bin/file-search`
* Typing e.g. `pdf:report` limits results to that kind of file and fuzzy-matches `report` among them. Kinds: `pdf doc sheet slides img video audio code text zip dir`; any other word is treated as a file extension (`sh:backup`, `kdl:`). The file list is cached in `$XDG_RUNTIME_DIR/file-search.list`; filtered results are produced by `file-search --filter`, via fzf's `change` hook (`--on-change`). Match highlighting is not shown while a prefix is active.
