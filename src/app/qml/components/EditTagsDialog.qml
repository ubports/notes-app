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

import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.ListItems 1.3
import Evernote 0.1

Dialog {
    id: root

    title: i18n.tr("Edit tags")
    text: tags.count == 0 ? noTagsText : haveTagsText

    property string noTagsText: i18n.tr("Enter a tag name to attach it to the note.")
    property string haveTagsText: i18n.tr("Enter a tag name or select one from the list to attach it to the note.")

    property var note
    property int pageHeight

    signal done();

    Tags {
        id: tags
    }

    SortFilterModel {
        id: tagsSortFilterModel
        model: tags
        filter.property: "name"
        filter.pattern: RegExp(textField.text)
    }

    RowLayout {
        Layout.preferredWidth: parent.width - units.gu(2)
        Layout.alignment: Qt.AlignHCenter
        z: 2

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: okButton.height

            TextField {
                id: textField
                placeholderText: i18n.tr("Tag name")
                anchors.fill: parent

                onAccepted: accept();

                function accept() {
                    var tagName = displayText;
                    text = '';

                    // Check if the tag exists
                    for (var i=0; i < tags.count; i++) {
                        var tag = tags.tag(i);
                        if (tag.name == tagName) {
                            // The tag exists, check if is already selected: if it is,
                            // do nothing, otherwise add to tags of the note
                            if (note.tagGuids.indexOf(tag.guid) === -1) {
                                note.tagGuids.push(tag.guid);
                            }
                            return;
                        }
                    }

                    var newTag = NotesStore.createTag(tagName);
                    print("tag created", newTag.name, "appending to note");
                    note.tagGuids.push(newTag.guid)
                }

            }

            Rectangle {
                anchors {
                    left: textField.left
                    top: textField.bottom
                    right: textField.right
                }
                color: "white"
                border.width: units.dp(1)
                border.color: "black"
                height: Math.min(5, tagsListView.count) * units.gu(4)
                visible: (textField.text.length > 0 || textField.inputMethodComposing) && (textField.focus || tagsListView.focus)

                ListView {
                    id: tagsListView
                    anchors.fill: parent
                    model: tagsSortFilterModel
                    clip: true

                    delegate: Empty {
                        height: units.gu(4)
                        RowLayout {
                            id: tagRow
                            anchors.fill: parent
                            anchors.margins: units.gu(1)
                            spacing: units.gu(1)

                            property bool used: root.note ? root.note.tagGuids.indexOf(model.guid) !== -1 : false
                            Label {
                                text: model.name
                                color: textField.text === model.name ? UbuntuColors.orange : "black"
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                            }
                            Icon {
                                name: "tick"
                                visible: tagRow.used
                                Layout.fillHeight: true
                            }
                        }

                        onClicked: {
                            textField.text = model.name
                        }
                    }
                }
            }
        }


        Button {
            id: okButton
            text: i18n.tr("OK")
            color: UbuntuColors.orange
            enabled: textField.text.replace(/\s+/g, '') !== '' || textField.inputMethodComposing === true; // Not only whitespaces!
            onClicked: textField.accept()
        }
    }

    OptionSelector {
        id: optionSelector

        Layout.preferredWidth: parent.width - units.gu(2)
        Layout.alignment: Qt.AlignHCenter

        currentlyExpanded: true
        multiSelection: true

        containerHeight: Math.min(root.pageHeight / 3, tags.count * itemHeight)

        model: tags

        delegate: OptionSelectorDelegate {
            text: model.name
            selected: root.note ? root.note.tagGuids.indexOf(model.guid) !== -1 : false

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (selected) {
                        var index = root.note.tagGuids.indexOf(model.guid);
                        root.note.tagGuids.splice(index, 1);
                    }
                    else {
                        root.note.tagGuids.push(model.guid);
                    }
                    NotesStore.saveNote(root.note.guid);
                }
            }
        }
    }

    Button {
        id: closeButton
        Layout.preferredWidth: parent.width - units.gu(2)
        Layout.alignment: Qt.AlignHCenter

        color: UbuntuColors.orange

        text: i18n.tr("Close")

        onClicked: {
            root.done();
            PopupUtils.close(root)
        }
    }
}
