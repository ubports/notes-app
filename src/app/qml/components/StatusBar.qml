import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3
import Evernote 0.1

Rectangle {
    id: root
    height: shown ? statusBarContents.height + units.gu(1) : 0
    clip: true

    property bool shown: false
    property alias iconName: icon.name
    property alias iconColor: icon.color
    property alias text: label.text
    property alias showCancelButton: cancelButton.visible

    signal cancel();

    Behavior on height {
        UbuntuNumberAnimation {}
    }

    RowLayout {
        id: statusBarContents
        anchors { left: parent.left; right: parent.right; leftMargin: units.gu(1); rightMargin: units.gu(1); verticalCenter: parent.verticalCenter }
        spacing: units.gu(1)
        Column {
            spacing: units.gu(1)
            Layout.fillWidth: true

            Row {
                anchors { left: parent.left; right: parent.right }
                spacing: units.gu(1)
                height: label.height

                Icon {
                    id: icon
                    height: units.gu(3)
                    width: height
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label {
                    id: label
                    width: parent.width - x
                    wrapMode: Text.WordWrap
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Button {
            id: cancelButton
            Layout.preferredWidth: height
            iconName: "cancel"
            onClicked: root.cancel();
        }
    }
}
