/*
 * Copyright: 2013 Canonical, Ltd
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

import QtQuick 2.3
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Components.Popups 1.0
import com.canonical.Oxide 1.5
import Ubuntu.Content 1.0
import Evernote 0.1
import "../components"

Item {
    id: root
    property var note: null
    property bool canClose: false

    signal editNote()

    BouncingProgressBar {
        anchors.top: parent.top
        visible: root.note == null || root.note.loading
        z: 10
    }

    Component.onDestruction: {
        if (priv.dirty) {
            NotesStore.saveNote(note.guid);
        }
    }

    QtObject {
        id: priv
        property bool dirty: false
    }

    WebContext {
        id: webContext

        userScripts: [
            UserScript {
                context: 'reminders://interaction'
                url: Qt.resolvedUrl("reminders-scripts.js");
            }
        ]
    }

    Rectangle {
        id: locationBar
        y: noteTextArea.locationBarController.offset
        anchors.left: parent.left
        anchors.right: parent.right
        height: headerContent.height
        color: "white"
        z: 2

        Header {
            id: headerContent
            note: root.note
            editingEnabled: false

            onEditReminders: {
                print("pushing reminderspage", root.note.reminder)
                pagestack.push(Qt.resolvedUrl("SetReminderPage.qml"), { note: root.note});
            }
            onEditTags: {
                PopupUtils.open(Qt.resolvedUrl("../components/EditTagsDialog.qml"), root, { note: root.note, pageHeight: root.height });
            }
        }
    }

    WebView {
        id: noteTextArea
        anchors.fill: parent
        anchors.bottomMargin: buttonPanel.height

        locationBarController {
            height: locationBar.height
        }

        property string html: root.note ? note.htmlContent : ""

        onHtmlChanged: {
            loadHtml(html, "file:///")
        }

        context: webContext
        preferences.standardFontFamily: 'Ubuntu'
        preferences.minimumFontSize: 14

        Connections {
            target: note ? note : null
            onResourcesChanged: {
                noteTextArea.loadHtml(noteTextArea.html, "file:///")
            }
        }

        messageHandlers: [
            ScriptMessageHandler {
                msgId: 'interaction'
                contexts: ['reminders://interaction']
                callback: function(message, frame) {
                    var data = message.args;

                    switch (data.type) {
                    case "checkboxChanged":
                        note.markTodo(data.todoId, data.checked);
                        priv.dirty = true;
                        break;
                    case "attachmentOpened":
                        var filePath = root.note.resource(data.resourceHash).hashedFilePath;
                        contentPeerPicker.filePath = filePath;

                        if (data.mediaType == "application/pdf") {
                            contentPeerPicker.contentType = ContentType.Documents;
                        } else if (data.mediaType.split("/")[0] == "audio" ) {
                            contentPeerPicker.contentType = ContentType.Music;
                        } else if (data.mediaType.split("/")[0] == "image" ) {
                            contentPeerPicker.contentType = ContentType.Pictures;
                        } else if (data.mediaType == "application/octet-stream" ) {
                            contentPeerPicker.contentType = ContentType.All;
                        } else {
                            contentPeerPicker.contentType = ContentType.Unknown;
                        }
                        contentPeerPicker.visible = true;
                    }
                }
            }
        ]
    }

    Item {
        id: buttonPanel
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: units.gu(6)

        RowLayout {
            anchors { left: parent.left; right: parent.right; fill: parent }
            anchors.margins: units.gu(1)
            height: units.gu(4)

            RtfButton {
                iconName: "tick"
                // TRANSLATORS: Button to close the note viewer
                text: i18n.tr("Close")
                height: parent.height
                iconColor: UbuntuColors.green
                visible: root.canClose
                onClicked: {
                    pageStack.pop()
                }
            }

            RtfSeparator {
                visible: root.canClose
            }

            Item {
                Layout.fillWidth: true
            }

            RtfSeparator {}

            RtfButton {
                iconName: "edit"
                // TRANSLATORS: Button to go from note viewer to note editor
                text: i18n.tr("Edit")
                height: parent.height
                iconColor: UbuntuColors.green
                onClicked: {
                    root.editNote()
                }
            }
        }
    }

    ContentItem {
        id: exportItem
        name: i18n.tr("Attachment")
    }

    ContentPeerPicker {
        id: contentPeerPicker
        visible: false
        contentType: ContentType.Unknown
        handler: ContentHandler.Destination
        anchors.fill: parent

        property string filePath: ""
        onPeerSelected: {
            var transfer = peer.request();
            if (transfer.state === ContentTransfer.InProgress) {
                var items = new Array()
                var path = contentPeerPicker.filePath;
                exportItem.url = path
                items.push(exportItem);
                transfer.items = items;
                transfer.state = ContentTransfer.Charged;
            }
            contentPeerPicker.visible = false
        }
        onCancelPressed: contentPeerPicker.visible = false
    }
}
