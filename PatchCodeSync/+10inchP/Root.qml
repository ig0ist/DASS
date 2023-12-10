import QtQuick 2.6
import QtGraphicalEffects 1.0

import HmiCore 1.0
import HmiGui 1.0
import HmiGuiFramework 1.0
import HmiGuiFramework.Controls 1.0
import Hmi.Ford.MessageTiles 1.0
import Hmi.Ford 1.0

import AL2HMIBridge 1.0 as AL2HMIBridge
import HmiTest 1.0 as HmiTest

import "dirpathedroot"

//TODO change it to item and move the content definition to style
Item {
    id: root

    property bool fullScreenTransparentPopupStacked: false
    property QtObject masterLayout: UiTheme.styleSelect("masterLayout", root)

    property string currentTheme: UiTheme.currentThemeName

    // Used by Squish
    property string systemLocale: AL2HMIBridge.globalSource.systemLocale
    property bool hasActivePopup: ViewManager.activePopup

    Binding {
        target: ViewController
        property: "driverRestrictionsGeneralAppsActive"
        value: AL2HMIBridge.globalSource.driverRestrictionsGeneralAppsActive
    }

    Binding {
        target: ViewController
        property: "driverRestrictionsVideoAppsActive"
        value: AL2HMIBridge.globalSource.driverRestrictionsVideoAppsActive
    }

    // START PathedRoot ----
    Item {
        PathedRoot {
            // ---
        }
    }
    // END PathedRoot ----

    Connections {
        target: ViewController
        onShowDriverRestrictionPopup: {
            if(type === ViewController.DriverRestrictionAppLinkPopup)
            {

                //~ TextID 4a865ffa-7abe-11e9-8457-08002718b8d7
                ViewController.requestDynamicPopup("DynamicTextPopup", qsTr("Please use voice commands to access mobile apps while driving."), 3000);
            }
            else if (type === ViewController.DriverRestrictionTypeKPopup)
            {
                ViewController.requestDynamicPopup("DriverRestrictionTypeKPopup", data);
            }
            else if(type === ViewController.DriverRestrictionTypeAPopup)
            {
                requestDriverRestrictionTypeAPopup();
            }
            else
            {
                console.error("Unknown Driver Restriction popup type received.");
            }
        }

        // keeping it here to maintain the leagcy code. #TODO FORDSYNC3-46561: replace all showDriverRestrictionTypeAPopup() calls with showDriverRestrictionPopup(ViewController.DriverRestrictionTypeAPopup).
        onShowDriverRestrictionTypeAPopup: {
            requestDriverRestrictionTypeAPopup();
        }

        onPlayDriverRestrictionViewVCAPrompt: {
            _rootStateController.playDriverRestrictionViewVCAPrompt(data);
        }
    }

    function requestDriverRestrictionTypeAPopup()
    {
        //~ TextID f16d2d61-cbda-11e3-88ac-08edb9db5203
        ViewController.requestDynamicPopup("DynamicTextPopup", qsTr("For your safety, some features have been disabled while your vehicle is in motion."), 3000)
    }

    Binding {
        target: ViewController
        property: "driverRestrictionViewTextLabel"
        value: HmiImage {
            id: driverRestrictionViewItem

            source: backgroundImage.backgroundSource
            TextLabel {
                anchors.fill: parent
                anchors.margins: UiTheme.styleRoot.generalMarginBig
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                //~ TextID f1906ccf-cbda-11e3-85cf-08edb9db5203
                text: qsTr("For your safety, some features have been disabled while your vehicle is in motion.", "drViewContext")
                wrapMode: Text.WordWrap
                z: 1
            }
            MouseArea {
                id: mouseArea_Root
                // for catching touch events from triggering anything underneath
                anchors.fill: parent
            }
        }
    }

    // Needs to be made invisible so that we can look through for navigation and rvc views
    // By default we show the background item
    TransformableItem {
        id: backgroundImage
        anchors.fill: parent
        property bool forceShow: false
        visible: ((ViewManager.activePopup && ViewManager.activePopup.transparentWindow
                   && !ViewManager.activePopup.hiding
                   && ViewManager.popupAllowed(ViewManager.activePopup.instanceId, ViewManager.popupBehavior))
                  || (ViewController.transparentWindowPopupShown && !ViewManager.activePopup.hiding)
                  || root.fullScreenTransparentPopupStacked) ? false
                                                             : ((forceShow && !ViewController.qrvc)
                                                                || !(ViewManager.activeViewItem && ViewManager.activeViewItem.transparentWindow))

        property url backgroundSource: UiTheme.palette.image(UiTheme.palette.viewBackground)

        HmiImage {
            anchors.fill: parent
            source: backgroundImage.backgroundSource
            visible: !solidColorBackground.visible
        }

        Rectangle {
            id: solidColorBackground
            anchors.fill: parent
            visible: ViewManager.activeViewItem && ViewManager.activeViewItem.solidColorBackgroundView
            color: ViewManager.activeViewItem ? ViewManager.activeViewItem.viewColor
                                              : "#00000000"
        }
    }

    Component.onCompleted: {
        width = AppSettings.screenWidth;
        height = AppSettings.screenHeight;

        animationTargets.publish()
    }

    // DO NOT remove this item. It is needed to get the status bar and menubar
    // layered above the views so that they cast shadows over the views themselves.
    Item {
        id: viewContainer
        objectName: "viewContainer"

        anchors.fill: parent

        property int regularViewLayer: 1
        property int topScreenLayer: 2
        property int menuBarLayer: 3
        property int fullScreenLayer: 4
        property int statusBarLayer: 5
        property int fullScreenStatusBarLayer: 6

        property int fullScreenViewActive: 0
        property int topScreenViewActive: 0
        property int fullScreenUsesNormalStatusBar: 0

        StatusBar {
            id: appStausBar
            objectName: "Root_appStatusBar"

            visible: ViewController.activeViewMode !== HmiGui.FarewellViewMode

            enabled: !AL2HMIBridge.eaPhoneSource.eventsBlocked // no clicking during 911 screens

            transientViewActive: visible && transientView.isActive
            showBackgroundImage: parent.fullScreenUsesNormalStatusBar === 0
        }

        MessageTileContainer {
            id: tileContainer
            anchors {
                top: appStausBar.bottom
                topMargin: -tileContainer.verticalOffset
                left: appStausBar.left
                right: appStausBar.right
            }
            visible: enabled && ViewManager.activeDomain !== HmiGui.HomeDomain
            z: appStausBar.z + 1
        }

        FullscreenStatusBar {
            id: fullscreenStausBar

            anchors.centerIn: appStausBar
            visible: isAvailable && transientView.isActive
            transientViewActive: visible
            isAvailable: !appStausBar.visible && (ViewManager.activeViewItem && ViewManager.activeViewItem.transientsAllowed)
        }

        TransientView {
            id: transientView

            statusBar: appStausBar.visible
                       && !(ViewManager.activePopup && ViewManager.activePopup.isOverlay)
                       && (ViewManager.activeViewItem && ViewManager.activeViewItem.transientsAllowed)
                           ? appStausBar : fullscreenStausBar
            statusBarLayout: appStausBar.visible
                             && !(ViewManager.activePopup && ViewManager.activePopup.isOverlay)
                             && (ViewManager.activeViewItem && ViewManager.activeViewItem.transientsAllowed)
                                 ? appStausBar.mainLayout : fullscreenStausBar.mainLayout
            onStatusBarChanged: {
                if (statusBar == appStausBar){
                    resetStatusBar(fullscreenStausBar)

                    if(fullscreenStausBar.statusBarItem.visible === false){

                        fullscreenStausBar.statusBarItem.visible = true
                        fullscreenStausBar.statusBarItem.yTranslation = 0
                        fullscreenStausBar.statusBarItem.opacity = 1.0
                    }
                }

                else{
                    resetStatusBar(appStausBar)

                    if(appStausBar.statusBarItem.visible === false){

                        appStausBar.statusBarItem.visible = true
                        appStausBar.statusBarItem.yTranslation = 0
                        appStausBar.statusBarItem.opacity = 1.0
                    }
                }
            }
        }

        MenuBar {
            id: appMenuBar
            visible: parent.fullScreenViewActive === 0 && ViewController.activeViewMode !== HmiGui.FarewellViewMode
            onModuleRequest: _rootStateController.activateModule(domain, moduleRootView)
        }

        states: [
            State {
                name: "overlayActive"
                when: ViewManager.activePopup && ViewManager.activePopup.isOverlay
                ParentChange { target: fullscreenStausBar; parent: root;}
            },
            State {
                name: "overlayNotActive"
                when: !(ViewManager.activePopup && ViewManager.activePopup.isOverlay)
                ParentChange { target: fullscreenStausBar; parent: viewContainer;}
            }
        ]
    }

    Connections {
        target: HmiKeyboard
        onGlobalKeyboardManagerRequest: {
            if (!root.globalKbm)
                root.globalKbm = kbm.createObject(viewContainer, {})
        }
    }
    property KeyboardManager globalKbm

    Component {
        id: kbm

        KeyboardManager {
            id: keyboardManager
            sourceId: AL2HMIBridge.globalSource.keyboardLayout
            selectionKey: HmiTranslationManager.currentLanguageId

            global: true

            onSourceIdChanged: AL2HMIBridge.globalSource.keyboardLayout = sourceId;
        }
    }

    Item {
        anchors.fill: parent
        z: -200
        visible: viewContainer.visible

        Rectangle {
            id: blackBackgroundStyleContainer
            anchors.fill: parent
            color: "black"
            visible: false
        }
    }

    HmiAnimationTargets {
        id: animationTargets
        property Item background: backgroundImage
        property StatusBar statusBar: appStausBar
        property MenuBar menuBar: appMenuBar
        property int showAnimationDelay: 0
        property Item blackBackground: blackBackgroundStyleContainer
    }

    HmiFormattingSettings {
        metricDistanceFormat: [
            //~ TextID f1906cd2-cbda-11e3-a400-08edb9db5203
            qsTr("%L1 km"),
            //~ TextID f1906cd3-cbda-11e3-a758-08edb9db5203
            qsTr("%L1 m")
        ]
        imperialDistanceFormat: [
            //~ TextID f19093de-cbda-11e3-b7fb-08edb9db5203
            qsTr("%L1 mi."),
            //~ TextID f19093df-cbda-11e3-8cbe-08edb9db5203
            qsTr("%L1 yd."),
            //~ TextID f19093e0-cbda-11e3-aa33-08edb9db5203
            qsTr("%L1 ft.")
        ]
        // FORDSYNC3-38450: qsTr usage removed as translation not needed
        fahrenheitFormat: "%L1 °F"
        // FORDSYNC3-38450: qsTr usage removed as translation not needed
        celsiusFormat: "%L1 °C"
        // FORDSYNC3-38450: qsTr usage removed as translation not needed
        fahrenheitShortFormat: "%L1°"
        // FORDSYNC3-38450: qsTr usage removed as translation not needed
        celsiusShortFormat: "%L1°"

        function getTemperatureMeasurementSystem() {
            if (AL2HMIBridge.globalSource.temperatureUnit === AL2HMIBridge.GlobalSource.DegreesCelcius) {
                return HmiFormattingSettings.Metric
            } else {
                //UK imperial is treated the same way as ImperialUS
                return HmiFormattingSettings.ImperialUS
            }
        }

        function getDistanceMeasurementSystem() {
            if (AL2HMIBridge.globalSource.distanceUnit === AL2HMIBridge.GlobalSource.Kilometers) {
                return HmiFormattingSettings.Metric
            } else if (measurementSystem === HmiFormattingSettings.ImperialUK) {
                return HmiFormattingSettings.ImperialUK
            } else {
                return HmiFormattingSettings.ImperialUS
            }
        }

        clockFormat: AL2HMIBridge.clockSource.format === AL2HMIBridge.ClockSource.Format12 ? HmiFormattingSettings.Clock12
                                                                                      : HmiFormattingSettings.Clock24
        distanceMeasurementSystem: getDistanceMeasurementSystem()
        temperatureMeasurementSystem: getTemperatureMeasurementSystem()
        measurementSystem: HmiFormatting.measurementSystemForLocale(AL2HMIBridge.globalSource.systemLocale)

        //~ TextID f19093e5-cbda-11e3-9f9d-08edb9db5203
        metricVolumeFormat: qsTr("%L1 l")
        //~ TextID f19093e6-cbda-11e3-a838-08edb9db5203
        imperialVolumeFormat: qsTr("%L1 gal.")

        //~ TextID f19093e7-cbda-11e3-8c30-08edb9db5203
        metricSpeedFormat: qsTr("%L1 km/h")
        //~ TextID f19093e8-cbda-11e3-9c5a-08edb9db5203
        imperialSpeedFormat: qsTr("%L1 mph")

        //~ TextID f19093e9-cbda-11e3-8f24-08edb9db5203
        metricFuelConsumptionFormat: qsTr("%L1 l/100")
        //~ TextID f19093ea-cbda-11e3-b1f7-08edb9db5203
        imperialFuelConsimptionFormat: qsTr("%L1 mpg")

        dateFormat: HmiMarketPropertyStore.getProperty(AL2HMIBridge.globalSource.destinationCountry,
                                                             "dateFormat")

        dateFormatNoYear: HmiMarketPropertyStore.getProperty(AL2HMIBridge.globalSource.destinationCountry,
                                                                   "dateFormatNoYear")

        timeFormat12: HmiMarketPropertyStore.getProperty(AL2HMIBridge.globalSource.destinationCountry,
                                                               "timeFormat12")
        timeFormat24: HmiMarketPropertyStore.getProperty(AL2HMIBridge.globalSource.destinationCountry,
                                                               "timeFormat24")

        dateTimeFormat12: HmiMarketPropertyStore.getProperty(AL2HMIBridge.globalSource.destinationCountry,
                                                                   "dateTimeFormat12")
        dateTimeFormat24: HmiMarketPropertyStore.getProperty(AL2HMIBridge.globalSource.destinationCountry,
                                                                   "dateTimeFormat24")

        shortTimeFormat12: HmiMarketPropertyStore.getProperty(AL2HMIBridge.globalSource.destinationCountry,
                                                                    "shortTimeFormat12")
        shortTimeFormat12NoAP: HmiMarketPropertyStore.getProperty(AL2HMIBridge.globalSource.destinationCountry,
                                                                    "shortTimeFormat12NoAP")
        shortTimeFormat24: HmiMarketPropertyStore.getProperty(AL2HMIBridge.globalSource.destinationCountry,
                                                                    "shortTimeFormat24")

        shortDateTimeFormat12: HmiMarketPropertyStore.getProperty(AL2HMIBridge.globalSource.destinationCountry,
                                                                        "shortDateTimeFormat12")
        shortDateTimeFormat24: HmiMarketPropertyStore.getProperty(AL2HMIBridge.globalSource.destinationCountry,
                                                                        "shortDateTimeFormat24")

        shortDateTimeNoYearFormat12: HmiMarketPropertyStore.getProperty(AL2HMIBridge.globalSource.destinationCountry,
                                                                              "shortDateTimeNoYearFormat12")
        shortDateTimeNoYearFormat24: HmiMarketPropertyStore.getProperty(AL2HMIBridge.globalSource.destinationCountry,
                                                                              "shortDateTimeNoYearFormat24")
        forceEnglishNumberFormat: true
        omitNumberGroupSeparator: true
    }

    Rectangle {
        id: touchMarker

        width: 60.0
        height: 60.0
        radius: 30.0
        border.width: 3
        border.color: "#9966ff33"
        color: "#7766aaff"

        visible: HmiTest.testSource.touchReticleEnabled && _hmiWindow.pressed
        x: _hmiWindow.pointerPosition.x - 30
        y: _hmiWindow.pointerPosition.y - 30
        z: 100
        scale: visible ? 1.0 : 0.25
        Behavior on scale {
            NumberAnimation { duration: 1250; easing.type: Easing.OutElastic }
        }
    }
}
