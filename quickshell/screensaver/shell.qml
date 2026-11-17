// Screensaver: a quiet clock with the date and weather.
//   starts by itself when idle; by hand: run "screensaver" (~/.local/bin/screensaver)
//   any key / click / mouse move   dismisses it
// It is a screensaver, NOT a lock: no password. Mod+/ or Super+Alt+L locks (~/.local/bin/lock).
// Saving this file applies changes immediately.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    // ── Settings ─────────────────────────────────────────────────────────────
    readonly property int    idleMinutes: 5          // start by itself after this long with no input (0 = never)
    readonly property int    monitorsOffMinutes: 15  // then switch the screens off this long after it starts (0 = never)
    readonly property string city: ""                // weather location, e.g. "Mumbai" ("" = detect from your network)
    readonly property bool   fahrenheit: false
    readonly property bool   use24h: true
    readonly property bool   showSeconds: false      // true redraws every second instead of every minute
    readonly property bool   showWeather: true
    // ─────────────────────────────────────────────────────────────────────────

    property bool   active: false
    property bool   startedByIdle: false
    property date   now: new Date()
    property string temperature: ""
    property string conditions: ""
    property double weatherFetchedAt: 0
    property real   driftX: 0     // the clock wanders a little each minute so nothing burns in
    property real   driftY: 0

    function show(byIdle) { startedByIdle = byIdle; now = new Date(); active = true }
    function hide()       { active = false; startedByIdle = false }

    onActiveChanged: {
        if (!active) return
        tick.restart()
        if (showWeather && Date.now() - weatherFetchedAt > 20 * 60 * 1000) weatherJob.running = true
    }

    IpcHandler {
        target: "saver"
        function toggle(): void { root.active ? root.hide() : root.show(false) }
        function start(): void  { root.show(false) }
        function stop(): void   { root.hide() }
    }

    IdleMonitor {
        enabled: root.idleMinutes > 0
        timeout: root.idleMinutes * 60
        respectInhibitors: true            // a playing video keeps the screensaver away
        onIsIdleChanged: {
            if (isIdle) root.show(true)
            else if (root.startedByIdle) root.hide()
        }
    }

    // clock: wakes once a minute (or once a second with showSeconds), only while visible
    Timer {
        id: tick
        running: root.active
        repeat: true
        interval: root.showSeconds ? 1000 - (Date.now() % 1000) + 5 : 60000 - (Date.now() % 60000) + 50
        onTriggered: {
            root.now = new Date()
            interval = root.showSeconds ? 1000 : 60000 - (Date.now() % 60000) + 50
            if (root.now.getSeconds() < 2) {
                root.driftX = (Math.random() - 0.5) * 120
                root.driftY = (Math.random() - 0.5) * 80
            }
        }
    }

    Timer {
        running: root.active && root.showWeather
        repeat: true
        interval: 30 * 60 * 1000
        onTriggered: weatherJob.running = true
    }

    Process {
        id: weatherJob
        command: ["curl", "-fsS", "--max-time", "8",
                  "https://wttr.in/" + encodeURIComponent(root.city) + "?format=%t|%C&" + (root.fahrenheit ? "u" : "m")]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("|")
                if (parts.length === 2 && parts[0].length < 12 && parts[1].length < 40) {
                    root.temperature = parts[0].replace(/^\+/, "")
                    root.conditions = parts[1]
                    root.weatherFetchedAt = Date.now()
                }
            }
        }
    }

    Timer {
        running: root.active && root.monitorsOffMinutes > 0
        interval: Math.max(1, root.monitorsOffMinutes) * 60 * 1000
        onTriggered: screensOff.running = true
    }
    Process { id: screensOff; command: ["niri", "msg", "action", "power-off-monitors"] }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData
            visible: root.active
            color: "#07080d"
            anchors { top: true; bottom: true; left: true; right: true }
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            WlrLayershell.namespace: "screensaver"

            property double shownAt: 0
            property point  firstMouse: Qt.point(-1, -1)
            onVisibleChanged: if (visible) { shownAt = Date.now(); firstMouse = Qt.point(-1, -1); content.opacity = 1 } else content.opacity = 0

            Item {
                anchors.fill: parent
                focus: true
                Keys.onPressed: event => {
                    // bare modifiers are ignored so that Mod+/ can toggle cleanly
                    const mods = [Qt.Key_Meta, Qt.Key_Super_L, Qt.Key_Super_R, Qt.Key_Shift, Qt.Key_Control, Qt.Key_Alt, Qt.Key_AltGr]
                    if (mods.indexOf(event.key) === -1) root.hide()
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.BlankCursor
                acceptedButtons: Qt.AllButtons
                onPressed: root.hide()
                onWheel: root.hide()
                onPositionChanged: mouse => {
                    if (Date.now() - win.shownAt < 800) return          // ignore the nudge from opening
                    if (win.firstMouse.x < 0) { win.firstMouse = Qt.point(mouse.x, mouse.y); return }
                    if (Math.abs(mouse.x - win.firstMouse.x) + Math.abs(mouse.y - win.firstMouse.y) > 24) root.hide()
                }
            }

            Column {
                id: content
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: root.driftX
                anchors.verticalCenterOffset: root.driftY
                spacing: win.height * 0.012
                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(root.now, (root.use24h ? "HH:mm" : "h:mm") + (root.showSeconds ? ":ss" : ""))
                    color: "#eeffff"
                    font { family: "Adwaita Sans"; weight: Font.ExtraLight; pixelSize: win.height * 0.24; features: { "tnum": 1 } }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(root.now, "dddd, d MMMM").toUpperCase()
                    color: "#676e95"
                    font { family: "Adwaita Sans"; weight: Font.Medium; pixelSize: win.height * 0.022; letterSpacing: win.height * 0.006 }
                }

                Item { width: 1; height: win.height * 0.03 }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: win.height * 0.016
                    visible: root.showWeather && root.temperature !== ""
                    Text {
                        text: root.temperature
                        color: "#84ffff"
                        font { family: "Adwaita Sans"; weight: Font.Normal; pixelSize: win.height * 0.03 }
                    }
                    Text {
                        text: root.conditions
                        color: "#a6accd"
                        font { family: "Adwaita Sans"; weight: Font.Light; pixelSize: win.height * 0.03 }
                    }
                }
            }
        }
    }
}
