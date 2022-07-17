#Persistent
#InstallMouseHook
#InstallKeybdHook
#NoEnv                                  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn                                   ; Enable warnings to assist with detecting common errors.
#SingleInstance         force           ; Determines whether a script is allowed to run again when it is already running.
#MaxHotkeysPerInterval  1000            ; Avoids warning messages for high speed wheel users.
#MaxThreadsPerHotkey    1

; Auto-Execute Section (AES)
; -------------------------------
; https://www.autohotkey.com/docs/Scripts.htm#auto
SendMode Input                          ; Recommended for new scripts due to its superior speed and reliability.
SetScrollLockState, AlwaysOff
SetCapsLockState, AlwaysOff
SetNumLockState, AlwaysOn
Menu, Tray, Tip, Startup.ahk (0.0a)

; WatchDogs Initializer
; -------------------------------
; Initializer WatchDog scripts
SetTimer, AfterBurnerWatchDog, 300000   ; Timer for 5 minutes

; Profile initializer
; -------------------------------
; For profile that requires initialization
gosub WF_Init
return

; WatchDogs
; -------------------------------
; Periodic scripts
AfterBurnerWatchDog:
    Process, Exist, MSIAfterburner.exe  ; check to see if MSIAfterburner.exe is running
    {
        if ! errorLevel
        {
            afterBurnerPath := "D:\scoop\apps\msiafterburner\current\MSIAfterburner.exe"
            if FileExist(afterBurnerPath)
            {
                MsgBox Starting AfterBurner
                Run *RunAs %afterBurnerPath% /s
            }
            else
                MsgBox MSIAfterburner.exe was not found!
        }
        ; else
        ; 	MsgBox "AfterBurner is Running"
    }
return

; Mouse Wheel Tab Scroll 4 Chrome
; -------------------------------
; Scroll though Chrome tabs with your mouse wheel when hovering over the tab bar.
; if the Chrome window is inactive when starting to scroll, it will be activated.
#If WinExist("ahk_class Chrome_WidgetWin_1")
WheelUp::
WheelDown::
    isWheelUp :=    A_ThisHotkey = "WheelUp"
    CoordMode,      Mouse, Screen
    MouseGetPos,    mouseXPos, mouseYPos, winId
    WinGetPos,      winXPos, winYPos, winWidth, winHeight, ahk_id %winId%
    WinGetClass,    winClass, ahk_id %winId%
    if mouseYPos - winYPos < 45 AND InStr(winClass, "Chrome_WidgetWin_1")
    {
        if NOT WinActive("ahk_id" winId)
            WinActivate ahk_id %winId%
        if isWheelUp
            Send ^{PgUp}
        else
            Send ^{PgDn}
    }
    else
    {
        if isWheelUp
            Send {WheelUp}
        else
            Send {WheelDown}
    }
return

; Warframe
; -------------------------------
#If WinActive("ahk_exe Warframe.x64.exe")
WF_Init:
    WF_SelectedAbility 		:= 1
    WF_AbilityActive 		:= False
    WF_AbilityIntervalMs 	:= [200, 200, 200, 19000]
return

WF_ActivateAbility:
    Send, {%WF_SelectedAbility%}
return

WF_PrevAbility:
F20::
    if !WF_AbilityActive AND WF_SelectedAbility > 1
        WF_SelectedAbility--
return

WF_NextAbility:
F19::
    if !WF_AbilityActive AND WF_SelectedAbility < 4
        WF_SelectedAbility++
return

WF_ToggleAbility:
MButton::
    WF_AbilityActive := NOT WF_AbilityActive
    if WF_AbilityActive {
        gosub       WF_ActivateAbility
        SetTimer,   WF_ActivateAbility, % WF_AbilityIntervalMs[WF_SelectedAbility]
    } else {
        SetTimer,   WF_ActivateAbility, Off
    }
return

WF_AltFire:
    Send, {NumpadDiv}
return

WF_AutoAltFire:
F14::
    thisHotKey :=   A_ThisHotkey
    SetTimer,       WF_AltFire, 50
    keyWait,        % thisHotKey
    SetTimer,       WF_AltFire, Off
return

WF_Fire:
    Send, {NumpadMult}
return

WF_AutoFire:
F15::
    thisHotKey :=   A_ThisHotkey
    SetTimer,       WF_Fire, 35
    keyWait,        % thisHotKey
    SetTimer,       WF_Fire, Off
return

WF_Crouch:
F16::v

WF_TacticalMenu:
WheelLeft::l

WF_OmniTool:
WheelRight::\

#if WinActive("ahk_exe Warframe.x64.exe") AND !GetKeyState("RButton", "P")
WF_Archwing:
F13::Numpad1

WF_Transference:
    Send, 	{NumpadDel}
return

WF_TransferenceFlash:
F17::
    gosub   WF_Transference
    Sleep, 	115
    Send, 	2
return

WF_Necramech:
F18::Numpad3

#if WinActive("ahk_exe Warframe.x64.exe") AND GetKeyState("RButton", "P")
WF_KDrive:
F13::Numpad2

WF_WellSpring:
F17::
    gosub   WF_Transference
    Sleep, 	250
    Send, 	1
    Sleep, 	850
    Send, 	1
    Sleep, 	1300
    gosub   WF_Transference
return

WF_ArchGun:
F18::Numpad4

; Fall Guys
; -------------------------------
#If WinActive("ahk_exe FallGuys_client_game.exe")
FG_Emotes:
F13::1
F14::2
F15::3
F18::4

FG_Dive:
F17::q

FG_Grab:
F16::e
