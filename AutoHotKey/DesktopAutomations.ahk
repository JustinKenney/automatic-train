/*
Copyright 2025 Justin Kenney

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

*/

#Requires AutoHotkey v2
#SingleInstance Force

Settings := Map(
    ;Constants
    "RequestShortDate", "short",
    "RequestLongDate", "long",
    "RequestSixWeeks", "sixweeks",
    "SixWeeksInDays", 42,

    ;Logging information
    "LogFile", A_ScriptDir "\LOG.txt",
    "LogE", "[ERROR]",
    "LogI", "[INFO]",
    "LogW", "[WARNING]",

    ;Config file information
    "ConfigFile", A_ScriptDir "\config.ini",
    "HotstringSection", "Hotstrings",
    "MainSection", "Main",

    ;FancyZones toggle directons
    "ToggleUp", 0,
    "ToggleDown", 1,
    "ProcessName", "PowerToys.FancyZones.exe",
)

SystemLogging(Settings["LogI"], "Script initialized")

;Main code
if FileExist(Settings["ConfigFile"]) {
    SystemLogging(Settings["LogI"], "Configuration file exists, beginning custom setting import")
    LoadHotstrings()
}
else {
    CreateConfigFile()
}

^+r::Reload
+!c::ToggleApp()
+!v::PasteAsKeystrokes
^#!WheelUp::FancyZonesStackToggle(Settings["ToggleUp"])
^#!WheelDown::FancyZonesStackToggle(Settings["ToggleDown"])


;Functions
GetDate(DateType) {
    switch DateType
    {
        case Settings["RequestShortDate"]: Return (FormatTime(, "dd MMM"))
        case Settings["RequestLongDate"]: Return (FormatTime(, "dd MMM yyyy"))
        case Settings["RequestSixWeeks"]: Return (FormatTime(DateAdd(A_Now, Settings["SixWeeksInDays"], "days"), "dd MMM"))
        default: SystemLogging(Settings["LogE"], "Incorrect value passed to GetDate function, value passed was: " . DateType)
        Return ""
    }
}

LoadHotstrings() {
    DynamicHotstrings := Map(
    "shdf", GetDate(Settings["RequestShortDate"]),
    "lgdf", GetDate(Settings["RequestLongDate"]),
    "swdf", GetDate(Settings["RequestSixWeeks"])
    )

    StaticHotstrings := ImportHotstrings()

    Generate(DynamicHotstrings)
    Generate(StaticHotstrings)

    Generate(MapName) {
        for triggers, values in MapName {
            FullyBuiltHotstring := ":" . ":" . triggers

            Hotstring(FullyBuiltHotstring, values)
        }
    }

    SystemLogging(Settings["LogI"], "Hotstrings locked and loaded")
}

ImportHotstrings() {
    StringFileResults := Map()

    try {
        SectionData := IniRead(Settings["ConfigFile"], Settings["HotstringSection"])
        Loop Parse, SectionData, "`n"
        {
            HotstringParts := StrSplit(A_LoopField, "=", 2)
            if (HotstringParts.Length == 2) {
                StringFileResults.Set(HotstringParts[1], HotstringParts[2])
            } else {
                SystemLogging(Settings["LogE"], "INI line misformed")
                Continue
            }
        }
        SystemLogging(Settings["LogI"], "Hotstrings read in from INI file")
    } catch as e {
        SystemLogging(Settings["LogE"], "Error reading hotstrings from config file. Error is " . e.Message)
        TrayTip("Error reading hotstrings from config file. " . e.Message,,3)
        Return Map()
    }
    
    Return StringFileResults
}

ToggleApp() {
    Try {
        ProgramToToggle := IniRead(Settings["ConfigFile"], Settings["MainSection"], "AppToggleOne")
        WinTitle := "ahk_exe" . ProgramToToggle
    } catch as e {
        SystemLogging(Settings["LogE"], "AppToggleOne not found in INI file [" . Settings["MainSection"] . "] section. Cannot toggle application.")
        Return
    }

    if WinActive(WinTitle) {
        Return WinClose(WinTitle)
    } if WinExist(WinTitle) {
        Return WinActivate(WinTitle)
    } else {
        try {
            Run ProgramToToggle
            Return WinWaitActive(WinTitle)
        } catch as e {
            SystemLogging(Settings["LogE"], "Application " . ProgramToToggle . " not found!")
            Return
        }
    }
}

PasteAsKeystrokes() {
/*
Certain programs (not naming names), like to randomly block
copy and paste. So this takes the clipboard and sends it as raw keystrokes
*/

    local ToPaste := A_Clipboard
    Send "{Raw}" . ToPaste
}

FancyZonesStackToggle(Direction) {
    RunCheck := ProcessExist(Settings["ProcessName"])
    if (RunCheck != 0) {
        if (Direction = Settings["ToggleUp"]) {
            Send "#{PgUp}"
        } else if (Direction = Settings["ToggleDown"]) {
            Send "#{PgDn}"
        }
    } else {
        SystemLogging(Settings["LogW"], "FancyZones target app '" . Settings["ProcessName"] . "' not running. Stack toggle ignored.")
    }
}

CreateConfigFile() {
    try {
        DefaultMessage := "
        (
            ; Use this section to fill in your desired hotstrings and replacement triggers
            ; Make sure to use the key value format, seperated by an equals sign
        )"
        
        ; creates a default toggle app
        IniWrite "ms-edge.exe", Settings["ConfigFile"], Settings["MainSection"], "AppToggleOne"
        ; creates hotstring sections and insert some comments on how to use
        IniWrite DefaultMessage, Settings["ConfigFile"], Settings["HotstringSection"]

        CreateMessage := "
        (
        Configuration file not found.
        An example file has been generated, please edit it to contain desired hotstrings.
        )"
        SystemLogging(Settings["LogW"], CreateMessage)
        TrayTip(CreateMessage,,2)
    } catch Error as e {
        FailedCreateMessage := "
        (
        The configuration file could not be found, and a generic one could not be created.
        The hotstring portion of this script will not work
        )"
        SystemLogging(Settings["LogE"], FailedCreateMessage . e.Message)
    }
}

SystemLogging(LogLevel, LogMessage) {
    try {
        LogTime := FormatTime(, "dd MMM yyyy - HH:mm:ss")
        FileAppend(LogLevel . ": " LogTime . " - " . LogMessage . "`n", Settings["LogFile"])
    } catch Error as e {
        TrayTip("Could not write to log file. " . e.Message,,3)
    }
}