/*
 * Copyright (C) 2021  Tewel
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * jellyfun is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/* Contribution
  Function to get the Fullscreen mode working
  https://github.com/mateosalta/cuddly-bassoon/blob/master/app/Main.qml
  https://github.com/mateosalta



  */


import QtQuick 2.9
import Ubuntu.Components 1.3
import QtWebEngine 1.9
import Qt.labs.settings 1.0
import QtQuick.Window 2.2
import io.thp.pyotherside 1.3
import Morph.Web 0.1
import QtQuick.Layouts 1.1
import Qt.labs.platform 1.0 //for the StandardPaths
import Ubuntu.Content 1.3




MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'jellyfun.jellyfun'
    automaticOrientation: true


    width: units.gu(45)
    height: units.gu(75)
    backgroundColor: "gray"

    property bool waitForScroll: true
    property int lastScrollPosY: 0.0
    property bool myFullScreen: false
    property string standartPathData: StandardPaths.writableLocation(StandardPaths.CacheLocation)

    property string m_contentTyp

    Settings{
        id: settings

        property string serverUrl
        property real myZoomFactor: 2.5

    }


    Label {
        width: parent.width
        height: flickMouse.drag.maximumY


        Text {
            id: refreshText
            text: qsTr("Pull to refresh")
            x: (parent.width / 2 ) - (width /2)
            y: parent.height / 2
            color: "white"
        }

    }


    // my own Flickable to meet the requirements

    MouseArea{
        id: flickMouse
        width: parent.width
        height: parent.height

        drag.target: webViewWrapper
        drag.axis: Drag.YAxis
        drag.maximumY: webViewWrapper.height/5
        drag.minimumY: root.x
        drag.filterChildren: true
        drag.smoothed: true
        drag.threshold: units.gu(10)


        onReleased: {

            if(webViewWrapper.y > (refreshText.height + refreshText.y)) {

                myWebview.reload()
                if(myWebview.loadProgress >= 50) {
                    webViewWrapper.y = root.x
                }

            } else {


                webViewWrapper.y = root.x
            }

        }


        // Timer to toggle the bottemMenu

        Timer{
            id: bottomMenuTimer
            interval: 5000

            onTriggered: {
                if(!webviewLoader.active){
                    bottomMenue.z = -1
                }

            }

        }

        // Timer to fade MsgBox away

        Timer{
            id: msgBoxTimer
            interval: 1000

            onTriggered: {
                msgBoxLoader.active = false
                msgBoxLoader.shortMsg = false

            }

        }


        Item {
            id:webViewWrapper
            width: root.width
            height: root.height


            WebEngineProfile {
                id: myWebProfile
                storageName: "myProfile"
                offTheRecord: false
                persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
                property alias dataPath: myWebProfile.persistentStoragePath
                downloadPath: standartPathData.slice(7) + "/Downloads/"

                onDownloadRequested: {
                    download.accept()
                    refreshProgressLoader.active = true
                }

                onDownloadFinished: {

                    //                        msgBoxLoader.msgHeadline = "Download Finished"
                    //                        msgBoxLoader.shortMsg = true
                    //                        msgBoxLoader.active = true
                    //                        msgBoxTimer.start()

                    // picker for the ContentHub

                    refreshProgressLoader.active = false

                    picker.contentTyp = m_contentTyp;
                    picker.url = download.path;
                    //  pickerLoader.loaderUrl = path;
                    picker.opacity = 1;
                    picker.z = 4
                    // downloadProgressID.opacity = 0  // Todo adding ProgressBar


                }

            }


            WebEngineView{
                id:myWebview
                zoomFactor: settings.myZoomFactor
                anchors.fill: parent
                url: settings.serverUrl

                profile: myWebProfile

                onLoadingChanged: {

                    if(loadProgress === 100) {
                        bottomMenuTimer.start()
                    }
                }


                onFullScreenRequested: function(request) {
                    request.accept();
                    if (request.toggleOn) {
                        window.showFullScreen();
                    }
                    else {
                        window.showNormal();
                    }
                }


                onScrollPositionChanged: {


                    var scrollDiffY = lastScrollPosY - scrollPosition.y

                    //                     console.log("lastScrollPos " + lastScrollPosY)
                    //                     console.log("scrollPos " + scrollPosition.y)
                    //                     console.log("scrollDiffY " + scrollDiffY)

                    lastScrollPosY = scrollPosition.y

                    // to detect scrolldirection

                    if(scrollDiffY > 0){
                        //   console.log("ScrollUp")
                        bottomMenue.z = 1

                    }else if(scrollDiffY < 0) {
                        //  console.log("ScrollDown")

                        bottomMenuTimer.start()


                    }


                    // the pull request is only possible if the scroll position is at the top

                    if (scrollPosition.y !== 0) {
                        flickMouse.drag.maximumY = 0


                    } else {

                        flickMouse.drag.maximumY = webViewWrapper.height/5

                    }

                }

                function setFullscreen(fullscreen) {
                    if (fullscreen) {
                        if (window.visibility != ApplicationWindow.FullScreen) {
                            window.visibility = ApplicationWindow.FullScreen
                        }
                    } else {
                        window.visibility = ApplicationWindow.Windowed
                    }
                }


                function toggleApplicationLevelFullscreen() {
                    setFullscreen(visibility !== ApplicationWindow.FullScreen)
                }

                Shortcut {
                    sequence: StandardKey.FullScreen
                    onActivated: window.toggleApplicationLevelFullscreen()
                }

                Shortcut {
                    sequence: "F11"
                    onActivated: window.toggleApplicationLevelFullscreen()
                }




            }  // End WebEngineView


            Rectangle {

                id: picker
                opacity: 0
                z: -1
                anchors.fill: parent

                property var activeTransfer
                property string url: "Test.txt"
                property var handler
                property var contentTyp

                ContentPeerPicker {
                    anchors.fill: parent;
                    contentType: ContentType.All
                    handler: ContentHandler.Destination

                    onPeerSelected: {
                        peer.selectionType = ContentTransfer.Single
                        picker.activeTransfer = peer.request()
                        picker.activeTransfer.stateChanged.connect(function() {
                            if (picker.activeTransfer.state === ContentTransfer.InProgress) {
                                console.log("In progress");
                                picker.activeTransfer.items = [ resultComponent.createObject(parent, {"url": picker.url}) ];
                                picker.activeTransfer.state = ContentTransfer.Charged;
                                pageStack.pop()

                            }
                        })
                    }


                    onCancelPressed: {
                        picker.z = -1
                        picker.opacity = 0
                        console.log("picker.url" + picker.url)


                    }

                }

                ContentTransferHint {
                    id: transferHint
                    anchors.fill: parent
                    activeTransfer:picker.activeTransfer
                }

                Component {
                    id: resultComponent
                    ContentItem{}
                }
            } // End picker



            //ToDo: implement ProgressBar for Download

            //            ProgressBar{
            //                    id: downloadProgressID
            //                    minimumValue:0;
            //                    maximumValue:100;
            //                    value: s
            //                    opacity: 0
            //                    z:2
            //                    width: parent.width
            //                    height: units.gu(2)
            //                    x:0
            //                    anchors {
            //                        bottom: parent.bottom

            //                    }

            //                }


        }

    }


    Rectangle {
        id: bottomMenue
        width: parent.width
        height: units.gu(4)
        color: "#292929"
        anchors.bottom: parent.bottom
        z: 1



        onZChanged: {

            if(!webviewLoader.active && (bottomMenue.z == 1)){
                bottomMenuTimer.start()
            }

        }

        Rectangle {
            id: startPageBtn
            width: parent.width/2
            height: parent.height
            color: "#292929"
            Image{
                id: startPageImg
                height: parent.height *0.8
                x:(parent.width - width )/2
                y: (parent.height -height) /2
                source: "../assets/startPageImg_blue.png"

                fillMode: Image.PreserveAspectFit

            }
            MouseArea {
                id: startPageMouse
                anchors.fill: parent
                onClicked: {
                    startPageImg.source = "../assets/startPageImg_blue.png"
                    if(webviewLoader.active){
                        webviewLoader.active = false


                    }

                }

            }
        }
        Rectangle {
            id: settingsBtn
            width: parent.width/2
            height: parent.height
            anchors.left: startPageBtn.right
            color: "#292929"
            Image{
                id: settingsImg
                height: parent.height *0.8
                x:(parent.width - width )/2
                y: (parent.height -height) /2
                source: "../assets/settingsIcon2.png"

                fillMode: Image.PreserveAspectFit

            }
            MouseArea {
                id: settingsMouse
                anchors.fill: parent
                onClicked: {
                    webviewLoader.source = "SettingsPage.qml"
                    webviewLoader.active = true
                    startPageImg.source = "../assets/startPageImg.png"

                }
            }
        }

    }

    Loader {
        id: webviewLoader
        height: parent.height
        width: parent.width

        active: false
        property string myurl
        property string token
        property string pollUrl

        source:"SettingsPage.qml"


        onStatusChanged: {
            if (webviewLoader.active) {
                settingsImg.source = "../assets/settingsIcon2_blue.png"
                startPageImg.source = "../assets/startPageImg.png"

            } else {
                settingsImg.source = "../assets/settingsIcon2.png"
                startPageImg.source = "../assets/startPageImg_blue.png"
            }

        }



    }

    Loader {
        id: msgBoxLoader
        width: parent.width *0.9
        height: if(shortMsg){return parent.height / 5}else{return parent.height / 3}
        x:parent.width /2 -width/2
        y: if(shortMsg){return units.gu (8)}else{return  units.gu (1)}
        active: false

        property string msgHeadline
        property string msgTxt
        property bool setTxt: false
        property string txtInput
        property bool shortMsg: false

        source:"MessageBox.qml"

        onStatusChanged: {
            if(msgBoxLoader.status == Loader.Ready){
                backgrounder.opacity = 0.4



                // textInputFolder.forceActiveFocus();
            }
            if(msgBoxLoader.status == Loader.Null){
                // backgrounder.opacity = 0
            }
        }

    }

    Loader {
          id: refreshProgressLoader
          active: false
          sourceComponent: refreshProgress
          width: parent.width / 3
          height: width
          x: parent.width/2 -width/2
          y:topRow.height + units.gu(5)

          onStatusChanged: {
              if(refreshProgressLoader.status == Loader.Ready){
                //  backgrounder.opacity = 0.2
              }
              if(refreshProgressLoader.status == Loader.Null){
                 // backgrounder.opacity = 0
              }
          }
      }

    Component {
            id: refreshProgress

            Image {
                id: refreshProgressIg
                //  x: parent.width /2 - width/2
                //  y: parent.height /2 - height/2
                source: "../assets/settingsIcon.png"
                fillMode: Image.PreserveAspectFit

                RotationAnimation on rotation {
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: 5000
                }
            }

        }

    //    Python {
    //        id: python

    //        Component.onCompleted: {
    //            addImportPath(Qt.resolvedUrl('../src/'));

    //            importModule('example', function() {
    //                console.log('module imported');
    //                python.call('example.speak', ['Hello World!'], function(returnValue) {
    //                    console.log('example.speak returned ' + returnValue);
    //                })
    //            });
    //        }

    //        onError: {
    //            console.log('python error: ' + traceback);
    //        }
    //    }

    Component.onCompleted: {

        if(settings.serverUrl === ""){

            webviewLoader.source = "StartPage.qml"
            webviewLoader.active = true
        }}
}
