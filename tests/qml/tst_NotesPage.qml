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
import Evernote 0.1

import '../../src/app/qml/components'
import '../../src/app/qml/'

Item {
    id: root

    width: units.gu(40)
    height: units.gu(60)

    QtObject {
        id: preferences

        property string accountName: "@local"
        property int sortOrder: 0

        function colorForNotebook(notebookguid) {
            return "black";
        }
    }

    Reminders {
        id: mainView
        anchors.fill: parent

        applicationName: "com.ubuntu.reminders_test"

        property bool useSandbox: false
        property bool tablet: false
        property bool phone: true
    }

    UbuntuTestCase {
        id: notebooksDelegateTestCase
        name: 'notebooksDelegateTestCase'
        when: windowShown

        function init() {
            tryCompare(NotesStore, "username", "@local")
            while (NotesStore.count > 0) {
                NotesStore.deleteNote(NotesStore.note(0).guid)
            }
        }

        function cleanupTestCase() {
            while (NotesStore.count > 0) {
                NotesStore.deleteNote(NotesStore.note(0).guid)
            }
            //wait(500)
            waitForRendering(mainView)
        }

        function initTestCase() {
            wait(500)
            //waitForRendering(mainView)
        }

        function createNote(title) {
            var note = NotesStore.createNote(title);
            waitForRendering(mainView);
            var saveButton = findChild(mainView, "saveButton");
            mouseClick(saveButton, 1, 1);
            waitForRendering(mainView);
            return note;
        }

        function test_createNoteFromBottomEdge() {

            var x = mainView.width / 2;
            var startY = mainView.height - 1;
            var dY = -mainView.height * 3 / 4;
            mousePress(mainView, x, startY)
            mouseMoveSlowly(mainView, x, startY, 0, dY, 10, 10)
            mouseRelease(mainView, x, startY + dY)

            tryCompare(NotesStore, "count", 1);
            waitForRendering(mainView);

            var noteTextArea = findChild(mainView, "noteTextArea");
            var titleTextField = findChild(mainView, "titleTextField");

            mouseClick(titleTextField, 1, 1);
            // clear the textField
            mouseClick(titleTextField, titleTextField.width - units.gu(1), titleTextField.height / 2);
            compare(titleTextField.text, "");

            typeString("testnote1");

            mouseClick(noteTextArea, 1, 1)

            typeString("This is a note for testing");

            var saveButton = findChild(mainView, "saveButton");
            mouseClick(saveButton, 1, 1);

            // Wait for bottom edge to close
            var notesPage = findChild(mainView, "notesPage")
            tryCompare(notesPage, "bottomEdgeContentShown", false);
            waitForRendering(mainView)

            var newNote = NotesStore.note(0);
            compare(newNote.title, "testnote1");
            compare(newNote.plaintextContent, "This is a note for testing");
        }

        function test_deleteNoteFromListItemAction() {
            createNote("testNote1")
            waitForRendering(mainView);

            var delegate = findChild(mainView, "notesDelegate0");

            var x = delegate.width / 2
            var y = delegate.height / 2
            var dx = delegate.width / 2
            mousePress(delegate, 1, 1)
            mouseMoveSlowly(delegate, x, y, dx, 0, 10, 20)
            mouseRelease(delegate, x + dx, y)
            waitForRendering(mainView)
            mouseClick(delegate, units.gu(3), y)
            tryCompare(NotesStore, "count", 0);
        }

        function test_sorting_data() {
            return [
                { tag: "Date created (newest first)", sortingOption: 0, sortOrder: [3, 2, 1] },
                { tag: "Date created (oldest first)", sortingOption: 1, sortOrder: [1, 2, 3] },
                { tag: "Date updated (newest first)", sortingOption: 2, sortOrder: [2, 3, 1] },
                { tag: "Date updated (oldest first)", sortingOption: 3, sortOrder: [1, 3, 2] },
                { tag: "Title (ascending)", sortingOption: 4, sortOrder: [1, 2, 3] },
                { tag: "Title (descending)", sortingOption: 5, sortOrder: [3, 2, 1] }
            ];
        }

        function test_sorting(data) {
            var note1 = createNote("testNote1");
            var note2 = createNote("testNote2");
            var note3 = createNote("testNote3");

            note2.reminder = true;
            NotesStore.saveNote(note2.guid);

            // TODO: Is there a better way to click on toolbar actions?
            mouseClick(mainView, mainView.width - units.gu(10), units.gu(4))

            waitForRendering(mainView);

            var sortOption = findChild(root, "sortingOption" + data.sortingOption);
            mouseClick(sortOption, 1, 1);

            waitForRendering(root);

            for (var i = 0; i < data.sortOrder.length; i++) {
                var delegate = findChild(mainView, "notesDelegate" + i);
                compare(delegate.title, "testNote" + data.sortOrder[i]);
            }
        }
    }
}
