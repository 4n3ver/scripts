;region
#Persistent
#InstallMouseHook
#InstallKeybdHook
#UseHook
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
SetScrollLockState  AlwaysOff
SetCapsLockState    AlwaysOff
SetNumLockState     AlwaysOn
SendMode            InputThenPlay
SetKeyDelay,        0, 0
CoordMode,          ToolTip,    Screen
CoordMode,          Pixel,      Screen
CoordMode,          Mouse,      Screen
CoordMode,          Caret,      Screen
CoordMode,          Menu,       Screen
Menu,               Tray,       Tip,    Startup.ahk (0.0a)

; ## Profile initializer
; -------------------------------
; For profile that requires initialization
;region
Init()
WF_Init()
;endregion

ShowInfoTrayTip(A_ScriptName, A_ScriptName " started!", 5000)
return
;endregion

; # Commons
; -------------------------------
; General utilities.
;region
RunAsync(task) {
    SetTimer, % task, -1
}

AutoFire(targetKey, delay := 100) {
    heldKey := A_ThisHotkey
    delay   := delay / 2

    ; Issue with SendInput
    ; https://www.autohotkey.com/boards/viewtopic.php?t=29748
    ; https://www.autohotkey.com/boards/viewtopic.php?f=76&t=72583
    while GetKeyState(heldKey, "P") {
        SendEvent   {%targetKey% DOWN}
        Sleep       % delay
        SendEvent   {%targetKey% UP}
        Sleep       % delay
    }
}

SendHold(key, holdTime = 250) {
    Send    {%key% DOWN}
    Sleep   % holdTime
    Send    {%key% UP}
}

ClearClipboard() {
    clipboard := ""
    ShowInfoTrayTip("ClearClipboard", "Clipboard Cleared!")
}

HideToolTip(id := 1) {
    ToolTip,,,, % id
}

ShowToolTip(msg, duration := 0, x := "", y := "", id := 1) {
    ToolTip % msg, % x, % y, % id
    if (duration > 0) {
        boundHideToolTip := Func("HideToolTip").Bind(id)
        SetTimer, % boundHideToolTip, % -duration
    }
}

ShowCenteredToolTip(msg, duration := 0, id := 1) {
    ShowToolTip(msg, duration, A_ScreenWidth / 2, A_ScreenHeight / 2, id)
}

HideTrayTip() {
    TrayTip  ; Attempt to hide it the normal way.
    ; if SubStr(A_OSVersion, 1, 3) = "10." {
    ;     Menu    Tray, NoIcon
    ;     Sleep   1000  ; It may be necessary to adjust this sleep.
    ;     Menu    Tray, Icon
    ; }
}

ShowTrayTip(title, msg, duration := 0, options := 0) {
    TrayTip, % title, % msg, % duration, % options
    if duration > 0
        SetTimer, HideTrayTip, % -duration
}

ShowInfoTrayTip(title, msg, duration := 0) {
    ShowTrayTip(title, msg, duration, 1 + 16)
}

ShowWarnTrayTip(title, msg, duration := 0) {
    ShowTrayTip(title, msg, duration, 2)
}

ShowErrorTrayTip(title, msg, duration := 0) {
    ShowTrayTip(title, msg, duration, 3 + 32)
}
;endregion

; # Default Profile
; -------------------------------
;region
Init() {
    SetTimer, AfterBurnerWatchDog, 300000   ; Timer for 5 minutes
}

AfterBurnerWatchDog() {
    Process, Exist, MSIAfterburner.exe      ; check to see if MSIAfterburner.exe is running
    {
        if ! errorLevel {
            afterBurnerPath := "D:\scoop\apps\msiafterburner\current\MSIAfterburner.exe"
            if FileExist(afterBurnerPath) {
                ShowInfoTrayTip("AfterBurnerWatchDog", "Starting AfterBurner!")
                Run *RunAs %afterBurnerPath% /s
            } else {
                ShowErrorTrayTip("AfterBurnerWatchDog", "MSIAfterburner.exe was not found!")
            }
        } else {
            ; ShowToolTip("AfterBurner is Running", 2000,,, 20)
        }
    }
}

