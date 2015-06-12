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
import "Buttons"
import "Animations"
import "Tools"
import "Tools/Actions"
import "Tools/Composites"

Rectangle {
    PyConsole {
        id: pyconsole
    }

    property string toolsPanelColor: '#00A383'
    property string controlsPanelColor: '#34D1B2'
    property string canvasPanelColor: '#5ED1BA'
    property string canvasPanelDropColor: '#1F7A68'
    property real toolsWidth: 200

    id: wrapper
    width: 1024
    height: 600
    z: 0

    Row {
        x: 0; y: 0

        Column {
            Rectangle {
                id: toolsPanel
                width: toolsWidth
                height: wrapper.height - controlsPanel.height
                color: toolsPanelColor
                z: 2

                Column {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    ToolsContainer {
                        id: compositesToolsContainer
                        title: 'Composites'
                        height: 150
                        width: toolsWidth - parent.spacing * 2

                        Sequence {
                            x: 10; y: 25
                        }

                        Selector {
                            x: 60; y: 25
                        }

                        Parallel {
                            x: 10; y: 75
                        }

                        MemSelector {
                            x: 60; y: 75
                        }

                        MemSequence {
                            x: 110; y: 75
                        }
                    }

                    ToolsContainer {
                        id: actionsToolsContainer
                        title: 'Actions'
                        height: 100
                        width: toolsWidth - parent.spacing * 2

                        UserAction {
                            x: 10; y: 25
                        }

                        Wait {
                            x: 60; y: 25
                        }
                    }

                    ToolsContainer {
                        id: decoratorsToolsContainer
                        title: 'Decorators'
                        width: toolsWidth - parent.spacing * 2

                        height: 100
                        DecoratorObject {
                            x: 10; y: 25
                            canvasDX: toolsWidth

                            onClicked: {
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: controlsPanel
                color: controlsPanelColor
                width: toolsWidth
                height: 150
                z: 2

                Column {
                    spacing: 10
                    anchors.centerIn: parent
                    NormalTextButton {
                        text: "Generate"
                        width: toolsWidth - 10
                    }

                    NormalTextButton {
                        text: "Export JSON"
                        width: toolsWidth - 10
                    }

                    NormalTextButton {
                        text: "Import JSON"
                        width: toolsWidth - 10
                    }
                }
            }
        }


        Rectangle {
            id: canvas
            color: canvasPanelColor
            width: wrapper.width - toolsWidth
            height: wrapper.height
            z: -10

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
                NormalColorAnimation {}
            }

            states: [
                State {
                    when: canvasDrop.containsDrag
                    PropertyChanges {
                        target: canvas
                        color: canvasPanelDropColor
                    }
                }
            ]
        }
    }
}
