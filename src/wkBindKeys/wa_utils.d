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
