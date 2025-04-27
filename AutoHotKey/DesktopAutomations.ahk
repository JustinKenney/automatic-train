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

#Requires AutoHotkey v2 ;Force script to AHK v2 syntax
#SingleInstance Force ;Allow only one instance of this script at a time
#Hotstring EndChars `t ;Sets tab key as end character for all hotstrings

;Constants
global RequestShortDate := "ShortDate"
global RequestLongDate := "LongDate"
global RequestSixWeeks := "SixWeeks"

;Main code
GenerateDynamicHotstrings() ;Generates dynamic hotstrings on launch
SetTimer GenerateDynamicHotstrings, 3600000 ;Regenerates dynamic hotstrings every hour

;Functions
GetDate(DateType) {
    switch DateType
    {
        case RequestShortDate: Return StrUpper(FormatTime(, "dd MMM"))
        case RequestLongDate: Return StrUpper(FormatTime(, "dd MMM yyyy"))
        case RequestSixWeeks: Return StrUpper(FormatTime(DateAdd(A_Now, 42, "days"), "dd MMM"))
        default: Return
    }
    /*
     Returns the date in the dd MMM format with the month in caps
     and appends the year if requested

     Can also return the date six weeks out from current date

     This function makes heavy use of the built-in FormatTime
     function to get the current date in the desired format
     and then uses the built-in StrUpper format to convert the
     month to upper case. A switch tree is used to determine which
     date to return

     In the case of the six weeks options, DateAdd is used to add
     six weeks to the current date. 

     If an incorrect value is passed, the function exits
     without returning any values. This is the expected behavior.
    */
}

GenerateDynamicHotstrings() {
    MyDynamicHotstrings := [
    {Label: "Short Date", Trigger: "d", Value: GetDate(RequestShortDate)},
    {Label: "Long Date", Trigger: "dy", Value: GetDate(RequestLongDate)},
    {Label: "Six Weeks Out", Trigger: "d6", Value: GetDate(RequestSixWeeks)}
    ]

    for hotstringTriggers in MyDynamicHotstrings {
        FullyBuiltHotstring := ":" . ":" . hotstringTriggers.Trigger

        Hotstring(FullyBuiltHotstring, hotstringTriggers.Value, 1)
    }

    /*
     This function generates hotstrings that are dynamic in nature
     and need regular content updates

     Hotstring trigger and content are stored in an array
     and a for loop iterates through the array to pass each
     trigger/value pair to the built-in Hotstring function
     which actually generates the hotstrings

     The Label value in the array is currently unused
     but server as a nice label for each trigger/value pair
    */
}
