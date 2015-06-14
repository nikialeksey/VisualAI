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
import "../Animations"

ArrowButton {
    property real realButtonWidth
    property real realButtonHeight

    normalColor: '#A468D5'
    pressedColor: '#9240D5'
    hoveredColor: '#582781'

    onEntered: {
        width *= 2;
        height *= 2;
    }

    onVisibleChanged: {
        if (visible) {
            width = realButtonWidth;
            height = realButtonHeight;
        }
    }

    onExited: {
        width = realButtonWidth;
        height = realButtonHeight;
    }

    Behavior on width {
        NormalNumberAnimation {}
    }

    Behavior on height {
        NormalNumberAnimation {}
    }

    Behavior on radius {
        NormalNumberAnimation {}
    }
}