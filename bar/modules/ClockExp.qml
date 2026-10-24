import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs

Item {
    property real calHeight: 80 + barContainer.height + 11

    Rectangle {
        id: barContainer
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 1
        anchors.margins: 15
        height: calendar.height + dayList.height + yearContainer.height + 40
        radius: 12
        color: Colors.surface_container
        clip: true

        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 15
            anchors.bottomMargin: 25


            Rectangle {
                id: yearContainer
                Layout.alignment: Qt.AlignCenter
                height: 40
                width: 400
                radius: 12
                color: "transparent"

                SystemClock {
                    id: yearTracker
                    precision: SystemClock.Hours
                }
  
                Text {
                    id: arrowLeft
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Fonts.icon
                    font.pointSize: 30
                    color: Colors.primary
                    text: "arrow_left"
                    rotation: 0

                    Behavior on rotation {
                        NumberAnimation {
                            duration: Anims.spatialSlowDur
                            easing.type: Easing.Bezier
                            easing.bezierCurve: Anims.spatialFast
                        }
                    }

                    MouseArea {
                        id: monthMinus
                        anchors.fill: parent
                        onClicked: {
                            arrowLeft.rotation = Math.ceil(arrowLeft.rotation / 360) * 360 - 360
                            let prev = new Date(calendar.year, calendar.month - 1, 1)
                            calendar.month = prev.getMonth()
                            calendar.year = prev.getFullYear()
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    font.family: Fonts.ui
                    font.pointSize: Fonts.sizeL
                    font.weight: Font.Bold
                    color: Colors.primary
                    text: calendar.title
                }

                Text {
                    id: arrowRight
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Fonts.icon
                    font.pointSize: 30
                    color: Colors.primary
                    text: "arrow_right"
                    rotation: 0

                    Behavior on rotation {
                        NumberAnimation {
                            duration: Anims.spatialSlowDur
                            easing.type: Easing.Bezier
                            easing.bezierCurve: Anims.spatialFast
                        }
                    }

                    MouseArea {
                        id: monthPlus
                        anchors.fill: parent
                        onClicked: {
                            arrowRight.rotation = Math.ceil(arrowRight.rotation / 360) * 360 + 360
                            let next = new Date(calendar.year, calendar.month + 1, 1)
                            calendar.month = next.getMonth()
                            calendar.year = next.getFullYear()
                        }
                    }
                }
            }

            DayOfWeekRow {
                id: dayList
                locale: calendar.locale
                Layout.fillWidth: true
                Layout.minimumHeight: 25

                delegate: Text {
                    required property string shortName

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: Fonts.ui
                    font.pointSize: Fonts.sizeM
                    font.weight: Font.Thin
                    color: Colors.on_surface
                    text: shortName
                }
            }

            MonthGrid {
                id: calendar
                Layout.fillWidth: true
                spacing: 5

                delegate: Item {
                    required property var model
                    required property var index

                    id: item
                    width: 40
                    height: 40

                    Rectangle {
                        anchors.centerIn: parent
                        width: 40
                        height: 40
                        radius: 20
                        color: (model.day == yearTracker.date.getDate() && model.month == yearTracker.date.getMonth() && model.year == yearTracker.date.getFullYear()) ? Colors.primary : "transparent"

                        Text {
                            anchors.centerIn: parent
                            font.family: Fonts.ui
                            font.pointSize: Fonts.sizeS
                            color: (model.day == yearTracker.date.getDate() && model.month == yearTracker.date.getMonth() && model.year == yearTracker.date.getFullYear()) ? Colors.on_primary : model.month == calendar.month ? Colors.on_surface : Colors.on_surface_variant
                            opacity: model.month == calendar.month ? 1 : 0.5

                            text: model.day
                        }
                    }
                }
            }
        }
    }
}
