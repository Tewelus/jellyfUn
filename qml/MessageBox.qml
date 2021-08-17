import QtQuick 2.4
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.3


Rectangle{
    id: msgBoxWrapper
    color: "#FAFAFA"
    anchors.fill: parent
    radius: units.gu(1)
    opacity: 0.8


    Text {
        id: msgHeadline
        text: {if(msgBoxLoader.msgHeadline){return msgBoxLoader.msgHeadline}}
        font.pointSize: units.gu(1.3)
        width: parent.width *0.8
        height: parent.height - selectBar.height
        x:parent.width/2 - width/2
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors {top: parent.top; margins: units.gu(3);}
        visible: {if(msgBoxLoader.msgHeadline){return true}}
    }

    Rectangle{
        height:units.gu(3)
        color: "white"
        border.color: "gray"
        anchors {left: parent.left; right: parent.right; margins: units.gu(3);top:msgHeadline.bottom}
        visible: msgBoxLoader.setTxt

        TextField {
            id:msgInputTxt
            text: ""
            //font.pointSize: units.gu(1.2)
            //cursorVisible: true
            width: parent.width
            height: parent.height
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter

        }

    }

    Rectangle{
        id:selectBar
        width: parent.width
        height: parent.height / 5
        color: "#FAFAFA"
        anchors{bottom: parent.bottom}
        visible: if(msgBoxLoader.shortMsg){return false}else{return true}


        Rectangle{
            id:selectCancel
            width: parent.width /2
            height: parent.height
            anchors {left: parent.left}
            border.color: "gray"
            visible: msgBoxLoader.setTxt
            Text {
                id: selectCancelTxt
                x:parent.width/2 -width/2
                y:parent.height/2 - height/2
                text: qsTr("Cancel")
            }
            MouseArea{
                anchors.fill: parent
                onPressed: {
                    console.log("Canceld Pressed")
                    msgBoxLoader.active = false

                }
            }
        }
        Rectangle{
            id:selectOK
            width: parent.width /2
            height: parent.height
            anchors {left: selectCancel.right}
            border.color: "gray"

            Text {
                id: selectOKTxt
                x:parent.width/2 -width/2
                y:parent.height/2 - height/2
                text: qsTr("OK")
            }
            MouseArea{
                anchors.fill: parent

                onClicked: {
                    console.log("OK Pressed")
                    msgBoxLoader.active = false
                    if(msgInputTxt.text){

                        msgBoxLoader.txtInput = msgInputTxt.text
                    }
                }
            }
        }
    }
}
