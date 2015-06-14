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

from PyQt5.QtQuick import QQuickPaintedItem, QQuickItem
from PyQt5.QtGui import QColor, QPainter, QPainterPath, QPen
from PyQt5.QtCore import pyqtProperty, QRectF, pyqtSignal, Qt
from docutils.nodes import paragraph


class BezierCurve(QQuickPaintedItem):
    """Класс представляет кривую безье, задаваемою двумя точками, толщиной, цветом и двумя флагами на наличие стартовой
    и концевой стрелочек.
    """
    def __init__(self, parent: QQuickItem=None):
        super(BezierCurve, self).__init__(parent)

        self._color = QColor()
        self._startX = 0
        self._startY = 0
        self._endX = 0
        self._endY = 0
        self._curveWidth = 1
        self._startArrow = False
        self._endArrow = False

    def updateRectSize(self):
        parent = self.parent()
        if parent is not None:
            self.setWidth(parent.width())
            self.setHeight(parent.height())

    colorChanged = pyqtSignal()

    @pyqtProperty(QColor, notify=colorChanged)
    def color(self):
        return self._color

    @color.setter
    def color(self, color):
        if self._color != color:
            self._color = QColor(color)
            self.colorChanged.emit()
            self.update()

    startXChanged = pyqtSignal()

    @pyqtProperty(float, notify=startXChanged)
    def startX(self):
        return self._startX
    
    @startX.setter
    def startX(self, startX):
        if self._startX != startX:
            self._startX = startX
            self.startXChanged.emit()
            self.updateRectSize()
            self.update()

    startYChanged = pyqtSignal()

    @pyqtProperty(float, notify=startXChanged)
    def startY(self):
        return self._startY
    
    @startY.setter
    def startY(self, startY):
        if self._startY != startY:
            self._startY = startY
            self.startYChanged.emit()
            self.updateRectSize()
            self.update()

    endXChanged = pyqtSignal()

    @pyqtProperty(float, notify=endXChanged)
    def endX(self):
        return self._endX
    
    @endX.setter
    def endX(self, endX):
        if self._endX != endX:
            self._endX = endX
            self.endXChanged.emit()
            self.updateRectSize()
            self.update()

    endYChanged = pyqtSignal()

    @pyqtProperty(float, notify=endYChanged)
    def endY(self):
        return self._endY
    
    @endY.setter
    def endY(self, endY):
        if self._endY != endY:
            self._endY = endY
            self.endYChanged.emit()
            self.updateRectSize()
            self.update()

    curveWidthChanged = pyqtSignal()

    @pyqtProperty(int, notify=curveWidthChanged)
    def curveWidth(self):
        return self._curveWidth

    @curveWidth.setter
    def curveWidth(self, curveWidth):
        if self._curveWidth != curveWidth:
            self._curveWidth = curveWidth
            self.curveWidthChanged.emit()
            self.update()
    
    startArrowChanged = pyqtSignal()        
    
    @pyqtProperty(bool, notify=startArrowChanged)
    def startArrow(self):
        return self._startArrow
    
    @startArrow.setter
    def startArrow(self, startArrow):
        if self._startArrow != startArrow:
            self._startArrow = startArrow
            self.startArrowChanged.emit()
            self.update()
            
    endArrowChanged = pyqtSignal()        
    
    @pyqtProperty(bool, notify=endArrowChanged)
    def endArrow(self):
        return self._endArrow
    
    @endArrow.setter
    def endArrow(self, endArrow):
        if self._endArrow != endArrow:
            self._endArrow = endArrow
            self.endArrowChanged.emit()
            self.update()

    @staticmethod
    def add_arrow_left(x, y, painter_path: QPainterPath):
        painter_path.moveTo(x, y)
        painter_path.lineTo(x + 5, y + 5)
        painter_path.moveTo(x, y)
        painter_path.lineTo(x + 5, y - 5)

    @staticmethod
    def add_arrow_right(x, y, painter_path: QPainterPath):

        painter_path.moveTo(x, y)
        painter_path.lineTo(x - 5, y + 5)
        painter_path.moveTo(x, y)
        painter_path.lineTo(x - 5, y - 5)

    def add_arrow(self, x, y, direction, painter_path: QPainterPath):
        if direction == 'l':
           self.add_arrow_left(x, y, painter_path)
        elif direction == 'r':
            self.add_arrow_right(x, y, painter_path)

    def paint(self, painter: QPainter):
        painter_path = QPainterPath()
        painter_path.moveTo(self._startX, self._startY)
        x1 = self._endX
        y1 = self._startY
        x2 = self._startX
        y2 = self._endY
        painter_path.cubicTo(x1, y1, x2, y2, self._endX, self._endY)

        if self._startArrow:
            self.add_arrow(self._startX, self._startY, 'l' if self._startX <= self._endX else 'r',painter_path)

        if self._endArrow:
            self.add_arrow(self._endX, self._endY,  'r' if self._startX <= self._endX else 'l',painter_path)

        pen = QPen(self._color, self._curveWidth, Qt.SolidLine, Qt.RoundCap, Qt.RoundJoin)
        painter.setPen(pen)
        painter.setRenderHints(QPainter.Antialiasing, True)
        painter.drawPath(painter_path)

