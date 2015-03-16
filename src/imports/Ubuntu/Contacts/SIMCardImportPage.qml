﻿/*
 * Copyright (C) 2015 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import QtContacts 5.0

import Ubuntu.Components 1.1
import Ubuntu.Contacts 0.1
import Ubuntu.Components.ListItems 1.0 as ListItem

import MeeGo.QOfono 0.2

Page {
    id: root

    readonly property string exportFile: "file:///tmp/ubuntu_contacts_sim.vcf"
    readonly property alias hasContacts: simCardContacts.hasContacts
    property var targetModel: null

    title: i18n.tr("SIM contacts")

    OfonoManager {
        id: ofonoManager
    }

    Column {
        id: lockedSIMList
        anchors {
            left: parent.left
            right: parent.right
        }
        //height: childrenRect.height

        Repeater {
            anchors {
                left: parent.left
                right: parent.right
            }
            model: ofonoManager.modems
            delegate: ListItem.Standard {
                OfonoSimManager {
                    id: simManager
                    modemPath: modelData
                }
                visible: simManager.pinRequired !== OfonoSimManager.NoPin
                text: i18n.tr("SIM %1 is locked").arg(index + 1)
                control: Button {
                    text: i18n.tr("Unlock")
                    onClicked: Qt.openUrlExternally("settings:///system/security-privacy")
                }
            }
        }
    }

    ContactListView {
        id: contactList
        objectName: "contactListViewFromSimCard"

        anchors {
            left: parent.left
            right: parent.right
            top: lockedSIMList.bottom
            bottom: parent.bottom
        }
        multiSelectionEnabled: true
        multipleSelection: true
        showSections: false
        visible: !indicator.visible

        manager: "memory"
        onSelectionCanceled: pageStack.pop()
    }

    Label {
        id: statusMessage

        anchors.centerIn: parent
        text: i18n.tr("No contacts found")
        visible: (contactList.count == 0 &&
                  root.state === "" &&
                  !contactList.busy)
    }

    Column {
        id: indicator

        property alias title: activityLabel.text

        anchors.centerIn: root
        spacing: units.gu(2)
        visible: false

        ActivityIndicator {
            id: activity

            anchors.horizontalCenter: parent.horizontalCenter
            running: indicator.visible
        }
        Label {
            id: activityLabel

            anchors.horizontalCenter: activity.horizontalCenter
        }
    }

    SimCardContacts {
        id: simCardContacts

        property bool contactImported: false

        Component.onCompleted: {
            if (vcardFile != "" && !contactImported) {
                root.state = "loading"
                contactImported = true
                contactList.listModel.importContacts(vcardFile)
            }
        }
        onVcardFileChanged: {
            if ((vcardFile != "") && !contactImported) {
                contactImported = true
                contactList.listModel.importContacts(vcardFile)
            }
        }
        onImportFail: root.state = "error"
    }

    Connections {
        target: contactList.listModel
        onImportCompleted: {
            contactList.startSelection()
            root.state = ""
        }

        onExportCompleted: {
            if ((error === ContactModel.ExportNoError) && targetModel) {
                targetModel.importContacts(url)
             }
             pageStack.pop()
        }
    }

    head.actions: [
        Action {
            text: (contactList.selectedItems.count === contactList.count) ?
                      i18n.tr("Unselect All") :
                      i18n.tr("Select All")
            iconName: "select"
            onTriggered: {
                if (contactList.selectedItems.count === contactList.count) {
                    contactList.clearSelection()
                } else {
                    contactList.selectAll()
                }
            }
            visible: (contactList.count > 0)
        },
        Action {
            text: i18n.tr("Import")
            objectName: "confirmImport"

            iconName: "tick"
            enabled: (contactList.selectedItems.count > 0)
            onTriggered: {
                root.state = "importing"
                var contacts = []
                var items = contactList.selectedItems

                for (var i=0, iMax=items.count; i < iMax; i++) {
                    contacts.push(items.get(i).model.contact)
                }

                contactList.listModel.exportContacts(root.exportFile,
                                                     [],
                                                     contacts)
            }
        }
    ]

    states: [
        State {
            name: "loading"
            PropertyChanges {
                target: indicator
                title: i18n.tr("Loading")
                visible: true
            }
        },
        State {
            name: "importing"
            PropertyChanges {
                target: indicator
                title: i18n.tr("Importing")
                visible: true
            }
        },
        State {
            name: "error"
            PropertyChanges {
                target: statusMessage
                text: i18n.tr("Fail to read SIM card")
                visible: true
            }
        }
    ]
}
