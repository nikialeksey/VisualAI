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

class JsonGenerator(QQuickItem):

    def __init__(self, parent=None):
        super(JsonGenerator, self).__init__(parent)

        self._fileName = ''
        self._rootNode = None

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
        print('generated')