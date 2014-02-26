/*
 *             Copyright Andrej Mitrovic 2014.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module wkBindKeys.dialog;

import std.algorithm;
import std.string;

import win32.winuser;

/** Spawn a dialog box with a warning message. */
void warn(string msg)
{
    MessageBox(null, msg.trimForDialog.toStringz,
               "wxBindKeys warning", MB_OK | MB_ICONWARNING);
}

/** Spawn a dialog box with an error message. */
void error(string msg)
{
    MessageBox(null, msg.trimForDialog.toStringz,
               "wxBindKeys error", MB_OK | MB_ICONERROR);
}

/**
    MessageBox seems to be extremely slow with
    displaying text longer than 10K characters.
*/
private string trimForDialog(string input)
{
    return input[0 .. min(10_000, input.length)];
}
