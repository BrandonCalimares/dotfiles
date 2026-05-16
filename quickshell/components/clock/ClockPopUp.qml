import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick.Layouts
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

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    property var currentDate: clock.date
    property int month: currentDate.getMonth()

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

            // Calendar
            Rectangle {
                implicitWidth: grid.implicitWidth + Theme.popupPadding * 2
                implicitHeight: grid.implicitHeight + Theme.popupPadding * 2
                radius: Theme.innerRadius
                color: Theme.surface0
                border.width: Theme.borderWidth
                border.color: Theme.surface1

                GridLayout {
                    id: grid
                    anchors.centerIn: parent
                    columns: 7
                    columnSpacing: Theme.popupInnerSpacing
                    rowSpacing: Theme.popupInnerSpacing

                    Rectangle {
                        id: header
                        color: Theme.surface1
                        implicitHeight: Theme.barHeight
                        Layout.fillWidth: true
                        Layout.columnSpan: 7
                        radius: Theme.innerRadius
                        border.color: Theme.surface2
                        border.width: Theme.borderWidth

                        RowLayout {
                            anchors.centerIn: parent
                            anchors.margins: Theme.popupInnerSpacing
                            width: header.width - Theme.popupPadding * 2
                            spacing: Theme.popupInnerSpacing

                            Text {
                                text: ""
                                font: Theme.barFont
                                color: prevMonthArea.containsMouse ? "white" : Theme.text

                                MouseArea {
                                    id: prevMonthArea
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: month--
                                    hoverEnabled: true
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: Qt.formatDateTime(new Date(clock.date.getFullYear(), month, 1), "MMMM yyyy")
                                font: Theme.barFont
                                color: Theme.text
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: ""
                                font: Theme.barFont
                                color: nextMonthArea.containsMouse ? "white" : Theme.text

                                MouseArea {
                                    id: nextMonthArea
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: month++
                                    hoverEnabled: true
                                }
                            }
                        }
                    }

                    Repeater {
                        model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                        delegate: DayCell {
                            required property var modelData
                            day: modelData
                            dayName: true
                        }
                    }

                    property int daysInMonth: new Date(clock.date.getFullYear(), month + 1, 0).getDate()
                    property int offset: (new Date(clock.date.getFullYear(), month, 1).getDay() + 6) % 7

                    Repeater {
                        model: grid.daysInMonth + grid.offset
                        delegate: DayCell {
                            required property var index
                            Layout.fillWidth: true
                            day: index < grid.offset ? null : index - grid.offset + 1
                            today: (index - grid.offset + 1 === clock.date.getDate()) && (month === clock.date.getMonth())
                        }
                    }
                }
            }

            ColumnLayout {
                spacing: Theme.popupInnerSpacing
                Layout.fillHeight: true

                // Weather
                Rectangle {
                    id: weather
                    color: Theme.surface0
                    radius: Theme.innerRadius
                    border.width: Theme.borderWidth
                    border.color: Theme.surface1
                    implicitWidth: 160
                    implicitHeight: weatherLayout.implicitHeight + Theme.popupPadding * 2

                    property real lat: 0
                    property real lon: 0

                    Process {
                        id: geoProc
                        running: true
                        command: ["sh", "-c", "curl -s https://ipinfo.io/json"]
                        stdout: StdioCollector {
                            onStreamFinished: {
                                try {
                                    var data = JSON.parse(this.text);
                                    var coords = data.loc.split(",");
                                    weather.lat = parseFloat(coords[0]);
                                    weather.lon = parseFloat(coords[1]);
                                    fetchWeather.running = true;
                                } catch (_) {}
                            }
                        }
                    }

                    property real temp: 0
                    property int weatherCode: 0
                    property bool loading: true

                    Timer {
                        interval: 600000
                        running: true
                        repeat: true
                        onTriggered: fetchWeather.running = true
                    }

                    Process {
                        id: fetchWeather
                        running: false
                        command: ["bash", "-c", `curl -sf 'https://api.open-meteo.com/v1/forecast` + `?latitude=${weather.lat}&longitude=${weather.lon}` + `&current=temperature_2m,weather_code' | jq -c .current`]

                        stdout: SplitParser {
                            onRead: data => {
                                try {
                                    const d = JSON.parse(data);
                                    weather.temp = d.temperature_2m;
                                    weather.weatherCode = d.weather_code;
                                    weather.loading = false;
                                } catch (_) {}
                            }
                        }
                    }

                    function wmoIcon(code) {
                        if (code === 0)
                            return "";  // clear
                        if (code <= 3)
                            return "";  // cloudy
                        if (code <= 48)
                            return "";  // fog
                        if (code <= 67)
                            return "";  // rain
                        if (code <= 77)
                            return "";  // snow
                        if (code <= 82)
                            return "";  // showers
                        return "";                            // thunder
                    }

                    function wmoColor(code) {
                        if (code === 0)
                            return Theme.peach;    // clear
                        if (code <= 3)
                            return Theme.overlay1; // cloudy
                        if (code <= 48)
                            return Theme.overlay2; // fog
                        if (code <= 67)
                            return Theme.blue;     // rain
                        if (code <= 77)
                            return Theme.sky;      // snow
                        if (code <= 82)
                            return Theme.blue;     // showers
                        return Theme.mauve;                     // thunder
                    }

                    function wmoText(code) {
                        if (code === 0)
                            return "Clear";
                        if (code <= 3)
                            return "Cloudy";
                        if (code <= 48)
                            return "Fog";
                        if (code <= 67)
                            return "Rain";
                        if (code <= 77)
                            return "Snow";
                        if (code <= 82)
                            return "Showers";
                        return "Thunder";
                    }

                    RowLayout {
                        id: weatherLayout
                        anchors.centerIn: parent
                        anchors.margins: Theme.popupPadding
                        spacing: Theme.popupSpacing

                        Text {
                            id: weatherText
                            text: weather.loading ? "" : weather.wmoIcon(weather.weatherCode)
                            color: weather.loading ? Theme.subtext0 : weather.wmoColor(weather.weatherCode)
                            font.family: Theme.barFont.family
                            font.pixelSize: 32
                        }

                        ColumnLayout {
                            spacing: Theme.popupInnerSpacing / 2

                            Text {
                                text: weather.loading ? "Loading" : `${weather.temp}°C`
                                color: Theme.text
                                font: Theme.bigFont
                            }

                            Text {
                                text: weather.loading ? "..." : weather.wmoText(weather.weatherCode)
                                color: Theme.subtext0
                                font: Theme.smallFont
                            }
                        }
                    }
                }

                // Clock
                Rectangle {
                    color: Theme.surface0
                    radius: Theme.innerRadius
                    border.width: Theme.borderWidth
                    border.color: Theme.surface1
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Theme.popupSpacing

                        Text {
                            text: Qt.formatDateTime(clock.date, "hh\nmm")
                            color: Theme.text
                            font.family: Theme.barFont.family
                            font.weight: Theme.barFont.weight
                            font.pixelSize: 42
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: Qt.formatDateTime(clock.date, "dddd, dd")
                            color: Theme.text
                            font: Theme.barFont
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }
    }
}
