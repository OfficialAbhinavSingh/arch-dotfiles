import QtQuick
import Quickshell
import QtQuick.Shapes

Item {
    id: ropeRect

    property int anchorX: 0
    property int anchorY: 0
    property int pullX: 100
    property int pullY: 100

    property int segments: 10
    property int segment_length: 5
    property color color: "#88d6ba"
    property int strokeWidth: 6

    anchors.fill: parent

    Shape {
        id: rope
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        Instantiator {
            model: ropeRect.segments
            onObjectAdded: (index, pathCurve) => {
                pathCurves.pathElements.push(pathCurve)
            }
            delegate: PathCurve {
                property int index: model.index
                x: ropeRect.anchorX
                y: ropeRect.anchorY
            }
        }

        ShapePath {
            id: pathCurves
            strokeColor: ropeRect.color
            fillColor: "transparent"
            strokeWidth: ropeRect.strokeWidth
            startX: ropeRect.anchorX
            startY: ropeRect.anchorY
        }

        ShapePath {
            id: dotPath
            strokeColor: "transparent"
            fillColor: "transparent"

            PathAngleArc {
                id: startPoint
                property int index: -1
                property double dx: 0
                property double dy: 0
                property double vx: 0
                property double vy: 0

                onCenterXChanged: {
                    pathCurves.startX = centerX
                }
                onCenterYChanged: {
                    pathCurves.startY = centerY
                }

                centerX: ropeRect.anchorX
                centerY: ropeRect.anchorY
                radiusX: 1
                radiusY: 1
                startAngle: 0
                sweepAngle: 360
            }
        }

        Timer {
            interval: 1000 / 60
            running: ropeRect.visible
            repeat: true

            onTriggered: {
                if (!dotPath.pathElements || dotPath.pathElements.length <= ropeRect.segments) return
                if (!pathCurves.pathElements || pathCurves.pathElements.length < ropeRect.segments) return

                for (var i = ropeRect.segments; i > 0; i--) {
                    var point = dotPath.pathElements[i]
                    var prev = dotPath.pathElements[i - 1]
                    if (!point || !prev) continue

                    var prevDx = prev.centerX - point.centerX
                    var prevDy = prev.centerY - point.centerY

                    var prevDist = Math.sqrt(Math.pow(prevDx, 2) + Math.pow(prevDy, 2))
                    if (prevDist <= 0.001) prevDist = 0.001
                    var prevExtend = prevDist - ropeRect.segment_length

                    var vx = (prevDx / prevDist) * prevExtend
                    var vy = (prevDy / prevDist) * prevExtend + 9.8

                    if (isNaN(vx)) vx = 0
                    if (isNaN(vy)) vy = 0

                    if (i < ropeRect.segments - 3) {
                        var next = dotPath.pathElements[i + 1]
                        if (next) {
                            var nextDx = next.centerX - point.centerX
                            var nextDy = next.centerY - point.centerY
                            var nextDist = Math.sqrt(Math.pow(nextDx, 2) + Math.pow(nextDy, 2))
                            if (nextDist <= 0.001) nextDist = 0.001
                            var nextExtend = nextDist - ropeRect.segment_length 
                            vx += (nextDx / nextDist) * nextExtend
                            vy += (nextDy / nextDist) * nextExtend
                        }
                    } else {
                        point.centerX = ropeRect.pullX
                        point.centerY = ropeRect.pullY
                    }

                    point.vx = (point.vx || 0) * 0.5 + vx * 0.45
                    point.vy = (point.vy || 0) * 0.5 + vy * 0.45

                    point.centerX += point.vx
                    point.centerY += point.vy
                }
            }
        }

        Instantiator {
            model: ropeRect.segments
            onObjectAdded: (index, pathAngleArc) => {
                dotPath.pathElements.push(pathAngleArc)
            }
            delegate: PathAngleArc {
                id: points
                property int index: model.index
                property double dx: 0
                property double dy: 0
                property double vx: 0
                property double vy: 0

                onCenterXChanged: {
                    if (pathCurves.pathElements && index < pathCurves.pathElements.length && pathCurves.pathElements[index]) {
                        pathCurves.pathElements[index].x = centerX
                    }
                }
                onCenterYChanged: {
                    if (pathCurves.pathElements && index < pathCurves.pathElements.length && pathCurves.pathElements[index]) {
                        pathCurves.pathElements[index].y = centerY
                    }
                }
                Component.onCompleted: {
                    if (pathCurves.pathElements && index < pathCurves.pathElements.length && pathCurves.pathElements[index]) {
                        pathCurves.pathElements[index].x = centerX
                        pathCurves.pathElements[index].y = centerY
                    }
                }

                centerX: anchorX + (pullX - anchorX) * ((index + 1) / (ropeRect.segments + 1))
                centerY: anchorY + (pullY - anchorY) * ((index + 1) / (ropeRect.segments + 1))
                radiusX: 1
                radiusY: 1
                startAngle: 0
                sweepAngle: 360
            }
        }
    }
}
