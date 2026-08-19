import Quickshell
import Quickshell.Io
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import qs

Item {
    readonly property var wifiDev: Networking.devices.values.find(x => x.type === DeviceType.Wifi) || null
    readonly property var activeNet: wifiDev && wifiDev.networks ? wifiDev.networks.values.find(n => n && n.connected) || null : null
    readonly property var signal: activeNet ? activeNet.signalStrength : 0
    property bool isClicked: false
    property string panelName: "connection"

    implicitWidth: 35
    implicitHeight: 35

    Rectangle {
        anchors.centerIn: parent
        color: "transparent"
        implicitWidth: 35
        implicitHeight: 35
        radius: 100

        Text {
            id: smallConnectionDisplay
            anchors.centerIn: parent
            anchors.verticalCenter: parent.verticalCenter
            font.family: Fonts.icon
            font.pointSize: Fonts.sizeIcon
            color: Colors.on_surface
            text: {
                if (activeNet == null) {
                    return "signal_wifi_off"
                } else {
                    if (signal <= 0.1) {
                        return "signal_wifi_0_bar"
                    } else if (signal <= 0.2) {
                        return "network_wifi_1_bar"
                    } else if (signal <= 0.4) {
                        return "network_wifi_2_bar"
                    } else if (signal <= 0.6) {
                        return "network_wifi_3_bar"
                    } else if (signal <= 0.8) {
                        return "network_wifi"
                    } else if (signal <= 1) {
                        return "signal_wifi_4_bar"
                    }
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
