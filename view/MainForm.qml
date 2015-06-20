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
import QtQuick.Dialogs 1.2
import PyConsole 1.0
import "Buttons"
import "Animations"
import "Tools"
import "Tools/Actions"
import "Tools/Composites"
import "Tools/Decorators"
import Generators 1.0

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

    Row {
        x: 0; y: 0

        Column {
            Rectangle {
                id: toolsPanel
                width: toolsWidth
                height: wrapper.height - controlsPanel.height
                color: toolsPanelColor

                property real distanceToCanvasX: toolsWidth - 10

                Column {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    ToolsContainer {
                        id: compositesToolsContainer
                        title: 'Composites'
                        height: 130
                        width: toolsWidth - parent.spacing * 2

                        Sequence {
                            x: 10; y: 25
                            canvasDX: toolsPanel.distanceToCanvasX
                            canvas: canvas
                        }

                        Selector {
                            x: 60; y: 25
                            canvasDX: toolsPanel.distanceToCanvasX
                            canvas: canvas
                        }

                        Parallel {
                            x: 10; y: 75
                            canvasDX: toolsPanel.distanceToCanvasX
                            canvas: canvas
                        }

                        MemSelector {
                            x: 60; y: 75
                            canvasDX: toolsPanel.distanceToCanvasX
                            canvas: canvas
                        }

                        MemSequence {
                            x: 110; y: 25
                            canvasDX: toolsPanel.distanceToCanvasX
                            canvas: canvas
                        }
                    }

                    ToolsContainer {
                        id: actionsToolsContainer
                        title: 'Actions'
                        height: 100
                        width: toolsWidth - parent.spacing * 2
                        property int realPositionY: compositesToolsContainer.height + parent.spacing

                        UserAction {
                            x: 10; y: 25
                            canvasDX: toolsPanel.distanceToCanvasX
                            canvasDY: -actionsToolsContainer.realPositionY
                            canvas: canvas
                        }

                        Wait {
                            x: 60; y: 25
                            canvasDX: toolsPanel.distanceToCanvasX
                            canvasDY: -actionsToolsContainer.realPositionY
                            canvas: canvas
                        }

                        Condition {
                            x: 110; y: 25
                            canvasDX: toolsPanel.distanceToCanvasX
                            canvasDY: -actionsToolsContainer.realPositionY
                            canvas: canvas
                        }
                    }

                    ToolsContainer {
                        id: decoratorsToolsContainer
                        title: 'Decorators'
                        height: 130
                        width: toolsWidth - parent.spacing * 2
                        property int realPositionY: actionsToolsContainer.realPositionY + actionsToolsContainer.height + parent.spacing

                        Inverter {
                            x: 10; y: 25
                            canvasDX: toolsPanel.distanceToCanvasX
                            canvasDY: -decoratorsToolsContainer.realPositionY
                            canvas: canvas
                        }

                        AlwaysSuccess {
                            x: 60; y: 25
                            canvasDX: toolsPanel.distanceToCanvasX
                            canvasDY: -decoratorsToolsContainer.realPositionY
                            canvas: canvas
                        }

                        AlwaysFail {
                            x: 110; y: 25
                            canvasDX: toolsPanel.distanceToCanvasX
                            canvasDY: -decoratorsToolsContainer.realPositionY
                            canvas: canvas
                        }

                        UntilSuccess {
                            x: 10; y: 75
                            canvasDX: toolsPanel.distanceToCanvasX
                            canvasDY: -decoratorsToolsContainer.realPositionY
                            canvas: canvas
                        }

                        UntilFail {
                            x: 60; y: 75
                            canvasDX: toolsPanel.distanceToCanvasX
                            canvasDY: -decoratorsToolsContainer.realPositionY
                            canvas: canvas
                        }

                        Repeat {
                            x: 110; y: 75
                            canvasDX: toolsPanel.distanceToCanvasX
                            canvasDY: -decoratorsToolsContainer.realPositionY
                            canvas: canvas
                        }

                    }
                }
            }

            Rectangle {
                id: controlsPanel
                color: controlsPanelColor
                width: toolsWidth
                height: 150

                Column {
                    spacing: 10
                    anchors.centerIn: parent
                    NormalTextButton {
                        text: "Generate"
                        width: toolsWidth - 10

                        onClicked: {
                            generateCodeFileDialog.open();
                        }
                    }

                    NormalTextButton {
                        text: "Export JSON"
                        width: toolsWidth - 10

                        onClicked: {
                            exportJsonFileDialog.open();
                        }
                    }

                    NormalTextButton {
                        text: "Import JSON"
                        width: toolsWidth - 10
                    }
                }
            }
        }


        Rectangle {
            id: canvasRectangle
            color: canvasPanelColor
            width: wrapper.width - toolsWidth
            height: wrapper.height
            z: -1

            Canvas {
                id: canvas
                anchors.fill: parent

                Root {
                    id: rootNode
                    x: 10
                    y: parent.height/2 - height/2
                    isPrototype: false
                    canvas: canvas
                }
            }

            DropArea {
                id: canvasDrop
                anchors.fill: parent
                keys: ['tool', ]
            }

            Behavior on color {
                NormalColorAnimation {}
            }

            states: [
                State {
                    when: canvasDrop.containsDrag
                    PropertyChanges {
                        target: canvasRectangle
                        color: canvasPanelDropColor
                    }
                }
            ]
        }
    }

    FileDialog {
        id: exportJsonFileDialog
        title: "Выберете файл для сохранения дерева в json-формате"
        selectExisting: false
        selectFolder: false
        selectMultiple: false
        nameFilters: ["Json Files (*.json)", ]

        onAccepted: {
            jsonGenerator.fileName = fileUrl;
            jsonGenerator.rootNode = rootNode;
            jsonGenerator.generate();
        }
    }

    FileDialog {
        id: generateCodeFileDialog
        title: "Выберете файл для сохранения дерева в java коде"
        selectExisting: false
        selectFolder: false
        selectMultiple: false
        nameFilters: ["Java (*.java)", ]

        onAccepted: {
            jsonGenerator.fileName = fileUrl;
            jsonGenerator.rootNode = rootNode;
            jsonGenerator.generateCode();
        }
    }

    JsonGenerator {
        id: jsonGenerator
    }
}
