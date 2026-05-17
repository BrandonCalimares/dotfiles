pragma Singleton
import Quickshell
import QtQuick

Singleton {
    property var c: Catppuccin

    // Colors
    readonly property string accent: c.peach
    readonly property string rosewater: c.rosewater
    readonly property string flamingo: c.flamingo
    readonly property string pink: c.pink
    readonly property string mauve: c.mauve
    readonly property string red: c.red
    readonly property string maroon: c.maroon
    readonly property string peach: c.peach
    readonly property string yellow: c.yellow
    readonly property string green: c.green
    readonly property string teal: c.teal
    readonly property string sky: c.sky
    readonly property string sapphire: c.sapphire
    readonly property string blue: c.blue
    readonly property string lavender: c.lavender
    readonly property string text: c.text
    readonly property string subtext1: c.subtext1
    readonly property string subtext0: c.subtext0
    readonly property string overlay2: c.overlay2
    readonly property string overlay1: c.overlay1
    readonly property string overlay0: c.overlay0
    readonly property string surface2: c.surface2
    readonly property string surface1: c.surface1
    readonly property string surface0: c.surface0
    readonly property string base: c.base
    readonly property string mantle: c.mantle
    readonly property string crust: c.crust

    readonly property color background: Qt.alpha(mantle, 0.8)

    // Fonts
    readonly property font smallFont: Qt.font({
        family: "JetBrainsMono NerdFont",
        pixelSize: 12
    })

    readonly property font mediumFont: Qt.font({
        family: "JetBrainsMono NerdFont",
        pixelSize: 13,
        weight: Font.Bold
    })

    readonly property font barFont: Qt.font({
        family: "JetBrainsMono NerdFont",
        pixelSize: 14,
        weight: Font.Bold
    })

    readonly property font bigFont: Qt.font({
        family: "JetBrainsMono NerdFont",
        pixelSize: 16,
        weight: Font.Bold
    })

    readonly property font largeFont: Qt.font({
        family: "JetBrainsMono NerdFont",
        pixelSize: 22,
        weight: Font.Bold
    })

    // Bar Dimensions
    readonly property int barHeight: barFont.pixelSize + 15
    readonly property int barWidth: barFont.pixelSize + 20
    readonly property int barPadding: 8
    readonly property int barSpacing: 6
    readonly property int outerMargin: 14
    readonly property int outerRadius: 13
    readonly property int innerRadius: 8
    readonly property int borderWidth: 1

    // Popup Dimensions
    readonly property int popupPadding: 14
    readonly property int popupSpacing: barSpacing * 3
    readonly property int popupInnerSpacing: barSpacing * 2
    readonly property int pfpSize: 84
    readonly property int volumeBarWidth: 160
    readonly property int volumeBarHeight: 6
    readonly property int musicBarWidth: 220
    readonly property int musicBarHeight: volumeBarHeight
    readonly property int appWidth: 380

    // Animations
    readonly property int colorDuration: 150
    readonly property int popupDuration: 200
    readonly property int widthDuration: 200
}
