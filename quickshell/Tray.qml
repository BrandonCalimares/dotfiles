import QtQuick
import Quickshell.Services.SystemTray
import Quickshell
import "components/tray"

Item {
    visible: SystemTray.items.values.length > 0
    implicitWidth: row.implicitWidth + Theme.barPadding * 2
    implicitHeight: Theme.barHeight

    Rectangle {
        id: rect
        border.color: Theme.surface1
        border.width: Theme.borderWidth
        anchors.fill: parent
        color: Theme.surface0
        radius: Theme.innerRadius

        Behavior on width {
            NumberAnimation {
                duration: Theme.widthDuration
                easing.type: Easing.InOutQuad
            }
        }

        Row {
            id: row
            spacing: Theme.barPadding
            anchors.centerIn: parent

            Repeater {
                model: SystemTray.items

                Item {
                    implicitWidth: icon.sourceSize.width
                    implicitHeight: icon.sourceSize.height

                    Image {
                        id: icon
                        sourceSize.width: 18
                        sourceSize.height: 18
                        source: modelData.icon
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        onClicked: event => {
                            if (event.button === Qt.RightButton && modelData.hasMenu) {
                                popup.expanded = !popup.expanded;
                            } else if (event.button === Qt.LeftButton) {
                                modelData.activate();
                            }
                        }
                    }

                    TrayPopUp {
                        id: popup
                        trayItem: modelData
                    }
                }
            }
        }
    }
}
