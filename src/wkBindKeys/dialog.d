/*
 *             Copyright Andrej Mitrovic 2014.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module wkBindKeys.dialog;

import std.string;

import win32.winuser;

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
