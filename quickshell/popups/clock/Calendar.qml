import QtQuick
import QtQuick.Layouts
import "../../themes"

Rectangle {
    id: root
    required property var date
    property int month: date.getMonth()

    implicitWidth: grid.implicitWidth + Theme.popupPadding * 2
    implicitHeight: grid.implicitHeight + Theme.popupPadding * 2
    radius: Theme.innerRadius
    color: Theme.surface0
    border.width: Theme.borderWidth
    border.color: Theme.surface1

    GridLayout {
        id: grid
        anchors.centerIn: parent
        columns: 7
        columnSpacing: Theme.popupInnerSpacing
        rowSpacing: Theme.popupInnerSpacing

        // Month Header
        Rectangle {
            id: header
            color: Theme.surface1
            implicitHeight: Theme.barHeight
            Layout.fillWidth: true
            Layout.columnSpan: 7
            radius: Theme.innerRadius
            border.color: Theme.surface2
            border.width: Theme.borderWidth

            RowLayout {
                anchors.centerIn: parent
                anchors.margins: Theme.popupInnerSpacing
                width: header.width - Theme.popupPadding * 2
                spacing: Theme.popupInnerSpacing

                Text {
                    text: ""
                    font: Theme.barFont
                    color: prevMonthArea.containsMouse ? "white" : Theme.text

                    MouseArea {
                        id: prevMonthArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.month--
                        hoverEnabled: true
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: Qt.formatDateTime(new Date(root.date.getFullYear(), root.month, 1), "MMMM yyyy")
                    font: Theme.barFont
                    color: Theme.text
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: ""
                    font: Theme.barFont
                    color: nextMonthArea.containsMouse ? "white" : Theme.text

                    MouseArea {
                        id: nextMonthArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.month++
                        hoverEnabled: true
                    }
                }
            }
        }

        // Day names
        Repeater {
            model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            delegate: DayCell {
                required property var modelData
                day: modelData
                dayName: true
            }
        }

        property int daysInMonth: new Date(root.date.getFullYear(), root.month + 1, 0).getDate()
        property int offset: (new Date(root.date.getFullYear(), root.month, 1).getDay() + 6) % 7

        // Days
        Repeater {
            model: grid.daysInMonth + grid.offset
            delegate: DayCell {
                required property var index
                Layout.fillWidth: true
                day: index < grid.offset ? null : index - grid.offset + 1
                today: (index - grid.offset + 1 === root.date.getDate()) && (root.month === root.date.getMonth())
            }
        }
    }
}