MediaControl:
PrintScreen::Media_Prev
ScrollLock::Media_Play_Pause
Pause::Media_Next

AutoClearClipboard:
~^x::
~^c::
    SetTimer, ClearClipboard, -900000      ; Clear clipboard 15 minutes after copying
return

ScriptReload:
~^!r::
    ShowToolTip("Reloading script...", 1000)
    Sleep   1000
    Reload
    Sleep   5000
    ShowErrorTrayTip("ScriptReload", "Failed to reload " A_ScriptName "!")
return

XBoxHome:
VK07::F22

; ## Mouse Wheel Tab Scroll 4 Chrome
; -------------------------------
; Scroll though Chrome tabs with your mouse wheel when hovering over the tab bar.
; if the Chrome window is inactive when starting to scroll, it will be activated.
;region
#If WinExist("ahk_class Chrome_WidgetWin_1")
WheelUp::
WheelDown::
    ChromeTabScroll() {
        thisKey := A_ThisHotkey
        MouseGetPos,,   mouseYPos, winId
        WinGetPos,,     winYPos,,, ahk_id %winId%
        WinGetClass,    winClass, ahk_id %winId%
        if mouseYPos - winYPos < 45 AND InStr(winClass, "Chrome_WidgetWin_1") {
            if NOT WinActive("ahk_id" winId)
                WinActivate ahk_id %winId%
            if thisKey = WheelUp
                Send ^{PgUp}
            else
                Send ^{PgDn}
        } else {
            Send {%thisKey%}
        }
    }
;endregion
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
    static DELAY_MS := [300, 300, 300, 19000]

    __New() {
        this.selectedAbility    := WF_AutoAbility.MIN
        this.abilityActive      := False
        this._lastState         := False
        this._activate          := this["_Activate"].Bind(this)
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
        this.abilityActive  := True
        activate            := this._activate
        this["_Activate"]()
        SetTimer, % activate, % WF_AutoAbility.DELAY_MS[this.selectedAbility]
    }

    Deactivate() {
        this.abilityActive  := False
        activate            := this._activate
        SetTimer,   % activate, Off
        KeyWait     % this.selectedAbility
    }

    Toggle() {
        if NOT this.abilityActive
            this.Activate()
        else
            this.Deactivate()
    }

    Pause() {
        if this.abilityActive {
            this._lastState := True
            this.Deactivate()
            return True
        }
        return False
    }

    Resume() {
        if this._lastState {
            this._lastState := False
            this.Activate()
            return True
        }
        return False
    }

    _Activate() {
        SendHold(this.selectedAbility, 250)
    }

    __Delete() {
        this.Deactivate()
    }
}

WF_Init() {
    global WF_ability := new WF_AutoAbility()
}

WF_Transference() {
    global WF_ability
    wasPaused := WF_ability.Pause()
    Send {NumpadDel}
    if NOT wasPaused {
        KeyWait NumpadDel
        WF_ability.Resume()
    }
}

WF_ToggleAbility:   ; MButton still went through
MButton::WF_ability.Toggle()

WF_TacticalMenu:
WheelLeft::l

WF_OmniTool:
WheelRight::\

WF_NextAbility:
F19::WF_ability.SelectNext()

WF_PrevAbility:
F20::WF_ability.SelectPrev()

WF_Archwing:
F13::Numpad1

WF_AutoAltFire:
F14::AutoFire("NumpadDiv", 50)

WF_AutoFire:
F15::AutoFire("NumpadMult", 35)

WF_Crouch:
F16::v

WF_TransferenceFlash:
F17::
    WF_Transference()
    Sleep   125
    Send    2
return

WF_Necramech:
F18::Numpad3

WF_AltFire:
RButton & MButton::NumpadDiv

WF_KDrive:
RButton & F13::Numpad2

WF_WellSpring:
RButton & F17::
    WF_Transference()
    Sleep   300
    Send    1
    Sleep   750
    Send    1
    Sleep   1300
    WF_Transference()
return

WF_ArchGun:
RButton & F18::Numpad4
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
