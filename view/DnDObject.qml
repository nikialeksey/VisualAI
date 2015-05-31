import QtQuick 2.3

FormObject {
    property bool isDrag: false

    property real dragMinimumX: x
    property real dragMaximumX: x

    property real dragMinimumY: y
    property real dragMaximumY: y

    property real mouseX: mouseArea.mouseX
    property real mouseY: mouseArea.mouseY

    signal dragBegin
    signal dragEnd
    signal clicked
    signal pressed
    signal released

    function catchMouse() {
        // mouseArea.drag.start();
    }

    function stopDragImmediately() {
        // mouseArea.drag.cancel();
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
        if (mouseArea.pressed && !isDrag) {
            dragBegin();
            isDrag = true;
        }
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

