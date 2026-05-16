import QtQuick
import "../.."

Rectangle {
    id: root
    required property string btnText
    required property var process
    required property var btnColor

    color: mouseArea.containsMouse ? btnColor : Theme.surface0
    border.color: Theme.surface1
    border.width: mouseArea.containsMouse ? 0 : Theme.borderWidth
    implicitWidth: text.implicitHeight + Theme.popupPadding * 2
    implicitHeight: text.implicitHeight + Theme.popupPadding
    radius: Theme.innerRadius

    Behavior on color {
        ColorAnimation {
            duration: Theme.colorDuration
            easing.type: Easing.InOutQuad
        }
    }

    Text {
        id: text
        text: root.btnText
        color: mouseArea.containsMouse ? Theme.base : btnColor
        font: Theme.largeFont
        anchors.centerIn: parent

        Behavior on color {
            ColorAnimation {
                duration: Theme.colorDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.process.startDetached()
        hoverEnabled: true
    }
}
