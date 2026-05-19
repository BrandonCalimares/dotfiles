import Quickshell.Io
import QtQuick
import Qt5Compat.GraphicalEffects
import "../.."

Item {
    id: root
    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight

    required property string statType
    required property Timer timer
    property string statIcon: statType === "cpu" ? "" : ""
    property Process statProc: statType === "cpu" ? cpuProc : ramProc
    property color statColor: statType === "cpu" ? Qt.alpha(Theme.blue, 0.25) : Qt.alpha(Theme.green, 0.25)
    property int statUsage: 0

    //CPU Usage
    property int lastCpuIdle: 0
    property int lastCpuTotal: 0

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]

        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                var p = data.trim().split(/\s+/);
                var idle = parseInt(p[4]) + parseInt(p[5]);
                var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0);
                if (root.lastCpuTotal > 0) // skip first run
                    root.statUsage = Math.round(100 * (1 - (idle - root.lastCpuIdle) / (total - root.lastCpuTotal)));
                root.lastCpuTotal = total;
                root.lastCpuIdle = idle;
            }
        }
        Component.onCompleted: running = root.statType === "cpu"
    }

    // RAM Usage
    Process {
        id: ramProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                var parts = data.trim().split(/\s+/);
                var total = parseInt(parts[1]) || 1;
                var used = parseInt(parts[2]) || 0;
                root.statUsage = Math.round(100 * used / total);
            }
        }
        Component.onCompleted: running = root.statType !== "cpu"
    }

    Connections {
        target: root.timer
        function onTriggered() {
            root.statProc.running = true;
        }
    }

    // Mask
    Rectangle {
        id: container
        anchors.fill: parent
        anchors.centerIn: parent
        implicitHeight: statText.implicitHeight + Theme.popupPadding * 2
        implicitWidth: parent.implicitWidth
        radius: Theme.innerRadius
        visible: false
    }

    // Usage Bar
    Rectangle {
        anchors.fill: container
        color: Qt.alpha(Theme.surface0, 0.5)
        radius: Theme.innerRadius
        border.width: Theme.borderWidth
        border.color: Theme.surface1

        Rectangle {
            anchors.right: parent.right
            width: parent.width * (root.statUsage / 100)
            height: parent.height
            color: root.statColor

            Behavior on width {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Text {
            id: statText
            text: root.statIcon + "  " + root.statUsage + "%"
            font: Theme.lFont
            color: Theme.text
            anchors.centerIn: parent
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: container
        }
    }
}
