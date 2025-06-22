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
    "ConfigFileHotstringsSection", "Hotstrings",
)

SystemLogging(Settings[LogI], "Script initialized")

;Main code
if FileExist(Settings[ConfigFile]) {
    SystemLogging(Settings[LogI], "Configuration file exists, beginning custom setting import")
    LoadHotstrings()
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
        case Settings[RequestShortDate]: Return (FormatTime(, "dd MMM"))
        case Settings[RequestLongDate]: Return (FormatTime(, "dd MMM yyyy"))
        case Settings[RequestSixWeeks]: Return (FormatTime(DateAdd(A_Now, Settings[SixWeeksInDays], "days"), "dd MMM"))
        default: SystemLogging(Settings[LogE], "Incorrect value passed to GetDate function, value passed was: " . DateType)
        Return ""
    }
}

LoadHotstrings() {
    DynamicHotstrings := Map(
    "shdf", GetDate(Settings[RequestShortDate]),
    "lgdf", GetDate(Settings[RequestLongDate]),
    "swdf", GetDate(Settings[RequestSixWeeks])
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

    SystemLogging(Settings[LogI], "Hotstrings locked and loaded")
}

ImportHotstrings() {
    StringFileResults := Map()

    try {
        SectionData := IniRead(Settings[ConfigFile], Settings[ConfigFileHotstringsSection])
        Loop Parse, SectionData, "`n"
        {
            HotstringParts := StrSplit(A_LoopField, "=", 2)
            if (HotstringParts.Length == 2) {
                StringFileResults.Set(HotstringParts[1], HotstringParts[2])
            } else {
                SystemLogging(Settings[LogE], "INI line misformed")
                Continue
            }
        }
        SystemLogging(Settings[LogI], "Hotstrings read in from INI file")
    } catch as e {
        SystemLogging(Settings[LogE], "Error reading hotstrings from config file. Error is " . e.Message)
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
    try {
        IniWrite "test phrase 1", Settings[ConfigFile], Settings[ConfigFileHotstringsSection], "te"
        IniWrite "test phrase 2", Settings[ConfigFile], Settings[ConfigFileHotstringsSection], "tr"

        CreateMessage := "
        (
        Configuration file not found.
        An example file has been generated, please edit it to contain desired hotstrings.
        )"
        SystemLogging(Settings[LogW], CreateMessage)
        MsgBox(CreateMessage)
    } catch Error as e {
        FailedCreateMessage := "
        (
        The configuration file could not be found, and a generic one could not be created.
        The hotstring portion of this script will not work
        )"
        SystemLogging(Settings[LogE], FailedCreateMessage . e.Message)
    }
}

SystemLogging(LogLevel, LogMessage) {
    try {
        LogTime := FormatTime(, "dd MMM yyyy - HH:mm:ss")
        FileAppend(LogLevel . ": " LogTime . " - " . LogMessage . "`n", Settings[LogFile])
    } catch Error as e {
        MsgBox("Could not write to log file. " . e.Message)
    }
}