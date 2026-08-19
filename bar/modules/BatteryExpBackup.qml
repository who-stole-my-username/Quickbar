import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import qs

Item {
    property real batPerc: UPower.displayDevice.percentage * 100

    Timer {
        id: timer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true 
        onTriggered: {
            lastChargingProc.running = true
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 1
        anchors.margins: 15
        radius: 12
        color: Colors.surface_container_low
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
                text: "battery_android_full"
                color: Colors.on_primary
            }
        }

        Text {
            id: batteryDisplay
            anchors.verticalCenter: iconContainer.verticalCenter
            anchors.left: iconContainer.right
            anchors.leftMargin: 15
            font.pointSize: Fonts.sizeM
            font.family: Fonts.ui
            text: "Battery"
            color: Colors.on_surface
        }

        Rectangle {
            id: batteryStatusDisplayBox
            anchors.verticalCenter: batteryDisplay.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 20
            color: Colors.primary
            width: batteryStatusDisplay.implicitWidth + 15
            height: batteryStatusDisplay.implicitHeight + 5
            radius: 5
            
            Text {
                id: batteryStatusDisplay
                anchors.centerIn: parent
                font.pointSize: Fonts.sizeS
                font.family: Fonts.ui
                text: UPowerDeviceState.toString(UPower.displayDevice.state)
                color: Colors.on_primary
            }
        }

        Row {
            id: batteryPercRow
            anchors.top: iconContainer.bottom
            anchors.topMargin: 22
            anchors.left: parent.left
            anchors.leftMargin: 20
            spacing: 4

            Text {
                id: batteryPerc
                font.pointSize: Fonts.sizeXXL
                font.family: Fonts.ui
                text: Math.round(batPerc)
                color: batPerc <= 15 ? Colors.error : Colors.on_surface
            }

            Text {
                anchors.baseline: batteryPerc.baseline
                font.pointSize: Fonts.sizeM
                font.family: Fonts.ui
                font.variableAxes: ({ "wght": 600 })
                text: "%"
                color: batPerc <= 15 ? Colors.error : Colors.on_surface
            }
        }

        Canvas {
            property real phase: 0
            property real dotY: 0
            property real frequency: 0.12

            id: waveCanvas
            anchors.left: parent.left
            anchors.leftMargin: 25
            anchors.top: batteryPercRow.bottom
            anchors.topMargin: 6
            anchors.right: parent.right
            anchors.rightMargin: 20
            height: 15
            clip:false

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                var amplitude = UPower.displayDevice.state === UPowerDeviceState.Charging ? 4 : 0
                var midY = height / 2
                var progressX = width * batPerc / 100

                ctx.beginPath()
                ctx.moveTo(progressX + 10, midY)
                ctx.lineTo(width, midY)
                ctx.strokeStyle = Colors.surface_container_highest
                ctx.lineWidth = 5
                ctx.lineCap = "round"
                ctx.stroke()

                ctx.beginPath()
                ctx.arc(width - 2.5, midY, 2, 0, Math.PI * 2)
                ctx.fillStyle = batPerc <= 15 ? Colors.error : Colors.primary
                ctx.fill()

                ctx.beginPath()
                for (var x = 0; x <= progressX; x++) {
                    var y = midY + amplitude * Math.sin(frequency * x + phase)
                    if (x === 0) {
                        ctx.moveTo(x, y)
                    } else {
                        ctx.lineTo(x, y)
                    }
                }
                ctx.strokeStyle = batPerc <= 15 ? Colors.error : Colors.primary
                ctx.lineWidth = 5
                ctx.lineCap = "round"
                ctx.stroke()
            }

            Timer {
                interval: 16
                running: true
                repeat: true
                onTriggered: {
                    waveCanvas.phase += 0.04;
                    waveCanvas.dotY = waveCanvas.height / 2 + (UPower.displayDevice.state === UPowerDeviceState.Charging ? 4 : 0) * Math.sin(waveCanvas.frequency * 0 + waveCanvas.phase)
                    waveCanvas.requestPaint()
                }
            }
        }

        Rectangle {
            y: waveCanvas.y + waveCanvas.dotY - height / 2
            anchors.horizontalCenter: waveCanvas.left
            width: 5
            height: 5
            radius: 10
            color: batPerc <= 15 ? Colors.error : Colors.primary
        }

        GridLayout {
            anchors.top: waveCanvas.bottom
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.topMargin: 25
            columnSpacing: 100

            Column {
                id: leftColumn
                spacing: 7

                Text {
                    id: batteryTimeDesc
                    anchors.left: leftColumn.left
                    font.pointSize: Fonts.sizeS
                    font.family: Fonts.ui
                    color: Colors.on_surface_variant
                    text: UPower.displayDevice.state !== UPowerDeviceState.Charging ? "Remaining" : "Until full"
                }

                Text {
                    id: batteryTime
                    anchors.left: leftColumn.left
                    font.pointSize: Fonts.sizeL
                    font.family: Fonts.ui
                    color: Colors.on_surface
                    text: UPower.displayDevice.state === UPowerDeviceState.Discharging ? Math.floor(UPower.displayDevice.timeToEmpty / 3600) + "h " + Math.floor(UPower.displayDevice.timeToEmpty % 3600 / 60) + "m" : UPower.displayDevice.state === UPowerDeviceState.Charging ? Math.floor(UPower.displayDevice.timeToFull / 3600) + "h " + Math.floor(UPower.displayDevice.timeToFull % 3600 / 60) + "m" : "-- --"
                }
            }
        
            Column {
                id: rightColumn
                spacing: 7

                Text {
                    id: lastChargingDesc
                    anchors.left: rightColumn.left
                    font.pointSize: Fonts.sizeS
                    font.family: Fonts.ui
                    color: Colors.on_surface_variant
                    text: "Since charged"
                }

                Text {
                    id: lastCharging
                    anchors.left: parent.left
                    font.pointSize: Fonts.sizeL
                    font.family: Fonts.ui
                    color: Colors.on_surface
                    
                    Process {
                        id: lastChargingProc
                        command: [ "bash", "-c", "echo $(date +%s) $(cat ~/.config/scripts/files/last_charged)" ]
                        running: true
                        stdout: StdioCollector {
                            onStreamFinished: {
                                let output = this.text
                                output = output.split(" ")
                                if (UPower.displayDevice.state !== UPowerDeviceState.Charging) {
                                    let hours = String(Math.floor((output[0] - output[1]) / 3600))//.padStart(2, "0")
                                    let minutes = String(Math.floor(((output[0] - output[1]) % 3600) / 60))//.padStart(2, "0")
                                    lastCharging.text = hours + "h " + minutes + "m"
                                } else {
                                    lastCharging.text = "00:00"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}