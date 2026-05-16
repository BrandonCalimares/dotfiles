import QtQuick 2.15
import QtQuick.Layouts 1.15
import "../.."

RowLayout {
    spacing: Theme.popupSpacing
    required property var activePlayer

    Text {
        text: ""
        font: Theme.barFont
        color: activePlayer && activePlayer.shuffleSupported ? (shuffleArea.containsMouse || activePlayer.shuffle ? Theme.green : Theme.text) : Theme.overlay0

        MouseArea {
            id: shuffleArea
            anchors.fill: parent
            enabled: activePlayer && activePlayer.shuffleSupported
            cursorShape: activePlayer && activePlayer.shuffleSupported ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: activePlayer.shuffle = !activePlayer.shuffle
            hoverEnabled: true
        }
    }

    Text {
        text: ""
        font: Theme.bigFont
        color: activePlayer && activePlayer.canGoPrevious ? (prevArea.containsMouse ? Theme.green : Theme.text) : Theme.overlay0

        MouseArea {
            id: prevArea
            anchors.fill: parent
            enabled: activePlayer && activePlayer.canGoPrevious
            cursorShape: activePlayer && activePlayer.canGoPrevious ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: activePlayer.previous()
            hoverEnabled: true
        }
    }

    Text {
        text: activePlayer && activePlayer.isPlaying ? "" : ""
        font: Theme.largeFont
        color: activePlayer && activePlayer.canPlay && activePlayer.canPause ? (playArea.containsMouse ? Theme.green : Theme.text) : Theme.overlay0

        MouseArea {
            id: playArea
            anchors.fill: parent
            enabled: activePlayer && activePlayer.canPlay && activePlayer.canPause
            cursorShape: activePlayer && activePlayer.canPlay && activePlayer.canPause ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: activePlayer.togglePlaying()
            hoverEnabled: true
        }
    }

    Text {
        text: ""
        font: Theme.bigFont
        color: activePlayer && activePlayer.canGoNext ? (nextArea.containsMouse ? Theme.green : Theme.text) : Theme.overlay0

        MouseArea {
            id: nextArea
            anchors.fill: parent
            enabled: activePlayer && activePlayer.canGoNext
            cursorShape: activePlayer && activePlayer.canGoNext ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: activePlayer.next()
            hoverEnabled: true
        }
    }

    Text {
        text: ""
        font: Theme.barFont
        color: activePlayer && activePlayer.loopSupported ? (stopArea.containsMouse || activePlayer.loopState ? Theme.green : Theme.text) : Theme.overlay0

        MouseArea {
            id: stopArea
            anchors.fill: parent
            enabled: activePlayer && activePlayer.loopSupported
            cursorShape: activePlayer && activePlayer.loopSupported ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: activePlayer.loopState = !activePlayer.loopState
            hoverEnabled: true
        }
    }
}
