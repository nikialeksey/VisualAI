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
    id: wrapper
    width: 560
    height: 560
    z: 0

    Row {
        x: 0; y: 0
        //z: 1
        Rectangle {
            id: toolsResource
            width: 100
            height: wrapper.height
            border.color: 'red'
            z: 2

            DecoratorObject {
                x: 10; y: 10
                canvasDX: 100
            }
        }


        Rectangle {
            id: canvas
            border.color: 'red'
            width: wrapper.width - toolsResource.width
            height: wrapper.height
            z: 1

            Canvas {

                id: cnv
                anchors.fill: parent
                onPaint: {
                    var ctx = cnv.getContext('2d');
                    ctx.strokeStyle = 'rgb(255, 100, 55, 1.0)';
                    ctx.beginPath();
                    ctx.moveTo(75,40);
                    ctx.bezierCurveTo(75,37,70,25,50,25);
                    ctx.bezierCurveTo(20,25,20,62.5,20,62.5);
                    ctx.bezierCurveTo(20,80,40,102,75,120);
                    ctx.bezierCurveTo(110,102,130,80,130,62.5);
                    ctx.bezierCurveTo(130,62.5,130,25,100,25);
                    ctx.bezierCurveTo(85,25,75,37,75,40);
                    ctx.stroke();
                    ctx.closePath();
                }
            }

            DropArea {
                id: canvasDrop
                anchors.fill: parent
            }

            Behavior on color {
                ColorAnimation { duration: 500; easing.type: Easing.OutBack }
            }

            states: [
                State {
                    when: canvasDrop.containsDrag
                    PropertyChanges {
                        target: canvas
                        color: "grey"
                    }
                }
            ]
        }
    }
}
