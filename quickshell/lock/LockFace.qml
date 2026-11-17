// What the lock screen shows: clock, date, weather, password field.
import QtQuick

Column {
    id: face
    required property real unit          // screen height; everything scales from it
    spacing: unit * 0.012

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDateTime(root.now, root.use24h ? "HH:mm" : "h:mm")
        color: "#eeffff"
        font { family: "Adwaita Sans"; weight: Font.ExtraLight; pixelSize: face.unit * 0.24; features: { "tnum": 1 } }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDateTime(root.now, "dddd, d MMMM").toUpperCase()
        color: "#676e95"
        font { family: "Adwaita Sans"; weight: Font.Medium; pixelSize: face.unit * 0.022; letterSpacing: face.unit * 0.006 }
    }

    Item { width: 1; height: face.unit * 0.03 }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: face.unit * 0.016
        opacity: root.showWeather && root.temperature !== "" ? 1 : 0     // keeps its space so nothing jumps
        Text {
            text: root.temperature || " "
            color: "#84ffff"
            font { family: "Adwaita Sans"; weight: Font.Normal; pixelSize: face.unit * 0.03 }
        }
        Text {
            text: root.conditions
            color: "#a6accd"
            font { family: "Adwaita Sans"; weight: Font.Light; pixelSize: face.unit * 0.03 }
        }
    }

    Item { width: 1; height: face.unit * 0.05 }

    // password field: a thin pill that fills with dots
    Rectangle {
        id: field
        anchors.horizontalCenter: parent.horizontalCenter
        width: face.unit * 0.42
        height: face.unit * 0.062
        radius: height / 2
        color: "#0f111a"
        border.width: Math.max(1, face.unit * 0.0016)
        border.color: root.state === "wrong" ? "#f07178" : root.password !== "" || root.state === "checking" ? "#84ffff" : "#232637"
        Behavior on border.color { ColorAnimation { duration: 180 } }

        Text {
            anchors.centerIn: parent
            visible: root.password === ""
            text: root.state === "checking" ? "Checking…" : root.state === "wrong" ? root.notice : "Type your password"
            color: root.state === "wrong" ? "#f07178" : "#464b5d"
            font { family: "Adwaita Sans"; weight: Font.Normal; pixelSize: face.unit * 0.02 }
        }

        Row {
            anchors.centerIn: parent
            spacing: face.unit * 0.009
            visible: root.password !== ""
            Repeater {
                model: Math.min(root.password.length, 24)
                Rectangle {
                    width: face.unit * 0.011; height: width; radius: width / 2
                    color: root.state === "checking" ? "#464b5d" : "#eeffff"
                }
            }
        }

        // a short shake when the password is wrong
        transform: Translate { id: nudge }
        SequentialAnimation {
            running: root.state === "wrong"
            NumberAnimation { target: nudge; property: "x"; to: face.unit * 0.012; duration: 50 }
            NumberAnimation { target: nudge; property: "x"; to: -face.unit * 0.012; duration: 90 }
            NumberAnimation { target: nudge; property: "x"; to: 0; duration: 60 }
        }
    }
}
