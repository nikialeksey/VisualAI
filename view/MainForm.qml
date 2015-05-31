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

Rectangle {
    width: 360
    height: 360

    Rectangle {
        x: 0; y: 0
        border.color: 'black'
        width: 100
        height: parent.height

        DnDObject {
            x: 10; y: 10
            width: 50
            height: 50
            color: "#a7ec75"
            dragMinimumX: 0
            dragMaximumX: 100
            dragMinimumY: 0
            dragMaximumY: 100

            onDragBegin: {
                var component = Qt.createComponent('DnDObject.qml');

                var posX = mouseX;
                var posY = mouseY;

                var incubator = component.incubateObject(
                        parent.parent.parent,
                        {
                                x: posX,
                                y: posY,
                                color: 'red',
                                width: 30,
                                height: 30,
                                dragMinimumX: 0,
                                dragMaximumX: 100,
                                dragMinimumY: 0,
                                dragMaximumY: 100,
                        }
                );
                incubator.onStatusChanged = function (status) {
                    if (status === Component.Ready) {
                        console.log('Ready!');
                        var obj = incubator.object;
                        obj.color = 'green';
                        obj.opacity = 0.5;

                        stopDragImmediately();

                        obj.catchMouse();

                    }
                }
            }
        }
    }


}
