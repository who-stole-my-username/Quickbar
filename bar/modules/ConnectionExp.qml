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
    property string connectCode: ""

    property bool wifiExp: false
    property bool vpnExp: false
    property real connectionsHeight: (wifiExp ? 80 + connectionsContainer.height + (connectionsContainer.count === 0 ? 70 : 20) : 80) + (vpnExp ? 80 + vpnLocationSearch.height + 20 + vpnList.height + (vpnList.count === 0 ? 70 : 20) : 80) + 92 + 15

    readonly property var filterCountries: {
        const allCountries = Object.keys(Countries.countries)
        const search = vpnSearchField.text.trim().toLowerCase()
        if (search === "") return allCountries

        return allCountries.filter(code => Countries.countries[code].toLowerCase().includes(search) || code.toLowerCase().includes(search))
    }

    onWifiExpChanged: if (wifiDev) {
        wifiDev.scannerEnabled = wifiExp
    }

    onVpnExpChanged: vpnSearchField.text = ""

    function calcListHeight(items) {
        return items * 50 + (items - 1) * 3
    }

    function connectVpn(code) {
        if (connectToVpn.running == true) return
        connectToVpn.country = code
        idk.connectCode = code
        connectToVpn.running = true
    }

    Rectangle {
        id: barContainer
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 1
        anchors.margins: 15
        height: idk.wifiExp ? 80 + connectionsContainer.height + (connectionsContainer.count === 0 ? 70 : 20) : 80
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
                text: activeNet == null ? "Disconnected" : "Connected"
                color: Colors.on_secondary
            }
        }

        ListView {
            id: connectionsContainer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 80
            anchors.margins: 10
            height: Math.min(contentHeight, idk.calcListHeight(4))
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
                id: item

                required property var modelData
                required property int index

                property bool expanded: false
                readonly property bool last: index === connectionsContainer.count - 1

                height: subContainer.height + subSubContainer.anchors.topMargin + subSubContainer.height
                width: ListView.view.width
                onExpandedChanged: if (expanded) {
                    connectionsPasswordField.forceActiveFocus()
                }
                function submitPassword() {
                    const pwd = connectionsPasswordField.text;
                    if (pwd.length >= 8) {
                        modelData.connectWithPsk(pwd);
                    }
                    connectionsPasswordField.text = "";
                    expanded = !expanded;
                }

                Rectangle {
                    id: subContainer
                    color: Colors.surface_container_highest
                    topLeftRadius: index === 0 ? 10 : 3
                    topRightRadius: index === 0 ? 10 : 3
                    bottomLeftRadius: (!item.expanded && item.last) ? 10 : 3
                    bottomRightRadius: (!item.expanded && item.last) ? 10 : 3
                    height: 50
                    x: 10
                    width: parent.width - 20
                    scale: mouseArea.pressed ? 1.02 : 1

                    Behavior on scale {
                        NumberAnimation {
                            properties: "scale"
                            duration: Anims.spatialFastDur
                            easing.bezierCurve: Anims.spatialFast
                        }
                    }

                    Text {
                        id: connectionsListIcon
                        anchors.top: parent.top
                        anchors.topMargin: 10
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        font.pointSize: Fonts.sizeIcon
                        font.family: Fonts.icon
                        color: Colors.on_surface
                        text: {
                            if (modelData.signalStrength == null) {
                                return "signal_wifi_off";
                            } else {
                                if (modelData.signalStrength <= 0.1) {
                                    return "signal_wifi_0_bar";
                                } else if (modelData.signalStrength <= 0.2) {
                                    return "network_wifi_1_bar";
                                } else if (modelData.signalStrength <= 0.4) {
                                    return "network_wifi_2_bar";
                                } else if (modelData.signalStrength <= 0.6) {
                                    return "network_wifi_3_bar";
                                } else if (modelData.signalStrength <= 0.8) {
                                    return "network_wifi";
                                } else if (modelData.signalStrength <= 1) {
                                    return "signal_wifi_4_bar";
                                }
                            }
                        }
                    }

                    Text {
                        id: connectionsListName
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
                        id: connectionsListStatus
                        anchors.top: parent.top
                        anchors.topMargin: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        font.pointSize: Fonts.sizeIcon
                        font.family: Fonts.icon
                        color: Colors.on_surface
                        text: modelData.connected ? "check" : ""
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onClicked: {
                            if (modelData.connected) {
                                modelData.disconnect();
                                return;
                            }

                            if (modelData.known) {
                                modelData.connect();
                            } else {
                                item.expanded = !item.expanded;
                            }
                        }
                    }
                }

                Rectangle {
                    id: subSubContainer
                    color: Colors.surface_container_highest
                    anchors.top: subContainer.bottom
                    anchors.topMargin: height > 0 ? 3 : 0
                    height: item.expanded ? 50 : 0
                    visible: height > 0
                    x: 10
                    width: parent.width - 20
                    clip: true

                    topLeftRadius: 3
                    topRightRadius: 3
                    bottomRightRadius: item.last ? 10 : 3
                    bottomLeftRadius: item.last ? 10 : 3

                    Rectangle {
                        id: connectionsPasswordBox
                        color: "transparent"
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

                            onAccepted: item.submitPassword()
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

        Rectangle {
            id: connectionsListDefaultValue
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 80
            anchors.margins: 20
            color: Colors.surface_container_highest
            height: 50
            radius: 10
            visible: connectionsContainer.count === 0 ? true : false

            Text {
                id: connectionsErrorIcon
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                font.pointSize: Fonts.sizeIcon
                font.family: Fonts.icon
                color: Colors.on_surface
                text: "error"
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: connectionsErrorIcon.right
                anchors.leftMargin: 10
                font.pointSize: Fonts.sizeM
                font.family: Fonts.ui
                color: Colors.on_surface
                text: !Networking.wifiEnabled ? "Wi-Fi is turned off" : "No networks in range"
            }
        }
    }

    Rectangle {
        id: barContainerVpn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: barContainer.bottom
        anchors.margins: 15
        height: idk.vpnExp ? 80 + vpnLocationSearch.height + 20 + vpnList.height + (vpnList.count === 0 ? 70 : 20) : 80
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

        MouseArea {
            anchors.fill: parent
            onClicked: idk.vpnExp = !idk.vpnExp
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
                font.variableAxes: ({
                        "FILL": 1
                    })
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
                text: connectToVpn.running === true ? "Connecting" : (disconnectVpn.running === true ? "Disonnecting" : (activeVpn == "" ? "Disabled" : "Enabled"))
            }
        }

        Rectangle {
            id: vpnLocationSearch
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 80
            anchors.margins: 20
            height: 50
            color: Colors.surface_container_highest
            radius: 10

            Text {
                id: searchIcon
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 10
                font.pointSize: Fonts.sizeIcon
                font.family: Fonts.icon
                color: Colors.on_surface
                text: "search"
            }

            TextInput {
                id: vpnSearchField
                anchors.fill: parent
                anchors.leftMargin: 48
                anchors.rightMargin: 10
                verticalAlignment: TextInput.AlignVCenter
                clip: true
                font.pointSize: Fonts.sizeS
                font.family: Fonts.ui
                color: Colors.on_surface
                selectByMouse: true
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: searchIcon.right
                anchors.leftMargin: 10
                visible: vpnSearchField.text.length === 0
                font.pointSize: Fonts.sizeS
                font.family: Fonts.ui
                color: Colors.on_surface_variant
                text: "Search coutnries"
            }

            Text {
                id: clearSearchIcon
                anchors.top: parent.top
                anchors.topMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                font.pointSize: Fonts.sizeIcon
                font.family: Fonts.icon
                color: Colors.on_surface
                text: "close"
                visible: vpnSearchField.text === "" ? false : true
                rotation: 0

                MouseArea {
                    anchors.fill: parent
                    onClicked: vpnSearchField.text = ""
                }
            }
        }

        ListView {
            id: vpnList
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: vpnLocationSearch.bottom
            anchors.margins: 10
            anchors.topMargin: 20
            height: Math.min(contentHeight, idk.calcListHeight(4))
            spacing: 3
            clip: true

            model: idk.filterCountries

            delegate: Item {

                required property string modelData
                required property int index

                readonly property string code: modelData
                readonly property string name: Countries.countries[code]

                readonly property bool last: index === vpnList.count - 1

                id: vpnListItem
                height: vpnEntryBox.height
                width: ListView.view.width

                Rectangle {
                    id: vpnEntryBox
                    color: Colors.surface_container_highest
                    topLeftRadius: index === 0 ? 10 : 3
                    topRightRadius: index === 0 ? 10 : 3
                    bottomLeftRadius: vpnListItem.last ? 10 : 3
                    bottomRightRadius: vpnListItem.last ? 10 : 3
                    height: 50
                    x: 10
                    width: parent.width - 20
                    scale: vpnMouseArea.pressed ? 1.02 : 1

                    Behavior on scale {
                        NumberAnimation {
                            properties: "scale"
                            duration: Anims.spatialFastDur
                            easing.bezierCurve: Anims.spatialFast
                        }
                    }

                    Text {
                        id: vpnListIcon
                        anchors.top: parent.top
                        anchors.topMargin: 10
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        font.pointSize: Fonts.sizeIcon
                        font.family: Fonts.icon
                        color: Colors.on_surface
                        text: "globe"
                    }

                    Text {
                        id: vpnListName
                        anchors.top: parent.top
                        anchors.topMargin: 15
                        anchors.left: vpnListIcon.right
                        anchors.leftMargin: 10
                        font.pointSize: Fonts.sizeS
                        font.family: Fonts.ui
                        color: Colors.on_surface
                        text: name
                    }

                    Text {
                        id: vpnListCode
                        anchors.top: parent.top
                        anchors.topMargin: 15
                        anchors.left: vpnListName.right
                        anchors.leftMargin: 5
                        font.pointSize: Fonts.sizeS
                        font.family: Fonts.ui
                        color: Colors.on_surface_variant
                        text: "(" + code + ")"
                    }

                    Text {
                        id: vpnListStatus
                        anchors.top: parent.top
                        anchors.topMargin: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        font.pointSize: Fonts.sizeIcon
                        font.family: Fonts.icon
                        color: Colors.on_surface
                        text: (connectToVpn.running === true && idk.connectCode == code) || (disconnectVpn.running === true && idk.activeVpn === code) ? "progress_activity" : (idk.activeVpn == code ? "check" : "")
                        RotationAnimation on rotation {
                            running: connectToVpn.running && idk.connectCode === code || disconnectVpn.running && idk.activeVpn === code
                            from: 0
                            to: 360
                            duration: 1000
                            loops: Animation.Infinite
                        }
                        onTextChanged: rotation = 0
                    }

                    MouseArea {
                        id: vpnMouseArea
                        anchors.fill: parent
                        onClicked: {
                            if (idk.activeVpn == code) {
                                disconnectVpn.running = true
                            } else {
                                idk.connectVpn(code)
                            }

                        }
                    }
                }
            }
        }

        Rectangle {
            id: vpnListDefaultValue
            anchors.top: vpnLocationSearch.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 20
            anchors.margins: 20
            color: Colors.surface_container_highest
            height: 50
            radius: 10
            visible: vpnList.count === 0 ? true : false
            clip: true

            Text {
                id: vpnErrorIcon
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                font.pointSize: Fonts.sizeIcon
                font.family: Fonts.icon
                color: Colors.on_surface
                text: "error"
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: vpnErrorIcon.right
                anchors.leftMargin: 10
                font.pointSize: Fonts.sizeM
                font.family: Fonts.ui
                color: Colors.on_surface
                text: "No country matches: " + vpnSearchField.text.trim()
            }
        }

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
            command: ["bash", "-c", "nmcli -t -f NAME,DEVICE connection show --active | rg ':proton0$'"]
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    let line = this.text.trim().split("\n");
                    let vpn = "";
                    if (line == "") {
                        idk.activeVpn = ""
                        return
                    }

                    line = line[0].split(":");
                    line = line[0].split(" ");
                    vpn = line[1].slice(0, 2).toUpperCase();

                    idk.activeVpn = vpn;
                }
            }
        }

        Process {
            id: connectToVpn
            property string country
            command: ["protonvpn", "connect", "--country", country]
            onExited: idk.connectCode = ""
        }

        Process {
            id: disconnectVpn
            command: ["protonvpn", "disconnect"]
        }
    }
}
