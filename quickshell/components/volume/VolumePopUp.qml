import QtQuick
import Quickshell
import Quickshell.Hyprland
import QtQuick.Layouts
import "../.."

PanelWindow {
    id: popup
    property bool expanded: false
    property bool opened: expanded || content.height > 0

    visible: opened

    anchors.top: true
    anchors.right: true
    aboveWindows: true
    margins.top: Theme.outerMargin / 2
    margins.right: Theme.outerMargin
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight + audioSources.implicitHeight
    color: "transparent"

    HyprlandFocusGrab {
        id: grab
        windows: [popup]
        active: popup.expanded
        onCleared: {
            popup.expanded = false;
            audioSinks.expanded = false;
            audioSources.expanded = false;
        }
    }

    Rectangle {
        id: content
        implicitWidth: column.implicitWidth + Theme.popupPadding * 2
        implicitHeight: column.implicitHeight + Theme.popupPadding * 2
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
            id: column
            anchors.centerIn: parent
            spacing: Theme.popupSpacing

            AudioSection {
                id: sinkSection
                type: "sink"
                audioList: audioSinks
            }

            AudioSection {
                id: sourceSection
                type: "source"
                audioList: audioSources
            }
        }
    }

    AudioList {
        id: audioSinks
        audioSection: sinkSection
        rootColumn: column
        type: "sink"
    }

    AudioList {
        id: audioSources
        audioSection: sourceSection
        rootColumn: column
        type: "source"
    }
}
