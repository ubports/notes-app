import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.ListItems 1.3
import Evernote 0.1

Dialog {
    id: dialog
    title: i18n.tr("Sort by")

    property alias sortOrder: optionSelector.selectedIndex

    signal accepted(int sortOrder);

    OptionSelector {
        id: optionSelector
        expanded: true
        model: [
            i18n.tr("Date created (newest first)"),
            i18n.tr("Date created (oldest first)"),
            i18n.tr("Date updated (newest first)"),
            i18n.tr("Date updated (oldest first)"),
            i18n.tr("Title (ascending)"),
            i18n.tr("Title (descending)")
        ]
        delegate: OptionSelectorDelegate {
            objectName: "sortingOption" + index
        }
        onDelegateClicked: {
            dialog.accepted(index);
            PopupUtils.close(dialog);
        }
    }
}
