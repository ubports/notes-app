/*
 * Copyright: 2014 Canonical, Ltd
 *
 * This file is part of reminders
 *
 * reminders is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * reminders is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import QtTest 1.0
import Ubuntu.Components 1.1
import Ubuntu.Test 0.1

import '../../src/app/qml/components'

Item {
    id: root

    width: units.gu(40)
    height: units.gu(60)

    ListModel {
        id: notebooks

       ListElement {
            objectName: 'privateNote'
            guid: 'dummy'
            name: 'dummy'
            lastUpdatedString: 'dummy'
            published: false
            noteCount: 'dummy'
        }

        ListElement {
            objectName: 'sharedNote'
            guid: 'dummy'
            name: 'dummy'
            lastUpdatedString: 'dummy'
            published: true
            noteCount: 'dummy'
        }
    }

    ListView {
        id: notebooksListView
        anchors.fill: parent
        
        model: notebooks

        delegate: NotebooksDelegate {
            objectName: model.objectName
        }
    }

    UbuntuTestCase {
        id: notebooksDelegateTestCase
        name: 'notebooksDelegateTestCase'

        when: windowShown

        function init() {
            waitForRendering(notebooksListView)
        }

        function test_unpublishedNotebookMustDisplayPrivateLabel() {
            var privateNote = findChild(notebooksListView, 'privateNote')
            var publishedLabel = findChild(
                privateNote, 'notebookPublishedLabel')

            compare(publishedLabel.text, 'Private')
            compare(publishedLabel.color, '#b3b3b3')
            compare(publishedLabel.font.bold, false)
        }

        function test_publishedNotebookMustDisplaySharedLabel() {
            var privateNote = findChild(notebooksListView, 'sharedNote')
            var publishedLabel = findChild(
                privateNote, 'notebookPublishedLabel')

            compare(publishedLabel.text, 'Shared')
            compare(publishedLabel.color, '#000000')
            compare(publishedLabel.font.bold, true)
        }
    }

}
