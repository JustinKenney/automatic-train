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
RequestShortDate := 0
RequestLongDate := 1
RequestSixWeeks := 6
HotstringsTextFile := A_ScriptDir "\strings.ini"
ErrorLog := A_ScriptDir "\LOG.txt"
SixWeeksInDays := 42

;Main code
GenerateStaticHotstrings()
GenerateDynamicHotstrings()

^+r::GenerateDynamicHotstrings() ;Usefull if you want to regenerate just the dynamic hotstrings

;Functions
GetDate(DateType) {
    switch DateType
    {
        case RequestShortDate: Return StrUpper(FormatTime(, "dd MMM"))
        case RequestLongDate: Return StrUpper(FormatTime(, "dd MMM yyyy"))
        case RequestSixWeeks: Return StrUpper(FormatTime(DateAdd(A_Now, SixWeeksInDays, "days"), "dd MMM"))
        default: FileAppend(A_Now . " - " . "Incorrect value passed to GetDate function, value passed was: " . DateType, ErrorLog)
        Return "null"
    }
    /*
     Returns the date in the dd MMM format with the month in caps
     and appends the year if requested

     Can also return the date six weeks out from current date
    */
}

GenerateDynamicHotstrings() {
    MyDynamicHotstrings := Map(
    "d", GetDate(RequestShortDate),
    "dy", GetDate(RequestLongDate),
    "d6", GetDate(RequestSixWeeks)
    )

    GenerateFromCollection(MyDynamicHotstrings)
}

GenerateStaticHotstrings() {
    MyStaticHotstrings := ReadFromHotstringsFile()
    
    GenerateFromCollection(MyStaticHotstrings)
}

GenerateFromCollection(collection) {
    for triggers, values in collection {
        FullyBuiltHotstring := ":" . ":" . triggers

        Hotstring(FullyBuiltHotstring, values)
    }
}

ReadFromHotstringsFile() {
    StringFileResults := Map()

    try {
        Loop Read, HotstringsTextFile
        {
            HotstringParts := StrSplit(A_LoopReadLine, ";", 2)
            if(HotstringParts.Length >= 2) {
                StringFileResults.Set(HotstringParts[1], HotstringParts[2])
            } else {
                FileAppend(A_Now . " - " . "Syntax error in strings file at " . A_Index . ": " . A_LoopReadLine . "`n", ErrorLog)
                Continue
            }
        }
    } catch as e {
        FileAppend(A_Now . " - " . "Could not open hotstrings file. Error is " . e.Message . "`n", ErrorLog)
        MsgBox("Error reading hotstring file " . e.Message)
        Return
    }
    
    Return StringFileResults
}
