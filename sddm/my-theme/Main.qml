import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    anchors.fill: parent
    color: config.base

    Column {
        visible: screenModel.primary == 0
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: userModel.lastUser  
            color: config.text 
            font.pixelSize: 24
            anchors.horizontalCenter: parent.horizontalCenter
        }
        TextField {
            id: passwordField
            placeholderText: "Password"
            echoMode: TextInput.Password
            width: 250
            focus: true

            onAccepted: sddm.login(userModel.lastUser, text, sessionModel.lastIndex)
        }

        Button {
            text: "Log in"
            anchors.horizontalCenter: parent.horizontalCenter

            onClicked: sddm.login(userModel.lastUser, passwordField.text, sessionModel.lastIndex)
        }

        Text {
            id: errorText
            color: config.red
            font.pixelSize: 14
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            errorText.text = "Invalid password"
            passwordField.text = ""
        }
    }
}
