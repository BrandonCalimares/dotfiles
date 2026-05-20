import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Services.Notifications

PanelWindow {
    id: root
    property bool expanded: false
    property bool opened: expanded || content.height > 0

    visible: opened

    anchors.top: true
    anchors.right: true
    aboveWindows: true
    margins.top: Theme.outerMargin / 2
    margins.right: Theme.outerMargin
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    color: "transparent"

    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        keepOnReload: false
        onNotification: function (notification) {
            notification.tracked = true;
            soundProcess.running = true;
            root.notification = notification;

            root.timeout = notification.expireTimeout;
            progressAnim.restart();

            root.expanded = true;
        }
    }

    property var notification: null

    Process {
        id: soundProcess
        command: ["paplay", "/usr/share/sounds/freedesktop/stereo/bell.oga"]
    }

    property var timeout: 5000

    Rectangle {
        id: content
        implicitWidth: container.implicitWidth + Theme.popupPadding * 2
        implicitHeight: container.implicitHeight + Theme.popupPadding * 2
        height: root.expanded ? implicitHeight : 0
        color: Theme.background
        radius: Theme.outerRadius
        clip: true

        Behavior on height {
            NumberAnimation {
                duration: Theme.popupDuration
                easing.type: Easing.InOutQuad
            }
        }

        Rectangle {
            id: container
            implicitWidth: col.implicitWidth + Theme.popupPadding * 2
            implicitHeight: col.implicitHeight + Theme.popupPadding * 2
            radius: Theme.innerRadius
            color: Theme.surface0
            anchors.centerIn: parent
            border.width: Theme.borderWidth
            border.color: Theme.surface1

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onEntered: progressAnim.pause()
                onExited: progressAnim.resume()
            }

            // Progress Bar
            Rectangle {
                id: progressBar
                height: parent.height
                anchors.left: parent.left
                color: Theme.surface1
                radius: Theme.innerRadius

                NumberAnimation on width {
                    id: progressAnim
                    from: 0
                    to: container.width
                    duration: root.timeout
                    easing.type: Easing.Linear
                    running: false

                    onFinished: {
                        root.notification.expire();
                        root.expanded = false;
                    }
                }
            }

            ColumnLayout {
                id: col
                anchors.centerIn: parent
                spacing: Theme.popupInnerSpacing

                // Header
                RowLayout {
                    spacing: Theme.popupInnerSpacing

                    Text {
                        text: ""
                        font: Theme.sFont
                        color: Theme.subtext1
                    }

                    Text {
                        text: notification != null ? notification.appName : ""
                        font: Theme.sFont
                        color: Theme.subtext1
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: ""
                        font: Theme.barFont
                        color: closeArea.containsMouse ? Theme.red : Theme.subtext0

                        MouseArea {
                            id: closeArea
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.notification.dismiss();
                                root.expanded = false;
                            }
                            hoverEnabled: true
                        }
                    }
                }

                // Body
                RowLayout {
                    spacing: Theme.popupSpacing
                    Layout.preferredWidth: 340
                    Layout.maximumHeight: 140

                    IconImage {
                        source: notification != null ? notification.image : ""
                        visible: source != ""
                        implicitSize: 42
                    }

                    ColumnLayout {
                        spacing: Theme.popupInnerSpacing / 2
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Text {
                            text: notification != null ? notification.summary : ""
                            font: Theme.barFont
                            color: Theme.text
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: notification != null ? notification.body : ""
                            font: Theme.mFont
                            color: Theme.subtext0
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }
                }
            }
        }
    }
}
