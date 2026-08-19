import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs

Item {
    property real brightnessLvl: 0

    Rectangle {
        id: barContainer
        anchors.fill: parent
        anchors.topMargin: 1
        anchors.margins: 15
        radius: 12
        color: Colors.surface_container
        clip: true

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
                renderType: Text.NativeRendering
                font.hintingPreference: Font.PreferNoHinting
                font.variableAxes: ({ "FILL": 1 })
                text: "lightbulb"
                color: Colors.on_primary
            }
        }

        Text {
            id: brightnessDisplay
            anchors.verticalCenter: iconContainer.verticalCenter
            anchors.left: iconContainer.right
            anchors.leftMargin: 15
            font.pointSize: Fonts.sizeM
            font.family: Fonts.ui
            text: "Brightness"
            color: Colors.on_surface
        }

        Row {
            id: brightnessPercRow
            anchors.top: iconContainer.bottom
            anchors.topMargin: 22
            anchors.left: parent.left
            anchors.leftMargin: 20
            spacing: 4

            Text {
                id: brightnessPerc
                font.pointSize: Fonts.sizeXXL
                font.family: Fonts.ui
                text: brightnessLvl
                color: brightnessLvl < 90 ? Colors.on_surface : Colors.error
            }

            Text {
                anchors.baseline: brightnessPerc.baseline
                font.pointSize: Fonts.sizeM
                font.family: Fonts.ui
                font.variableAxes: ({ "wght": 600 })
                text: "%"
                color: brightnessLvl < 90 ? Colors.on_surface : Colors.error
            }
        }

        Rectangle {
            id: percBar
            anchors.top: brightnessPercRow.bottom
            anchors.topMargin: 11
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            height: 5
            color: "transparent"

            Rectangle {
                id: percBarFill
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                width: parent.width * brightnessLvl / 100
                color: brightnessLvl < 90 ? Colors.primary : Colors.error
                radius: 10

                Behavior on color {
                    ColorAnimation {
                        duration: Anims.effectsNormalDur
                        easing.bezierCurve: Anims.effectsNormal
                    }
                }

                Behavior on width {
                    NumberAnimation {
                        duration: Anims.spatialFastDur
                        easing.bezierCurve: Anims.spatialFast
                    }
                }
            }

            Rectangle {
                id: percBarEnd
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.left: percBarFill.right
                anchors.leftMargin: 5
                color: Colors.surface_container_highest
                radius: 10

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 1.75
                    width: 3.5
                    height: 3.5
                    radius: 10
                    color: brightnessLvl < 90 ? Colors.primary : Colors.error
                    
                    Behavior on color { ColorAnimation { duration: 300 }}
                }
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -10

                function apply(x) {
                    let frac = (x - 10) / percBar.width
                    let percSelection = Math.round(frac * 100)
                    percSelection = Math.max(0, Math.min(100, percSelection))
                    setBrightnessLvl.command = [ "brightnessctl", "set", percSelection + "%" ]
                    setBrightnessLvl.running = true
                }

                onClicked: (mouse) => apply(mouse.x)
                onPositionChanged: (mouse) => { if (pressed) apply(mouse.x) }
            }
        }

        Process {
            id: setBrightnessLvl
            running: false
        }

        /*Row {
            anchors.top: percBar.bottom
            anchors.topMargin: 30
            anchors.left: parent.left
            anchors.leftMargin: 20
            spacing: 35

            Rectangle {
                id: minusRect
                anchors.verticalCenter: parent.verticalCenter
                width: 170
                height: 75
                color: mouseAreaMinus.containsMouse ? Colors.primary : Colors.surface_container_high
                radius: mouseAreaMinus.containsMouse ? 12 : 37.5

                Behavior on color { ColorAnimation { duration: 100 }}
                Behavior on radius { NumberAnimation { duration: 100 }}

                Text {
                    anchors.centerIn: parent
                    font.pointSize: 32
                    font.family: "CaskaydiaCove Nerd Font"
                    color: mouseAreaMinus.containsMouse ? Colors.on_primary : Colors.primary
                    text: "-"

                    Behavior on color  { ColorAnimation  { duration: 100 }}
                }

                MouseArea {
                    id: mouseAreaMinus
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        setBrightnessLvl.command = [ "brightnessctl", "set", "5%-" ]
                        setBrightnessLvl.running = true
                    }
                }
            }

            Rectangle {
                id: plusRect
                anchors.verticalCenter: parent.verticalCenter
                width: 170
                height: 75
                color: mouseAreaPlus.containsMouse ? Colors.primary : Colors.surface_container_high
                radius: mouseAreaPlus.containsMouse ? 12 : 37.5

                Behavior on color { ColorAnimation { duration: 100 }}
                Behavior on radius { NumberAnimation { duration: 100 }}

                Text {
                    anchors.centerIn: parent
                    font.pointSize: 32
                    font.family: "CaskaydiaCove Nerd Font"
                    color: mouseAreaPlus.containsMouse ? Colors.on_primary : Colors.primary
                    text: "+"
                    
                    Behavior on color  { ColorAnimation  { duration: 100 }}
                }

                MouseArea {
                    id: mouseAreaPlus
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        setBrightnessLvl.command = [ "brightnessctl", "set", "+5%" ]
                        setBrightnessLvl.running = true
                    }
                }
            }
        }*/
    }
}