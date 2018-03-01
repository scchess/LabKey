Function VerifyPassword
  Pop $0
  Pop $1
  StrCmp $0 $1 Success Failure
  Failure:
     MessageBox MB_OK "Passwords do not match.  Please re-enter your password in both boxes."
     Abort
  Success:
FunctionEnd

Function FileSearch
    Exch $0 ;search for
    Exch
    Exch $1 ;input file
    Push $2
    Push $3
    Push $4
    Push $5
    Push $6
    Push $7
    Push $8
    Push $9
    Push $R0
    FileOpen $2 $1 r
    StrLen $4 $0
    StrCpy $5 0
    StrCpy $7 no
    StrCpy $8 0
    StrCpy $9 0
    ClearErrors
    loop_main:
        FileRead $2 $3
        IfErrors done
        IntOp $R0 $R0 + $9
        StrCpy $9 0
        StrCpy $5 0
    filter_top:
        IntOp $5 $5 - 1
        StrCpy $6 $3 $4 $5
        StrCmp $6 "" loop_main
        StrCmp $6 $0 0 filter_top
        StrCpy $3 $3 $5
        StrCpy $5 0
        StrCpy $7 yes
        StrCpy $9 1
        IntOp $8 $8 + 1
        Goto filter_top
    done:
        FileClose $2
        StrCpy $0 $8
        StrCpy $1 $7
        StrCpy $2 $R0
        Pop $R0
        Pop $9
        Pop $8
        Pop $7
        Pop $6
        Pop $5
        Pop $4
        Pop $3
        Exch $2 ;output number of lines
        Exch 2
        Exch $1 ;output yes/no
        Exch
        Exch $0 ;output count found
FunctionEnd

Function AdvReplaceInFile
    Exch $0 ;file to replace in
    Exch
    Exch $1 ;number to replace after
    Exch
    Exch 2
    Exch $2 ;replace and onwards
    Exch 2
    Exch 3
    Exch $3 ;replace with
    Exch 3
    Exch 4
    Exch $4 ;to replace
    Exch 4
    Push $5 ;minus count
    Push $6 ;universal
    Push $7 ;end string
    Push $8 ;left string
    Push $9 ;right string
    Push $R0 ;file1
    Push $R1 ;file2
    Push $R2 ;read
    Push $R3 ;universal
    Push $R4 ;count (onwards)
    Push $R5 ;count (after)
    Push $R6 ;temp file name

      GetTempFileName $R6
      FileOpen $R1 $0 r ;file to search in
      FileOpen $R0 $R6 w ;temp file
       StrLen $R3 $4
       StrCpy $R4 -1
       StrCpy $R5 -1

    loop_read:
     ClearErrors
     FileRead $R1 $R2 ;read line
     IfErrors exit

       StrCpy $5 0
       StrCpy $7 $R2

    loop_filter:
       IntOp $5 $5 - 1
       StrCpy $6 $7 $R3 $5 ;search
       StrCmp $6 "" file_write2
       StrCmp $6 $4 0 loop_filter

    StrCpy $8 $7 $5 ;left part
    IntOp $6 $5 + $R3
    IntCmp $6 0 is0 not0
    is0:
    StrCpy $9 ""
    Goto done
    not0:
    StrCpy $9 $7 "" $6 ;right part
    done:
    StrCpy $7 $8$3$9 ;re-join

    IntOp $R4 $R4 + 1
    StrCmp $2 all file_write1
    StrCmp $R4 $2 0 file_write2
    IntOp $R4 $R4 - 1

    IntOp $R5 $R5 + 1
    StrCmp $1 all file_write1
    StrCmp $R5 $1 0 file_write1
    IntOp $R5 $R5 - 1
    Goto file_write2

    file_write1:
     FileWrite $R0 $7 ;write modified line
    Goto loop_read

    file_write2:
     FileWrite $R0 $R2 ;write unmodified line
    Goto loop_read

    exit:
      FileClose $R0
      FileClose $R1

       SetDetailsPrint none
      Delete $0
      Rename $R6 $0
      Delete $R6
       SetDetailsPrint both

    Pop $R6
    Pop $R5
    Pop $R4
    Pop $R3
    Pop $R2
    Pop $R1
    Pop $R0
    Pop $9
    Pop $8
    Pop $7
    Pop $6
    Pop $5
    Pop $4
    Pop $3
    Pop $2
    Pop $1
    Pop $0
FunctionEnd

; Grab all digits/decimals from front of version string
Function GetVersionNumber
	!define GetVersionNumber `!insertmacro GetVersionNumberCall`

	!macro GetVersionNumberCall _VerStr _RESULT
		Push `${_VerStr}`
		Call GetVersionNumber
		Pop ${_RESULT}
	!macroend
	
    Exch $0 ;Full Version String (e.g. 12.1Dev)
    Push $1 ;Offset
    Push $2 ;Current character
    Push $3 ;Version Number (e.g. 12.1)
    Push $4 ;Full Version String length
    
    StrCpy $1 0
    StrCpy $3 ''
    StrLen $4 $0
    Loop:
    IntCmp $4 $1 Done Done
    StrCpy $2 $0 1 $1

    StrCmp $2 '0' Next
    StrCmp $2 '1' Next
    StrCmp $2 '2' Next
    StrCmp $2 '3' Next
    StrCmp $2 '4' Next
    StrCmp $2 '5' Next
    StrCmp $2 '6' Next
    StrCmp $2 '7' Next
    StrCmp $2 '8' Next
    StrCmp $2 '9' Next
    StrCmp $2 '.' Next
    Goto Done
    
    Next:
    StrCpy $3 $3$2
    IntOp $1 $1 + 1
    Goto Loop
    Done:
    StrCpy $0 $3
    Pop $4
    Pop $3
    Pop $2
    Pop $1
    Exch $0
