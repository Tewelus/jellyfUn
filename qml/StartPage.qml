import QtQuick 2.7
import Ubuntu.Components 1.3


Rectangle {
    id: startPage
    anchors.fill: parent
    color: "black"





    Rectangle {
        id:serverColum
        color: "black"
        width: parent.width
        height: parent.height / 7

        Text {
            id: setServerTxt
            text: qsTr('Server:')
            color: "white"
            height: units.gu(4)
            width: (parent.width - setServerTxt.width) * 0.7
            x: setServerInputWrapper.x
            y:parent.height/2-height/2
            // anchors {leftMargin: units.gu(3)}
        }

        Rectangle {
            id: setServerInputWrapper
            height: units.gu(4)
            width: parent.width  * 0.7

            x:(parent.width - width)/2
            anchors.top: setServerTxt.bottom
            clip: true



            TextField {
                id:setServerInput


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
            id: serverButton
            width: parent.width * 0.2
            height: parent.height *0.8
            anchors {top: serverColum.bottom; topMargin: units.gu(3);}
            radius: units.gu(3)
            x: parent.width /2 - width/2
            y: parent.height/2 -height/2
            color: "#00a4dc"
            Text {
                id: authButtonTxt
                text: qsTr("Go")
                color: "white"
                x: parent.width /2 - width/2
                y: parent.height/2 -height/2
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {

                    if(setServerInput.text){
                        settings.serverUrl = setServerInput.text

                        webviewLoader.active = false


                    } else {

                        console.log("Set server and username")

                        //                   msgBoxLoader.msgHeadline = "Please set your Server and Username"
                        //                   msgBoxLoader.active = true

                    }
                }
            }
        }


    }
    Image{
        id: jellyBanner
        width: parent.width *0.6
        x:(parent.width - width )/2
        y: (parent.height -height) /2
        source: "banner-light.png"

        fillMode: Image.PreserveAspectFit

    }
}


