import AL2HMIBridge 1.0 as AL2HMIBridge
import QtQuick 2.6
import HmiMedia 1.0
import Hmi.Ford.Popups 1.0


Item {
    id: root
    objectName: "PathedRoot"

    //
    // ---------------- DASS Timer
    Timer {
        id: timerASS
        interval: 30000        // in milliseconds 100 SECONDS
        // repeat: true         // No Repeat
        running: true

        onTriggered: {
//            console.log("DASS - Start timer autoStartStop in /PathedRoot.qml");
//            console.log("DASS - autoStartStopStatus : ",AL2HMIBridge.driverAssistSource.autoStartStopStatus);
//            console.log("DASS - autoStartStopSupport : ",AL2HMIBridge.driverAssistSource.autoStartStopSupport);
//            console.log("DASS - AutoStartStopStatus_Selected : ",AL2HMIBridge.driverAssistSource.AutoStartStopStatus_Selected);

            if (AL2HMIBridge.driverAssistSource.autoStartStopSupport) {
            	console.log("DASS - autoStartStop Support");
                 // Check is active
                   if (  AL2HMIBridge.driverAssistSource.autoStartStopStatus === AL2HMIBridge.DriverAssistSource.AutoStartStopStatus_Selected ) {
                       console.log("DASS - Timer autoStartStop - NotPressed");
                       // Тут магия
                       AL2HMIBridge.driverAssistSource.autoStartStopButtonPressed(AL2HMIBridge.DriverAssistSource.AutoStartStopButton_Pressed);
                       AL2HMIBridge.driverAssistSource.autoStartStopButtonPressed(AL2HMIBridge.DriverAssistSource.AutoStartStopButton_NotPressed);
                       // NOT
                       AL2HMIBridge.driverAssistSource.autoStartStopButtonPressed(AL2HMIBridge.DriverAssistSource.AutoStartStopButton_Held);
                       // HELD and ?
                       AL2HMIBridge.driverAssistSource.autoStartStopButtonPressed(AL2HMIBridge.DriverAssistSource.AutoStartStopButton_NotPressed);
                   } else {
                    console.log("DASS - Skip");
                 }
            } else {
            	console.log("DASS - Not autoStartStop Support, sorry -( Exit...");
            }
            // console.log("DASS ->autoStartStopStatus : ",AL2HMIBridge.driverAssistSource.autoStartStopStatus);
            // console.log("DASS ->autoStartStopSupport : ",AL2HMIBridge.driverAssistSource.autoStartStopSupport);
            // console.log("DASS ->AutoStartStopStatus_Selected : ",AL2HMIBridge.driverAssistSource.AutoStartStopStatus_Selected);
            // console.log("DASS ->AutoStartStopStatus is Selected : ",(AL2HMIBridge.driverAssistSource.autoStartStopStatus === AL2HMIBridge.DriverAssistSource.AutoStartStopStatus_Selected));
            // console.log("DASS ->AutoStartStopStatus is Deselected : ",(AL2HMIBridge.driverAssistSource.autoStartStopStatus === AL2HMIBridge.DriverAssistSource.AutoStartStopStatus_Deselected));
        } // onTriggered
    } // Timer


    // ---------------- Other Line 1
    // ---------------- Other Line 2
    // ---------------- Other Line 3
    // ---------------- Other Line 4
    // ---------------- Other Line 5
    // ---------------- Other Line 6
    // ---------------- Other Line 7


}