FunctionEnd

; Grab all digits/decimals from front of version string
Function GetTrailingVersionNumber
	!define GetTrailingVersionNumber `!insertmacro GetTrailingVersionNumberCall`

	!macro GetTrailingVersionNumberCall _VerStr _RESULT
		Push `${_VerStr}`
		Call GetTrailingVersionNumber
		Pop ${_RESULT}
	!macroend

    Exch $0 ;Full Version String (e.g. C:\Program Files\apache-tomcat-6.0.35)
    Push $1 ;Current offset
    Push $2 ;Current character
    Push $3 ;Full Version String length
    Push $4 ;Versions string length

    StrLen $4 $0
    StrCpy $1 0

    Loop:
    IntOp $1 $1 + 1
    IntCmp $1 0 0 Done
    StrCpy $2 $0 1 -$1

    StrCmp $2 '0' Loop
    StrCmp $2 '1' Loop
    StrCmp $2 '2' Loop
    StrCmp $2 '3' Loop
    StrCmp $2 '4' Loop
    StrCmp $2 '5' Loop
    StrCmp $2 '6' Loop
    StrCmp $2 '7' Loop
    StrCmp $2 '8' Loop
    StrCmp $2 '9' Loop
    StrCmp $2 '.' Loop

    Done:
    IntOp $1 $1 - 1
    StrCpy $0 $0 "" -$1
    Pop $3
    Pop $2
    Pop $1
    Exch $0
FunctionEnd

Function StrStrip
Exch $R0 #string
Exch
Exch $R1 #in string
Push $R2
Push $R3
Push $R4
Push $R5
 StrLen $R5 $R0
 StrCpy $R2 -1
 IntOp $R2 $R2 + 1
 StrCpy $R3 $R1 $R5 $R2
 StrCmp $R3 "" +9
 StrCmp $R3 $R0 0 -3
  StrCpy $R3 $R1 $R2
  IntOp $R2 $R2 + $R5
  StrCpy $R4 $R1 "" $R2
  StrCpy $R1 $R3$R4
  IntOp $R2 $R2 - $R5
  IntOp $R2 $R2 - 1
  Goto -10
  StrCpy $R0 $R1
Pop $R5
Pop $R4
Pop $R3
Pop $R2
Pop $R1
Exch $R0
FunctionEnd
!macro StrStrip Str InStr OutVar
 Push '${InStr}'
 Push '${Str}'
  Call StrStrip
 Pop '${OutVar}'
!macroend
!define StrStrip '!insertmacro StrStrip'

!include FileFunc.nsh
!insertmacro GetDrives
Function GetUnusedDriveLetters
    Push $R0 ;List of drive letters
    Push $R1 ;Drive count
    Push $R2

    StrCpy $R0 'A:\|B:\|C:\|D:\|E:\|F:\|G:\|H:\|I:\|J:\|K:\|L:\|M:\|N:\|O:\|P:\|Q:\|R:\|S:\|T:\|U:\|V:\|W:\|X:\|Y:\|Z:\|'
    StrCpy $R1 0
    ${GetDrives} "ALL" GetDrivesCallback

    Pop $R2
    Pop $R1
    Exch $R0
FunctionEnd

Function GetDrivesCallback ;Get list of used drives
    ${StrStrip} '$9|' $R0 $R0
    
    Push $0
FunctionEnd

;-------------------------------
; Test if Visual Studio Redistributables 2008 SP1 installed
; Returns -1 if there is no VC redistributables intstalled
Function CheckVCRedist
   Push $R0
   ClearErrors
   ReadRegDword $R0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{9A25302D-30C0-39D9-BD6F-21E6EC160475}" "Version"

   ; if VS 2008 SP1 redist not installed, install it
   IfErrors 0 VSRedistInstalled
   StrCpy $R0 "-1"

VSRedistInstalled:
   Exch $R0
FunctionEnd

!define LVM_GETITEMCOUNT 0x1004
!define LVM_GETITEMTEXT 0x102D
 
Function DumpLog
  Exch $5
  Push $0
  Push $1
  Push $2
  Push $3
  Push $4
  Push $6
 
  FindWindow $0 "#32770" "" $HWNDPARENT
  GetDlgItem $0 $0 1016
  StrCmp $0 0 exit
  FileOpen $5 $5 "w"
  StrCmp $5 "" exit
    SendMessage $0 ${LVM_GETITEMCOUNT} 0 0 $6
    System::Alloc ${NSIS_MAX_STRLEN}
    Pop $3
    StrCpy $2 0
    System::Call "*(i, i, i, i, i, i, i, i, i) i \
      (0, 0, 0, 0, 0, r3, ${NSIS_MAX_STRLEN}) .r1"
    loop: StrCmp $2 $6 done
      System::Call "User32::SendMessageA(i, i, i, i) i \
        ($0, ${LVM_GETITEMTEXT}, $2, r1)"
      System::Call "*$3(&t${NSIS_MAX_STRLEN} .r4)"
      FileWrite $5 "$4$\r$\n"
      IntOp $2 $2 + 1
      Goto loop
    done:
      FileClose $5
      System::Free $1
      System::Free $3
  exit:
    Pop $6
    Pop $4
    Pop $3
    Pop $2
    Pop $1
    Pop $0
    Exch $5
FunctionEnd