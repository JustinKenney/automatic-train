#Requires AutoHotkey v2.0 ; Force script to AHK v2 syntax
#SingleInstance Force ; Only allow one instance of the script to run at a time. If script is reloaded, kill current instance and start a new one
#Hotstring EndChars `t ; Sets the TAB key (and only the TAB key) as the universal end key for all hotstrings in the entire script

; Declare global variables used throughout the script
global ShortDateObj := "" ; Stores the current date in dd MMM format so it isn't constanly recalculated throughougt the script
global UserDetails := "" ; Stores an object containing all user details from the GetUserDetails function, so that various hotstrings can retrieve and use the data

; Create a list of global variables, used to store replacement text for hotstrings. Effectively act as constants.
global WORK_DOMAIN := ""
global WORK_EMAIL := ""
global HELPDESK_EMAIL := ""
global NO_EMAIL := ""
global MFA := ""
global FOLLOW_UP := ""
global ONE_TIME_HOTSTRING := ""

DateFormat() ; Initial date calculation when script runs
SetTimer DateFormat, 3600000 ; Runs the DateFormat function once per hour to recalculate current date

GenerateHotstrings() ; Initial hotstring generation when script runs
SetTimer GenerateHotstrings, 3600000 ; Runs the GenerateHotstrings function once per hour to regenerate hotstings

+!e:: Edit ; Edit the current running script, trigger by Shift-Alt-E hotkey

+!r:: {
 SaveAndReload() ; Calls the SaveAndReload function vis Shift-Alt-R hotkey
}

#HotIf IsObject(UserDetails)
::fn:: {
 Send UserDetails.FirstName
}

::ln:: {
 Send UserDetails.LastName
}

::fl:: {
 Send UserDetails.FirstName . UserDetails.LastName
}

::uem:: {
 Send UserDetails.Email
}

::up:: {
 Send UserDetails.Phone
}

::usrclr:: {
 UserDetails.Delete()
}
#HotIf

::sat:: {
 SendText A_Clipboard
 /*
  Send the clipboard as individual keystrokes, instead of using paste. Usefull for remote connections or anywhere else standard copy/paste is blocked or unsupported
 */
}

^+q:: {
 ; Resize active window to 1/3 monitor width and 1/2 monitor height
 ; Used to "pop out" one of the windows docked via WindowTiling
 WindowTiling("SeventyPercent")
}

^+w:: {
 ; Resize active window to 1/3 monitor width and full monitor height
 WindowTiling("ReadingPane")
}

^+a:: {
 ; Pin active window as always on top
 WindowTiling("PinActive")
}

^+1:: {
 WindowTiling(1)
}

^+2:: {
 WindowTiling(2)
}

^+3:: {
 WindowTiling(3)
}

^+4:: {
 WindowTiling(4)
}

^+5:: {
 WindowTiling(5)
}

^+6:: {
 WindowTiling(6)
}

+!1:: {
 ; Calls function to store a one time hotstring
 global ONE_TIME_HOTSTRING := GetInput("Put repetitive phrase here, will trigger by 'rs' hotstring: ")
 GenerateHotstrings()
}

+!2:: {
 ; Calls function to store user details
 GetUserDetails()
}

; Functions that can be called throughout the script

DateFormat() {
 global ShortDateObj := StrUpper(FormatTime(, "dd MMM")) ; calls the FormatTime function, gets current date in dd MMM format, then call StrUpper function to make date all caps
}

GenerateHotstrings() {
    ;Define hotstrings via array
    ;Split into function so hotstrings can be reloaded to reflect dynamic content

    MyHotstrings := [
    {Label: "Work email", Trigger: "em", Value: WORK_EMAIL},
    {Label: "Helpdesk email", Trigger: "hem", Value: HELPDESK_EMAIL},
    {Label: "no email", Trigger: "nem", Value: NO_EMAIL},
    {Label: "MFA", Trigger: "mfa", Value: MFA},
    {Label: "Follow up", Trigger: "fue", Value: FOLLOW_UP},
    {Label: "Short Date", Trigger: "d", Value: ShortDateObj},
    {Label: "Long Date", Trigger: "dy", Value: ShortDateObj . " " . A_Year},
    {Label: "Six Weeks Out", Trigger: "d6", Value: SixWeeksOut},
    {Label: "One time hotstring", Trigger: "rs", Value: ONE_TIME_HOTSTRING}
    ]

    for hotstringTriggers in MyHotstrings {
        FullyBuiltHotstring := ":" . ":" . hotstringTriggers.Trigger

        Hotstring(FullyBuiltHotstring, hotstringTriggers.Value, 1)
    }
}

SixWeeksOut() {
 return StrUpper(FormatTime(DateAdd(A_Now, 42, "days"), "dd MMM"))
 /*
  adds six weeks to current day, uses FormatTime function to change date to dd MMM format, and uses StrUpper to make date all caps
 */
}

SaveAndReload() {
 Send "^s" ; saves the running script
 Sleep 500 ; gives the script chance to save
 Reload ; reloads script
}

GetInput(InputBoxText) {
 InputBoxResult := InputBox(InputBoxText, , "h100")
 
 if InputBoxResult.Result {
  ; User clicked OK
  return InputBoxResult.Value
 }
 else {
  ; User clicked Cancel or closed the InputBox
  return
 }
}

