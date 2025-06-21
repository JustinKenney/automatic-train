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
ErrorLog := A_ScriptDir "\LOG.txt"
ConfigFile := A_ScriptDir "\config.ini"
ConfigFileHotstringsSection := "Hotstrings"

;Main code
if FileExist(ConfigFile) {
    LoadHotstrings()
}
else {
    CreateConfigFile()
    MsgBox("Configuration file not found." . 
            "`n" . "An example file has been generated, please edit it to contain desired hotstrings")
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
        default: FileAppend(A_Now . " - " . "Incorrect value passed to GetDate function, value passed was: " . DateType, ErrorLog)
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
    }
}

ImportHotstrings() {
    StringFileResults := Map()

    try {
        SectionData := IniRead(ConfigFile, "Hotstrings")
        Loop Parse, SectionData, "`n"
        {
            HotstringParts := StrSplit(A_LoopField, "=", 2)
            StringFileResults.Set(HotstringParts[1], HotstringParts[2])
        }
    } catch as e {
        FileAppend(A_Now . " - " . "Error reading hotstrings from config file. Error is " . e.Message . "`n", ErrorLog)
        MsgBox("Error reading hotstrings from config file " . e.Message)
        Return
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