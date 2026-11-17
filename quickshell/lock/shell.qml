// Lock screen: the screensaver's clock, date and weather, plus a password field.
//   Mod+/ or Super+Alt+L   lock      (~/.local/bin/lock)
//   type your password, Enter to unlock; Esc clears what you typed
// This is a real lock: the compositor keeps the session locked until the
// password is accepted, even if this program crashes.
// "lock test" shows it for a few seconds and unlocks by itself, no password.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam

ShellRoot {
    id: root

    // ── Settings ─────────────────────────────────────────────────────────────
    readonly property string city: ""            // weather location ("" = detect from your network)
    readonly property bool   fahrenheit: false
    readonly property bool   use24h: true
    readonly property bool   showWeather: true
    // ─────────────────────────────────────────────────────────────────────────

    readonly property bool testMode: Quickshell.env("LOCK_TEST") === "1"
    property string password: ""
    property string state: "idle"        // idle | checking | wrong
    property string notice: ""
    property date   now: new Date()
    property string temperature: ""
    property string conditions: ""

    function unlock() { sessionLock.locked = false; quitSoon.start() }
    function submit() {
        if (state === "checking" || password === "") return
        state = "checking"
        if (!pam.start()) { state = "wrong"; notice = "Could not start the password check"; password = "" }
    }
    function typed(event) {
        if (state === "checking") return
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) submit()
        else if (event.key === Qt.Key_Escape) password = ""
        else if (event.key === Qt.Key_Backspace) password = password.slice(0, -1)
        else if (event.key === Qt.Key_U && (event.modifiers & Qt.ControlModifier)) password = ""
        else if (event.text.length > 0 && event.text.charCodeAt(0) >= 32 && event.text.charCodeAt(0) !== 127) {
            password += event.text
            if (state === "wrong") { state = "idle"; notice = "" }
        }
    }

    PamContext {
        id: pam
        config: "login"              // /etc/pam.d/login — the same check swaylock uses
        onResponseRequiredChanged: if (responseRequired) respond(root.password)
        onCompleted: result => {
            root.password = ""
            if (result === PamResult.Success) { root.unlock(); return }
            root.state = "wrong"
            root.notice = result === PamResult.MaxTries ? "Too many attempts" : "Wrong password"
        }
        onError: error => { root.password = ""; root.state = "wrong"; root.notice = "Password check failed: " + PamError.toString(error) }
    }

    Timer { id: quitSoon; interval: 150; onTriggered: Qt.quit() }
    Timer { running: root.testMode; interval: 3000; onTriggered: root.unlock() }

    Timer {
        running: true
        repeat: true
        interval: 60000 - (Date.now() % 60000) + 50
        onTriggered: { root.now = new Date(); interval = 60000 - (Date.now() % 60000) + 50 }
    }

    Process {
        running: root.showWeather
        command: ["curl", "-fsS", "--max-time", "8",
                  "https://wttr.in/" + encodeURIComponent(root.city) + "?format=%t|%C&" + (root.fahrenheit ? "u" : "m")]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("|")
                if (parts.length === 2 && parts[0].length < 12 && parts[1].length < 40) {
                    root.temperature = parts[0].replace(/^\+/, "")
                    root.conditions = parts[1]
                }
            }
        }
    }

    WlSessionLock {
        id: sessionLock
        locked: true

        WlSessionLockSurface {
            id: surface
            color: "#07080d"

            Item {
                id: keys
                anchors.fill: parent
                focus: true
                Component.onCompleted: forceActiveFocus()
                Keys.onPressed: event => root.typed(event)
            }
            MouseArea { anchors.fill: parent; cursorShape: Qt.BlankCursor; onPressed: keys.forceActiveFocus() }

            LockFace {
                anchors.centerIn: parent
                unit: surface.height
            }
        }
    }
}