GetUserDetails() {
 UserDetailsGui := Gui(, "User Details")
 UserDetailsGui.AddText(, "Enter users first name here: ")
 UserDetailsGui.AddEdit("r1 vFirstName" , "Users first name")
 UserDetailsGui.AddText(, "Enter users last name here: ")
 UserDetailsGui.AddEdit("r1 vLastName" , "Users last name")
 UserDetailsGui.AddText(, "Enter users email here: ")
 UserDetailsGui.AddEdit("r1 vEmail" , "null@null.com")
 UserDetailsGui.AddText(, "Enter users phone # here: ")
 UserDetailsGui.AddEdit("r1 vPhoneNumber" , "867-5309")
 UserDetailsGui.AddButton("default", "OK").OnEvent("Click", SaveResults)
 UserDetailsGui.Show("AutoSize Center")

 SaveResults(*) {
  UserDetails := UserDetailsGui.Submit()
 }
}

;Creates a map object as a global variable, used to store window hardware ID's from WindowTiling
global WindowID := Map()
global SaveDockedPosition := ""
global PoppedOutWindow := ""

; A function allowing user to quickly move and resize windows
WindowTiling(RequestNumber) {
    global PoppedOutWindow
    global SavedDockedPosition
    global WindowID
    try {
        CurrentWindow := WinGetID("A")
    } catch Error as e {
        MsgBox("Could not get window ID" . e.Message)
        Return
    }

    try {
        MonitorGetWorkArea(, , , &Right, &Bottom)
    } catch Error as e {
        MsgBox("Could not determine monitor size." . e.Message)
        Return
    }

    OneThirdScreen := Round(Right/3)
    HalfBottom := Round(Bottom/2)
    
    if (isInteger(RequestNumber) && RequestNumber >= 1 && RequestNumber <= 6) {
        switch RequestNumber
        {
            case 1: MoveToDock(0,0)
            case 2: MoveToDock(0 + OneThirdScreen,0)
            case 3: MoveToDock(0 + (OneThirdScreen*2),0)
            case 4: MoveToDock(0,HalfBottom)
            case 5: MoveToDock(0 + OneThirdScreen,HalfBottom)
            case 6: MoveToDock(0 + (OneThirdScreen*2),HalfBottom)
        }
    }

    if (RequestNumber == "ReadingPane") {
        try {
            WinMove(, , OneThirdScreen, Bottom/1.5, CurrentWindow)
        } catch Error as e {
            MsgBox("Could not move window!")
        }
    }

    if (RequestNumber == "PinActive") {
        try {
            WinSetAlwaysOnTop(-1, CurrentWindow)
        } catch Error as e {
            MsgBox("Could not pin window active!")
        }
    }

    if(RequestNumber == "SeventyPercent") {
        if(PoppedOutWindow == "") {
            for dockIndex, dockedWinID in WindowID {
                if (CurrentWindow == dockedWinID) {
                    SavedDockedPosition := dockIndex
                    PoppedOutWindow := CurrentWindow
                    PopOutWindow()
                    Return
                }
            }
        }
        if(PoppedOutWindow == CurrentWindow) {
            switch SavedDockedPosition
            {
                case 1: MoveToDock(0,0)
                case 2: MoveToDock(0 + OneThirdScreen,0)
                case 3: MoveToDock(0 + (OneThirdScreen*2),0)
                case 4: MoveToDock(0,HalfBottom)
                case 5: MoveToDock(0 + OneThirdScreen,HalfBottom)
                case 6: MoveToDock(0 + (OneThirdScreen*2),HalfBottom)
            }
            PoppedOutWindow := ""
            SavedDockedPosition := ""
        }
    }

    MoveToDock(PosX, PosY) {
        try {
            WindowID.Set(RequestNumber, CurrentWindow)
        } catch Error as e {
            MsgBox("Could not store dock position" . e.Message)
        }
        
        try {
            WinMove(PosX, PosY, OneThirdScreen, HalfBottom, CurrentWindow)
        } catch Error as e {
            MsgBox("Could not move window!")
        }
    }

    PopOutWindow() {
        Width := Round(0.7 * Right)
        Height := Bottom
        newX := Round((Right - Width) / 2)
        newY := Round((Bottom - Height) / 2)

        try {
            WinMove(newX, newY, Width, Height, CurrentWindow)
        } catch Error as e {
            MsgBox("Could not center window!")
        }
    }
}

/* This currently doesn't work, but I would like store all hotstrings in a seperate file of easier management. Once that part works, I might even move on to a GUI base hotstring manager.
MyHotstrings(FilePath) {
 Try {
  FileObj := FileOpen(FilePath, "r")
  
  if !IsObject(FileObj) {
   MsgBox ("Could not open hotstring file" FilePath)
   Return
  }
  
  HotstringMap := Map()
  MapPosition := ""
  FileContents := FileObj.Read()
  FileObj.Close()

  Loop Parse (FileContents, "`n=")
  {
   if (MapPosition == "") {
    MapPosition := A_LoopField
    Continue
   }
   
   if (MapPosition != "") {
    HotstringMap[MapPosition] := A_LoopField
    MapPosition := ""
   }
  }
 }
 Catch as e {
  MsgBox ("Could not read hotstring file " e.message)
 }
}
*/