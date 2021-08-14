import QtQuick 2.7
import Ubuntu.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import Morph.Web 0.1


Rectangle {
    id: settingsPage
    anchors.fill: parent
    color: "black"


    Rectangle {
        id:settingsServerColum
        color: "black"
        width: parent.width
        height: parent.height / 7

        Text {
            id: setSettingsServerTxt
            text: qsTr('Server:')
            color: "white"
            height: units.gu(4)
            width: (parent.width - setSettingsServerInputWrapper.width) * 0.7
            x: setSettingsServerInputWrapper.x
            y:parent.height/2-height/2
            // anchors {leftMargin: units.gu(3)}
        }

        Rectangle {
            id: setSettingsServerInputWrapper
            height: units.gu(4)
            width: parent.width  * 0.7

            x:(parent.width - width)/2
            anchors.top: setSettingsServerTxt.bottom
            clip: true



            TextField {
                id:setSettingsServerInput


                color: "#00a4dc"
                property bool serverChanged: false
                width: parent.width
                height: parent.height
                inputMethodHints: Qt.ImhUrlCharactersOnly
                text:{

                    if (settings.serverUrl !== ""){ settings.serverUrl} else {""}}
                //   wrapMode: TextInput.Wrap
                //  onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)



            }
        }

        Rectangle {
            id: settingsServerButton
            width: parent.width * 0.4
            height: parent.height *0.4
            anchors {top: settingsServerColum.bottom; topMargin: units.gu(3);}
            radius: units.gu(3)
            x: parent.width /2 - width/2
            y: parent.height/2 -height/2
            color: "#00a4dc"
            Text {
                id: serverButtonTxt
                text: qsTr("Save")
                color: "white"
                x: parent.width /2 - width/2
                y: parent.height/2 -height/2
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {

                    if(setServerInput.text){
                        settings.serverUrl = setSettingsServerInput.text

                        webviewLoader.active = false


                    } else {

                        console.log("Set server and username")

                        //                   msgBoxLoader.msgHeadline = "Please set your Server and Username"
                        //                   msgBoxLoader.active = true

                    }
                }
            }
        }

        Rectangle {
            id: scalingBox

            width: parent.width *0.8
            height: parent.height *0.8
            anchors.top: settingsServerButton.bottom
            color: "transparent"

            Text {
                id: setZoomSliderTxt
                text: qsTr('Set Zoomfactor:')
                color: "white"
                height: units.gu(4)
                width: (parent.width - setSettingsServerTxt.width) * 0.7
                x: setSettingsServerInputWrapper.x
                y:parent.height/2-height/2

            }

            Slider {
                anchors.top: setZoomSliderTxt.bottom
                x: setSettingsServerInputWrapper.x
                width: setSettingsServerInput.width
                function formatValue(v) { return v.toFixed(2) }
                minimumValue: 0.25
                maximumValue: 5
                value: settings.myZoomFactor
                live: true

                onValueChanged: {
                    settings.myZoomFactor = value
                    myWebview.zoomFactor = value
                }

            }
        }


    }

}
