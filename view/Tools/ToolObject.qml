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

    property bool isDeletable: true

    property var _leftPoint: leftPoint
    property var _rightPoint: rightPoint

    property bool isPrototype: true
    property real canvasDX: 0
    property real canvasDY: 0
    property string arrowPointColor: '#A69F00'

    property bool leftPointVisible: true // активна ли левая кнопка для стрелочек
    property bool rightPointVisible: true // активна ли правая кнопка для стрелочек
    property int maxChildrenCount: -1 // сколько стрелочек могут входить в правую кнопку (-1 - бесконечно много)

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
                        maxChildrenCount: toolObject.maxChildrenCount,
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

            if (parent == null) {
                destruct();
            }
        }
    }

    onEntered: {
        if (!isPrototype && isDeletable) {
            redX.opacity = 1;
        }
    }

    onExited: {
        if (!isPrototype && isDeletable) {
            redX.opacity = 0;
        }
    }

    NormalRedXButton {
        id: redX
        width: parent.width
        z: 1
        opacity: 0

        visible: !parent.isPrototype && parent.isDeletable

        onClicked: {
            parent.destruct();
        }
    }

    Component {
        id: bezierCurvePrototype
        BezierCurve {
            curveWidth: 2
            color: 'black'

            property var rightPoint // то, откуда выходит, то есть где старт
            property var leftPoint // то, куда приходит, то есть где конец
        }
    }

    NormalArrowButton {
        id: leftPoint
        realButtonWidth: parent.arrowButtonWidth
        realButtonHeight: parent.arrowButtonHeight
        x: -width
        y: parent.height / 2 - height / 2
        visible: false

        property var parentArrow
        property var arrow // текущая стрелочка (она в данный момент двигается вместе с мышкой)

        function getArrowEndX() {
            return parent.x - parent.arrowButtonWidth / 2;
        }

        function getArrowEndY() {
            return parent.y + parent.height / 2;
        }

        function addArrow(arrow) {
            if (parentArrow) {
                var rightPoint = parentArrow.rightPoint;
                if (rightPoint) {
                    rightPoint.removeArrow(parentArrow);
                }
                parentArrow.destroy();
            }

            arrow.endX = Qt.binding(getArrowEndX);
            arrow.endY = Qt.binding(getArrowEndY);
            arrow.leftPoint = leftPoint;

            parentArrow = arrow;
        }

        function removeArrow(arrow) {
            parentArrow = null;
        }

        onVisibleChanged: {
            if (visible) {
                width = parent.arrowButtonWidth;
                height = parent.arrowButtonHeight;
            }
        }

        onDrawArrowBegin: {
            var incubator = bezierCurvePrototype.incubateObject(
                parent.canvas,
                {
                    'endArrow': true,
                }
            );

            incubator.onStatusChanged = function (status) {
                if (status === Component.Ready) {
                    arrow = incubator.object;
                    arrow.endX = Qt.binding(getArrowEndX);
                    arrow.endY = Qt.binding(getArrowEndY);
                    arrow.startX = parent.x - parent.arrowButtonWidth + mouseX;
                    arrow.startY = parent.y + mouseY;

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
            arrow.startX = parent.x - parent.arrowButtonWidth + mouseX;
            arrow.startY = parent.y + mouseY;
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

        onEntered: {
            if (parentArrow) {
                textX.visible = true;
                color = '#80ff0000';
                opacity = 1;
            }
        }

        onExited: {
            if (parentArrow) {
                textX.visible = false;
                opacity = 0.2;
            }
        }

        onPressed: {
            if (parentArrow) {
                color = '#ffff0000';
                opacity = 1;
            }
        }

        onReleased: {
            opacity = 0.2;
        }

        onClicked: {
            if (parentArrow) {
                if(parentArrow.rightPoint) {
                    parentArrow.rightPoint.removeArrow(parentArrow);
                }
                parentArrow.destroy();
                parentArrow = null;

                textX.visible = false;
            }
        }

        Text {
            id: textX
            text: 'X'
            font.pointSize: 10
            anchors.centerIn: parent
            visible: false
        }

    }

    NormalArrowButton {
        id: rightPoint
        realButtonWidth: parent.arrowButtonWidth
        realButtonHeight: parent.arrowButtonHeight
        x: parent.width
        y: parent.height / 2 - height / 2
        visible: false

        property var arrows: [] // список всех стрелочек, торчащих из этой кнопки
        property var arrow // текущая стрелочка (она в данный момент двигается вместе с мышкой)

        function getArrowStartX() {
            return parent.x + parent.width + parent.arrowButtonWidth / 2;
        }

        function getArrowStartY() {
            return parent.y + parent.height / 2;
        }

        function addArrow(arrow) {
            if (arrows.length == parent.maxChildrenCount) {
                var i;
                var leftPoint = arrows[0].leftPoint;
                if (leftPoint) {
                    leftPoint.removeArrow(arrow[0]);
                }
                arrows[0].destroy();
                for (i = 1; i < arrows.length; i++) {
                    arrows[i - 1] = arrows[i];
                }
                arrows.pop();
            }
            arrow.startX = Qt.binding(getArrowStartX);
            arrow.startY = Qt.binding(getArrowStartY);
            arrow.rightPoint = rightPoint;

            arrows.push(arrow);
        }

        function removeArrow(arrow) {
            var index = arrows.indexOf(arrow);
            if (index >= 0) {
                arrows.splice(index, 1);
            }
        }

        onDrawArrowBegin: {
            var incubator = bezierCurvePrototype.incubateObject(
                parent.canvas,
                {
                    'endArrow': true,
                }
            );

            incubator.onStatusChanged = function (status) {
                if (status === Component.Ready) {
                    arrow = incubator.object;
                    arrow.endX = parent.x + parent.width + mouseX;
                    arrow.endY = parent.y + mouseY;
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
            arrow.endX = parent.x + parent.width + mouseX;
            arrow.endY = parent.y + mouseY;
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

    function destruct() {
        if (leftPoint.parentArrow) {
            var _rightPoint = leftPoint.parentArrow.rightPoint;
            _rightPoint.removeArrow(leftPoint.parentArrow);
            leftPoint.parentArrow.destroy();
        }

        var i;
        for (i = 0; i < rightPoint.arrows.length; i++) {
            var arrow = rightPoint.arrows[i];
            if (arrow && arrow.leftPoint) {
                arrow.leftPoint.removeArrow(arrow);
            }
            arrow.destroy();
        }
        rightPoint.arrows.splice(0, rightPoint.arrows.length);

        parent = null;
    }

    Component.onDestruction: {
    }
}