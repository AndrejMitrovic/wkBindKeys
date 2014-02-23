/*
 *             Copyright Andrej Mitrovic 2014.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module wkBindKeys.wa_utils;

import core.stdc.string;

import std.exception;
import std.file;
import std.traits;

import win32.winbase;
import win32.windef;
import win32.winuser;

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

/**
    Taken from wkColorFix - original code by Vladimir Panteleev.

    $(B Note:) Currently unused, this method should be used only
    sparingly since it's very slow. Do not use it in a keyboard
    procedure, especially not in a a low-level keyboard hook
    which has an upper limit on the time it can spend processing
    a key event.

    See the remarks section for the $(B LowLevelKeyboardProc) function:
    http://msdn.microsoft.com/en-us/library/windows/desktop/ms644985%28v=vs.85%29.aspx

    A more reliable and faster workaround is to hook into
    $(B ShowWindow) and $(B ShowWindowAsync) functions,
    and store the last known active state of the WA window,
    which you can then check in a tight loop.
*/
bool isWAWindowActive()
{
    auto fgWinHandle = GetForegroundWindow();
    DWORD pid;
    GetWindowThreadProcessId(fgWinHandle, &pid);

    if (pid != GetCurrentProcessId())
        return false;

    RECT rect;
    GetWindowRect(fgWinHandle, &rect);

    if (rect.top != 0 || rect.left != 0)
        return false;

    return true;
}

/**
    Wrapper for W:A functions which must be marked as nothrow.
    If any exception type is thrown, a diagnostic is emitted as a
    dialog box, and $(CODE ExitProcess(1)) is called.
*/
template ThrowWrapper(alias func)
{
    static ReturnType!func ThrowWrapper(ParameterTypeTuple!func args) nothrow
    {
        try
        {
            return func(args);
        }
        catch (Throwable ex)
        {
            import std.string;
            import win32.winbase;
            import wkBindKeys.dialog;

            string trace;
            collectException!Throwable(ex.toString(), trace);

            collectException!Throwable(
                error("Internal wkBindKeys.dll error. Please use CTRL+C to copy "
                  "the contents of this window and file the bug to:\n\n"
                  "https://github.com/AndrejMitrovic/wkBindKeys/issues/new\n\n"
                  "Please remove wkBindKeys.dll from your Worms Armageddon "
                  "installation folder and restart WA.exe to run "
                  "Worms Armageddon again.\n\n"
                  "Stack trace:\n"
                  "=======\n\n" ~
                  trace));

            collectException!Throwable(ExitProcess(1));
            assert(0);
        }
    }
}
