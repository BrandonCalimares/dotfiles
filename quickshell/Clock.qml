import QtQuick
import Quickshell
import "components/clock"

Item {
    id: root
    implicitWidth: row.implicitWidth + Theme.barPadding * 4
    implicitHeight: Theme.barHeight

    property bool focused: mouseArea.containsMouse || (popupLoader.item ? popupLoader.item.expanded : false)
    property var temp: null
    property int weatherCode: 0

    SystemClock {
        id: sysClock
        precision: SystemClock.Minutes
    }

    Rectangle {
        id: rect
        border.color: Theme.surface1
        border.width: root.focused ? 0 : Theme.borderWidth
        radius: Theme.innerRadius
        color: root.focused ? Theme.text : Theme.surface0
        anchors.fill: parent

        Behavior on color {
            ColorAnimation {
                duration: Theme.colorDuration
                easing.type: Easing.InOutQuad
            }
        }

        Row {
            id: row
            anchors.centerIn: parent

            Text {
                id: clock
                text: Qt.formatDateTime(sysClock.date, "hh:mm - ")
                anchors.verticalCenter: parent.verticalCenter
                color: root.focused ? Theme.base : Theme.text
                font: Theme.barFont

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.colorDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            Text {
                id: date
                text: Qt.formatDateTime(sysClock.date, "MMM d")
                anchors.verticalCenter: parent.verticalCenter
                color: root.focused ? Theme.surface0 : Theme.subtext0
                font: Theme.sFont

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.colorDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: popupLoader.active = true
        }
    }

    Loader {
        id: popupLoader
        active: false
        focus: true
        sourceComponent: ClockPopUp {
            temp: root.temp
            weatherCode: root.weatherCode
        }
        onLoaded: popupLoader.item.expanded = true
    }

    Connections {
        target: popupLoader.item
        function onOpenedChanged() {
            if (popupLoader.item && !popupLoader.item.opened) {
                popupLoader.active = false;
            }
        }

        function onTempChanged() {
            if (popupLoader.item) {
                root.temp = popupLoader.item.temp
            }
        }

        function onWeatherCodeChanged() {
            if (popupLoader.item) {
                root.weatherCode = popupLoader.item.weatherCode
            }
        }
    }
}
