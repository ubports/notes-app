import QtQuick 2.2
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Components.Themes.Ambiance 1.1
import Evernote 0.1


Column {
    id: root
    width: parent.width
    height: childrenRect.height

    property var note: null

    property bool editingEnabled: true

    property alias title: titleTextField.text

    signal editReminders();
    signal editTags();

    Notebooks {
        id: notebooks
    }

    Component.onCompleted: setNotebookTimer.start();
    onNoteChanged: setNotebookTimer.start();
    // in case note is set during creation, the animation breaks if we set selectedIndex. Wait for a eventloop pass
    Timer { id: setNotebookTimer; interval: 1; repeat: false; onTriggered: updateNotebook(); }

    function updateNotebook() {
        if (!root.note) return;
        for (var i = 0; i < notebooks.count; i++) {
            if (notebooks.notebook(i).guid == root.note.notebookGuid) {
                if (notebookSelector.selectedIndex != i) { // Avoid setting it twice as it breaks the animation
                    notebookSelector.selectedIndex = i;
                }
            }
        }
    }

    TextField {
        id: titleTextField
        height: units.gu(6)
        width: parent.width
        text: root.note ? root.note.title : ""
        placeholderText: i18n.tr("Untitled")
        font.pixelSize: units.gu(4)
        visible: root.editingEnabled
        style: TextFieldStyle {
            background: null
        }
    }

    Label {
        height: units.gu(6)
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: units.gu(1)
        text: root.note ? root.note.title : ""
        visible: !root.editingEnabled
        font.pixelSize: units.gu(4)
        verticalAlignment: Text.AlignVCenter
    }

    ThinDivider {}

    ItemSelector {
        id: notebookSelector
        width: parent.width
        model: notebooks

        onDelegateClicked: {
            var newNotebookGuid = model.notebook(index).guid;
            if (newNotebookGuid != root.note.notebookGuid) {
                root.note.notebookGuid = newNotebookGuid;
                NotesStore.saveNote(root.note.guid)
            }
        }

        delegate: OptionSelectorDelegate {
            Rectangle {
                anchors.fill: parent
                color: "white"

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: units.gu(1)
                        rightMargin: units.gu(1)
                        topMargin: units.gu(0.5)
                        bottomMargin: units.gu(0.5)
                    }

                    Item {
                        height: parent.height
                        width: height
                        Icon {
                            anchors.fill: parent
                            anchors.margins: units.gu(0.5)
                            name: "notebook"
                            color: preferences.colorForNotebook(model.guid)
                        }
                    }

                    Label {
                        text: model.name
                        Layout.fillWidth: true
                        color: preferences.colorForNotebook(model.guid)
                    }
                    RtfButton {
                        iconName: root.note && root.note.reminder ? "reminder" : "reminder-new"
                        height: parent.height
                        width: height
                        iconColor: root.note && note.reminder ? UbuntuColors.blue : Qt.rgba(0.0, 0.0, 0.0, 0.0)
                        visible: index == notebookSelector.selectedIndex
                        onClicked: {
                            Qt.inputMethod.hide();
                            root.editReminders();
                        }
                    }
                    RtfButton {
                        id: tagsButton
                        iconSource: "../images/tags.svg"
                        height: parent.height
                        width: height
                        visible: index == notebookSelector.selectedIndex
                        onClicked: {
                            Qt.inputMethod.hide();
                            root.editTags();
                        }
                    }
                }
            }
        }
    }

    ThinDivider {}
}

