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
import "../Animations"

AbstractButton {
    id: redXButton
    property string normalColor
    property string pressedColor
    property string hoveredColor

    color: normalColor

    width: textInstance.width
    height: textInstance.height

    Text {
        id: textInstance
        text: 'X'
        font.pointSize: 10
        anchors.centerIn: parent
    }

    Behavior on color {
        NormalColorAnimation {}
    }

    Behavior on opacity {
        NormalNumberAnimation {}
    }

    Behavior on x {
        NormalNumberAnimation {}
    }

    Behavior on y {
        NormalNumberAnimation {}
    }

    states: [
        State {
            name: ''
            PropertyChanges {target: redXButton; color: normalColor; opacity: 0}
        },
        State {
            name: 'pressed'
            when: isPressed
            PropertyChanges {target: redXButton; color: pressedColor; opacity: 1}
        },
        State {
            name: 'hovered'
            when: isHovered
            PropertyChanges {target: redXButton; color: hoveredColor; opacity: 1}
        }
    ]
}