/*
 *             Copyright Andrej Mitrovic 2014.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module wkBindKeys.key_hook;

import core.stdc.string;

import std.algorithm;
import std.bitmanip;
import std.exception;
import std.file;
import std.path;
import std.range;
import std.stdio;
import std.string;
import std.traits;

import win32.winbase;
import win32.windef;
import win32.winuser;

import wkBindKeys.dialog;
import wkBindKeys.key_codes;
import wkBindKeys.wa_utils;

import madhook2;

///
__gshared HHOOK keyHook_LL;

///
__gshared extern(Windows) BOOL function(HWND) setForegroundWindowNext;

///
__gshared extern(Windows) BOOL function(HWND, int) showWindowNext;

///
__gshared extern(Windows) BOOL function(HWND, int) showWindowAsyncNext;

void hookKeyboard(HINSTANCE modHandle)
{
    // todo: add checking code back in again.
    keyHook_LL = enforce(SetWindowsHookExA(WH_KEYBOARD_LL, &lowLevelKeyboardProc, cast(HINSTANCE)null, 0));

    // WA version older than v3.7.1.1 used $(CODE SetForegroundWindow(GetDesktopWindow()))
    HookAPI("user32.dll", "SetForegroundWindow", cast(void*)&onSetForegroundWindow, cast(void**)&setForegroundWindowNext);
    HookAPI("user32.dll", "ShowWindow", cast(void*)&onShowWindow, cast(void**)&showWindowNext);
    HookAPI("user32.dll", "ShowWindowAsync", cast(void*)&onShowWindowAsync, cast(void**)&showWindowAsyncNext);
}

void unhookKeyboard()
{
    UnhookWindowsHookEx(keyHook_LL);
    UnhookAPI(cast(void**)&setForegroundWindowNext);
    UnhookAPI(cast(void**)&showWindowAsyncNext);
    UnhookAPI(cast(void**)&showWindowNext);
}

/// Toggle-able key bindings.
__gshared bool useKeyMap;

///
__gshared KeyArr keyArr;

///
__gshared bool isWAActive = false;

extern (Windows)
BOOL onSetForegroundWindow(HWND hwnd)
{
    // desktop is about to be shown, W:A becomes inactive.
    if (hwnd == GetDesktopWindow())
        isWAActive = false;

    DWORD pid;
    GetWindowThreadProcessId(hwnd, &pid);
    if (pid == GetCurrentProcessId())
        isWAActive = true;

    return setForegroundWindowNext(hwnd);
}

///
extern (Windows)
BOOL onShowWindow(HWND hwnd, int sw)
{
    onShowWindowImpl(sw);
    return showWindowNext(hwnd, sw);
}

extern (Windows)
BOOL onShowWindowAsync(HWND hwnd, int sw)
{
    onShowWindowImpl(sw);
    return showWindowAsyncNext(hwnd, sw);
}

private void onShowWindowImpl(int sw)
{
    // todo: to capture state of SW_SHOWDEFAULT we need to hook into CreateProcess.

    if (sw == SW_FORCEMINIMIZE ||
        sw == SW_HIDE ||
        sw == SW_MINIMIZE ||
        sw == SW_SHOWMINIMIZED ||
        sw == SW_SHOWMINNOACTIVE)
        isWAActive = false;
    else
        isWAActive = true;
}

extern(Windows)
LRESULT lowLevelKeyboardProc(int code, WPARAM wParam, LPARAM lParam)
{
    auto kbs = cast(KBDLLHOOKSTRUCT*)lParam;

    // generate a new key event only if this key event was user-generated,
    // and if WA is active (the LL keyboard hook can only be global).
    if (isWAActive && !(kbs.flags & LLKHF_INJECTED))
    {
        immutable bool isKeyDown = (wParam == WM_KEYDOWN || wParam == WM_SYSKEYDOWN);
        auto keyIndex = cast(OriginalType!Key)kbs.vkCode;
        Key targetKey = keyArr[keyIndex];

        /// toggle the key binding
        if (isKeyDown && targetKey == Key.Toggle)
        {
            useKeyMap ^= 1;
            return -1;
        }

        if (!useKeyMap)
            return CallNextHookEx(keyHook_LL, code, wParam, lParam);

        INPUT input;
        input.type = INPUT_KEYBOARD;
        input.ki.dwFlags = isKeyDown ? 0 : KEYEVENTF_KEYUP;

        // replace the key
        input.ki.wVk = targetKey;

        SendInput(1, &input, INPUT.sizeof);
        return -1;
    }

    return CallNextHookEx(keyHook_LL, code, wParam, lParam);
}
