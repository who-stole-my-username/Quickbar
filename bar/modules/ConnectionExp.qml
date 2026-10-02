
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
    property real connectionsHeight: (wifiExp ? 80 + connectionsContainer.height + 20 : 80) + (vpnExp ? 200 : 80) + 92 + 15
    
    onWifiExpChanged: if (wifiDev) wifiDev.scannerEnabled = wifiExp

    Rectangle {
        id: barContainer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 1
        anchors.margins: 15
        height: idk.wifiExp ? 80 + connectionsContainer.height + 20 : 80
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

        ListView {
            id: connectionsContainer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 80
            anchors.margins: 20
            height: Math.min(contentHeight, 210)
            spacing: 3
            clip: true

            model: idk.wifiDev ? idk.wifiDev.networks : null

            Behavior on contentY {
                NumberAnimation {
                    duration: Anims.spatialFastDur
                    easing.type: Easing.Bezier
                    easing.bezierCurve: Anims.spatialFast
                }
            }

            delegate: Item {

                required property var modelData
                required property int index

                property bool expanded: false
                readonly property bool last: index === connectionsContainer.count -1

                id: item
                height: subContainer.height + subSubContainer.anchors.topMargin + subSubContainer.height
                width: ListView.view.width
                onExpandedChanged: if (expanded) connectionsPasswordField.forceActiveFocus()
                
                Rectangle {
                    id:subContainer
                    color: Colors.surface_container_highest
                    topLeftRadius: index === 0 ? 10 : 3
                    topRightRadius: index === 0 ? 10 : 3
                    bottomLeftRadius: (!item.expanded && item.last) ? 10 : 3
                    bottomRightRadius: (!item.expanded && item.last) ? 10 : 3
                    height: 50
                    width: parent.width

                    Text {
                      id: connectionsListIcon
                      anchors.top: parent.top
                      anchors.topMargin: 10
                      anchors.left: parent.left
                      anchors.leftMargin: 10
                      font.pointSize: Fonts.sizeIcon
                      font.family: Fonts.icon
                      text: {
                          if (modelData.signalStrength == null) {
                              return "signal_wifi_off"
                          } else {
                              if (modelData.signalStrength <= 0.1) {
                                  return "signal_wifi_0_bar"
                              } else if (modelData.signalStrength <= 0.2) {
                                  return "network_wifi_1_bar"
                              } else if (modelData.signalStrength <= 0.4) {
                                  return "network_wifi_2_bar"
                              } else if (modelData.signalStrength <= 0.6) {
                                  return "network_wifi_3_bar"
                              } else if (modelData.signalStrength <= 0.8) {
                                  return "network_wifi"
                              } else if (modelData.signalStrength <= 1) {
                                  return "signal_wifi_4_bar"
                              }
                          }
                      }
                      color: Colors.primary
                    }

                    Text {
                      id:connectionsListName
                      anchors.top: parent.top
                      anchors.topMargin: 15
                      anchors.left: connectionsListIcon.right
                      anchors.leftMargin: 10
                      font.pointSize: Fonts.sizeS
                      font.family: Fonts.ui
                      color: Colors.on_surface
                      text: modelData.name
                    }
                    
                    Text {
                      id:connectionsListStatus
                      anchors.top: parent.top
                      anchors.topMargin: 10
                      anchors.right: parent.right
                      anchors.rightMargin: 10
                      font.pointSize: Fonts.sizeIcon
                      font.family: Fonts.icon
                      color: Colors.on_surface
                      text: modelData.connected ? "link" : ""
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onClicked: {
                            item.expanded = !item.expanded
                        }
                    }

                }

                Rectangle {
                    id: subSubContainer
                    color: Colors.surface_container_highest
                    anchors.top: subContainer.bottom
                    anchors.topMargin: height > 0 ? 3 : 0
                    height: item.expanded ? 50 : 0
                    width: parent.width
                    visible: height > 0 
                    clip: true

                    topLeftRadius: 3
                    topRightRadius: 3
                    bottomRightRadius: item.last ? 10 : 3
                    bottomLeftRadius: item.last ? 10 : 3

                    Rectangle {
                        color: "transparent"
                        id: connectionsPasswordBox
                        anchors.fill: parent

                        TextInput {
                            id: connectionsPasswordField
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            verticalAlignment: TextInput.AlignVCenter
                            clip: true
                            echoMode: TextInput.Password
                            passwordCharacter: "●"
                            font.pointSize: Fonts.sizeS
                            font.family: Fonts.ui
                            color: Colors.on_surface
                            selectByMouse: true
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            visible: connectionsPasswordField.text.length === 0
                            font.pointSize: Fonts.sizeS
                            font.family: Fonts.ui
                            color: Colors.on_surface_variant
                            text: "Password"
                        }
                    }
                }
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
