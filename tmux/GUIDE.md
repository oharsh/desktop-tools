TMUX GUIDE                                   (Alt-? opens this, q closes, / searches)
════════════════════════════════════════════════════════════════════════════════

THE IDEA
  Session  = one project / context          (survives closing kitty, even reboots)
  Window   = a tab inside a session
  Pane     = a split inside a window

  Every daily action is ONE chord: hold Alt with one hand, tap a key with the
  other. No prefix. The prefix still exists as a fallback: Ctrl-Space.

START
  t            attach to (or create) the session "main"
  t work       attach to / create / switch to a session called "work"
  tp           fuzzy-pick a session or project folder (outside tmux)
  tl           list sessions            tk NAME   kill a session
  Detach with Ctrl-Space d — everything keeps running. Type `t` to come back.


CHEAT SHEET
────────────────────────────────────────────────────────────────────────────────
PANES
  Alt-Enter      smart split: halves the current pane along its longer side
  Alt-\          split side by side          Alt--          split stacked
  Alt-h/j/k/l    move left/down/up/right     Alt-H/J/K/L    resize (hold to repeat)
  Alt-z          zoom pane full-screen (again to restore)
  Alt-=          cycle layouts               Alt-x          close pane
  Alt-y          type into ALL panes at once (SYNC shows in the bar; again = off)

WINDOWS
  Alt-n          new window (same folder)    Alt-1 … Alt-9  jump to window N
  Alt-i / Alt-o  previous / next             Alt-a          last window (toggle)
  Alt-< / Alt->  move window left / right    Alt-r          rename
  Alt-X          close window (asks first)

SESSIONS
  Alt-g          GO: fuzzy picker of sessions + project folders
  Alt-q          last session (toggle)       Alt-( / Alt-)  previous / next
  Alt-w          tree overview of everything (x kills, enter jumps)
  Alt-R          rename session

POPUPS
  Alt-t          floating scratch terminal; Alt-t again hides it, state is kept
  Alt-G          lazygit for the current folder
  Alt-?          this guide

COPY / SCROLLBACK   (vi keys)
  Alt-v          enter copy mode             Alt-/          search scrollback now
  v  select      Ctrl-v  block select        y   copy to clipboard and exit
  [  /  ]        jump to previous / next shell prompt
  n / N          next / previous match       q or Esc   leave
  Mouse: drag to copy, wheel to scroll, drag borders to resize, click to focus.
  Paste: Ctrl-Shift-v (kitty) as usual.

OTHER
  F12            turn ALL tmux keys off/on (bar shows KEYS OFF)
  Ctrl-Space r   reload config               Ctrl-Space ?   list every binding
  Ctrl-Space I   install plugins             Ctrl-Space U   update plugins
  Ctrl-Space Ctrl-s / Ctrl-r   save / restore all sessions by hand


PRODUCTIVITY HACKS
────────────────────────────────────────────────────────────────────────────────
 1. One session per project, never per task.
    Alt-g, type three letters of a folder under ~/Projects, ~/code, ~/builds or
    ~/.config, Enter. A session named after the folder opens in that folder. Do it
    again later and you land back in the same session. Add your own folders in
    ~/.config/tmux/scripts/sessionizer (the ROOTS line).

 2. Alt-q and Alt-a are your Alt-Tab.
    Two projects? Alt-q flips between them. Editor and tests? Alt-a flips windows.
    You will use these two more than everything else combined.

 3. Give windows fixed jobs.
    1 = editor, 2 = run/tests, 3 = git/misc. Then Alt-1 / Alt-2 / Alt-3 become
    muscle memory and you never look at the bar.

 4. Zoom instead of rearranging.
    Small pane with a long log? Alt-z, read, Alt-z. The layout is untouched.

 5. Use the scratch popup for one-off commands.
    Alt-t, look something up or run a quick command, Alt-t. It opens in the
    current pane's folder the first time and keeps its history afterwards.

 6. Search output instead of re-running with `| grep`.
    Alt-/ then type and Enter; n jumps to older matches. Press [ to hop back
    prompt by prompt, so "where did that command start" is one key.

 7. Copy without the mouse.
    Alt-v, move with hjkl / w / b, v to select, y to copy. Ctrl-v gives a
    rectangle, good for grabbing one column of a table.

 8. Long job? Detach and walk away.
    Start the build, Ctrl-Space d, close kitty. `t` brings it back. Over ssh
    this means a dropped connection never kills your work.

 9. Watch a background window.
    A dot (●) appears next to a window name when it prints something new, so you
    can leave a build in window 2 and see when it moves.

10. Sync panes for repeated work.
    Split, ssh to several machines (or cd to several repos), Alt-y, type once.

11. Send a pane somewhere else.
    Ctrl-Space !   turn the current pane into its own window
    Ctrl-Space :   then `join-pane -t :2` moves the current pane into window 2
    Ctrl-Space { / }   swap pane with previous / next

12. tmux inside ssh inside tmux.
    Press F12 locally: your keys now go to the remote tmux. F12 again to return.
    Same trick if some program needs an Alt key that tmux is taking.

13. Sessions survive reboots (once plugins are installed).
    Layouts, folders and nvim sessions are saved every 15 minutes and restored
    when tmux first starts. Force a save with Ctrl-Space Ctrl-s.

14. Script your layout.
    A fish function can build a workspace in one command:
        function dev
            tmux new-session -ds dev -c ~/Projects/foo -n code 'nvim'
            tmux new-window  -t dev -n run -c ~/Projects/foo
            tmux split-window -h -t dev:run -c ~/Projects/foo
            t dev
        end

15. Show information in a popup instead of a window.
    Ctrl-Space : then e.g.  display-popup -E htop
    Add your own in tmux.conf by copying the Alt-G line.


KEYS TMUX TAKES FROM FISH
────────────────────────────────────────────────────────────────────────────────
  Alt-h (man page) and Alt-l (ls) now move panes; Alt-v (edit command in nvim)
  enters copy mode — use Alt-e for that instead, it does the same thing.
  Left alone on purpose: Alt-. (last argument), Alt-s (sudo), Alt-e, Alt-b/f/d,
  Alt-arrows. Alt-Enter (newline in the command line) is now the smart split.


OPTIONAL: START TMUX AUTOMATICALLY
────────────────────────────────────────────────────────────────────────────────
  Not enabled. If you decide you want every kitty window inside tmux, add this to
  ~/.config/fish/config.fish inside the `if status is-interactive` block:

      if not set -q TMUX; and test "$TERM" = xterm-kitty
          tmux new-session -A -s main
      end


FILES
────────────────────────────────────────────────────────────────────────────────
  ~/.config/tmux/tmux.conf              all settings and bindings
  ~/.config/tmux/scripts/sessionizer    the Alt-g picker
  ~/.config/fish/conf.d/tmux.fish       t, tp, tl, tk
  Colours follow the kitty theme automatically (the bar uses the terminal palette).
  To swap accent colours edit the Theme section: colour4 = blue, colour5 = magenta.
