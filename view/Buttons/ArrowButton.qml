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

AbstractButton {
    PyConsole {
        id: pyconsole
    }

    id: arrowButton
    property string normalColor
    property string pressedColor
    property string hoveredColor
    color: normalColor

    signal drawArrow // Возбуждается при перемещении курсора мыши при условии, что он была нажата кнопка мыши
                     // в поле объекта и не отжата
    signal drawArrowBegin // Возбуждается при первом перемещении курсора мыши при условии, что была нажата кнопка мыши в
                          // поле объекта и не отжата
    signal drawArrowEnd // Возбуждается после отжатия кнопки мыши при условии, что был возбужден сигнал
                        // drawArrowBegin ранее


    onPressed: {
        arrowButton.drawArrowBegin();
    }

    onReleased: {
        arrowButton.drawArrowEnd();
    }

    onChangeMousePosition: {
        if (isPressed) {
            arrowButton.drawArrow();
        }
    }

    Behavior on color {
        NormalColorAnimation {}
    }

    states: [
        State {
            name: ''
            PropertyChanges {target: arrowButton; color: normalColor}
        },
        State {
            name: 'pressed'
            when: isPressed
            PropertyChanges {target: arrowButton; color: pressedColor}
        },
        State {
            name: 'hovered'
            when: isHovered
            PropertyChanges {target: arrowButton; color: hoveredColor}
        }
    ]
}