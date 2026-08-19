
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts
import qs

Item {
    id: idk
    readonly property var wifiDev: Networking.devices.values.find(x => x.type === DeviceType.Wifi) || null
    readonly property var activeNet: wifiDev && wifiDev.networks ? wifiDev.networks.values.find(n => n && n.connected) || null : null
    readonly property var signal: activeNet ? activeNet.signalStrength : 0

    property string activeVpn
    property string activeVpnLocation

    property bool wifiExp: false
    property bool vpnExp: false
    property real connectionsHeight: (wifiExp ? 300 : 80) + (vpnExp ? 200 : 80) + 92 + 15

    Rectangle {
        id: barContainer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 1
        anchors.margins: 15
        height: idk.wifiExp ? 300 : 80
        radius: 12
        color: Colors.surface_container
        clip: true

        Behavior on height {
            NumberAnimation {
                duration: Anims.spatialFastDur
                easing.type: Easing.Bezier
                easing.bezierCurve: Anims.spatialFast
            }
        }

        Rectangle {
            id: iconContainer
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 20
            anchors.leftMargin: 20
            height: 40
            width: 40
            radius: 10
            color: Colors.primary
            
            Text {
                anchors.centerIn: parent
                font.family: Fonts.icon
                font.pointSize: Fonts.sizeIcon
                text: "signal_wifi_4_bar"
                color: Colors.on_primary
            }
        }

        Text {
            id: connectionDisplay
            anchors.verticalCenter: iconContainer.verticalCenter
            anchors.left: iconContainer.right
            anchors.leftMargin: 15
            font.pointSize: Fonts.sizeM
            font.family: Fonts.ui
            text: "Wi-Fi"
            color: Colors.on_surface
        }

        Text {
            id: dropDownWiFi
            anchors.verticalCenter: connectionDisplay.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 8
            font.pointSize: 30
            font.family: Fonts.icon
            color: Colors.on_surface
            text: "arrow_drop_down"
            rotation: wifiExp ? 180 : 0

            Behavior on rotation {
                NumberAnimation {
                    duration: Anims.spatialFastDur
                    easing.type: Easing.Bezier
                    easing.bezierCurve: Anims.spatialFast
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: idk.wifiExp = !idk.wifiExp
        }

        Rectangle {
            id: connectionStatusDisplayBox
            anchors.verticalCenter: connectionDisplay.verticalCenter
            anchors.right: dropDownWiFi.left
            anchors.rightMargin: 7
            color: Colors.secondary
            width: connectionStatusDisplay.implicitWidth + 15
            height: connectionStatusDisplay.implicitHeight + 5
            radius: 5

            Text {
                id: connectionStatusDisplay
                anchors.centerIn: parent
                font.pointSize: Fonts.sizeS
                font.family: Fonts.ui
                text: activeNet == null ? "Disabled" : "Enabled"
                color: Colors.on_secondary
            }
        }
    }

    Rectangle {
        id: barContainerVpn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: barContainer.bottom
        anchors.margins: 15
        height: idk.vpnExp ? 200 : 80
        radius: 12
        color: Colors.surface_container
        clip: true

        Behavior on height {
            NumberAnimation {
                duration: Anims.spatialFastDur
                easing.type: Easing.Bezier
                easing.bezierCurve: Anims.spatialFast
            }
        }

        Rectangle {
            id: iconContainerVpn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 20
            anchors.leftMargin: 20
            height: 40
            width: 40
            radius: 10
            color: Colors.primary
            
            Text {
                anchors.centerIn: parent
                font.family: Fonts.icon
                font.pointSize: Fonts.sizeIcon
                renderType: Text.NativeRendering
                font.hintingPreference: Font.PreferNoHinting
                font.variableAxes: ({ "FILL": 1 })
                text: "vpn_key"
                color: Colors.on_primary
            }
        }

        Text {
            id: connectionDisplayVpn
            anchors.verticalCenter: iconContainerVpn.verticalCenter
            anchors.left: iconContainerVpn.right
            anchors.leftMargin: 15
            font.pointSize: Fonts.sizeM
            font.family: Fonts.ui
            text: "VPN"
            color: Colors.on_surface
        }

        Text {
            id: dropDownVpn
            anchors.verticalCenter: connectionDisplayVpn.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 8
            font.pointSize: 30
            font.family: Fonts.icon
            color: Colors.on_surface
            text: "arrow_drop_down"
            rotation: vpnExp ? 180 : 0

            Behavior on rotation {
                NumberAnimation {
                    duration: Anims.spatialFastDur
                    easing.type: Easing.Bezier
                    easing.bezierCurve: Anims.spatialFast
                }
            }
        }

        Rectangle {
            id: connectionStatusDisplayBoxVpn
            anchors.verticalCenter: connectionDisplayVpn.verticalCenter
            anchors.right: dropDownVpn.left
            anchors.rightMargin: 7
            color: Colors.secondary
            width: connectionStatusDisplayVpn.implicitWidth + 15
            height: connectionStatusDisplayVpn.implicitHeight + 5
            radius: 5

            Text {
                id: connectionStatusDisplayVpn
                anchors.centerIn: parent
                font.pointSize: Fonts.sizeS
                font.family: Fonts.ui
                color: Colors.on_secondary
                text: activeVpn == "" ? "Disabled" : "Enabled"
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: idk.vpnExp = !idk.vpnExp //barContainer.height == 80 ? barContainer.height = 200 : barContainer.height = 80
        }

        /*Text {
            anchors.top: iconContainerVpn.bottom
            anchors.topMargin: 22
            anchors.left: parent.left
            anchors.leftMargin: 20
            font.pointSize: Fonts.sizeL
            font.family: Fonts.ui
            text: activeVpn
            color: Colors.on_surface
        }*/

        Process {
            command: [ "nmcli", "monitor" ]
            running: true
            stdout: SplitParser {
                onRead: (line) => {
                    vpnCheck.running = true
                }
            }
        }

        Process {
            id: vpnCheck
            command:  [ "bash", "-c", "nmcli -t -f TYPE,NAME connection show --active | rg '^(vpn|wireguard):'" ]
            stdout: StdioCollector {
                onStreamFinished: {
                    let vpn = this.text.trim().split("\n")
                    let loc = ""
                    if ( vpn.find(line => line.includes("wireguard"))) {
                        vpn = vpn.find(line => line.includes("wireguard"))
                        vpn = vpn.split(":")
                        vpn = vpn[1].split(" ")
                        loc = vpn[1]
                        vpn = vpn[0]
                    } else {
                        vpn = ""
                    }

                    activeVpn = vpn
                    activeVpnLocation = loc
                }
            }
        }
    }
}

//nmcli -t -f TYPE,NAME connection show --active | rg '^(vpn|wireguard):'
//wireguard:ProtonVPN LU#8