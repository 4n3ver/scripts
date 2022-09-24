;region
;@Ahk2Exe-Base              Unicode 64-bit
;@Ahk2Exe-SetName           Startup.ahk
;@Ahk2Exe-UpdateManifest    1,,, 1
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
SetWorkingDir       % A_ScriptDir                                               ; Ensures a consistent starting directory.
AutoTrim,           On
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
Menu,               Tray,       Icon
Menu,               Tray,       Tip,    %A_ScriptName% (0.0a)
Menu,               Tray,       NoStandard
Menu,               Tray,       Add,    Key History,        ShowKeyHistory
Menu,               Tray,       Add                                             ; Add Separator
Menu,               Tray,       Standard                                        ; Add Standard menu

; ## Profile initializer
; -------------------------------
; For profile that requires initialization
;region
AFTERBURNER_PATH    := GetEnvVar("SCOOP") . "\apps\msiafterburner\current\MSIAfterburner.exe"
AHK_COMPILER_PATH   := "ahk2exe.exe"
PROFILES            :=  { "Warframe.x64.exe"            : "WF"
                        , "FallGuys_client_game.exe"    : "FG"
                        , "DragonAgeInquisition.exe"    : "GD"
                        , "MassEffect1.exe"             : "GD"
                        , "MassEffect2.exe"             : "GD"
                        , "MassEffect3.exe"             : "GD"
                        , "MassEffectAndromeda.exe"     : "GD"
                        , "witcher.exe"                 : "GD"
                        , "witcher2.exe"                : "GD"
                        , "witcher3.exe"                : "GD"
                        , "GTA5.exe"                    : "GD"
                        , "HorizonZeroDawn.exe"         : "GD"
                        , "NMS.exe"                     : "GD"
                        , "Overcooked2.exe"             : "GD"
                        , "Notepad.exe"                 : "WF"
                        , "WatchDogs2.exe"              : "GD" }

Init()
;endregion

Sleep 2000
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

GetEnvVar(key) {
    EnvGet, val, % key
    return  val
}

GetObjectValues(obj) {
    values  := []
    for _, v in obj
        values.Push(v)
    return values
}

GetObjectKeys(obj) {
    keys    := []
    for k, _ in obj
        keys.Push(k)
    return keys
}

Unique(arr) {
    values  := {}
    for _, v in arr
        values[v] := v
    return GetObjectKeys(values)
}

