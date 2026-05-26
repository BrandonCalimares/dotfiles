import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick.Controls
import Quickshell.Services.Notifications
import "themes"

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

            if (notification.body == "" && notification.summary == "") {
                notification.expire();
                return;
            }

            root.notification = notification;
            root.defaultAction = notification.actions.find(action => action.identifier === "default") ?? null;
            root.timeout = notification.expireTimeout;
            progressAnim.restart();

            root.expanded = true;

            notification.closed.connect(function () {
                input.text = "";
                root.expanded = false;
            });
        }
    }

    property var notification: null
    property var defaultAction: null

    HyprlandFocusGrab {
        id: grab
        windows: [root]
        active: root.mouseInPopup
    }

    Process {
        id: soundProcess
        command: ["paplay", "/usr/share/sounds/freedesktop/stereo/bell.oga"]
    }

    property var timeout: 5000

    property bool mouseInPopup: mouseArea.containsMouse || closeArea.containsMouse || (input.visible && input.hovered)
    onMouseInPopupChanged: mouseInPopup ? progressAnim.pause() : progressAnim.resume()

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

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            propagateComposedEvents: true
            hoverEnabled: true
            onClicked: {
                if (root.defaultAction) {
                    root.defaultAction.invoke();
                }
            }
        }

        ColumnLayout {
            id: container
            spacing: Theme.popupInnerSpacing
            anchors.centerIn: parent

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.popupInnerSpacing

                Text {
                    text: ""
                    font: Theme.sFont
                    color: Theme.accent
                }

                Text {
                    text: root.notification != null ? root.notification.appName : ""
                    font: Theme.sFont
                    color: Theme.accent
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
                        onClicked: root.notification.dismiss()
                        hoverEnabled: true
                    }
                }
            }

            Rectangle {
                implicitWidth: col.implicitWidth + Theme.popupPadding * 2
                implicitHeight: col.implicitHeight + Theme.popupPadding * 2
                radius: Theme.innerRadius
                color: Theme.surface0
                border.width: Theme.borderWidth
                border.color: Theme.surface1

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
                        onFinished: root.notification.expire()
                    }
                }

                ColumnLayout {
                    id: col
                    anchors.centerIn: parent
                    spacing: Theme.popupInnerSpacing

                    // Body
                    RowLayout {
                        spacing: Theme.popupSpacing
                        Layout.preferredWidth: 340
                        Layout.maximumHeight: 100

                        IconImage {
                            source: root.notification != null ? root.notification.image : ""
                            visible: source != ""
                            implicitSize: 52
                        }

                        ColumnLayout {
                            spacing: Theme.popupInnerSpacing / 2
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Text {
                                text: root.notification != null ? root.notification.summary : ""
                                font: Theme.barFont
                                color: Theme.text
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: root.notification != null ? root.notification.body : ""
                                font: Theme.mFont
                                color: Theme.subtext0
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                            }
                        }
                    }

                    TextField {
                        id: input
                        visible: root.notification && root.notification.hasInlineReply
                        placeholderText: root.notification && root.notification.inlineReplyPlaceholder || "Type your reply..."
                        placeholderTextColor: Theme.overlay1
                        focus: true
                        Layout.fillWidth: true
                        activeFocusOnPress: true
                        color: Theme.text
                        padding: Theme.popupPadding
                        font: Theme.mFont

                        background: Rectangle {
                            color: Theme.base
                            border.color: Theme.surface0
                            border.width: Theme.borderWidth
                            radius: Theme.innerRadius
                        }

                        onAccepted: {
                            root.notification.sendInlineReply(input.text);
                            input.text = "";
                        }
                    }
                }
            }
        }
    }
}
