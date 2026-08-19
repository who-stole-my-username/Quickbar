import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import qs

Item {
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var volumeReader: sink && sink.audio ? sink.audio.volume : 0
    readonly property var mutedReader: sink && sink.audio ? sink.audio.muted : 0
    property bool isClicked: false
    property string panelName: "volume"

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
            renderType: Text.NativeRendering
            font.hintingPreference: Font.PreferNoHinting
            font.variableAxes: ({ "FILL": 1 })
            text: {
              if (mutedReader) {
                smallConnectionDisplay.color = Colors.on_surface
                return "volume_off"
              } else {
                if (volumeReader == 0) {
                  smallConnectionDisplay.color = Colors.on_surface
                  return "no_sound"
                } else if (volumeReader <= 0.333) {
                  smallConnectionDisplay.color = Colors.on_surface
                  return "volume_mute"
                } else if (volumeReader <= 0.666) {
                  smallConnectionDisplay.color = Colors.on_surface
                  return "volume_down"
                } else if (volumeReader <= 1) {
                  smallConnectionDisplay.color = Colors.on_surface
                  return "volume_up"
                } else if (volumeReader > 1) {
                  smallConnectionDisplay.color = Colors.error
                  return "volume_up"
                }
              }
            }

            Behavior on color {
              ColorAnimation {
                duration: Anims.effectsFastDur
                easing.bezierCurve: Anims.effectsFast
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

    PwObjectTracker {
      objects: [sink].filter(Boolean)
    }
}
