!include "LogicLib.nsh"

!define StrRep "!insertmacro StrRep"

!macro StrReplace ResultVar String SubString RepString
  Push "${String}"
  Push "${SubString}"
  Push "${RepString}"
  Call StrReplace
  Pop "${ResultVar}"
!macroend

Function StrReplace
/*After this point:
  ------------------------------------------
  $R0 = RepString (input)
  $R1 = SubString (input)
  $R2 = String (input)
  $R3 = RepStrLen (temp)
  $R4 = SubStrLen (temp)
  $R5 = StrLen (temp)
  $R6 = StartCharPos (temp)
  $R7 = TempStrL (temp)
  $R8 = TempStrR (temp)*/

  ;Get input from user
  Exch $R0
  Exch
  Exch $R1
  Exch
  Exch 2
  Exch $R2
  Push $R3
  Push $R4
  Push $R5
  Push $R6
  Push $R7
  Push $R8

  ;Return "String" if "SubString" is ""
  ${IfThen} $R1 == "" ${|} Goto Done ${|}

  ;Get "RepString", "String" and "SubString" length
  StrLen $R3 $R0
  StrLen $R4 $R1
  StrLen $R5 $R2
  ;Start "StartCharPos" counter
  StrCpy $R6 0

  ;Loop until "SubString" is found or "String" reaches its end
  ${Do}
    ;Remove everything before and after the searched part ("TempStrL")
    StrCpy $R7 $R2 $R4 $R6

    ;Compare "TempStrL" with "SubString"
    ${If} $R7 == $R1
      ;Split "String" to replace the string wanted
      StrCpy $R7 $R2 $R6 ;TempStrL

      ;Calc: "StartCharPos" + "SubStrLen" = EndCharPos
      IntOp $R8 $R6 + $R4

      StrCpy $R8 $R2 "" $R8 ;TempStrR

      ;Insert the new string between the two separated parts of "String"
      StrCpy $R2 $R7$R0$R8
      ;Now calculate the new "StrLen" and "StartCharPos"
      StrLen $R5 $R2
      IntOp $R6 $R6 + $R3
      ${Continue}
    ${EndIf}

    ;If not "SubString", this could be "String" end
    ${IfThen} $R6 >= $R5 ${|} ${ExitDo} ${|}
    ;If not, continue the loop
    IntOp $R6 $R6 + 1
  ${Loop}

  Done:

  ;Return output to user
  StrCpy $R0 $R2

/*After this point:
  ------------------------------------------
  $R0 = ResultVar (output)*/

  Pop $R8
  Pop $R7
  Pop $R6
  Pop $R5
  Pop $R4
  Pop $R3
  Pop $R2
  Pop $R1
  Exch $R0
FunctionEnd