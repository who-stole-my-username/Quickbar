import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs

Item {
    property bool isClicked: false
    property string panelName: "brightness"
    property real acBrightness: 0

    implicitWidth: 35
    implicitHeight: 35

    Rectangle {
        anchors.centerIn: parent
        color: "transparent"
        implicitWidth: 35
        implicitHeight: 35
        radius: 100

        Text {
            id: smallBrightnessDisplay
            anchors.centerIn: parent
            anchors.verticalCenter: parent.verticalCenter
            font.family: Fonts.icon
            font.pointSize: Fonts.sizeIcon
            renderType: Text.NativeRendering
            font.hintingPreference: Font.PreferNoHinting
            font.variableAxes: ({ "FILL": acBrightness / 100 })
            text: "lightbulb"
            color: acBrightness < 90 ? Colors.on_surface : Colors.error

            Behavior on color {
                ColorAnimation {
                    duration: Anims.effectsFastDur
                    easing.bezierCurve: Anims.effectsFast
                }
            }
            
            Process {
              id: briProc
              command: ["brightnessctl"]
              running: true
              stdout: StdioCollector {
                onStreamFinished: {
                  let bright = this.text.split("\n")
                  if (bright.find(line => line.includes("%"))) {
                    bright = bright.find(line => line.includes("%"));
                  } else {
                    bright = ""
                    smallBrightnessDisplay.text = "O"
                  }
                  bright = bright.split(" ");
                  bright = bright[3].split("(");
                  bright = bright[1].split("%");
                  bright = parseInt(bright[0]);
                  acBrightness = bright
                }
              }
            }
            
            Process {
                id: brightnessWatcher
                command: ["inotifywait", "-m", "-e", "modify", "/sys/class/backlight/intel_backlight/brightness"]
                running: true
                stdout: SplitParser {
                    onRead: data => {
                        briProc.running = true
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
