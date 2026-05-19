import QtQuick
import Quickshell
import Quickshell.Hyprland
import QtQuick.Layouts
import Quickshell.Services.Mpris

import "../.."

PanelWindow {
    id: popup
    property bool expanded: false
    property bool opened: expanded || content.height > 0

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

    property int activeIndex: 0
    property var playerList: Mpris.players.values
    property var activePlayer: playerList.length > 0 ? playerList[activeIndex < playerList.length ? activeIndex : 0] : null

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

        ColumnLayout {
            id: container
            spacing: Theme.popupInnerSpacing
            anchors.centerIn: parent

            RowLayout {
                spacing: Theme.popupInnerSpacing / 2
                visible: activePlayer != null
                Layout.leftMargin: 2

                Text {
                    text: activePlayer.identity + " "
                    font: Theme.sFont
                    color: switchArea.containsMouse ? Theme.green : Theme.subtext0
                }

                MouseArea {
                    id: switchArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: activeIndex = (activeIndex + 1) % playerList.length
                    hoverEnabled: true
                }
            }

            MusicInfo {
                activePlayer: popup.activePlayer
                Layout.fillWidth: true
            }

            RowLayout {
                id: row
                spacing: Theme.popupInnerSpacing
                Layout.alignment: Qt.AlignHCenter
                Layout.leftMargin: Theme.popupPadding
                Layout.rightMargin: Theme.popupPadding
                Layout.topMargin: Theme.popupInnerSpacing

                Rectangle {
                    implicitWidth: Theme.musicBarWidth
                    implicitHeight: Theme.musicBarHeight
                    color: Theme.surface2
                    radius: implicitHeight / 2

                    property bool dragging: false
                    property real dragPosition: 0

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor

                        onPressed: mouse => {
                            parent.dragging = true;
                            parent.dragPosition = Math.max(0, Math.min(1, mouse.x / parent.width)) * activePlayer.length;
                        }
                        onPositionChanged: mouse => {
                            parent.dragPosition = Math.max(0, Math.min(1, mouse.x / parent.width)) * activePlayer.length;
                        }
                        onReleased: mouse => {
                            activePlayer.position = parent.dragPosition;
                            parent.dragging = false;
                        }
                    }

                    FrameAnimation {
                        running: activePlayer.playbackState == MprisPlaybackState.Playing && !parent.dragging
                        onTriggered: activePlayer.positionChanged()
                    }

                    Rectangle {
                        property real displayPosition: parent.dragging ? parent.dragPosition : activePlayer.position

                        implicitWidth: parent.implicitWidth * displayPosition / activePlayer.length
                        implicitHeight: Theme.musicBarHeight
                        color: Theme.green
                        anchors.verticalCenter: parent.verticalCenter
                        radius: implicitHeight / 2

                        Rectangle {
                            implicitWidth: 14
                            implicitHeight: 14
                            color: Theme.text
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: parent.width - 7
                            radius: implicitHeight / 2
                        }
                    }
                }

                Text {
                    visible: activePlayer != null
                    text: "-" + Math.floor((activePlayer.length - activePlayer.position) / 60) + ":" + Math.floor((activePlayer.length - activePlayer.position) % 60).toString().padStart(2, "0")
                    color: Theme.text
                    font: Theme.barFont
                }
            }

            MusicControls {
                activePlayer: popup.activePlayer
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: Theme.popupPadding / 2
            }
        }
    }
}
