;region
#Persistent
#InstallMouseHook
#InstallKeybdHook
#NoEnv                                  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn                                   ; Enable warnings to assist with detecting common errors.
#SingleInstance         force           ; Determines whether a script is allowed to run again when it is already running.
#MaxHotkeysPerInterval  1000            ; Avoids warning messages for high speed wheel users.
#MaxThreadsPerHotkey    1
#MaxThreadsBuffer       Off
;endregion

; # Auto-Execute Section (AES)
; -------------------------------
; https://www.autohotkey.com/docs/Scripts.htm#auto
;region
SendMode            Input               ; Recommended for new scripts due to its superior speed and reliability.
SetScrollLockState  AlwaysOff
SetCapsLockState    AlwaysOff
SetNumLockState     AlwaysOn
Menu,               Tray, Tip, Startup.ahk (0.0a)

; ## WatchDogs Initializer
; -------------------------------
; Initializer WatchDog scripts
;region
SetTimer, AfterBurnerWatchDog, 300000   ; Timer for 5 minutes
;endregion

; ## Profile initializer
; -------------------------------
; For profile that requires initialization
;region
Gosub WF_Init
;endregion

return
;endregion

; # Commons
; -------------------------------
; General utilities.
;region
class AutoFire {
    __New(key, delay = 200) {
        this.key    := key
        this.delay  := -delay
        this.active := False
        this._fire  := this.Fire.Bind(this)
    }

    Fire() {
        fire    := this._fire
        key     := this.key
        delay   := this.delay
        Send % key
        if this.active {
            SetTimer, % fire, % delay
        }
    }

    Enable() {
        key         := this.key
        this.active := True
        this.Fire()
        KeyWait % key
        this.Disable()
    }

    Disable() {
        this.active := False
    }

    __Delete() {
        fire := this._fire
        SetTimer, % fire, Off
        this.Disable()
    }
}
;endregion

; # WatchDogs
; -------------------------------
; Periodic scripts.
;region
AfterBurnerWatchDog:
    Process, Exist, MSIAfterburner.exe  ; check to see if MSIAfterburner.exe is running
    {
        if ! errorLevel {
            afterBurnerPath := "D:\scoop\apps\msiafterburner\current\MSIAfterburner.exe"
            if FileExist(afterBurnerPath) {
                MsgBox Starting AfterBurner
                Run *RunAs %afterBurnerPath% /s
            } else
                MsgBox MSIAfterburner.exe was not found!
        }
        ; else
        ;   MsgBox "AfterBurner is Running"
    }
return
;endregion

; # Mouse Wheel Tab Scroll 4 Chrome
; -------------------------------
; Scroll though Chrome tabs with your mouse wheel when hovering over the tab bar.
; if the Chrome window is inactive when starting to scroll, it will be activated.
;region
#If WinExist("ahk_class Chrome_WidgetWin_1")
WheelUp::
WheelDown::
    isWheelUp       := A_ThisHotkey = "WheelUp"
    CoordMode,      Mouse, Screen
    MouseGetPos,    mouseXPos, mouseYPos, winId
    WinGetPos,      winXPos, winYPos, winWidth, winHeight, ahk_id %winId%
    WinGetClass,    winClass, ahk_id %winId%
    if mouseYPos - winYPos < 45 AND InStr(winClass, "Chrome_WidgetWin_1") {
        if NOT WinActive("ahk_id" winId)
            WinActivate ahk_id %winId%
        if isWheelUp
            Send ^{PgUp}
        else
            Send ^{PgDn}
    } else {
        if isWheelUp
            Send {WheelUp}
        else
            Send {WheelDown}
    }
return
;endregion

; # Game Profiles
; -------------------------------
; Top Buttons               : F19, F20
; Side Buttons - Top Row    : F13, F14, F15
; Side Buttons - Bottom Row : F18, F17, F16
; Shift Layer Button        : RButton
;region

; ## Warframe
; -------------------------------
;region
#If WinActive("ahk_exe Warframe.x64.exe") OR WinActive("ahk_exe Notepad.exe")
class WF_AutoAbility {
    static MAX      := 4
    static MIN      := 1
    static DELAY_MS := [200, 200, 200, 19000]

    __New() {
        this.selectedAbility    := WF_AutoAbility.MIN
        this.abilityActive      := False
        this._activate          := this.Activate.Bind(this)
    }

    SelectNext() {
        if !this.abilityActive AND this.selectedAbility < WF_AutoAbility.MAX
            this.selectedAbility++
    }

    SelectPrev() {
        if !this.abilityActive AND this.selectedAbility > WF_AutoAbility.MIN
            this.selectedAbility--
    }

    Activate() {
        Send % this.selectedAbility
    }

    Toggle() {
        this.abilityActive  := NOT this.abilityActive
        activate            := this._activate
        if this.abilityActive {
            this.Activate()
            SetTimer, % activate, % WF_AutoAbility.DELAY_MS[this.selectedAbility]
        } else {
            SetTimer, % activate, Off
        }
    }

    __Delete() {
        activate := this._activate
        SetTimer, % activate, Off
    }
}

WF_Init:
    WF_ability  := new WF_AutoAbility()
    WF_altFire  := new AutoFire("{NumpadDiv}", 50)
    WF_fire     := new AutoFire("{NumpadMult}", 35)
return

WF_PrevAbility:
F20::WF_ability.SelectPrev()

WF_NextAbility:
F19::WF_ability.SelectNext()

WF_ToggleAbility:
MButton::WF_ability.Toggle()

WF_AutoAltFire:
F14::WF_altFire.Enable()

WF_AutoFire:
F15::WF_fire.Enable()

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
    Send    {NumpadDel}
return

; need to add delay to flash
WF_TransferenceFlash:
F17::
    Gosub   WF_Transference
    Sleep   125
    Send    2
return

WF_Necramech:
F18::Numpad3

#if WinActive("ahk_exe Warframe.x64.exe") AND GetKeyState("RButton", "P")
WF_KDrive:
F13::Numpad2

WF_WellSpring:
F17::
    Gosub   WF_Transference
    Sleep   300
    Send    1
    Sleep   750
    Send    1
    Sleep   1300
    Gosub   WF_Transference
return

WF_ArchGun:
F18::Numpad4
;endregion

; ## Fall Guys
; -------------------------------
;region
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
;endregion
;endregion
