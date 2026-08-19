import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs

Item {
    implicitWidth: 155
    implicitHeight: 75

    Row {
        id: workspaceRow
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 8
        spacing: 0
        clip: true
        width: 155

        Repeater {
            model: {
                let ws = [];
                if (Hyprland.workspaces) {
                    for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
                        ws.push(Hyprland.workspaces.values[i]);
                    }
                }
                ws.sort((a, b) => a.id - b.id);
                return ws.filter(w => w.id > 0);
            }

            delegate: Item {
                id: wokspaceItem
                required property var modelData

                width: 32
                height: 40

                Rectangle {
                    id: workspaceRect

                    state: {
                        if (modelData.id === Hyprland.focusedMonitor?.activeWorkspace?.id)
                            return "active";
                        if (mouseArea.containsMouse)
                            return "hovered";
                        return "";
                    }

                    anchors.centerIn: parent
                    width: 10
                    height: 10
                    radius: 20
                    color: Colors.on_surface

                    states: [
                        State {
                            name: "active"
                            PropertyChanges {
                                target: workspaceRect
                                width: 20
                                color: Colors.primary
                            }
                        },
                        State {
                            name: "hovered"
                            PropertyChanges {
                                target: workspaceRect
                                width: 20
                            }
                        }
                    ]

                    transitions: [
                        Transition {
                            to: "active"
                            ColorAnimation {
                                properties: "color"
                                duration: Anims.effectsNormalDur
                                easing.bezierCurve: Anims.effectsNormal
                            }
                            NumberAnimation {
                                properties: "width"
                                duration: Anims.spatialFastDur
                                easing.bezierCurve: Anims.spatialFast
                            }
                        },
                        Transition {
                            from: "active"
                            ColorAnimation {
                                properties: "color"
                                duration: Anims.effectsNormalDur
                                easing.bezierCurve: Anims.effectsNormal
                            }
                            NumberAnimation {
                                properties: "width"
                                duration: Anims.spatialFastDur
                                easing.bezierCurve: Anims.spatialFast
                            }
                        },
                        Transition {
                            to: "hovered"
                            NumberAnimation {
                                properties: "width"
                                duration: Anims.spatialFastDur
                                easing.bezierCurve: Anims.spatialFast
                            }
                        },
                        Transition {
                            from: "hovered"
                            NumberAnimation {
                                properties: "width"
                                duration: Anims.spatialFastDur
                                easing.bezierCurve: Anims.spatialFast
                            }
                        }
                    ]
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + modelData.id)
                    hoverEnabled: true
                }
            }
        }
    }
}
