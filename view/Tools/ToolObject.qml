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

    property bool leftPointVisible: true // активна ли левая кнопка для стрелочек
    property bool rightPointVisible: true // активна ли правая кнопка для стрелочек
    property int maxLeftArrows: 1 // сколько стрелочек могут входить в левую кнопку
    property int maxRightArrows: -1 // сколько стрелочек могут входить в правую кнопку (-1 - бесконечно много)

    property real arrowButtonWidth: 10
    property real arrowButtonHeight: height

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
                        leftPointVisible: toolObject.leftPointVisible,
                        rightPointVisible: toolObject.rightPointVisible,
                        maxLeftArrows: toolObject.maxLeftArrows,
                        maxRightArrows: toolObject.maxRightArrows,
                        arrowButtonWidth: toolObject.arrowButtonWidth,
                        arrowButtonHeight: toolObject.arrowButtonHeight,
                    }
            );
            incubator.onStatusChanged = function (status) {
                if (status === Component.Ready) {
                    var obj = incubator.object;
                    toolObject.isPrototype = false;
                    toolObject.z = 4;
                    leftPoint.visible = leftPointVisible;
                    rightPoint.visible = rightPointVisible;
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

        function addArrow(arrow) {
            if (arrows.length == toolObject.maxLeftArrows) {
                var i;
                arrows[0].destroy();
                for (i = 1; i < arrows.length; i++) {
                    arrows[i - 1] = arrows[i];
                }

                arrows.pop();
            }
            arrow.endX = Qt.binding(getArrowEndX);
            arrow.endY = Qt.binding(getArrowEndY);

            arrows.push(arrow);
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
            var dropArea = arrow.Drag.target
            if (dropArea) {
                addArrow(arrow);

                var rightPoint = dropArea.parent;
                rightPoint.addArrow(arrow);

                arrow.Drag.active = false;
            } else {
                arrow.destroy();
            }
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
                    opacity: 0.8
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

        function addArrow(arrow) {
            if (arrows.length == toolObject.maxRightArrows) {
                var i;
                arrows[0].destroy();
                for (i = 1; i < arrows.length; i++) {
                    arrows[i - 1] = arrows[i];
                }
                arrows.pop();
            }
            arrow.startX = Qt.binding(getArrowStartX);
            arrow.startY = Qt.binding(getArrowStartY);

            arrows.push(arrow);
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
            var dropArea = arrow.Drag.target;
            if (dropArea) {
                addArrow(arrow);

                var leftPoint = dropArea.parent;
                leftPoint.addArrow(arrow);

                arrow.Drag.active = false;
            } else {
                arrow.destroy();
            }
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
                    opacity: 0.8
                }
            }
        ]
    }
}