/*
 *             Copyright Andrej Mitrovic 2014.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module wkBindKeys.main;

/**
    Typical minimal DLL main entry point.
*/

import core.sys.windows.windows;
import core.sys.windows.dll;

import std.exception;
import std.path;
import std.string;

import win32.winbase;

import wkBindKeys.dialog;
import wkBindKeys.key_hook;
import wkBindKeys.wa_utils;

/** Main entry point. */
extern (Windows)
BOOL DllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved) nothrow
{
    return ThrowWrapper!myDllMain(hInstance, ulReason, pvReserved);
}

BOOL myDllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved)
{
    switch (ulReason)
    {
        case DLL_PROCESS_ATTACH:
        {
            g_hInst = hInstance;
            dll_process_attach(hInstance, true);
            initialize();
            break;
        }

        case DLL_PROCESS_DETACH:
        {
            uninitialize();
            dll_process_detach(hInstance, true);
            break;
        }

        case DLL_THREAD_ATTACH:
            dll_thread_attach(true, true);
            break;

        case DLL_THREAD_DETACH:
            dll_thread_detach(true, true);
            break;

        default:
            assert(0);
    }

    return true;
}

///
immutable string configFileName = "wkBindKeys.ini";

///
__gshared private HINSTANCE g_hInst;

///
__gshared private bool hasHooked;

/**
    Main initialization routine.
    Attempt to read the wkBindKeys config file,
    if read properly set up the low-level keyboard hook.
*/
void initialize()
{
    auto waDir = getWAPath().dirName();
    auto configPath = waDir.buildPath(configFileName);

    Status status = readConfigFile(configPath);

    final switch (status) with (Status)
    {
        case ok:
            hookKeyboard(g_hInst);
            hasHooked = true;
            break;

        case error:
            ExitProcess(1);
            break;

        case missing_file:
            break;
    }
}

/** Cleanup routine. */
void uninitialize()
{
    if (hasHooked)
        unhookKeyboard();
}
