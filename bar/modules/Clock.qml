import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs

Item {
    property bool expanded: false

    implicitHeight: 40
    implicitWidth: 100
    Text {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        transformOrigin: Item.Top 
        font.family: Fonts.ui
        font.pointSize: Fonts.sizeM
        color: Colors.on_surface

        Timer {
            interval: 5000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                let clockObj = new Date();
                let hours = String(clockObj.getHours()).padStart(2, "0");
                let minutes = String(clockObj.getMinutes()).padStart(2, "0");
                let display = hours + ":" + minutes;
                clock.text = display
            }
        }
    }

    Text {
        id: date
        visible: expanded ? true : false
        opacity: expanded ? 1 : 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: clock.bottom
        font.family: Fonts.ui
        font.pointSize: Fonts.sizeXXS
        color: Colors.on_surface

        Timer {
            interval: 60000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                let dateObj = new Date();
                let day = String(dateObj.getDate()).padStart(2, "0");
                let month = String(dateObj.getMonth() + 1).padStart(2, "0");
                let year = dateObj.getFullYear();
                let display = day + "." + month + "." + year;
                date.text = display
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Anims.effectsFastDur
                easing.bezierCurve: Anims.effectsFast
            }
        }
    }
}