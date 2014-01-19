/*
 * Copyright: 2013 Canonical, Ltd
 *
 * This file is part of reminders-app
 *
 * reminders-app is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * reminders-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import Evernote 0.1
import "../components"

Page {
    id: notebooksPage

    onActiveChanged: {
        if (active) {
            notebooks.refresh();
        }
    }

    tools: ToolbarItems {
        ToolbarButton {
            text: "search"
            iconName: "search"
            onTriggered: {
                pagestack.push(Qt.resolvedUrl("SearchNotesPage.qml"))
            }
        }

        ToolbarSpacer { }

        ToolbarButton {
            text: "add notebook"
            iconName: "add"
            onTriggered: {
                contentColumn.newNotebook = true;
            }
        }
    }


    Notebooks {
        id: notebooks
    }

    Column {
        id: contentColumn
        anchors.fill: parent
        property bool newNotebook: false

        states: [
            State {
                name: "newNotebook"; when: contentColumn.newNotebook
                PropertyChanges { target: newNotebookContainer; opacity: 1; height: newNotebookContainer.implicitHeight }
                PropertyChanges { target: buttonRow; opacity: 1; height: cancelButton.height + units.gu(4) }
            }
        ]

        Empty {
            id: newNotebookContainer
            height: 0
            visible: opacity > 0
            opacity: 0
            clip: true

            Behavior on height {
                UbuntuNumberAnimation {}
            }
            Behavior on opacity {
                UbuntuNumberAnimation {}
            }

            onVisibleChanged: {
                newNoteTitleTextField.forceActiveFocus();
            }

            TextField {
                id: newNoteTitleTextField
                anchors { left: parent.left; right: parent.right; margins: units.gu(2); verticalCenter: parent.verticalCenter }
            }
        }

        ListView {
            model: notebooks
            anchors { left: parent.left; right: parent.right }
            height: parent.height - y - buttonRow.height

            delegate: NotebooksDelegate {
                name: model.name
                noteCount: model.noteCount
                shareStatus: model.publised ? i18n.tr("shared") : i18n.tr("private")

                onClicked: {
                    pagestack.push(Qt.resolvedUrl("NotesPage.qml"), {title: name, filter: guid});
                }
            }
        }

        Item {
            id: buttonRow
            anchors { left: parent.left; right: parent.right; margins: units.gu(2) }
            height: 0
            visible: height > 0
            clip: true

            Behavior on height {
                UbuntuNumberAnimation {}
            }

            Button {
                id: cancelButton
                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                text: i18n.tr("Cancel")
                onClicked: {
                    newNoteTitleTextField.text = "";
                    contentColumn.newNotebook = false
                }
            }
            Button {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                text: i18n.tr("Save")
                enabled: newNoteTitleTextField.text.length > 0
                onClicked: {
                    NotesStore.createNotebook(newNoteTitleTextField.text);
                    newNoteTitleTextField.text = "";
                    contentColumn.newNotebook = false
                }
            }
        }
    }
}