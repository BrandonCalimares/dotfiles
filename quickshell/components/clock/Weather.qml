import QtQuick
import Quickshell.Io
import QtQuick.Layouts
import "../.."

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

    property var temp: null
    property int weatherCode: 0
    property bool loading: temp === null

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
                font: Theme.lFont
            }

            Text {
                text: weather.loading ? "..." : weather.wmoText(weather.weatherCode)
                color: Theme.subtext0
                font: Theme.sFont
            }
        }
    }
}
