/*
 *             Copyright Andrej Mitrovic 2014.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module wkBindKeys.config_parser;

import std.file;
import std.stdio;
import std.string;
import std.range;
import std.traits;

import wkBindKeys.dialog;
import wkBindKeys.key_codes;

/// Status codes for reading the config file.
enum Status
{
    ok,           /// config file was read ok, bindings active.
    error,        /// error in readign the config file, exit WA.
    missing_file, /// config file missing, bindings inactive, continue loading WA.
}

/**
    Read the configuration file configFileName and populate the keyMap.
    Return true if config file exists, is well-formed, and was read properly.
*/
Status readConfigFile(string configPath, ref KeyArr keyArr)
{
    keyArr = getInitKeyArr();

    if (!configPath.exists)
    {
        warn("Config file '%s' not found. \n\nNo key bindings will be used."
             .format(configPath));
        return Status.missing_file;
    }

    Key[Key] keyMap;  // temp key map for diagnostics

    /// store to both the temp key map and the key array.
    void storeKey(Key source, Key target)
    {
        keyMap[source] = target;
        keyArr[cast(OriginalType!Key)source] = target;
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

        Key srcKey = left.toKey();
        Key tgtKey = right.toKey();

        if (srcKey == Key.Invalid || tgtKey == Key.Invalid)
        {
            error("Unrecognized key association in line #%s:\n\"%s\"\n\nWorms Armageddon will now exit."
                  .format(lineNum, lineBuff));
            return Status.error;
        }

        if (srcKey == Key.Toggle)
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
        if (srcKey == Key.VK_CONTROL)
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

            storeKey(Key.VK_LCONTROL, tgtKey);
            storeKey(Key.VK_RCONTROL, tgtKey);
        }

        // map MENU to: L_MENU and R_MENU.
        if (srcKey == Key.VK_MENU)
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

            storeKey(Key.VK_LMENU, tgtKey);
            storeKey(Key.VK_RMENU, tgtKey);
        }

        // map SHIFT to: L_SHIFT and R_SHIFT.
        if (srcKey == Key.VK_SHIFT)
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

            storeKey(Key.VK_LSHIFT, tgtKey);
            storeKey(Key.VK_RSHIFT, tgtKey);
        }

        if (auto targetKey = srcKey in keyMap)
        {
            diag(*targetKey, left);
            return Status.error;
        }

        storeKey(srcKey, tgtKey);
    }

    return Status.ok;
}
