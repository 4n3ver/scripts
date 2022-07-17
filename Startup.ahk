#Persistent
#NoEnv									; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn									; Enable warnings to assist with detecting common errors.
#SingleInstance force					; Determines whether a script is allowed to run again when it is already running.
#InstallMouseHook
#InstallKeybdHook
#MaxHotkeysPerInterval 1000				; Avoids warning messages for high speed wheel users.

; Auto-Execute Section (AES)
; -------------------------------
; https://www.autohotkey.com/docs/Scripts.htm#auto
SendMode Input 							; Recommended for new scripts due to its superior speed and reliability.
SetScrollLockState, AlwaysOff
SetCapsLockState, AlwaysOff
SetNumLockState, AlwaysOn
Menu, Tray, Tip, "Startup.ahk (0.0a)"

; WatchDogs Initializer
; -------------------------------
; Initializer WatchDog scripts
SetTimer, AfterBurnerWatchDog, 300000	; Timer for 5 minutes

; Profile initializer
; -------------------------------
; For profile that requires initialization
gosub WF_Init
return

; WatchDogs
; -------------------------------
; Periodic scripts
AfterBurnerWatchDog:
	Process, Exist, MSIAfterburner.exe ; check to see if MSIAfterburner.exe is running
	{
		if ! errorLevel
		{
			afterBurnerPath := "D:\scoop\apps\msiafterburner\current\MSIAfterburner.exe"
			if FileExist(afterBurnerPath)
			{
				MsgBox "Starting AfterBurner"
				Run *RunAs %afterBurnerPath% /s
			}
			else
				MsgBox "MSIAfterburner.exe was not found!"
		}
		; else
		; 	MsgBox "AfterBurner is Running"
	}
return

; Mouse Wheel Tab Scroll 4 Chrome
; -------------------------------
; Scroll though Chrome tabs with your mouse wheel when hovering over the tab bar.
; if the Chrome window is inactive when starting to scroll, it will be activated.
#IfWinExist ahk_class Chrome_WidgetWin_1
WheelUp::
WheelDown::
	MouseGetPos,, ypos, id
	WinGetClass, class, ahk_id %id%
	if (ypos < 45 and InStr(class,"Chrome_WidgetWin"))
	{
		IfWinNotActive ahk_id %id%
			WinActivate ahk_id %id%
		if A_ThisHotkey = WheelUp
			Send ^{PgUp}
		else
			Send ^{PgDn}
	}
	else
	{
		if A_ThisHotkey = WheelUp
			Send {WheelUp}
		else
			Send {WheelDown}
	}
return

; Warframe
; -------------------------------
#IfWinActive ahk_exe Warframe.x64.exe
WF_Init:
	WF_SelectedAbility 		:= 1
	WF_AbilityActive 		:= False
	WF_AbilityIntervalMs 	:= [100, 100, 100, 19000]
return

WF_ActivateAbility:
	Send, {%WF_SelectedAbility%}
return

WF_PrevAbility:
WheelLeft::
	if (!WF_AbilityActive AND WF_SelectedAbility > 1)
		WF_SelectedAbility--
return

WF_NextAbility:
WheelRight::
	if (!WF_AbilityActive AND WF_SelectedAbility < 4)
		WF_SelectedAbility++
return

WF_ToggleAbility:
MButton::
	WF_AbilityActive := NOT WF_AbilityActive
	if (WF_AbilityActive) {
		gosub WF_ActivateAbility
		SetTimer, WF_ActivateAbility, % WF_AbilityIntervalMs[WF_SelectedAbility]
	} else {
		SetTimer, WF_ActivateAbility, Off
	}
return

WF_AutoAltFire:
F14::
	while GetKeyState("F14","P")
	{
		Send, 	{NumpadDiv}
		Sleep, 	30
	}
return

WF_AutoFire:
F15::
	while GetKeyState("F15","P")
	{
		Send, 	{NumpadMult}
		Sleep,	30
	}
return

WF_Crouch:
F16::v

#if !GetKeyState("RButton", "P")
WF_Archwing:
F13::Numpad1

WF_Transference:
F17::
	Send, 	{NumpadDel}
	Sleep, 	100
	Send, 	2
return

WF_Necramech:
F18::Numpad3

#if GetKeyState("RButton", "P")
WF_KDrive:
F13::Numpad2

WF_WellSpring:
F17::
	Send, 	{NumpadDel}
	Sleep, 	100
	Send, 	1
	Sleep, 	750
	Send, 	1
	Sleep, 	1300
	Send, 	{NumpadDel}
return

WF_ArchGun:
F18::Numpad4
