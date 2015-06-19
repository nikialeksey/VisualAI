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

FormObject {
    PyConsole {
        id: pyconsole
    }

    property bool isDragEnabled: true // true, если манипулирование при помощи Drag-and-drop разрешено

    property bool isDrag: false // true, если эелемнт перетаскивается мышью
    property bool isHovered: false // true, если мышь находится над элементом

    property real dragMinimumX: x // минимальное значение координаты x объекта
    property real dragMaximumX: x // максимальное значение координаты x объекта

    property real dragMinimumY: y // минимальное значение координаты y объекта
    property real dragMaximumY: y // максимальное значение координаты y объекта

    property real mouseX: mouseArea.mouseX // значение x-координаты курсора мыши относительно данного объекта
    property real mouseY: mouseArea.mouseY // значение y-координаты курсора мыши относительно данного объекта

    Drag.active: mouseArea.drag.active
    Drag.hotSpot.x: width/2
    Drag.hotSpot.y: height/2

    signal dragBegin // возбуждается на начало манипулирования при помощи Drag-and-drop
    signal dragEnd // возбуждается после окончания манипулирования при помощи Drag-and-drop
    signal clicked // возбуждается после клика мышью на объект
    signal pressed // возбуждается при нажатии мышью на объект
    signal released // возбуждается после отжатия мыши на объекте
    signal entered // возбуждается при входе курсора мыши в поле объекта
    signal exited // возбуждается при выходе курсора мыши за поле объекта

    onChildrenChanged: {
        /*if (children.length === 2) {
            // Для того, чтобы все дочерние элементы, кроме тех,
            // что описаны в этом файле, были перенаправлены в
            // mouseArea. Это необходимо для того, чтобы drag
            // работал на всех дочерних элементах
            var childrens = [];
            for(var i = 0; i < mouseArea.children.length; i++) {
                childrens[i] = mouseArea.children[0];
            }
            childrens[mouseArea.children.length] = children[1];
            mouseArea.children = childrens;
            children = [children[0], ];
        }*/
    }

    MouseArea {
        id: mouseArea

        enabled: parent.isDragEnabled

        hoverEnabled: true
        anchors.fill: parent
        drag.target: parent
        drag.filterChildren: true
        drag.minimumX: parent.dragMinimumX
        drag.maximumX: parent.dragMaximumX
        drag.minimumY: parent.dragMinimumY
        drag.maximumY: parent.dragMaximumY

        onPositionChanged: {
            if (mouseArea.pressed && !parent.isDrag) {
                parent.dragBegin();
                parent.isDrag = true;
            }
        }

        onClicked: {
            parent.clicked();
        }

        onPressed: {
            parent.pressed();
        }

        onReleased: {
            if (parent.isDrag) {
                parent.dragEnd();
                parent.isDrag = false;
            }

            parent.released();
        }

        onEntered: {
            parent.isHovered = true;
            parent.entered();
        }

        onExited: {
            parent.isHovered = false;
            parent.exited();
        }
    }
}

