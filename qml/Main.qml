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
import QtWebEngine 1.7
import Qt.labs.settings 1.0
import QtQuick.Window 2.2
import io.thp.pyotherside 1.3
import Morph.Web 0.1

import "." // QTBUG-34418 importet for the MorphBrowser Part



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


        Item {
            id:webViewWrapper
            width: root.width
            //  height: root.height - bottomMenue.height
            height: root.height

            WebEngineView{
                id:myWebview
                zoomFactor: settings.myZoomFactor
                anchors.fill: parent
                url: settings.serverUrl

                settings.fullScreenSupportEnabled: true

                onLoadingChanged: {

    /////////////////////////////////// MorphBrowser Part

                    if (loadRequest.errorCode === 420) {
                        myWebview.stop()
                    }
                    if ((loadRequest.url === url) && (loadRequest.status !== WebEngineLoadRequest.LoadStartedStatus)) {
                        internal.lastLoadRequestStatus = loadRequest.status;
                        internal.lastLoadRequestErrorString = loadRequest.errorString;
                        internal.lastLoadRequestErrorDomain = loadRequest.errorDomain;
                    }
                    internal.dismissCurrentContextualMenu();


    ///////////////////////////////// End MorphBrowser Part



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


  /////////////////////////////////////////// added from MorphBrowser
                property alias context: myWebview.profile
                property var incognito: false

                   /**
                    * TODO: Make contextualActions work again - for compatibility to allow
                    * some apps to still run
                    **/
                   property ActionList contextualActions

                   property var locationBarController: QtObject {
                       readonly property int modeAuto: 0
                       readonly property int modeShown: 1
                       readonly property int modeHidden: 2

                       property bool animated: false
                       property int mode: modeAuto
                       function show(animate) {
                           console.log('locationBarController.show() called')
                           // TODO
                       }
                   }

                   property var certificateError: null
                   onCertificateError: certificateError = error
                   function resetCertificateError() {
                       certificateError = null
                   }

                   /**
                   *   html select override
                   *   set enableSelectOverride to true to make Morph.Web handle select
                   *   note that as it uses javascript prompt,
                   *   make sure that onJavaScriptDialogRequested signal handler don't overplay prompt dialog by checking the isASelectRequest(request)
                   */

                   property bool enableSelectOverride: false
                   property var selectOverride: function(request) {
                       var dialog = PopupUtils.open(Qt.resolvedUrl("MorphSelectOverrideDialog.qml"), this);
                       dialog.options = request.defaultText;
                       dialog.accept.connect(request.dialogAccept);
                       dialog.reject.connect(request.dialogReject);
                       //make sure to close dialogs after returning a value ( fix freeze with big dropdowns )
                       dialog.accept.connect(function() { PopupUtils.close(dialog) })
                       dialog.reject.connect(function() { PopupUtils.close(dialog) })
                   }
                   readonly property var isASelectRequest: function(request){
                       return (request.type === JavaScriptDialogRequest.DialogTypePrompt && request.message==='XX-MORPH-SELECT-OVERRIDE-XX')
                   }

                   userScripts: WebEngineScript {
                       runOnSubframes: true
                       sourceUrl: enableSelectOverride && (screenDiagonal > 0 && screenDiagonal < 190)  ? Qt.resolvedUrl("select_overrides.js") : ""
                       injectionPoint: WebEngineScript.DocumentCreation
                       worldId: WebEngineScript.MainWorld
                   }

                   onJavaScriptDialogRequested: function(request) {

                       if (enableSelectOverride && isASelectRequest(request)) {
                           request.accepted = true
                           selectOverride(request)
                       }
                   }


                   /**
                    * Client overridable function called before the default treatment of a
                    *  valid navigation request. This function can stop the navigation request
                    *  if it sets the 'action' field of the request to IgnoreRequest.
                    *
                    */
                   function navigationRequestedDelegate(request) { }

                   context: incognito ? SharedWebContext.sharedIncognitoContext : SharedWebContext.sharedContext

                   /*
                   messageHandlers: [
                       Oxide.ScriptMessageHandler {
                           msgId: "scroll"
                           contexts: ["oxide://selection/"]
                           callback: function(msg, frame) {
                               internal.dismissCurrentContextualMenu()
                           }
                       }
                   ]
                   */

                   onNavigationRequested: {
                       request.action = WebEngineNavigationRequest.AcceptRequest;
                       navigationRequestedDelegate(request);
                   }

                   /* TODO check how this can be done with QtWebEngine
                   preferences.passwordEchoEnabled: Qt.inputMethod.visible
                   */

                   /* TODO what is this?
                   popupMenu: ItemSelector02 {
                       webview: _webview
                   }
                   */

                   function copy() {
                       console.warn("WARNING: the copy() function is deprecated and does nothing.")
                   }

               //    touchSelectionController.handle: Image {
               //        objectName: "touchSelectionHandle"
               //        readonly property int handleOrientation: orientation
               //        width: units.gu(1.5)
               //        height: units.gu(1.5)
               //        source: "handle.png"
               //        Component.onCompleted: horizontalPaddingRatio = 0.5
               //    }

                   Connections {
                       target: myWebview.touchSelectionController
                       onStatusChanged: {
                           var status = myWebview.touchSelectionController.status
                           if (status == Oxide.TouchSelectionController.StatusInactive) {
                               quickMenu.visible = false
                           } else if (status == Oxide.TouchSelectionController.StatusSelectionActive) {
                               quickMenu.visible = true
                           }
                       }
                       onInsertionHandleTapped: quickMenu.visible = !quickMenu.visible
                       onContextMenuIntercepted: quickMenu.visible = true
                   }

                   /* TODO check how copy&paste works in QtWebEngine
                   UbuntuShape {
                       id: quickMenu
                       objectName: "touchSelectionActions"
                       visible: false
                       opacity: (_webview.activeFocus
                                 && (_webview.touchSelectionController.status != Oxide.TouchSelectionController.StatusInactive)
                                 && !_webview.touchSelectionController.handleDragInProgress
                                 && !selectionOutOfSight) ? 1.0 : 0.0
                       aspect: UbuntuShape.DropShadow
                       backgroundColor: "white"
                       readonly property int padding: units.gu(1)
                       width: touchSelectionActionsRow.width + padding * 2
                       height: childrenRect.height + padding * 2
                       readonly property rect bounds: _webview.touchSelectionController.bounds
                       readonly property bool selectionOutOfSight: (bounds.x > _webview.width) || ((bounds.x + bounds.width) < 0) || (bounds.y > _webview.height) || ((bounds.y + bounds.height) < 0)
                       readonly property real handleHeight: units.gu(1.5)
                       readonly property real spacing: units.gu(1)
                       readonly property bool fitsBelow: (bounds.y + bounds.height + handleHeight + spacing + height) <= _webview.height
                       readonly property bool fitsAbove: (bounds.y - spacing - height) >= (_webview.locationBarController.height + _webview.locationBarController.offset)
                       readonly property real xCentered: bounds.x + (bounds.width - width) / 2
                       x: ((xCentered >= 0) && ((xCentered + width) <= _webview.width))
                           ? xCentered : (xCentered < 0) ? 0 : _webview.width - width
                       y: fitsBelow ? (bounds.y + bounds.height + handleHeight + spacing)
                                    : fitsAbove ? (bounds.y - spacing - height)
                                                : (_webview.height + _webview.locationBarController.height + _webview.locationBarController.offset - height) / 2
                       ActionList {
                           id: touchSelectionActions
                           Action {
                               name: "selectall"
                               text: i18n.dtr('ubuntu-ui-toolkit', "Select All")
                               iconName: "edit-select-all"
                               enabled: _webview.editingCapabilities & Oxide.WebView.SelectAllCapability
                               visible: enabled
                               onTriggered: _webview.executeEditingCommand(Oxide.WebView.EditingCommandSelectAll)
                           }
                           Action {
                               name: "cut"
                               text: i18n.dtr('ubuntu-ui-toolkit', "Cut")
                               iconName: "edit-cut"
                               enabled: _webview.editingCapabilities & Oxide.WebView.CutCapability
                               visible: enabled
                               onTriggered: _webview.executeEditingCommand(Oxide.WebView.EditingCommandCut)
                           }
                           Action {
                               name: "copy"
                               text: i18n.dtr('ubuntu-ui-toolkit', "Copy")
                               iconName: "edit-copy"
                               enabled: _webview.editingCapabilities & Oxide.WebView.CopyCapability
                               visible: enabled
                               onTriggered: _webview.executeEditingCommand(Oxide.WebView.EditingCommandCopy)
                           }
                           Action {
                               name: "paste"
                               text: i18n.dtr('ubuntu-ui-toolkit', "Paste")
                               iconName: "edit-paste"
                               enabled: _webview.editingCapabilities & Oxide.WebView.PasteCapability
                               visible: enabled
                               onTriggered: _webview.executeEditingCommand(Oxide.WebView.EditingCommandPaste)
                           }
                       }
                       Row {
                           id: touchSelectionActionsRow
                           x: parent.padding
                           y: parent.padding
                           width: {
                               // work around what seems to be a bug in Row’s childrenRect.width
                               var w = 0
                               for (var i in visibleChildren) {
                                   w += visibleChildren[i].width
                               }
                               return w
                           }
                           height: units.gu(6)
                           Repeater {
                               model: touchSelectionActions.children
                               AbstractButton {
                                   objectName: "touchSelectionAction_" + action.name
                                   anchors {
                                       top: parent.top
                                       bottom: parent.bottom
                                   }
                                   width: Math.max(units.gu(5), implicitWidth) + units.gu(2)
                                   action: modelData
                                   styleName: "ToolbarButtonStyle"
                                   activeFocusOnPress: false
                                   onClicked: _webview.touchSelectionController.hide()
                               }
                           }
                       }
                   }
                   */

                   QtObject {
                       id: internal
                       property int lastLoadRequestStatus: -1
                       property string lastLoadRequestErrorString: ""
                       property int lastLoadRequestErrorDomain: -1
                       property QtObject contextModel: null

                       function dismissCurrentContextualMenu() {
                           var model = contextModel
                           contextModel = null
                           if (model) {
                               model.close()
                           }
                       }

                       onContextModelChanged: if (!contextModel) myWebview.contextualData.clear()
                   }

                   readonly property bool lastLoadSucceeded: internal.lastLoadRequestStatus === WebEngineLoadRequest.LoadSucceededStatus
                   readonly property bool lastLoadStopped: false // TODO internal.lastLoadRequestStatus === Oxide.LoadEvent.TypeStopped
                   readonly property bool lastLoadFailed: internal.lastLoadRequestStatus === WebEngineLoadRequest.LoadFailedStatus
                   readonly property string lastLoadRequestErrorString: internal.lastLoadRequestErrorString
                   readonly property int lastLoadRequestErrorDomain: internal.lastLoadRequestErrorDomain
//                   onLoadingChanged: {
//                       if (loadRequest.errorCode === 420) {
//                           myWebview.stop()
//                       }
//                       if ((loadRequest.url === url) && (loadRequest.status !== WebEngineLoadRequest.LoadStartedStatus)) {
//                           internal.lastLoadRequestStatus = loadRequest.status;
//                           internal.lastLoadRequestErrorString = loadRequest.errorString;
//                           internal.lastLoadRequestErrorDomain = loadRequest.errorDomain;
//                       }
//                       internal.dismissCurrentContextualMenu();
//                   }

                   readonly property int screenOrientation: Screen.orientation
                   onScreenOrientationChanged: {
                       internal.dismissCurrentContextualMenu()
                   }

                   onJavaScriptConsoleMessage: {
                       if (myWebview.incognito) {
                           return
                       }

                       var msg = "[JS] (%1:%2) %3".arg(sourceID).arg(lineNumber).arg(message)
                       if (level === WebEngineView.InfoMessageLevel) {
                           console.log(msg)
                       } else if (level === WebEngineView.WarningMessageLevel) {
                           console.warn(msg)
                       } else if (level === WebEngineView.ErrorMessageLevel) {
                           console.error(msg)
                       }
                   }









  ///////////////////////////////////////// End added from MorphBrowser










            }  // End WebEngineView

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
