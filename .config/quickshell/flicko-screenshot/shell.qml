import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    PanelWindow {
        id: window

        readonly property color accent: "#88d6ba"
        readonly property color washColor: "#cc0f1512"
        readonly property int borderWidth: 6
        readonly property int handleRadius: 20
        readonly property int handleDiameter: handleRadius * 2

        property rect selection: Qt.rect(0, 0, 0, 0)
        property bool dragging: false
        property real originX: 0
        property real originY: 0
        readonly property bool hasSelection: selection.width > 4 && selection.height > 4

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "flicko-screenshot"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        FocusScope {
            anchors.fill: parent
            focus: true

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    killer.running = true
                    event.accepted = true
                }
            }

            // Outside wash darkening
            Item {
                anchors.fill: parent

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: Math.max(0, window.hasSelection ? window.selection.y : parent.height)
                    color: window.washColor
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: window.hasSelection
                        ? Math.max(0, parent.height - window.selection.y - window.selection.height)
                        : 0
                    color: window.washColor
                }

                Rectangle {
                    visible: window.hasSelection
                    anchors.left: parent.left
                    y: window.selection.y
                    width: Math.max(0, window.selection.x)
                    height: window.selection.height
                    color: window.washColor
                }

                Rectangle {
                    visible: window.hasSelection
                    anchors.right: parent.right
                    y: window.selection.y
                    width: Math.max(0, parent.width - window.selection.x - window.selection.width)
                    height: window.selection.height
                    color: window.washColor
                }
            }

            // Flicko Ropes & Selection
            Item {
                anchors.fill: parent
                visible: window.hasSelection

                Rope {
                    anchorX: 0
                    anchorY: 0
                    pullX: window.selection.x
                    pullY: window.selection.y
                    color: window.accent
                    strokeWidth: window.borderWidth
                    visible: parent.visible
                }

                Rope {
                    anchorX: parent.width
                    anchorY: 0
                    pullX: window.selection.x + window.selection.width
                    pullY: window.selection.y
                    color: window.accent
                    strokeWidth: window.borderWidth
                    visible: parent.visible
                }

                Rope {
                    anchorX: 0
                    anchorY: parent.height
                    pullX: window.selection.x
                    pullY: window.selection.y + window.selection.height
                    color: window.accent
                    strokeWidth: window.borderWidth
                    visible: parent.visible
                }

                Rope {
                    anchorX: parent.width
                    anchorY: parent.height
                    pullX: window.selection.x + window.selection.width
                    pullY: window.selection.y + window.selection.height
                    color: window.accent
                    strokeWidth: window.borderWidth
                    visible: parent.visible
                }

                // Selection box outline
                Rectangle {
                    x: window.selection.x - window.borderWidth / 2
                    y: window.selection.y - window.borderWidth / 2
                    width: window.selection.width + window.borderWidth
                    height: window.selection.height + window.borderWidth
                    color: "transparent"
                    border.color: window.accent
                    border.width: window.borderWidth
                    radius: 4
                }

                // Four corner circles
                Rectangle {
                    x: window.selection.x - window.handleRadius
                    y: window.selection.y - window.handleRadius
                    width: window.handleDiameter
                    height: window.handleDiameter
                    radius: window.handleRadius
                    color: window.accent
                }

                Rectangle {
                    x: window.selection.x + window.selection.width - window.handleRadius
                    y: window.selection.y - window.handleRadius
                    width: window.handleDiameter
                    height: window.handleDiameter
                    radius: window.handleRadius
                    color: window.accent
                }

                Rectangle {
                    x: window.selection.x - window.handleRadius
                    y: window.selection.y + window.selection.height - window.handleRadius
                    width: window.handleDiameter
                    height: window.handleDiameter
                    radius: window.handleRadius
                    color: window.accent
                }

                Rectangle {
                    x: window.selection.x + window.selection.width - window.handleRadius
                    y: window.selection.y + window.selection.height - window.handleRadius
                    width: window.handleDiameter
                    height: window.handleDiameter
                    radius: window.handleRadius
                    color: window.accent
                }

                // Dimension reading pill
                Rectangle {
                    x: Math.min(Math.max(10, window.selection.x), parent.width - width - 10)
                    y: window.selection.y > height + 10 ? window.selection.y - height - 10 : window.selection.y + 10
                    width: dimText.implicitWidth + 24
                    height: 28
                    radius: 14
                    color: "#141414"
                    border.color: "#282828"
                    border.width: 1

                    Text {
                        id: dimText
                        anchors.centerIn: parent
                        text: `${Math.round(window.selection.width)} × ${Math.round(window.selection.height)}`
                        color: "#ffffff"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.CrossCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onPressed: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        killer.running = true
                        return
                    }
                    window.dragging = true
                    window.originX = mouse.x
                    window.originY = mouse.y
                    window.selection = Qt.rect(mouse.x, mouse.y, 0, 0)
                }

                onPositionChanged: mouse => {
                    if (window.dragging) {
                        window.selection = Qt.rect(
                            Math.min(window.originX, mouse.x),
                            Math.min(window.originY, mouse.y),
                            Math.abs(mouse.x - window.originX),
                            Math.abs(mouse.y - window.originY)
                        )
                    }
                }

                onReleased: mouse => {
                    if (mouse.button !== Qt.LeftButton) return
                    window.dragging = false
                    if (window.selection.width > 4 && window.selection.height > 4) {
                        window.visible = false
                        let geom = `${Math.round(window.selection.x)},${Math.round(window.selection.y)} ${Math.round(window.selection.width)}x${Math.round(window.selection.height)}`
                        captureProc.geom = geom
                        captureProc.running = true
                    } else {
                        killer.running = true
                    }
                }
            }
        }
    }

    Process {
        id: captureProc
        property string geom: ""
        command: [
            "sh", "-c",
            `f="$HOME/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"
             grim -g "${geom}" "$f"
             wl-copy < "$f"
             notify-send -i "$f" "Screenshot" "Saved to Pictures and copied to clipboard"
            `
        ]
        onExited: (exitCode) => {
            killer.running = true
        }
    }

    Process {
        id: killer
        command: ["kill", "-TERM", String(Quickshell.processId)]
    }
}
