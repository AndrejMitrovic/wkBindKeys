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

import win32.winbase;
import win32.windef;
import win32.winuser;

import wkBindKeys.dialog;
import wkBindKeys.key_codes;

///
__gshared HHOOK keyHook_LL;

void hookKeyboard(HINSTANCE modHandle)
{
    keyHook_LL = enforce(SetWindowsHookExA(WH_KEYBOARD_LL, &LowLevelKeyboardProc, cast(HINSTANCE)null, 0));
}

void unhookKeyboard()
{
    UnhookWindowsHookEx(keyHook_LL);
}

/** Get the path to $(B WA.exe) and verify it exists. */
string getWAPath()
{
    enum MAX_PATH = 4096;
    char[MAX_PATH] waPath;
    GetModuleFileName(null, waPath.ptr, MAX_PATH);

    string path = assumeUnique(waPath[0 .. strlen(waPath.ptr)]);
    enforce(path.exists());
    return path;
}

/// Toggle-able
__gshared bool useKeyMap;

/// See the key table here:
/// http://msdn.microsoft.com/en-us/library/windows/desktop/dd375731%28v=vs.85%29.aspx
/// or in win32.winuser
/// todo: remove hardcoding
Key[Key] keyMap;

/// Status codes for reading the config file.
enum Status
{
    ok,           /// config file was read ok, bindings active.
    error,        /// error in readign the config file, exit WA.
    missing_file, /// config file missing, bindings inactive, continue loading WA.
}

/**
    Read the configuration file configFileName.
    Return true if config file exists, is well-formed, and was read properly.
*/
Status readConfigFile(string configFileName)
{
    auto waDir = getWAPath().dirName();
    auto configPath = waDir.buildPath(configFileName);

    if (!configPath.exists)
    {
        warn("Config file '%s' not found in '%s'. \n\nNo key bindings will be used."
             .format(configFileName, waDir));
        return Status.missing_file;
    }

    size_t lineNum;
    foreach (lineBuff; File(configPath, "r").byLine())
    {
        void emitError() { error("Invalid line #%s in config file:\n\"%s\"\n\nWorms Armageddon will now exit."
                                 .format(lineNum, lineBuff)); }

        ++lineNum;

        auto line = lineBuff.strip();
        if (line.empty || line.startsWith("#"))
            continue;

        auto vals = line.splitter("=");
        if (vals.empty)
        {
            emitError();
            return Status.error;
        }

        auto left = vals.front.strip;
        vals.popFront();
        if (vals.empty)
        {
            emitError();
            return Status.error;
        }

        auto right = vals.front.strip;
        vals.popFront();
        if (!vals.empty)
        {
            emitError();
            return Status.error;
        }

        Key newKey = left.toKey();
        Key oldKey = right.toKey();

        if (newKey == Key.Invalid || oldKey == Key.Invalid)
        {
            error("Unrecognized key association in line #%s:\n\"%s\"\n\nWorms Armageddon will now exit."
                  .format(lineNum, lineBuff));
            return Status.error;
        }

        if (newKey == Key.Toggle)
        {
            error("\"toggle\" can only appear on the right side of a key association."
                  "In line #%s:\n\"%s\"\n\nWorms Armageddon will now exit."
                  .format(lineNum, lineBuff));
            return Status.error;
        }

        void diag(Key targetKey, const(char)[] keyName)
        {
            error("\"%s\" is already mapped to \"%s\". Key binding in line #%s would override it:\n"
                  "\"%s\"\n\nWorms Armageddon will now exit."
                  .format(keyName, targetKey, lineNum, lineBuff));
        }

        // map CONTROL to: L_CONTROL and R_CONTROL.
        if (newKey == Key.VK_CONTROL)
        {
            if (auto targetKey = Key.VK_LCONTROL in keyMap)
            {
                diag(*targetKey, "Left-control");
                return Status.error;
            }

            if (auto targetKey = Key.VK_RCONTROL in keyMap)
            {
                diag(*targetKey, "Right-control");
                return Status.error;
            }

            keyMap[Key.VK_LCONTROL] = oldKey;
            keyMap[Key.VK_RCONTROL] = oldKey;
        }

        // map MENU to: L_MENU and R_MENU.
        if (newKey == Key.VK_MENU)
        {
            if (auto targetKey = Key.VK_LMENU in keyMap)
            {
                diag(*targetKey, "Left-alt");
                return Status.error;
            }

            if (auto targetKey = Key.VK_RMENU in keyMap)
            {
                diag(*targetKey, "Right-alt");
                return Status.error;
            }

            keyMap[Key.VK_LMENU] = oldKey;
            keyMap[Key.VK_RMENU] = oldKey;
        }

        // map SHIFT to: L_SHIFT and R_SHIFT.
        if (newKey == Key.VK_SHIFT)
        {
            if (auto targetKey = Key.VK_LSHIFT in keyMap)
            {
                diag(*targetKey, "Left-shift");
                return Status.error;
            }

            if (auto targetKey = Key.VK_RSHIFT in keyMap)
            {
                diag(*targetKey, "Right-shift");
                return Status.error;
            }

            keyMap[Key.VK_LSHIFT] = oldKey;
            keyMap[Key.VK_RSHIFT] = oldKey;
        }

        if (auto targetKey = newKey in keyMap)
        {
            diag(*targetKey, left);
            return Status.error;
        }

        keyMap[newKey] = oldKey;
    }

    return Status.ok;
}

extern(Windows)
LRESULT LowLevelKeyboardProc(int code, WPARAM wParam, LPARAM lParam)
{
    auto kbs = cast(KBDLLHOOKSTRUCT*)lParam;

    // generate a new key event only if this key event was user-generated.
    if (!(kbs.flags & LLKHF_INJECTED))
    {
        immutable bool isKeyDown = (wParam == WM_KEYDOWN || wParam == WM_SYSKEYDOWN);
        Key sourceKey = cast(Key)kbs.vkCode;
        Key targetKey = keyMap.get(sourceKey, sourceKey);

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