AutoFire(targetKey, delay := 100) {
    thisKey := A_ThisHotkey
    delay   := delay / 2

    ; Issue with SendInput
    ; https://www.autohotkey.com/boards/viewtopic.php?t=29748
    ; https://www.autohotkey.com/boards/viewtopic.php?f=76&t=72583
    while GetKeyState(thisKey, "P") {
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

ShowKeyHistory() {
    KeyHistory
}

GetActiveWindow(mode) {
    WinGet, name, % mode, a
    return name
}

GetActiveProfile() {
    global PROFILES
    activeProfileName := PROFILES[GetActiveWindow("ProcessName")]
    ; ShowToolTip(activeProfileName, 500)
    return activeProfileName = ""
        ? "Default"
        : activeProfileName
}
;endregion

; # Global Profile
; -------------------------------
; Context-insensitive, active at all times.
;region
Init() {
    global PROFILES
    for _, profileName in Unique(GetObjectValues(PROFILES)) {
        initFn := Func(profileName . "_Init")
        if initFn != 0
            initFn.Call()
    }
    SetTimer, AfterBurnerWatchDog, 300000   ; Timer for 5 minutes
}

AfterBurnerWatchDog() {
    Process, Exist, MSIAfterburner.exe      ; check to see if MSIAfterburner.exe is running
    {
        if ! errorLevel {
            global AFTERBURNER_PATH
            if FileExist(AFTERBURNER_PATH) {
                ShowInfoTrayTip("AfterBurnerWatchDog", "Starting AfterBurner!")
                Run *RunAs %AFTERBURNER_PATH% /s
            } else {
                ShowErrorTrayTip("AfterBurnerWatchDog", "MSIAfterburner.exe was not found!")
            }
        } else {
            ; ShowToolTip("AfterBurner is Running", 2000,,, 20)
        }
    }
}

AutoClearClipboard:
~^x::
~^c::
    SetTimer, ClearClipboard, -900000      ; Clear clipboard 15 minutes after copying
return

~^!r::
    ScriptReload() {
        global AHK_COMPILER_PATH
        try {
            ShowToolTip("Compiling script...")
            scriptFullPathNoExt := SubStr(A_ScriptFullPath, 1, -4)
            scriptFullPath      := scriptFullPathNoExt . ".ahk"
            compiledFullPath    := scriptFullPathNoExt . ".exe"
            RunWait "%AHK_COMPILER_PATH%" /in "%scriptFullPath%"

            ShowToolTip("Reloading script...", 750)
            Sleep   850
            Run     "%compiledFullPath%"
            ExitApp
        } catch ex {
            ShowToolTip(ex, 10000)
            ShowErrorTrayTip("ScriptReload", "Failed to reload " . A_ScriptName . "!")
        }
    }

MediaControl:
PrintScreen::Media_Prev
ScrollLock::Media_Play_Pause
Pause::Media_Next

XBoxHome:
VK07::F22
;endregion

; # Default Profile
; -------------------------------
; Default key bindings if no other profile is active.
;region
#If GetActiveProfile() = "Default"
F21::
    SwitchToLeftVirtualDesktop() {
        thisKey     := A_ThisHotkey
        Send        {RControl DOWN}
        Send        {RWin DOWN}
        Sleep       35
        Send        {Left}
        Send        {RWin UP}
        Send        {RControl UP}
        KeyWait,    % thisKey
    }

F22::
    SwitchToRightVirtualDesktop() {
        thisKey     := A_ThisHotkey
        Send        {RControl DOWN}
        Send        {RWin DOWN}
        Sleep       35
        Send        {Right}
        Send        {RWin UP}
        Send        {RControl UP}
        KeyWait,    % thisKey
    }

F19::
    OpenNotificationCenter() {
        thisKey     := A_ThisHotkey
        Send        {RWin DOWN}
        Sleep       35
        Send        n
        Send        {RWin UP}
        KeyWait,    % thisKey
    }

F20::
    OpenWidgets() {
        thisKey     := A_ThisHotkey
        Send        {RWin DOWN}
        Sleep       35
        Send        w
        Send        {RWin UP}
        KeyWait,    % thisKey
    }

F13::
    OpenTaskView() {
        thisKey     := A_ThisHotkey
        Send        {RWin DOWN}
        Sleep       35
        Send        {Tab}
        Send        {RWin UP}
        KeyWait,    % thisKey
    }

Forward:
F14::XButton2

Back:
F15::XButton1

F18::
    HideDesktop() {
        thisKey     := A_ThisHotkey
        Send        {RWin DOWN}
        Sleep       35
        Send        d
        Send        {RWin UP}
        KeyWait,    % thisKey
    }

MouseLayers:
RButton::RButton
F17::
    MouseShift() {
        thisKey     := A_ThisHotkey
        Send        {RShift DOWN}
        KeyWait,    % thisKey
        Send        {RShift UP}
    }
F16::
    MouseControl() {
        thisKey     := A_ThisHotkey
        Send        {RControl DOWN}
        KeyWait,    % thisKey
        Send        {RControl UP}
    }

MouseMediaControl:
RButton & MButton::Media_Play_Pause
RButton & WheelUp::Volume_Up
RButton & WheelDown::Volume_Down
RButton & F21::Media_Prev
RButton & F22::Media_Next

; ## Mouse Wheel Tab Scroll 4 Chrome
; -------------------------------
; Scroll though Chrome tabs with your mouse wheel when hovering over the tab bar.
; if the Chrome window is inactive when starting to scroll, it will be activated.
;region
#If WinExist("ahk_class Chrome_WidgetWin_1")
WheelUp::
WheelDown::
    ChromeTabScroll() {
        thisKey         := A_ThisHotkey
        MouseGetPos,,   mouseYPos, winId
        WinGetPos,,     winYPos,,, ahk_id %winId%
        WinGetClass,    winClass, ahk_id %winId%
        yDiff   := mouseYPos - winYPos
        if (yDiff > 0 AND yDiff < 45 AND InStr(winClass, "Chrome_WidgetWin_1")) {
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
;region

; ## Game Default (GD)
; -------------------------------
; Horizontal Wheel          : F21, F22
; Top Buttons               : F19, F20
; Side Buttons - Top Row    : F13, F14, F15
; Side Buttons - Bottom Row : F18, F17, F16
; Shift Layer Button        : RButton
;region
#If GetActiveProfile() = "GD"
GD_HorizontalWheel:
F21::F21
F22::F22

GD_TopButtons:
F19::F19
F20::F20

GD_SideButtonsTopRow:
F13::F13
F14::F14
F15::F15

GD_SideButtonsBottomRow:
F18::F18
F17::F17
F16::F16
;endregion

; ## Warframe (WF)
; -------------------------------
;region
#If GetActiveProfile() = "WF"
class WF_AutoAbility {
    static DELAY_MS := [300, 300, 300, 19000]
    static MIN      := WF_AutoAbility.DELAY_MS.MinIndex()
    static MAX      := WF_AutoAbility.DELAY_MS.MaxIndex()

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
        if GetActiveProfile() = "WF"
            SendHold(this.selectedAbility, 250)
        else
            this.Deactivate()
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

F21::
    WF_PrevAbility() {
        thisKey     := A_ThisHotkey
        global WF_ability
        WF_ability.SelectPrev()
        KeyWait,    % thisKey
    }

F22::
    WF_NextAbility() {
        thisKey     := A_ThisHotkey
        global WF_ability
        WF_ability.SelectNext()
        KeyWait,    % thisKey
    }

WF_OmniTool:
F19::\

WF_TacticalMenu:
F20::l

WF_Archwing:
F13::Numpad1

WF_AutoAltFire:
F14::AutoFire("NumpadDiv", 50)

WF_AutoFire:
F15::AutoFire("NumpadMult", 35)

WF_Necramech:
F18::Numpad3

WF_TransferenceFlash:
F17::
    WF_Transference()
    Sleep   125
    Send    2
return

WF_Crouch:
F16::v

; WF_Aim:
; RButton::RButton  ; This will be sent twice

WF_AltFire:
RButton & MButton::NumpadDiv

WF_KDrive:
RButton & F13::Numpad2

WF_ArchGun:
RButton & F18::Numpad4

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
;endregion

; ## Fall Guys (FG)
; -------------------------------
;region
#If GetActiveProfile() = "FG"
F21::F21
F22::F22

F19::F19
F20::F20

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
