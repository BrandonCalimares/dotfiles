import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import "../../themes"

Rectangle {
    color: Theme.surface0
    radius: Theme.innerRadius
    border.color: Theme.surface1
    border.width: Theme.borderWidth
    implicitHeight: column.implicitHeight + Theme.popupPadding * 2
    clip: true

    required property var activePlayer

    ColumnLayout {
        id: column
        spacing: Theme.popupPadding
        anchors.verticalCenter: parent.verticalCenter
        anchors.fill: parent
        anchors.left: parent.left
        anchors.margins: Theme.popupPadding

        RowLayout {
            id: row
            spacing: Theme.popupSpacing
            Layout.fillWidth: true

            ClippingWrapperRectangle {
                id: artWrapper
                Layout.preferredWidth: 80
                Layout.preferredHeight: 80
                radius: Theme.innerRadius
                visible: activePlayer != null
                Image {
                    source: activePlayer ? activePlayer.trackArtUrl : ""
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 80
                    sourceSize.width: 80
                    sourceSize.height: 80
                    fillMode: Image.PreserveAspectCrop
                    clip: true
                }
            }

            ColumnLayout {
                spacing: Theme.popupInnerSpacing / 2
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop

                Text {
                    text: activePlayer ? activePlayer.trackTitle || "Unknown Title" : "No media detected"
                    font: Theme.lFont
                    color: Theme.text
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: activePlayer ? activePlayer.trackAlbum || "" : " "
                    font: Theme.barFont
                    color: Theme.subtext0
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    visible: activePlayer && activePlayer.trackAlbum
                }

                Text {
                    text: activePlayer ? activePlayer.trackArtist || "" : " "
                    font: Theme.sFont
                    color: Theme.subtext0
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    visible: activePlayer && activePlayer.trackArtist
                }
            }
        }
    }
}