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

import PyConsole 1.0
import QtQuick 2.4

DnDObject {
    PyConsole {
        id: pyconsole
    }

    id: decorator
    x: 10; y: 10
    width: 50
    height: 50
    color: "#a7ec75"
    dragMinimumX: 0
    dragMaximumX: 1000
    dragMinimumY: 0
    dragMaximumY: 1000
    z: 3
    border.width: 5
    border.color: 'black'
    property bool isPrototype: true

    onDragBegin: {
        if (isPrototype) {
            var component = Qt.createComponent('DecoratorObject.qml');

            var posX = mouseX;
            var posY = mouseY;

            var incubator = component.incubateObject(
                    decorator.parent
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
}