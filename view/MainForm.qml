import QtQuick 2.3

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
