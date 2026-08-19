import qs
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "modules" as Modules

Variants {
    model: Quickshell.screens
    delegate: Component {
        PanelWindow {
            id: bar

            required property var modelData

            property string activePanel: ""
            property int activePanelHeight: activePanel == "battery" ? 361 : activePanel == "brightness" ? 262 : activePanel == "volume" ? 262 : activePanel == "connection" ? connectionExp.connectionsHeight : 75
            property string pendingPanel: ""

            property var panelModules: ({ "battery": battery, "brightness": brightness, "volume": volume, "connection": connection })

            screen: modelData
            implicitHeight: 1000
            exclusiveZone: 40
            mask: Region {
                item: mainContainer
            }
            margins {
                bottom: 0
                top: 8
            }
            color: "transparent"
            anchors {
                top: true
                left: true
                right: true
            }

            Rectangle {
                property real targetHeight: activePanel != "" ? activePanelHeight : hoverHandler.hovered ? 75 : 40
                property bool growingHeight: false
                property real lastHeight: 40

                onTargetHeightChanged: {
                    growingHeight = targetHeight > lastHeight
                    lastHeight = targetHeight
                    heightAnimation.easing.bezierCurve = Anims.spatialFast
                }

                id: mainContainer
                width: 128
                height: targetHeight
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                color: Colors.surface
                radius: 100
                transformOrigin: Item.Top
                scale: 1
                clip: true

                GridLayout {
                    id: mainGridLayout
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.top: parent.top
                    anchors.right: parent.right
                    width: 200
                    visible: mainContainer.state == "hovered" || mainContainer.state == "expanded"
                    opacity: mainContainer.state == "hovered" || mainContainer.state == "expanded"

                    Modules.Workspaces { id: workspaces }

                    Rectangle {
                        id: mainGridSpacer
                        width: 90
                        height: 50
                        color: "transparent"
                    }

                    Row {
                        id: iconRow
                        spacing: 3.75
                        clip: true
                        width: 155

                        Modules.Connection { id: connection }
                        Modules.Volume { id: volume }
                        Modules.Brightness { id: brightness }
                        Modules.Battery { id: battery }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            properties: "opacity"
                            duration: 200
                            easing.type: Easing.InQuad
                        }
                    }
                }

                Modules.Clock { 
                    id: clock
                    expanded: mainContainer.state == "hovered" || mainContainer.state == "expanded"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    transformOrigin: Item.Top 
                    anchors.topMargin: 8
                }

                Modules.BatteryExp {
                    id: batteryExp
                    anchors.top: mainGridLayout.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    enabled: mainContainer.state == "expanded" && bar.activePanel == "battery" ? 1 : 0
                    opacity: mainContainer.state == "expanded" && bar.activePanel == "battery" ? 1 : 0 

                    Behavior on opacity {
                        NumberAnimation {
                            properties: "opacity"
                            duration: mainContainer.state == "expanded" ? 150 : 200
                            easing.type: mainContainer.state == "expanded" ? Easing.OutQuad : Easing.InQuad
                        }
                    }
                }

                Modules.BrightnessExp {
                    id: brightnessExp
                    brightnessLvl: brightness.acBrightness
                    anchors.top: mainGridLayout.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    enabled: mainContainer.state == "expanded" && bar.activePanel == "brightness" ? 1 : 0
                    opacity: mainContainer.state == "expanded" && bar.activePanel == "brightness" ? 1 : 0 

                    Behavior on opacity {
                        NumberAnimation {
                            properties: "opacity"
                            duration: mainContainer.state == "expanded" ? 150 : 200
                            easing.type: mainContainer.state == "expanded" ? Easing.OutQuad : Easing.InQuad
                        }
                    }
                }

                Modules.VolumeExp {
                    id: volumeExp
                    volumeLvl: volume.volumeReader
                    muted: volume.mutedReader
                    anchors.top: mainGridLayout.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    enabled: mainContainer.state == "expanded" && bar.activePanel == "volume" ? 1 : 0
                    opacity: mainContainer.state == "expanded" && bar.activePanel == "volume" ? 1 : 0 

                    Behavior on opacity {
                        NumberAnimation {
                            properties: "opacity"
                            duration: mainContainer.state == "expanded" ? 150 : 200
                            easing.type: mainContainer.state == "expanded" ? Easing.OutQuad : Easing.InQuad
                        }
                    }
                }

                Modules.ConnectionExp {
                    id: connectionExp
                    anchors.top: mainGridLayout.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    enabled: mainContainer.state == "expanded" && bar.activePanel == "connection" ? 1 : 0
                    opacity: mainContainer.state == "expanded" && bar.activePanel == "connection" ? 1 : 0 

                    Behavior on opacity {
                        NumberAnimation {
                            properties: "opacity"
                            duration: mainContainer.state == "expanded" ? 150 : 200
                            easing.type: mainContainer.state == "expanded" ? Easing.OutQuad : Easing.InQuad
                        }
                    }
                }

                states: [
                    State {
                        name: "hovered"
                        PropertyChanges {
                            target: mainContainer
                            width: 475
                            radius: 15
                        }
                        PropertyChanges {
                            target: clock
                            scale: 1.5
                            anchors.topMargin: 8
                        }
                    },
                    State {
                        name: "expanded"
                        PropertyChanges {
                            target: mainContainer
                            width: 475
                            radius: 15
                        }

                        PropertyChanges {
                            target: clock
                            scale: 1.5
                            anchors.topMargin: 8
                        }
                    }
                ]

                transitions: [
                    Transition {
                        to: "hovered"
                        from: ""
                        NumberAnimation {
                            properties: "width, height, radius, scale"
                            duration: Anims.spatialFastDur
                            easing.bezierCurve: Anims.spatialFast
                        }

                        AnchorAnimation { 
                            duration: Anims.spatialFastDur
                            easing.bezierCurve: Anims.spatialFast
                        }
                    },
                    Transition {
                        from: "hovered"
                        to: ""
                        NumberAnimation {
                            properties: "width, height, radius, scale"
                            duration: Anims.spatialFastDur
                            easing.bezierCurve: Anims.spatialFast
                        }

                        AnchorAnimation {
                            duration: Anims.spatialFastDur
                            easing.bezierCurve: Anims.spatialFast
                        }
                    },
                    Transition {
                        to: "expanded"
                        from: "hovered"
                        NumberAnimation {
                            properties: "width, height, radius, scale"
                            duration: Anims.spatialFastDur
                            easing.bezierCurve: Anims.spatialFast
                        }

                        AnchorAnimation {
                            duration: Anims.spatialFastDur
                            easing.bezierCurve: Anims.spatialFast
                        }
                    },
                    Transition {
                        from: "expanded"
                        to: "hovered"
                        NumberAnimation {
                            properties: "width, height, radius, scale"
                            duration: Anims.spatialFastDur
                            easing.bezierCurve: Anims.spatialFast
                        }

                        AnchorAnimation {
                            duration: Anims.spatialFastDur
                            easing.bezierCurve: Anims.spatialFast
                        }
                    },
                    Transition {
                        from: "expanded"
                        to: ""
                        NumberAnimation {
                            properties: "width, height, radius, scale"
                            duration: Anims.spatialFastDur
                            easing.bezierCurve: Anims.spatialFast
                        }

                        AnchorAnimation {
                            duration: Anims.spatialFastDur
                            easing.bezierCurve: Anims.spatialFast
                        }
                    }
                ]

                Behavior on height {
                    NumberAnimation {
                        id: heightAnimation
                        duration: Anims.spatialFastDur
                        easing.bezierCurve: Anims.spatialFast
                    }
                }

                Timer { 
                    id: panelSwitchTimer
                    interval: 300
                    onTriggered: {
                        if (bar.pendingPanel != "") {
                            bar.activePanel = bar.pendingPanel
                            bar.pendingPanel = ""
                        }
                    }
                }

                state: activePanel != "" ? "expanded" : hoverHandler.hovered ? "hovered" : ""
            }

            HoverHandler {
                id: hoverHandler
                onHoveredChanged: {
                    if (!hovered) {
                        bar.activePanel = ""
                        battery.isClicked = false
                        brightness.isClicked = false
                    }
                }
            }
            
            function clickHandler(object) {
                if (object.isClicked) {
                    if (bar.activePanel == "") {
                        bar.activePanel = object.panelName
                    } else if (bar.activePanel != "" && bar.activePanel != object.panelName) {
                        if (panelModules[bar.activePanel]) {
                            panelModules[bar.activePanel].isClicked = false
                        }

                        bar.pendingPanel = object.panelName
                        bar.activePanel = ""
                        panelSwitchTimer.start()
                    }
                } else {
                    if (bar.activePanel == object.panelName) {
                        bar.activePanel = ""
                    }
                }

            }

            Connections {
                target: battery
                function onIsClickedChanged() {
                    bar.clickHandler(battery)
                }
            }

            Connections {
                target: brightness
                function onIsClickedChanged() {
                   bar.clickHandler(brightness)
                }
            }
            
            Connections {
                target: volume
                function onIsClickedChanged() {
                   bar.clickHandler(volume)
                }
            }
            
            Connections {
                target: connection
                function onIsClickedChanged() {
                   bar.clickHandler(connection)
                }
            }
        }
    }
}
