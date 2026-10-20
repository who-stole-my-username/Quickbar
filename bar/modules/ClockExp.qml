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
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                height: 40
                radius: 12
                color: "transparent"

                SystemClock {
                    id: yearTracker
                    precision: SystemClock.Hours
                }

                Text {
                    anchors.centerIn: parent
                    font.family: Fonts.ui
                    font.pointSize: Fonts.sizeL
                    font.weight: Font.Bold
                    color: Colors.primary
                    text: Qt.formatDateTime(yearTracker.date, "MMMM yyyy")
                }
            }

            DayOfWeekRow {
                id: dayList
                locale: calendar.locale
                Layout.fillWidth: true

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
                        color: model.today ? Colors.primary : "transparent"

                        Text {
                            anchors.centerIn: parent
                            font.family: Fonts.ui
                            font.pointSize: Fonts.sizeS
                            color: model.today ? Colors.on_primary : model.month == calendar.month ? Colors.on_surface : Colors.on_surface_variant
                            opacity: model.month == calendar.month ? 1 : 0.5

                            text: model.day
                        }
                    }
                }
            }
        }
    }
}
