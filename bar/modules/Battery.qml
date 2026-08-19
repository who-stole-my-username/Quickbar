import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import qs

Item {
    property bool isClicked: false
    property real batPerc: UPower.displayDevice.percentage * 100
    property string panelName: "battery"

    implicitWidth: 35
    implicitHeight: 35

    Rectangle {
        id: iconContainer
        anchors.centerIn: parent
        color: "transparent"
        implicitWidth: 35
        implicitHeight: 35
        radius: 100

        Text {
            id: smallBatteryDisplay
            anchors.centerIn: parent
            font.family: Fonts.icon
            font.pointSize: Fonts.sizeIcon
            renderType: Text.NativeRendering
            font.hintingPreference: Font.PreferNoHinting
            font.variableAxes: ({ "FILL": batPerc / 100 })
            color: batPerc <= 15 ? Colors.error : Colors.on_surface
            text: UPower.displayDevice.state === UPowerDeviceState.Charging ? "battery_android_bolt" : batPerc <= 15 ? "battery_android_alert" : "battery_android_0"

            Behavior on color {
                ColorAnimation {
                    duration: Anims.effectsFastDur
                    easing.bezierCurve: Anims.effectsFast
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                isClicked = !isClicked
            }
        }
    }
}
