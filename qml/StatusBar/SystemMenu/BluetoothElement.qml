/* @@@LICENSE
*
*      Copyright (c) 2009-2013 LG Electronics, Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*
* LICENSE@@@ */

import QtQuick 2.0
import LunaNext.Common 0.1

Drawer {
    id: bluetoothMenu
    property int ident:        0
    property int internalIdent: 0

    property bool isBluetoothOn: false
    property bool btTurningOn:   false
    property bool coloseOnConnect: false
    property string deviceAddressInError: ""

    // ------------------------------------------------------------
    // External interface to the Bluetooth Element is defined here:

    signal menuCloseRequest(int delayMs)
    signal menuOpened()
    signal menuClosed()
    signal onOffTriggered()
    signal prefsTriggered()
    signal itemSelected(int index)

    function setBluetoothState(isOn, turningOn, state) {

        if(turningOn) {
            bluetoothOnOffText.text = "Turning on Bluetooth...";
        } else {
            if(!isOn) {
                bluetoothOnOffText.text = "Turn on Bluetooth";
            } else {
                bluetoothOnOffText.text = "Turn off Bluetooth";
            }
        }

        isBluetoothOn = isOn
        btTurningOn = turningOn;
        bluetoothTitleState.text = state
    }

    function addBluetoothEntry(name, address, cod, connStatus, connected) {
       btTurningOn = false;

       bluetoothList.append({ "deviceName": name,
                              "deviceAddress": address,
                              "deviceCod": cod,
                              "connectionStatus": connStatus,
                              "isConnected": connected,
                              "listIndex": bluetoothList.count,
                              "itemStatus": (connStatus != "connecting") ? "" : "Connecting...",
                              "showErrorIfConnectFails": (connStatus === "connecting"),
                              "showSelected":(connStatus == "connecting")
                              })

            bluetoothListView.height = (bluetoothOnOff.height + separator.height) * bluetoothList.count
    }



    function updateBluetoothEntry(name, address, cod, connectionStatus, connected) {
        for(var index = 0; index < bluetoothList.count; index++) {
            var entry = bluetoothList.get(index)
            if(entry.deviceAddress === address) {

                if(bluetoothMenu.isOpen() && (entry.connectionStatus != "connected") && (connectionStatus === "connected") && coloseOnConnect) {
                    // close the menu upon connection
                    menuCloseRequest(350);
                    coloseOnConnect = false;
                }

                entry.deviceName       = name;
                entry.connectionStatus = connectionStatus;
                entry.isConnected      = connected;
                entry.showSelected     = (connectionStatus == "connecting");
                if(cod != 0)
                    entry.deviceCod = cod;

                if(connectionStatus == "disconnected") {
                    console.log("##### Device Disconnected: " + entry.deviceName + ". entry.showErrorIfConnectFails = " + entry.showErrorIfConnectFails);
                    if(entry.showErrorIfConnectFails == true) {
                        // we failed to connect, so notify the user
                        entry.itemStatus = "Unable to connect";
                        resetStatusTimer.stop();
                        resetStatusTimer.interval = 5000;
                        resetStatusTimer.start();

                        if((deviceAddressInError != address) && (deviceAddressInError != "")) {
                            resetEntryStatus();
                        }

                        deviceAddressInError = address;
                    } else {
                        entry.itemStatus = "";
                    }
                } else if(connectionStatus == "connecting") {
                    entry.itemStatus = "Connecting...";
                    entry.showErrorIfConnectFails = true;
                } else if(connectionStatus == "connected") {
                    entry.itemStatus = "";
                    entry.showErrorIfConnectFails = false;
                } else if(connectionStatus == "disconnecting") {
                    entry.itemStatus = "";
                 } else {
                    entry.itemStatus = "";
                    entry. showErrorIfConnectFails = false;
                }
            }
        }
    }

    function clearBluetoothList() {
        bluetoothList.clear()
	bluetoothListView.height = 1
    }

    function resetEntryStatus() {
        for(var index = 0; index < bluetoothList.count; index++) {
            var entry = bluetoothList.get(index)
            if(entry.deviceAddress === deviceAddressInError) {
                entry.itemStatus = "";
                entry.showErrorIfConnectFails = false;
                entry.showSelected = false;
                deviceAddressInError = "";
            }
        }
    }

    // ------------------------------------------------------------

    width: parent.width

    onDrawerOpened:  {
        coloseOnConnect = false;
        menuOpened();
        resetStatusTimer.stop();
    }

    onDrawerClosed: menuClosed()

    drawerHeader:
    MenuListEntry {
        selectable: bluetoothMenu.active
        content: Item {
                    width: parent.width;

                    Text{
                        id: bluetoothTitle
                        x: ident;
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Bluetooth";
                        color: bluetoothMenu.active ? "#FFF" : "#AAA";
                        font.bold: false;
                        font.pixelSize: FontUtils.sizeToPixels("medium") //18
                        font.family: "Prelude"
                    }

                    Spinner {
                        id: bluetoothSpinner
                        x: bluetoothTitle.width + Units.gu(2); 
                        y: Units.gu(-1.7) 
                        width: Units.gu(3.2)
                        height: Units.gu(3.2)
                        on: btTurningOn && bluetoothMenu.isOpen();
                    }

                    Text {
                        id: bluetoothTitleState
                        x: bluetoothMenu.width - width - Units.gu(1.4); 
                        width: bluetoothMenu.width - bluetoothTitle.width - Units.gu(3.5)
                        horizontalAlignment: Text.AlignRight
                        elide: Text.ElideRight;
                        anchors.verticalCenter: parent.verticalCenter
                        text: "init";
                        color: "#AAA";
                        font.pixelSize: FontUtils.sizeToPixels("small") //13
                        font.family: "Prelude"
                        font.capitalization: Font.AllUppercase
                    }
                }
    }

    drawerBody:
    Column {
        spacing: 0
        width: parent.width

        MenuDivider { id: separator }

        MenuListEntry {
            id: bluetoothOnOff
            selectable: true
            content: Text {
                         id: bluetoothOnOffText;
                         x: ident + internalIdent;
                         text: "Turn off Bluetooth";
                         color: "#FFF";
                         font.bold: false;
                         font.pixelSize: FontUtils.sizeToPixels("medium"); //18;
                         font.family: "Prelude"
                     }
            onAction: {
                 if(isBluetoothOn && !btTurningOn)
                    menuCloseRequest(300);

                onOffTriggered()
            }
        }

        MenuDivider  { }

        ListView {
	    id: bluetoothListView
            width: parent.width
	    height: Units.gu(0.1)
            interactive: false
            spacing: 0
            model: bluetoothList
            delegate: bluetoothListDelegate
        }

        MenuListEntry {
            selectable: true
            content: Text {
		x: ident + internalIdent;
        text: "Bluetooth Preferences";
		color: "#FFF";
	        font.bold: false;
		font.pixelSize: FontUtils.sizeToPixels("medium"); //18; 
		font.family: "Prelude";
	    }
            onAction: {
                prefsTriggered();
                menuCloseRequest(300);
            }
        }
    }

    Component {
        id: bluetoothListDelegate
        Column {
            spacing: 0
            width: parent.width
            property int index: listIndex

            MenuListEntry {
                id: entry
                selectable: true
                forceSelected: showSelected

                content: BluetoothEntry {
                            id: btDeviceData
                            x: ident + internalIdent;
                            width: bluetoothMenu.width-x;
                            name:         deviceName;
                            address:      deviceAddress;
                            cod:          deviceCod;
                            connStatus:   connectionStatus;
                            status:       itemStatus;
                            connected:    isConnected;
                         }

                onAction: {
                    if(deviceAddressInError != "") {
                        resetEntryStatus();
                    }

                    bluetoothList.get(index).showErrorIfConnectFails = false;
                    itemSelected(index)

                    coloseOnConnect = false;

                    if(btDeviceData.connected) {
                        menuCloseRequest(350);
                    } else {
                        coloseOnConnect = true;
                    }
                }
            }

            MenuDivider  { }

        }

    }

    ListModel {
        id: bluetoothList
    }

    Timer{
        id      : resetStatusTimer
        repeat  : false;
        running : false;

        onTriggered: resetEntryStatus()
    }
}

