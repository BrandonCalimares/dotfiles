import QtQuick
import "../.."

Rectangle {
    required property string day
    property bool today: false
    property bool dayName: false

    color: today ? Theme.accent : "transparent"
    radius: Theme.innerRadius
    implicitHeight: Theme.barHeight
    implicitWidth: dayText.implicitWidth + Theme.popupPadding * 2

    Text {
        id: dayText
        text: day
        anchors.centerIn: parent
        font: Theme.mediumFont
        color: dayName ? Theme.text : (today ? Theme.base : Theme.subtext0)
    }
}
