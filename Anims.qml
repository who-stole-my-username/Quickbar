pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property var spatialFast: [0.42, 1.67, 0.21, 0.90, 1, 1]
    readonly property var spatialNormal: [0.38, 1.21, 0.22, 1.00, 1, 1]
    readonly property var spatialSlow: [0.39, 1.29, 0.35, 0.98, 1, 1]

    readonly property var effectsFast: [0.31, 0.94, 0.34, 1.00, 1, 1]
    readonly property var effectsNormal: [0.34, 0.80, 0.34, 1.00, 1, 1]
    readonly property var effectsSlow: [0.34, 0.88, 0.34, 1.00, 1, 1]

    readonly property int spatialFastDur: 350
    readonly property int spatialNormalDur: 500
    readonly property int spatialSlowDur: 650

    readonly property int effectsFastDur: 150
    readonly property int effectsNormalDur: 200
    readonly property int effectsSlowDur: 300
}
