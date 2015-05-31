import QtQuick 2.0

FormObject {
    signal clicked
    signal pressed
    signal released
    signal entered
    signal exited


    MouseArea {
        id: mouseArea
        anchors.fill: parent

        hoverEnabled: true

        onClicked: {
            parent.clicked();
        }

        onPressed: {
            parent.pressed();
        }

        onReleased: {
            parent.released();
        }

        onEntered: {
            parent.entered();
        }

        onExited: {
            parent.exited();
        }
    }
}

