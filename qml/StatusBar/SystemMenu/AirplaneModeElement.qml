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

MenuListEntry {
    id: airplaneModeElement
    property int ident: 0
    property alias modeText:     airplaneMode.text
    property bool  airplaneOn:   false

    property int iconSpacing : Units.gu(0.4) 
    property int rightMarging: Units.gu(0.8) 

    content:
        Item {
        width: airplaneModeElement.width

            Text {
            id: airplaneMode
                x: ident;
                anchors.verticalCenter: parent.verticalCenter
                //text: runtime.getLocalizedString("Turn on Airplane Mode");
                text: "Turn on Airplane Mode"
                color: selectable ? "#FFF" : "#AAA";
                font.bold: false;
                font.pixelSize: FontUtils.sizeToPixels("medium") //18
                font.family: "Prelude"
            }

            Image {
                id: airplaneIndicatorOn
                visible: !airplaneOn
                x: parent.width - width - iconSpacing - rightMarging
                width: Units.gu(3.2)
                height: Units.gu(3.2)
                anchors.verticalCenter: parent.verticalCenter
                opacity: selectable ? 1.0 : 0.65;
                source: "../../images/statusbar/icon-airplane.png"
             }

            Image {
                id: airplaneIndicatorOff
                visible: airplaneOn
                x: parent.width - width - iconSpacing - rightMarging
                width: Units.gu(3.2)
                height: Units.gu(3.2)
                anchors.verticalCenter: parent.verticalCenter
                opacity: selectable ? 1.0 : 0.65;
                source: "../../images/statusbar/icon-airplane-off.png"
             }
        }
}
