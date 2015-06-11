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

DnDObject {
    PyConsole {
        id: pyconsole
    }

    id: decorator

    z: 3

    width: 50
    height: 50

    color: "#a7ec75"
    dragMinimumX: -10000
    dragMaximumX: 10000
    dragMinimumY: -10000
    dragMaximumY: 10000

    border.width: 5
    border.color: 'black'

    property bool isPrototype: true
    property real canvasDX: 0
    property real canvasDY: 0

    onDragBegin: {
        if (isPrototype) {
            var component = Qt.createComponent('ToolObject.qml');

            var posX = mouseX;
            var posY = mouseY;

            var incubator = component.incubateObject(
                    decorator.parent, {
                        x: decorator.x,
                        y: decorator.y,
                        canvasDX: decorator.canvasDX,
                        canvasDY: decorator.canvasDY,
                        color: decorator.color,
                        border: decorator.border,
                    }
            );
            incubator.onStatusChanged = function (status) {
                if (status === Component.Ready) {
                    pyconsole.out('ok');
                    var obj = incubator.object;
                    decorator.isPrototype = false;
                    decorator.z = 4;
                }
            }
        }
    }

    onPositionChanged: {
        /*if (Drag.target !== null) {
            parent = Drag.target;
            x = mouseX;
            y = mouseY;
        }*/
    }

    onDragEnd: {
        if (parent != Drag.target) {
            parent = Drag.target == null? null: Drag.target

            x = x - canvasDX;
            y = y - canvasDY;
        }
    }
}