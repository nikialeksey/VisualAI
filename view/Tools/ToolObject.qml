/*
The MIT License (MIT)

Copyright (c) 2015 Alexey Nikitin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import QtQuick 2.4
import PyConsole 1.0
import "../Base"
import "../Buttons"
import Curves 1.0

DnDObject {
    PyConsole {
        id: pyconsole
    }

    id: toolObject

    z: 3

    width: 40
    height: 40

    color: "#A468D5"
    dragMinimumX: -10000
    dragMaximumX: 10000
    dragMinimumY: -10000
    dragMaximumY: 10000

    Drag.keys: ['tool', ]

    property bool isPrototype: true
    property real canvasDX: 0
    property real canvasDY: 0
    property string arrowPointColor: '#A69F00'

    property Canvas canvas

    function createPrototypeComponent() {
        return Qt.createComponent('ToolObject.qml');
    }

    onDragBegin: {
        if (isPrototype) {
            var component = createPrototypeComponent();

            var posX = mouseX;
            var posY = mouseY;

            var incubator = component.incubateObject(
                    toolObject.parent, {
                        x: toolObject.x,
                        y: toolObject.y,
                        canvasDX: toolObject.canvasDX,
                        canvasDY: toolObject.canvasDY,
                        color: toolObject.color,
                        canvas: toolObject.canvas,
                    }
            );
            incubator.onStatusChanged = function (status) {
                if (status === Component.Ready) {
                    var obj = incubator.object;
                    toolObject.isPrototype = false;
                    toolObject.z = 4;
                    leftPoint.visible = true;
                    rightPoint.visible = true;
                }
            }
        }
    }

    onDragEnd: {
        if (parent != Drag.target) {
            parent = Drag.target;

            x = x - canvasDX;
            y = y - canvasDY;
        }
    }

    onPositionChanged: {
        //leftPoint.updateArrowsPosition();
    }

    // TODO arrowButtonWidth/Height не передастся копии объекта при dragStart, если его переопределят извне
    property real arrowButtonWidth: 10
    property real arrowButtonHeight: height

    Component {
        id: bezierCurvePrototype
        BezierCurve {
            curveWidth: 2
            color: 'black'
        }
    }

    NormalArrowButton {
        id: leftPoint
        realButtonWidth: toolObject.arrowButtonWidth
        realButtonHeight: toolObject.arrowButtonHeight
        x: -width
        y: toolObject.height / 2 - height / 2
        visible: false

        function getArrowEndX() {
            return toolObject.x - toolObject.arrowButtonWidth / 2;
        }

        function getArrowEndY() {
            return toolObject.y + toolObject.height / 2;
        }

        onVisibleChanged: {
            if (visible) {
                width = toolObject.arrowButtonWidth;
                height = toolObject.arrowButtonHeight;
            }
        }

        onDrawArrowBegin: {
            var incubator = bezierCurvePrototype.incubateObject(
                toolObject.canvas,
                {
                    'endArrow': true,
                }
            );

            incubator.onStatusChanged = function (status) {
                if (status === Component.Ready) {
                    arrow = incubator.object;
                    arrow.endX = Qt.binding(getArrowEndX);
                    arrow.endY = Qt.binding(getArrowEndY);
                    arrow.startX = toolObject.x - toolObject.arrowButtonWidth + mouseX;
                    arrow.startY = toolObject.y + mouseY;

                    arrow.Drag.active = true;
                    arrow.Drag.keys = ['left', ];
                    arrow.Drag.hotSpot.x = Qt.binding(function() {return arrow.startX;});
                    arrow.Drag.hotSpot.y = Qt.binding(function() {return arrow.startY;});
                }
            };
        }

        onDrawArrowEnd: {
            var i;
            for (i = 0; i < arrows.length; i++) {
                arrows[i].destroy();
            }
            arrows = []

            var dropArea = arrow.Drag.target
            if (dropArea) {
                var rightPoint = dropArea.parent;
                var toolObject = rightPoint.parent;

                arrow.startX = Qt.binding(rightPoint.getArrowStartX);
                arrow.startY = Qt.binding(rightPoint.getArrowStartY);
                rightPoint.arrows.push(arrow);
            }

            arrow.Drag.active = false;
            arrows[0] = arrow;
            arrow = null;
        }

        onDrawArrow: {
            arrow.startX = toolObject.x - toolObject.arrowButtonWidth + mouseX;
            arrow.startY = toolObject.y + mouseY;
        }

        DropArea {
            id: leftPointDrop
            anchors.fill: parent

            keys: ['right', ]
        }

        states: [
            State {
                when: leftPointDrop.containsDrag
                PropertyChanges {
                    target: leftPoint
                    width: realButtonWidth * 2
                    height: realButtonHeight * 2
                }
            }
        ]
    }

    NormalArrowButton {
        id: rightPoint
        realButtonWidth: toolObject.arrowButtonWidth
        realButtonHeight: toolObject.arrowButtonHeight
        x: toolObject.width
        y: toolObject.height / 2 - height / 2
        visible: false

        function getArrowStartX() {
            return toolObject.x + toolObject.width + toolObject.arrowButtonWidth / 2;
        }

        function getArrowStartY() {
            return toolObject.y + toolObject.height / 2;
        }

        onDrawArrowBegin: {
            var incubator = bezierCurvePrototype.incubateObject(
                toolObject.canvas,
                {
                    'endArrow': true,
                }
            );

            incubator.onStatusChanged = function (status) {
                if (status === Component.Ready) {
                    arrow = incubator.object;
                    arrow.endX = toolObject.x + toolObject.width + mouseX;
                    arrow.endY = toolObject.y + mouseY;
                    arrow.startX = Qt.binding(getArrowStartX);
                    arrow.startY = Qt.binding(getArrowStartY);

                    arrow.Drag.active = true;
                    arrow.Drag.keys = ['right', ];
                    arrow.Drag.hotSpot.x = Qt.binding(function() {return arrow.endX;});
                    arrow.Drag.hotSpot.y = Qt.binding(function() {return arrow.endY;});
                }
            };
        }

        onDrawArrowEnd: {
            var dropArea = arrow.Drag.target
            if (dropArea) {
                var leftPoint = dropArea.parent;
                var toolObject = leftPoint.parent;

                arrow.endX = Qt.binding(leftPoint.getArrowEndX);
                arrow.endY = Qt.binding(leftPoint.getArrowEndY);

                var i;
                for (i = 0; i < leftPoint.arrows.length; i++){
                    leftPoint.arrows[i].destroy();
                }
                leftPoint.arrows = [];
                leftPoint.arrows.push(arrow);
            }

            arrow.Drag.active = false;
            arrows.push(arrow);
            arrow = null;
        }

        onDrawArrow: {
            arrow.endX = toolObject.x + toolObject.width + mouseX;
            arrow.endY = toolObject.y + mouseY;
        }

        DropArea {
            id: rightPointDrop
            anchors.fill: parent

            keys: ['left', ]
        }

        states: [
            State {
                when: rightPointDrop.containsDrag
                PropertyChanges {
                    target: rightPoint
                    width: realButtonWidth * 2
                    height: realButtonHeight * 2
                }
            }
        ]
    }
}