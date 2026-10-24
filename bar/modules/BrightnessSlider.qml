import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs

Item {
    property real brightnessLvl: 0

    implicitHeight: 40
    implicitWidth: 100

    Text {
        id: brightnessIcon
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        font.family: Fonts.icon
        font.pointSize: Fonts.sizeIcon
        renderType: Text.NativeRendering
        font.hintingPreference: Font.PreferNoHinting
        font.variableAxes: ({
            "FILL": 1
        })
        text: "lightbulb"
        color: Colors.on_surface
    }

    Rectangle {
        id: brightnessSliderContainer
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: brightnessIcon.right
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 60
        height: 5
        color: "transparent"

        Rectangle {
            property real fillWidth: brightnessLvl / 100
            id: brightnessSliderFill
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: parent.width * fillWidth
            color: Colors.primary
            radius: 10

            Behavior on fillWidth {
                NumberAnimation {
                    duration: Anims.effectsFastDur
                    easing.bezierCurve: Anims.effectsFast
                }
            }
        }

        Rectangle {
            id: brightnessSliderEnd
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: brightnessSliderFill.right
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
                color: Colors.primary
            }
        }
    }

    Text {
        id: brightnessPerc
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10
        font.pointSize: Fonts.sizeXS
        font.family: Fonts.ui
        font.weight: Font.Black
        text: brightnessLvl + "%"
        color: Colors.on_surface
    }
}
