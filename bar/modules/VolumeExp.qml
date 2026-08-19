import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import qs

Item {
    property real volumeLvl: 0
    property var muted: 0

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

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
                text: "volume_up"
                color: Colors.on_primary
            }
        }

        Text {
            id: volumeDisplay
            anchors.verticalCenter: iconContainer.verticalCenter
            anchors.left: iconContainer.right
            anchors.leftMargin: 15
            font.pointSize: Fonts.sizeM
            font.family: Fonts.ui
            text: "Volume"
            color: Colors.on_surface
        }

        Rectangle {
            id: volumeStatusDisplayBox
            anchors.verticalCenter: volumeDisplay.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 20
            color: Colors.secondary
            width: volumeStatusDisplay.implicitWidth + 15
            height: volumeStatusDisplay.implicitHeight + 5
            radius: 5

            Text {
                id: volumeStatusDisplay
                anchors.centerIn: parent
                font.pointSize: Fonts.sizeS
                font.family: Fonts.ui
                text: Pipewire.defaultAudioSink.nickname == "Pro" ? "Internal" : "External"
                color: Colors.on_secondary
            }
        }

        Row {
            id: percRow
            anchors.top: iconContainer.bottom
            anchors.topMargin: 22
            anchors.left: parent.left
            anchors.leftMargin: 20
            spacing: 4

            Text {
                id: volumePerc
                font.pointSize: Fonts.sizeXXL
                font.family: Fonts.ui
                text: Math.round(volumeLvl * 100)
                color: muted ? Colors.on_surface_variant : volumeLvl < 0.01 ? Colors.on_surface_variant : volumeLvl >= 1 ? Colors.error : Colors.on_surface

                Behavior on color {
                    ColorAnimation {
                        duration: Anims.effectsNormalDur
                        easing.bezierCurve: Anims.effectsNormal
                    }
                }
            }

            Text {
                anchors.baseline: volumePerc.baseline
                font.pointSize: Fonts.sizeM
                font.family: Fonts.ui
                font.variableAxes: ({ "wght": 600 })
                text: "%"
                color: muted ? Colors.on_surface_variant : volumeLvl < 0.01 ? Colors.on_surface_variant : volumeLvl >= 1 ? Colors.error : Colors.on_surface
                
                Behavior on color {
                    ColorAnimation {
                        duration: Anims.effectsNormalDur
                        easing.bezierCurve: Anims.effectsNormal
                    }
                }
            }
        }

        Canvas {
            property real progress: muted ? 1 : volumeLvl < 0.01 ? 1 : 0 

            id: diagonal
            height: percRow.height
            width: percRow.width
            anchors.horizontalCenter: percRow.horizontalCenter
            anchors.verticalCenter: percRow.verticalCenter
            onProgressChanged: requestPaint()
            
            Behavior on progress {
                NumberAnimation {
                    duration: Anims.effectsNormalDur
                    easing.bezierCurve: Anims.effectsNormal
                }
            }

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                ctx.beginPath()
                ctx.moveTo(2, 9)
                ctx.lineTo(2 + progress * (width - 4), 9 + progress * (height - 18))
                ctx.strokeStyle = Colors.on_surface_variant
                ctx.lineWidth = 4
                ctx.lineCap = "round"
                ctx.stroke()
            }
        }

        Rectangle {
            id: percBar
            anchors.top: percRow.bottom
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
                width: parent.width * (volumeLvl <= 1 ? volumeLvl : 1)
                color: volumeLvl < 1 ? Colors.primary : Colors.error
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
                    color: volumeLvl <= 1 ? Colors.primary : Colors.error
                    
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
                    setVolumeLvl.command = [ "wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", percSelection + "%" ]
                    setVolumeLvl.running = true
                }

                onClicked: (mouse) => apply(mouse.x)
                onPositionChanged: (mouse) => { if (pressed) apply(mouse.x) }
            }
        }

        Process {
            id: setVolumeLvl
            running: false
        }
/*
        Row {
            anchors.top: percBar.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            spacing: 30

            Rectangle {
                id: minusRect
                anchors.verticalCenter: parent.verticalCenter
                width: 105
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
                        setVolumeLvl.command = [ "wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-" ]
                        setVolumeLvl.running = true
                    }
                }
            }

            Rectangle {
                id: smth
                anchors.verticalCenter: parent.verticalCenter
                width: 105
                height: 75
                radius: 37.5
                color: Colors.surface_container_high
            }

            Rectangle {
                id: plusRect
                anchors.verticalCenter: parent.verticalCenter
                width: 105
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
                        setVolumeLvl.command = [ "wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+" ]
                        setVolumeLvl.running = true
                    }
                }
            }
        }*/
    }
}