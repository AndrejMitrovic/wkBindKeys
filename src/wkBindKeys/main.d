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

import wkBindKeys.key_hook;

extern (Windows)
BOOL DllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved)
{
    __gshared HINSTANCE g_hInst;

    switch (ulReason)
    {
        case DLL_PROCESS_ATTACH:
            g_hInst = hInstance;
            dll_process_attach(hInstance, true);
            hookKeyboard(g_hInst);
            break;

        case DLL_PROCESS_DETACH:
            unhookKeyboard();
            dll_process_detach(hInstance, true);
            break;

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
