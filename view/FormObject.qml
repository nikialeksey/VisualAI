import QtQuick 2.0

Rectangle {
    signal positionChanged

    onXChanged: {
        positionChanged();
    }

    onYChanged: {
        positionChanged();
    }
}

