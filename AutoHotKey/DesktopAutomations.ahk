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
#Hotstring EndChars `t ;Sets tab key as end character for all hotstrings

;Constants
RequestShortDate := "short"
RequestLongDate := "long"
RequestSixWeeks := "sixweeks"
SixWeeksInDays := 42

;Logging information
LogFile := A_ScriptDir "\LOG.txt"
LogE := "[ERROR]"
LogI := "[INFO]"
LogW := "[WARNING]"

;Config file information
ConfigFile := A_ScriptDir "\config.ini"
ConfigFileHotstringsSection := "Hotstrings"

;Main code
if FileExist(ConfigFile) {
    LoadHotstrings()
    SystemLogging(LogI, "Configuration file exists, begining custom setting import")
}
else {
    CreateConfigFile()
}

^+r::Reload
+!c::ToggleApp("ms-teams.exe")
+!v::PasteAsKeystrokes

;Functions
GetDate(DateType) {
    switch DateType
    {
        case RequestShortDate: Return (FormatTime(, "dd MMM"))
        case RequestLongDate: Return (FormatTime(, "dd MMM yyyy"))
        case RequestSixWeeks: Return (FormatTime(DateAdd(A_Now, SixWeeksInDays, "days"), "dd MMM"))
        default: SystemLogging(LogE, "Incorrect value passed to GetDate function, value passed was: " . DateType)
        Return ""
    }
}

LoadHotstrings() {
    DynamicHotstrings := Map(
    "d", GetDate(RequestShortDate),
    "dy", GetDate(RequestLongDate),
    "d6", GetDate(RequestSixWeeks)
    )

    StaticHotstrings := ImportHotstrings()

    Generate(DynamicHotstrings)
    Generate(StaticHotstrings)

    Generate(MapName) {
        for triggers, values in MapName {
            FullyBuiltHotstring := ":" . ":" . triggers

            Hotstring(FullyBuiltHotstring, values)
        }
        SystemLogging(LogI, "Hotstrings locked and loaded")
    }
}

ImportHotstrings() {
    StringFileResults := Map()

    try {
        SectionData := IniRead(ConfigFile, ConfigFileHotstringsSection)
        Loop Parse, SectionData, "`n"
        {
            HotstringParts := StrSplit(A_LoopField, "=", 2)
            if (HotstringParts.Length == 2) {
                StringFileResults.Set(HotstringParts[1], HotstringParts[2])
            } else {
                SystemLogging(LogE, "INI line misformed")
                Continue
            }
        }
        SystemLogging(LogI, "Hotstrings read in from INI file")
    } catch as e {
        SystemLogging(LogE, "Error reading hotstrings from config file. Error is " . e.Message)
        MsgBox("Error reading hotstrings from config file. " . e.Message)
        Return Map()
    }
    
    Return StringFileResults
}

ToggleApp(ProgramToToggle) {
    WinTitle := "ahk_exe" . ProgramToToggle

    if WinActive(WinTitle) {
        Return WinClose(WinTitle)
    }
    if WinExist(WinTitle) {
        Return WinActivate(WinTitle)
    }

    Run ProgramToToggle
    Return WinWaitActive(WinTitle)
}

PasteAsKeystrokes() {
/*
Certain programs (not naming names), like to randomly block
copy and paste. So this takes the clipboard and sends it as raw keystrokes
*/

    local ToPaste := A_Clipboard
    Send "{Raw}" . ToPaste
}

CreateConfigFile() {
    DefaultValues := "
    (
    te = test phrase 1
    tr = test phrase 2
    )"

    try {
        IniWrite DefaultValues, ConfigFile, ConfigFileHotstringsSection

        CreateMessage := "
        (
        Configuration file not found.
        An example file has been generated, please edit it to contain desired hotstrings.
        )"
        SystemLogging(LogW, CreateMessage)
        MsgBox(CreateMessage)
    } catch Error as e {
        FailedCreateMessage := "
        (
        The configuration file could not be found, and a generic one could not be created.
        The hotstring portion of this script will not work
        )"
        SystemLogging(LogE, FailedCreateMessage . e.Message)
    }
}

SystemLogging(LogLevel, LogMessage) {
    try {
        LogTime := FormatTime(, "dd MMM yyyy - HH:mm:ss")
        FileAppend(LogLevel . ": " LogTime . " - " . LogMessage, LogFile)
    } catch Error as e {
        MsgBox("Could not write to log file. " . e.Message)
    }
}