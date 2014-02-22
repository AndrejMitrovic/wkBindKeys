/*
 *             Copyright Andrej Mitrovic 2014.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module wkBindKeys.key_codes;

import std.conv;
import std.exception;
import std.string;

import win32.windef;

import wkBindKeys.dialog;

/** Parse a number of user representations of keys as a Key. */
Key toKey(const(char)[] input)
{
    auto data = input.toLower();

    /** Support direct reference to a virtual key. */
    if (data.startsWith("vk_"))
    {
        Key result;
        if (collectException!ConvException(to!Key(input), result))
            return Key.Invalid;

        return result;
    }

    switch (data)
    {
        /** a - z. */
        case "a": return Key.VK_A;
        case "b": return Key.VK_B;
        case "c": return Key.VK_C;
        case "d": return Key.VK_D;
        case "e": return Key.VK_E;
        case "f": return Key.VK_F;
        case "g": return Key.VK_G;
        case "h": return Key.VK_H;
        case "i": return Key.VK_I;
        case "j": return Key.VK_J;
        case "k": return Key.VK_K;
        case "l": return Key.VK_L;
        case "m": return Key.VK_M;
        case "n": return Key.VK_N;
        case "o": return Key.VK_O;
        case "p": return Key.VK_P;
        case "q": return Key.VK_Q;
        case "r": return Key.VK_R;
        case "s": return Key.VK_S;
        case "t": return Key.VK_T;
        case "u": return Key.VK_U;
        case "v": return Key.VK_V;
        case "w": return Key.VK_W;
        case "x": return Key.VK_X;
        case "y": return Key.VK_Y;
        case "z": return Key.VK_Z;

        /** 0 - 9. */
        case "0": return Key.VK_0;
        case "1": return Key.VK_1;
        case "2": return Key.VK_2;
        case "3": return Key.VK_3;
        case "4": return Key.VK_4;
        case "5": return Key.VK_5;
        case "6": return Key.VK_6;
        case "7": return Key.VK_7;
        case "8": return Key.VK_8;
        case "9": return Key.VK_9;

        /** F1 - F24.*/
        case "f1": return Key.VK_F1;
        case "f2": return Key.VK_F2;
        case "f3": return Key.VK_F3;
        case "f4": return Key.VK_F4;
        case "f5": return Key.VK_F5;
        case "f6": return Key.VK_F6;
        case "f7": return Key.VK_F7;
        case "f8": return Key.VK_F8;
        case "f9": return Key.VK_F9;
        case "f10": return Key.VK_F10;
        case "f11": return Key.VK_F11;
        case "f12": return Key.VK_F12;
        case "f13": return Key.VK_F13;
        case "f14": return Key.VK_F14;
        case "f15": return Key.VK_F15;
        case "f16": return Key.VK_F16;
        case "f17": return Key.VK_F17;
        case "f18": return Key.VK_F18;
        case "f19": return Key.VK_F19;
        case "f20": return Key.VK_F20;
        case "f21": return Key.VK_F21;
        case "f22": return Key.VK_F22;
        case "f23": return Key.VK_F23;
        case "f24": return Key.VK_F24;

        /** arrow keys. */
        case "left":  return Key.VK_LEFT;
        case "right": return Key.VK_RIGHT;
        case "up":    return Key.VK_UP;
        case "down":  return Key.VK_DOWN;

        /** modifiers and command keys. */
        case "ctrl", "control":
            return Key.VK_CONTROL;

        case "lctrl", "l-ctrl", "l_ctrl", "leftctrl", "left-ctrl", "left_ctrl",
             "lcontrol", "l-control", "l_control", "leftcontrol", "left-control", "left_control":
            return Key.VK_LCONTROL;

        case "rctrl", "r-ctrl", "r_ctrl", "rightctrl", "right-ctrl", "right_ctrl",
             "rcontrol", "r-control", "r_control", "rightcontrol", "right-control", "right_control":
            return Key.VK_RCONTROL;

        case "alt":    return Key.VK_MENU;

        case "lalt", "l-alt", "l_alt", "leftalt", "left-alt", "left_alt":
            return Key.VK_LMENU;

        case "ralt", "r-alt", "r_alt", "rightalt", "right-alt", "right_alt":
            return Key.VK_RMENU;

        case "shift":  return Key.VK_SHIFT;

        case "lshift", "l-shift", "l_shift", "leftshift", "left-shift", "left_shift":
            return Key.VK_LSHIFT;

        case "rshift", "r-shift", "r_shift", "rightshift", "right-shift", "right_shift":
            return Key.VK_RSHIFT;

        case "space":  return Key.VK_SPACE;
        case "tab":    return Key.VK_TAB;
        case "toggle": return Key.Toggle;
        case "home":   return Key.VK_HOME;

        case "`", "backtick", "back-tick", "back_tick":
            return Key.VK_OEM_3;

        case "backspace", "back-space", "back_space":
            return Key.VK_BACK;

        case "enter", "return":
            return Key.VK_RETURN;

        case "+", "plus":
            return Key.VK_OEM_PLUS;

        case "-", "minus":
            return Key.VK_OEM_MINUS;

        default: return Key.Invalid;
    }
}

