import QtQuick
import Quickshell
import Quickshell.Hyprland
import QtQuick.Layouts
import "../.."

PanelWindow {
    id: popup
    property bool expanded: false
    property bool opened: expanded || content.height > 0

    property var temp: null
    property int weatherCode: 0

    visible: opened

    anchors.top: true
    exclusiveZone: 0
    margins.top: Theme.outerMargin / 2
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    color: "transparent"

    HyprlandFocusGrab {
        id: grab
        windows: [popup]
        active: popup.expanded
        onCleared: popup.expanded = false
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    property var currentDate: clock.date

    Rectangle {
        id: content
        implicitWidth: container.implicitWidth + Theme.popupPadding * 2
        implicitHeight: container.implicitHeight + Theme.popupPadding * 2
        height: popup.expanded ? implicitHeight : 0
        color: Theme.background
        radius: Theme.outerRadius
        clip: true

        Behavior on height {
            NumberAnimation {
                duration: Theme.popupDuration
                easing.type: Easing.InOutQuad
            }
        }

        RowLayout {
            id: container
            anchors.centerIn: parent
            spacing: Theme.popupSpacing

            Calendar {
                date: clock.date
            }

            ColumnLayout {
                spacing: Theme.popupInnerSpacing
                Layout.fillHeight: true

                Weather {
                    id: weather
                    temp: popup.temp
                    weatherCode: popup.weatherCode
                }

                Connections {
                    target: weather
                    function onTempChanged() {
                        if (weather.temp !== null) {
                            popup.temp = weather.temp
                        }
                    }
                    function onWeatherCodeChanged() {
                        popup.weatherCode = weather.weatherCode
                    }
                }

                BigClock {
                    date: clock.date
                }
            }
        }
    }
}
