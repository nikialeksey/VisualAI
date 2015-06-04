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

import QtQuick 2.3
import PyConsole 1.0

FormObject {
    PyConsole {
        id: pyconsole
    }

    property bool isDrag: false

    property real dragMinimumX: x
    property real dragMaximumX: x

    property real dragMinimumY: y
    property real dragMaximumY: y

    property real mouseX: mouseArea.mouseX
    property real mouseY: mouseArea.mouseY

    Drag.active: mouseArea.drag.active

    signal dragBegin
    signal dragEnd
    signal clicked
    signal pressed
    signal released

    function catchMouse() {
        mouseArea.enabled = true;
    }

    function stopDragImmediately() {
        pyconsole.out('ok');
        mouseArea.enabled = false;
        Drag.active = false;
        mouseArea.drag.active = false;
        Drag.cancel();
        mouseArea.drag.cancel();

    }

    onChildrenChanged: {
        if (children.length === 2) {
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
        }
    }

    onPositionChanged: {

    }

    MouseArea {
        id: mouseArea

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
    }
}

