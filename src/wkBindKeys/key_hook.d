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

/** Spawn a dialog box with a warning message. */
void warn(string msg)
{
    MessageBox(null, msg.toStringz, "wxBindKeys warning", MB_OK | MB_ICONWARNING);
}

/** Spawn a dialog box with an error message and throw an exception. */
void error(string msg)
{
    MessageBox(null, msg.toStringz, "wxBindKeys error", MB_OK | MB_ICONERROR);
}

void errorEnforce(bool state, lazy string msg)
{
    if (state)
        return;

    error(msg);
}

/// Toggle-able
__gshared bool useKeyMap;

/// See the key table here:
/// http://msdn.microsoft.com/en-us/library/windows/desktop/dd375731%28v=vs.85%29.aspx
/// or in win32.winuser
/// todo: remove hardcoding
Key[Key] keyMap;

/**
    Read the configuration file configFileName.
    Return true if config file exists, is well-formed, and was read properly.
*/
bool readConfigFile(string configFileName)
{
    auto waDir = getWAPath().dirName();
    auto configPath = waDir.buildPath(configFileName);

    if (!configPath.exists)
    {
        warn("Config file '%s' not found in '%s'. \n\nNo key bindings will be used."
             .format(configFileName, waDir));
        return false;
    }

    size_t lineNum;
    foreach (lineBuff; File(configPath, "r").byLine())
    {
        void emitError() { error("Invalid line #%s in config file:\n\"%s\"\n\nNo key bindings will be used."
                                 .format(lineNum, lineBuff)); }

        ++lineNum;

        auto line = lineBuff.strip();
        if (line.empty || line.startsWith("#"))
            continue;

        auto vals = line.splitter("=");
        if (vals.empty)
        {
            emitError();
            return false;
        }

        auto left = vals.front.strip;
        vals.popFront();
        if (vals.empty)
        {
            emitError();
            return false;
        }

        auto right = vals.front.strip;
        vals.popFront();
        if (!vals.empty)
        {
            emitError();
            return false;
        }

        Key newKey = left.toKey();
        Key oldKey = right.toKey();

        if (newKey == Key.Invalid || oldKey == Key.Invalid)
        {
            error("Unrecognized key association in line #%s:\n\"%s\"\n\nNo key bindings will be used."
                  .format(lineNum, lineBuff));
            return false;
        }

        if (newKey == Key.Toggle)
        {
            error("\"toggle\" can only appear on the right side of a key association."
                  "In line #%s:\n\"%s\"\n\nNo key bindings will be used."
                  .format(lineNum, lineBuff));
            return false;
        }

        if (newKey in keyMap)
        {
            error("Duplicate key map \"%s\" found in line #%s:\n"
                  "\"%s\"\n\nNo key bindings will be used."
                  .format(left, lineNum, lineBuff));
            return false;
        }

        keyMap[newKey] = oldKey;
    }

    return true;

    //~ debug=1
    //~ extern=extern "C" __attribute__((dllexport))
    //~ values=foo,bar,doo
    //~ ints=1,2,3
    //~ compiler=dmd
    //~ intSetSingle=1
    //~ intSetMultiple=1,2,3
    //~ input_language=c++
    //~ private_value=zero

    //~ enum VK_D = 0x44;

    //~ keyMap =
    //~ [
        //~ VK_D : VK_SPACE,
        //~ 65   : 13,
        //~ 83   : 222,
        //~ 81   : 222,
        //~ 87   : 119,
        //~ 69   : 112,
        //~ 74   : 37,
        //~ 75   : 40,
        //~ 76   : 39,
        //~ 73   : 38,
        //~ 85   : 8,
        //~ 48   : 121,
        //~ 49   : 122,
        //~ 50   : 113,
        //~ 51   : 114,
        //~ 52   : 115,
        //~ 53   : 116,
        //~ 54   : 117,
        //~ 55   : 118,
        //~ 56   : 119,
        //~ 57   : 120,
        //~ 90   : 49,
        //~ 88   : 50,
        //~ 67   : 51,
        //~ 86   : 52,
        //~ 66   : 53,
        //~ 17   : 187,
        //~ 18   : 189,
    //~ ];
}

extern(Windows)
LRESULT LowLevelKeyboardProc(int code, WPARAM wParam, LPARAM lParam)
{
    auto kbs = cast(KBDLLHOOKSTRUCT*)lParam;

    // generate a new key event only if this key event was user-generated.
    if (!(kbs.flags & LLKHF_INJECTED))
    {
        // todo: kbs.flags isn't handled below for targetKey
        // Alt == toggle key binding
        //~ if (kbs.flags & LLKHF_ALTDOWN)
            //~ useKeyMap ^= 1;

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