/**
    $(D win32.winuser) doesn't define all possible virtual key codes.
    These were extracted from: http://nehe.gamedev.net/article/msdn_virtualkey_codes/15009/
*/
enum Key : WORD
{
    Invalid = 0x07,  // sentinel
    Toggle = 0x0A,   // special toggle key

    VK_LBUTTON = 0x01,
    VK_RBUTTON,
    VK_CANCEL,
    VK_MBUTTON,
    VK_XBUTTON1,
    VK_XBUTTON2,

    VK_BACK = 0x08,
    VK_TAB,

    VK_CLEAR = 0x0C,
    VK_RETURN,

    VK_SHIFT = 0x10,
    VK_CONTROL,
    VK_MENU,
    VK_PAUSE,
    VK_CAPITAL,
    VK_KANA,
    VK_HANGUEL,
    VK_HANGUL,

    VK_JUNJA = 0x17,
    VK_FINAL,
    VK_HANJA,
    VK_KANJI,

    VK_ESCAPE = 0x1B,
    VK_CONVERT,
    VK_NONCONVERT,
    VK_ACCEPT,
    VK_MODECHANGE,
    VK_SPACE,
    VK_PRIOR,
    VK_NEXT,
    VK_END,
    VK_HOME,
    VK_LEFT,
    VK_UP,
    VK_RIGHT,
    VK_DOWN,
    VK_SELECT,
    VK_PRINT,
    VK_EXECUTE,
    VK_SNAPSHOT,
    VK_INSERT,
    VK_DELETE,
    VK_HELP,
    VK_0,
    VK_1,
    VK_2,
    VK_3,
    VK_4,
    VK_5,
    VK_6,
    VK_7,
    VK_8,
    VK_9,

    VK_A = 0x41,
    VK_B,
    VK_C,
    VK_D,
    VK_E,
    VK_F,
    VK_G,
    VK_H,
    VK_I,
    VK_J,
    VK_K,
    VK_L,
    VK_M,
    VK_N,
    VK_O,
    VK_P,
    VK_Q,
    VK_R,
    VK_S,
    VK_T,
    VK_U,
    VK_V,
    VK_W,
    VK_X,
    VK_Y,
    VK_Z,
    VK_LWIN,
    VK_RWIN,
    VK_APPS,

    VK_SLEEP = 0x5F,
    VK_NUMPAD0,
    VK_NUMPAD1,
    VK_NUMPAD2,
    VK_NUMPAD3,
    VK_NUMPAD4,
    VK_NUMPAD5,
    VK_NUMPAD6,
    VK_NUMPAD7,
    VK_NUMPAD8,
    VK_NUMPAD9,
    VK_MULTIPLY,
    VK_ADD,
    VK_SEPARATOR,
    VK_SUBTRACT,
    VK_DECIMAL,
    VK_DIVIDE,
    VK_F1,
    VK_F2,
    VK_F3,
    VK_F4,
    VK_F5,
    VK_F6,
    VK_F7,
    VK_F8,
    VK_F9,
    VK_F10,
    VK_F11,
    VK_F12,
    VK_F13,
    VK_F14,
    VK_F15,
    VK_F16,
    VK_F17,
    VK_F18,
    VK_F19,
    VK_F20,
    VK_F21,
    VK_F22,
    VK_F23,
    VK_F24,

    VK_NUMLOCK = 0x90,
    VK_SCROLL,

    VK_LSHIFT = 0xA0,
    VK_RSHIFT,
    VK_LCONTROL,
    VK_RCONTROL,
    VK_LMENU,
    VK_RMENU,
    VK_BROWSER_BACK,
    VK_BROWSER_FORWARD,
    VK_BROWSER_REFRESH,
    VK_BROWSER_STOP,
    VK_BROWSER_SEARCH,
    VK_BROWSER_FAVORITES,
    VK_BROWSER_HOME,
    VK_VOLUME_MUTE,
    VK_VOLUME_DOWN,
    VK_VOLUME_UP,
    VK_MEDIA_NEXT_TRACK,
    VK_MEDIA_PREV_TRACK,
    VK_MEDIA_STOP,
    VK_MEDIA_PLAY_PAUSE,
    VK_LAUNCH_MAIL,
    VK_LAUNCH_MEDIA_SELECT,
    VK_LAUNCH_APP1,
    VK_LAUNCH_APP2,

    VK_OEM_1 = 0xBA,
    VK_OEM_PLUS,
    VK_OEM_COMMA,
    VK_OEM_MINUS,
    VK_OEM_PERIOD,
    VK_OEM_2,
    VK_OEM_3,


    VK_OEM_4 = 0xDB,
    VK_OEM_5,
    VK_OEM_6,
    VK_OEM_7,
    VK_OEM_8,


    VK_OEM_102 = 0xE2,

    VK_PROCESSKEY = 0xE5,

    VK_PACKET = 0xE7,


    VK_ATTN = 0xF6,
    VK_CRSEL,
    VK_EXSEL,
    VK_EREOF,
    VK_PLAY,
    VK_ZOOM,
    VK_NONAME,
    VK_PA1,
    VK_OEM_CLEAR,
}
