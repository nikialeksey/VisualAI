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

import json
import ast

from PyQt5.QtQuick import QQuickItem
from PyQt5.QtCore import pyqtSignal, pyqtProperty, pyqtSlot
from PyQt5.QtQml import QQmlProperty

class JsonGenerator(QQuickItem):

    def __init__(self, parent=None):
        super(JsonGenerator, self).__init__(parent)

        self._fileName = ''
        self._rootNode = None

        self.name_to_method = {
            ############################################################################################################
            #                           JSON
            ############################################################################################################
            '_generateSequence': self._generateSequence, '_generateInverter': self._generateInverter,
            '_generateMemSelector': self._generateMemSelector, '_generateMemSequence': self._generateMemSequence,
            '_generateParallel': self._generateParallel, '_generateSelector': self._generateSelector,
            '_generateUserAction': self._generateUserAction, '_generateWait': self._generateWait,

            ############################################################################################################
            #                           CODE
            ############################################################################################################
            '_generateCodeSequence': self._generateCodeSequence, '_generateCodeInverter': self._generateCodeInverter,
            '_generateCodeMemSelector': self._generateCodeMemSelector, '_generateCodeMemSequence': self._generateCodeMemSequence,
            '_generateCodeParallel': self._generateCodeParallel, '_generateCodeSelector': self._generateCodeSelector,
            '_generateCodeUserAction': self._generateCodeUserAction, '_generateCodeWait': self._generateCodeWait,
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
        s = self._generateStr()
        file.write(s)
        file.close()

    def _generateStr(self):
        entry = self._generateJson(self._rootNode, 0)
        return entry

    @pyqtSlot()
    def generateCode(self):
        s = self._generateStr()
        # d = json.loads(s.replace("'", '"'))
        d = ast.literal_eval(s.replace("'", '"'))
        c = self._generateCode(d, 3)
        file = open(self._fileName[8:], 'w')
        file.write(
"""
import org.nikialeksey.gameengine.ai.behaviortree.*;
import org.nikialeksey.gameengine.ai.behaviortree.Actions.*;
import org.nikialeksey.gameengine.ai.behaviortree.Composites.*;
import org.nikialeksey.gameengine.ai.behaviortree.Decorators.*;

class BehaviorTreeBuilder {
    public static BehaviorTree buildBehaviorTree() {
        Node root = \n""" + c + """;
        BehaviorTree behaviorTree = new BehaviorTree(root);
        return behaviorTree;
    }
}
"""
        )
        file.close()

    def _generateCode(self, entry: dict, offset):
        s = (' ' * offset * 4) + self['_generateCode' + entry['name']](entry)
        was_iter = False
        for _entry in entry.get('children', []):
            s += (',\n' if was_iter else '') + self._generateCode(_entry, offset + 1)
            was_iter = True
        s += '\n' + (' ' * offset * 4) + ')'
        return s

    def _generateJson(self, node: QQuickItem, offset: int) -> str:
        s = (' ' * (offset) * 4) + '{\n'
        s += (' ' * (offset + 1) * 4) + self['_generate' + QQmlProperty.read(node, 'actualName')](node)

        s += (' ' * (offset + 1) * 4) + "'x': " + str(node.x()) + ',\n'
        s += (' ' * (offset + 1) * 4) + "'y': " + str(node.y()) + ',\n'

        s += (' ' * (offset + 1) * 4) + "'children': [\n"
        rightPoint = QQmlProperty.read(node, '_rightPoint')
        if rightPoint is not None:
            try:
                arrows = QQmlProperty.read(rightPoint, 'arrows')
                if arrows.isArray():
                    for i in range(0, arrows.property('length').toInt()):
                        arrow = arrows.property(i).toQObject()
                        leftPoint = QQmlProperty.read(arrow, 'leftPoint')
                        s += self._generateJson(leftPoint.parent(), offset + 2) + ',\n'
            except Exception as e:
                print(e)
        s += (' ' * (offset + 1) * 4) + '],\n'
        s += (' ' * (offset) * 4) + '}'
        return s

    ####################################################################################################################
    #                 SEQUENCE
    ####################################################################################################################
    def _generateSequence(self, node: QQuickItem) -> str:
        s = "'name': 'Sequence',\n"

        return s

    def _generateCodeSequence(self, entry: dict) -> str:
        s = "new Sequence(\n"

        return s

    ####################################################################################################################
    #                 SELECTOR
    ####################################################################################################################
    def _generateSelector(self, node: QQuickItem) -> str:
        s = "'name': 'Selector',\n"

        return s

    def _generateCodeSelector(self, entry: dict) -> str:
        s = "new Selector(\n"

        return s

    ####################################################################################################################
    #                 PARALLEL
    ####################################################################################################################
    def _generateParallel(self, node: QQuickItem) -> str:
        s = "'name': 'Parallel',\n"

        return s

    def _generateCodeParallel(self, entry: dict) -> str:
        s = "new Parallel(\n"

        return s

    ####################################################################################################################
    #                 MEMSEQUENCE
    ####################################################################################################################
    def _generateMemSequence(self, node: QQuickItem) -> str:
        s = "'name': 'MemSequence',\n"

        return s

    def _generateCodeMemSequence(self, entry: dict) -> str:
        s = "new MemSequence(\n"

        return s

    ####################################################################################################################
    #                 MEMSELECTOR
    ####################################################################################################################
    def _generateMemSelector(self, node: QQuickItem) -> str:
        s = "'name'': MemSelector',\n"

        return s

    def _generateCodeMemSelector(self, entry: dict) -> str:
        s = "new MemSelector(\n"

        return s

    ####################################################################################################################
    #                 USERACTION
    ####################################################################################################################
    def _generateUserAction(self, node: QQuickItem) -> str:
        s = "'name': 'UserAction',\n"

        return s

    def _generateCodeUserAction(self, entry: dict) -> str:
        s = "new UserAction(\n"

        return s

    ####################################################################################################################
    #                 WAIT
    ####################################################################################################################
    def _generateWait(self, node: QQuickItem) -> str:
        s = "'name': 'Wait',\n"

        return s

    def _generateCodeWait(self, entry: dict) -> str:
        s = "new Wait(\n"

        return s

    ####################################################################################################################
    #                 INVERTER
    ####################################################################################################################
    def _generateInverter(self, node: QQuickItem) -> str:
        s = "'name': 'Inverter',\n"

        return s

    def _generateCodeInverter(self, entry: dict) -> str:
        s = "new Inverter(\n"

        return s
