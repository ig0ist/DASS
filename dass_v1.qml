// Disable AAS






    // console.log("DASS - Start timer autoStartStop in /10L/Root.qml V.0.3");
            // console.log("DASS - autoStartStopStatus : ",AL2HMIBridge.driverAssistSource.autoStartStopStatus);
            // console.log("DASS - autoStartStopSupport : ",AL2HMIBridge.driverAssistSource.autoStartStopSupport);
            // console.log("DASS - AutoStartStopStatus_Selected : ",AL2HMIBridge.driverAssistSource.AutoStartStopStatus_Selected);

            if (AL2HMIBridge.driverAssistSource.autoStartStopSupport) {
            	 // console.log("DASS - autoStartStop Support , timer = ",AL2HMIBridge.driverAssistSource.autoStartStopStatusAutorepeatMs);
                 // Check is active
                 if (  AL2HMIBridge.driverAssistSource.autoStartStopStatus === AL2HMIBridge.DriverAssistSource.AutoStartStopStatus_Selected ) {
                    console.log("DASS - Timer autoStartStop - NotPressed");

                    AL2HMIBridge.driverAssistSource.autoStartStopButtonPressed(AL2HMIBridge.DriverAssistSource.AutoStartStopButton_Pressed);


                    AL2HMIBridge.driverAssistSource.autoStartStopButtonPressed(AL2HMIBridge.DriverAssistSource.AutoStartStopButton_NotPressed);
                    // NOT
                    AL2HMIBridge.driverAssistSource.autoStartStopButtonPressed(AL2HMIBridge.DriverAssistSource.AutoStartStopButton_Held);
                    // HELD and ?
                    AL2HMIBridge.driverAssistSource.autoStartStopButtonPressed(AL2HMIBridge.DriverAssistSource.AutoStartStopButton_NotPressed);
                 } else {
                  //   console.log("DASS - Skip");
                 }
            } else {
            	// console.log("DASS - Not autoStartStop Support, sorry ");
            }
            // console.log("DASS ->autoStartStopStatus : ",AL2HMIBridge.driverAssistSource.autoStartStopStatus);
            // console.log("DASS ->autoStartStopSupport : ",AL2HMIBridge.driverAssistSource.autoStartStopSupport);
            // console.log("DASS ->AutoStartStopStatus_Selected : ",AL2HMIBridge.driverAssistSource.AutoStartStopStatus_Selected);
            // console.log("DASS ->AutoStartStopStatus is Selected : ",(AL2HMIBridge.driverAssistSource.autoStartStopStatus === AL2HMIBridge.DriverAssistSource.AutoStartStopStatus_Selected));
            // console.log("DASS ->AutoStartStopStatus is Deselected : ",(AL2HMIBridge.driverAssistSource.autoStartStopStatus === AL2HMIBridge.DriverAssistSource.AutoStartStopStatus_Deselected));
