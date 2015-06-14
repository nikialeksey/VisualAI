"""
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
"""

from PyQt5.QtQuick import QQuickItem
from PyQt5.QtCore import pyqtSignal, pyqtProperty, pyqtSlot
from PyQt5.QtQml import QQmlProperty

class JsonGenerator(QQuickItem):

    def __init__(self, parent=None):
        super(JsonGenerator, self).__init__(parent)

        self._fileName = ''
        self._rootNode = None

        self.name_to_method = {
            '_generateSequence': self._generateSequence, '_generateInverter': self._generateInverter,
            '_generateMemSelector': self._generateMemSelector, '_generateMemSequence': self._generateMemSequence,
            '_generateParallel': self._generateParallel, '_generateSelector': self._generateSelector,
            '_generateUserAction': self._generateUserAction, '_generateWait': self._generateWait,
        }

    def __getitem__(self, item):
        return self.name_to_method.get(item)

    fileNameChanged = pyqtSignal()

    @pyqtProperty(str, notify=fileNameChanged)
    def fileName(self):
        return self._fileName

    @fileName.setter
    def fileName(self, fileName):
        if self._fileName != fileName:
            self._fileName = fileName
            self.fileNameChanged.emit()

    rootNodeChanged = pyqtSignal()

    @pyqtProperty(QQuickItem, notify=rootNodeChanged)
    def rootNode(self):
        return self._rootNode

    @rootNode.setter
    def rootNode(self, rootNode):
        if self._rootNode != rootNode:
            self._rootNode = rootNode
            self.rootNodeChanged.emit()

    @pyqtSlot()
    def generate(self):
        file = open(self._fileName[8:], 'w')
        entry = self._generate(self._rootNode, 1)
        s = '{\n' + entry + '}\n'
        file.write(s)
        file.close()

    def _generate(self, node: QQuickItem, offset: int) -> str:

        s = (' ' * offset * 4) + self['_generate' + QQmlProperty.read(node, 'actualName')](node)

        s += (' ' * (offset + 1) * 4) + "'children': [\n"
        rightPoint = QQmlProperty.read(node, '_rightPoint')
        if rightPoint is not None:
            try:
                arrows = QQmlProperty.read(rightPoint, 'arrows')
                if arrows.isArray():
                    for i in range(0, arrows.property('length').toInt()):
                        arrow = arrows.property(i).toQObject()
                        leftPoint = QQmlProperty.read(arrow, 'leftPoint')
                        s += self._generate(leftPoint.parent(), offset + 2)
            except Exception as e:
                print(e)
        s += (' ' * (offset + 1) * 4) + '],\n'
        s += (' ' * offset * 4) + '},\n'
        return s

    def _generateSequence(self, node: QQuickItem) -> str:
        s = "'Sequence': {\n"

        return s

    def _generateSelector(self, node: QQuickItem) -> str:
        s = "'Selector': {\n"

        return s

    def _generateParallel(self, node: QQuickItem) -> str:
        s = "'Parallel': {\n"

        return s

    def _generateMemSequence(self, node: QQuickItem) -> str:
        s = "'MemSequence': {\n"

        return s

    def _generateMemSelector(self, node: QQuickItem) -> str:
        s = "'MemSelector': {\n"

        return s

    def _generateUserAction(self, node: QQuickItem) -> str:
        s = "'UserAction': {\n"

        return s

    def _generateWait(self, node: QQuickItem) -> str:
        s = "'Wait': {\n"

        return s

    def _generateInverter(self, node: QQuickItem) -> str:
        s = "'Inverter': {\n"

        return s
