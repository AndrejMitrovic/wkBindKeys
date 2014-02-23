module madhook2;

/**
    Copyright (C) 1999 - 2009 www.madshi.net, All Rights Reserved
    License: See license.txt in the root dir of this project.

    This is the D binding of the madCodeHook library.

    See the madCodeHook homepage for more info:
    http://madshi.net/madCodeHookDescription.htm

    $(B Note): This module targets targets the older header file madCHook v2.1i (date: 2008-07-25),
    but ideally would target madCHook.dll file version 2.2.8.0 (date: 2008-03-10).
    It will attempt to load a file named $(B madCHook-2.2.8.0.dll) before it attempts to
    load `madCHook.dll`

    This older version is useful if you want to write hooking code for
    e.g. Worms Armageddon WormKit modules.

    $(B WARNING:) Not all functions were prototyped properly yet,
    a valid header file for the old version is hard to find.

    The D binding was created by Andrej Mitrovic.

    $(B Note:) DStep[1] was used to extract the functions from the headers.
    However not all comments and macros have yet been ported.
    [1] : https://github.com/jacob-carlborg/dstep/
*/

import std.exception;
import std.string;
import std.typecons;

// Note: core bindings missing structs such as STARTUPINFOA
// import core.sys.windows.windows;

import win32.winbase;
import win32.windef;

///
extern(Windows) alias DWORD function(LPVOID) PREMOTE_EXECUTE_ROUTINE;

///
extern(Windows) alias void function(LPCSTR, PVOID, DWORD, PVOID, DWORD) PIPC_CALLBACK_ROUTINE;

/// These are typesafe bitflags that can be combined together and used in the
/// calls to $(D HookCode) and $(D HookAPI), e.g.:
/// $(CODE HookAPI("kernel32.dll", "WinExec", cast(void*)&proc, cast(void**)&procNext, DONT_COUNT | MIXTURE_MODE);)
enum : HookFlags
{
    /// No change of behavior
    NO_FLAGS = HookFlags(0x0),

    /// by default madCodeHook counts how many times any thread is currently
    /// running inside of your callback function
    /// this way unhooking can be safely synchronized to that counter
    /// sometimes you don't need/want this counting to happen, e.g.
    /// (1) if you don't plan to ever unhook, anyway
    /// (2) if the counting performance drop is too high for your taste
    /// (3) if you want to unhook from inside the hook callback function
    /// in those cases you can set the flag "NO_SAFE_UNHOOKING"
    /// old name - kept for compatability
    DONT_COUNT = HookFlags(0x00000001),

    /// new name
    NO_SAFE_UNHOOKING = HookFlags(0x00000001),

    /// with 2.1f the "safe unhooking" functionality (see above) was improved
    /// most probably there's no problem with the improvement
    /// but to be sure you can disable the improvement
    /// the improved safe unhooking is currently only available in the NT family
    NO_IMPROVED_SAFE_UNHOOKING = HookFlags(0x00000040),

    /// optionally madCodeHook can use a special technique to make sure that
    /// hooking in multi threaded situations won't result in crashing threads
    /// this technique is not tested too well right now, so it's optional for now
    /// you can turn this feature on by setting the flag "SAFE_HOOKING"
    /// without this technique crashes can happen, if a thread is calling the API
    /// which we want to hook in exactly the moment when the hook is installed
    /// safe hooking is currently only available in the NT family
    SAFE_HOOKING = HookFlags(0x00000020),

    /// madCodeHook implements two different API hooking methods
    /// the mixture mode is the second best method, it's only used if the main
    /// hooking method doesn't work for whatever reason (e.g. API code structure)
    /// normally madCodeHook chooses automatically which mode to use
    /// you can force madCodeHook to use the mixture mode by specifying this flag:
    MIXTURE_MODE = HookFlags(0x00000002),

    /// if you don't want madCodeHook to use the mixture mode, you can say so
    /// however, if the main hooking mode can't be used, hooking then simply fails
    NO_MIXTURE_MODE = HookFlags(0x00000010),

    /// winsock2 normally doesn't like the mixture mode
    /// however, I've found a way to convince winsock2 to accept mixture hooks
    /// this is a somewhat experimental feature, though
    /// so it must be turned on explicitly
    ALLOW_WINSOCK2_MIXTURE_MODE = HookFlags(0x00000080),

    /// under win9x you can hook code system wide, if it begins > $80000000
    /// or if the code section of the to-be-hooked dll is shared
    /// the callback function is in this case automatically copied to shared memory
    /// use only kernel32 APIs in such a system wide hook callback function (!!)
    /// if you want an easier way and/or a NT family compatible way to hook code
    /// system wide, please use InjectLibrary(ALL_SESSIONS) instead of these flags:
    SYSTEM_WIDE_9X = HookFlags(0x00000004),

    /// This flag is only valid in combination with SYSTEM_WIDE_9X.
    /// It means that installation of the hook shall succeed even if
    /// your callback function contains unknown call/jmp targets.
    /// See the documentation of CopyFunction for more information.
    ACCEPT_UNKNOWN_TARGETS_9X = HookFlags(0x00000008),
}

/// Ditto
struct HookFlags
{
    /// Allow flag operators
    HookFlags opBinary(string op)(HookFlags rhs)
    {
        mixin("return HookFlags(flags " ~ op ~ " rhs.flags);");
    }

    /// Allow flag operator assignments
    void opOpAssign(string op)(HookFlags rhs)
    {
        mixin("flags " ~ op ~ "= rhs.flags;");
    }

    private DWORD flags;
}

unittest
{
    HookFlags flags;
    flags |= DONT_COUNT;
    assert(flags == DONT_COUNT);

    flags |= MIXTURE_MODE;
    assert(flags == (DONT_COUNT | MIXTURE_MODE));
}

/// Some aspects of madCodeHook can be modified,
/// for this there's the function $(D SetMadCHookOption),
/// which as its first argument allows you to select
/// and configure one of the following options,
/// and where the second argument $(B value) may be optional:
enum : HookOption
{
    /// don't use the driver file embedded in madCodeHook
    /// instead use an external driver file
    /// to avoid virus false alarms you can rename the driver
    /// you can also sign it with your own Verisign certificate
    /// $(B value): e.g. "C:\Program Files\yourSoft\yourInjDrv.sys"
    USE_EXTERNAL_DRIVER_FILE = HookOption(0x00000001),

    /// make all memory maps available only to current user + admins + system
    /// without this option all memory maps are open for Everyone
    /// this option is not fully tested yet
    /// so use it only after extensive testing and on your own danger
    /// $(B value): unsused
    SECURE_MEMORY_MAPS = HookOption(0x00000002),

    /// before installing an API hook madCodeHook does some security checks
    /// one check is verifying whether the to be hooked code was already modified
    /// in this case madCodeHook does not tempt to modify the code another time
    /// otherwise there would be a danger to run into stability issues
    /// with protected/compressed modules there may be false alarms, though
    /// so you can turn this check off
    /// $(B value): unsused
    DISABLE_CHANGED_CODE_CHECK = HookOption(0x00000003),

    /// madCodeHook has two different IPC solutions built in
    /// in Vista and in all 64 bit OSs the "old" IPC solution doesn't work
    /// so in these OSs the new IPC solution is always used
    /// in all other OSs the old IPC solution is used by default
    /// the new solution is based on undocumented internal Windows IPC APIs
    /// the old solution is based on pipes and memory mapped files
    /// you can optionally enable the new IPC solution for the older OSs, too
    /// the new IPC solution doesn't work in win9x and so cannot be enabled there
    /// $(B value): unused
    USE_NEW_IPC_LOGIC = HookOption(0x00000004),

    /// when calling SendIpcMessage you can specify a timeout value
    /// this value only applies to how long madCodeHook waits for the reply
    /// there's an additional internal timeout value which specifies how long
    /// madCodeHook waits for the IPC message to be accepted by the queue owner
    /// the default value is 2000ms
    /// $(B value): internal timeout value in ms
    /// example: SetMadCHookOption(SET_INTERNAL_IPC_TIMEOUT, (LPCWSTR) 5000);
    SET_INTERNAL_IPC_TIMEOUT = HookOption(0x00000005),

    /// VMware: when disabling acceleration dll injection sometimes is delayed
    /// to work around this issue you can activate this special option
    /// it will result in a slightly modified dll injection logic
    /// as a side effect injection into DotNet applications may not work properly
    /// $(B value): unused
    VMWARE_INJECTION_MODE = HookOption(0x00000006),
}

/// Ditto
struct HookOption
{
    private DWORD option;
}

/**
    Collection of all madCodeHook functions.

    All of these functions are loaded once in a shared module constructor.
    They are available in module scope, injected through the $(B ExportMembers)
    mixin statement.

    You can also use MadHook itself as a namespace, e.g. $(CODE MadHook.HookAPI(...)).

    $(RED Note:) These functions have the Windows calling convention even though
    the symbols are not mangled in the madCodeHook DLL.
*/
struct MadHook
{
__gshared extern(Windows):

    ///
    BOOL function(HookOption option, LPCWSTR value = null) SetMadCHookOption;

    ///
    BOOL function() InstallMadCHook;

    ///
    BOOL function() UninstallMadCHook;

    ///
    BOOL function(PVOID pCode, PVOID pCallbackFunc, PVOID* pNextHook, HookFlags dwFlags = NO_FLAGS) HookCode;

    ///
    BOOL function(LPCSTR pszModule, LPCSTR pszFuncName, PVOID pCallbackFunc, PVOID* pNextHook, HookFlags dwFlags = NO_FLAGS) HookAPI;

    ///
    BOOL function(PVOID* pNextHook) RenewHook;

    ///
    DWORD function(PVOID* pNextHook) IsHookInUse;

    ///
    BOOL function(PVOID* pNextHook) UnhookCode;

    ///
    BOOL function(PVOID* pNextHook) UnhookAPI;

    ///
    VOID function() CollectHooks;

    ///
    VOID function() FlushHooks;

    ///
    BOOL function(LPCSTR lpApplicationName, LPSTR lpCommandLine, LPSECURITY_ATTRIBUTES lpProcessAttributes, LPSECURITY_ATTRIBUTES lpThreadAttributes, BOOL bInheritHandles, DWORD dwCreationFlags, LPVOID lpEnvironment, LPCSTR lpCurrentDirectory, LPSTARTUPINFOA lpStartupInfo, LPPROCESS_INFORMATION lpProcessInformation, LPCSTR lpLoadLibrary) CreateProcessExA;

    ///
    BOOL function(LPCWSTR lpApplicationName, LPWSTR lpCommandLine, LPSECURITY_ATTRIBUTES lpProcessAttributes, LPSECURITY_ATTRIBUTES lpThreadAttributes, BOOL bInheritHandles, DWORD dwCreationFlags, LPVOID lpEnvironment, LPCWSTR lpCurrentDirectory, LPSTARTUPINFOW lpStartupInfo, LPPROCESS_INFORMATION lpProcessInformation, LPCWSTR lpLoadLibrary) CreateProcessExW;
    ///
    PVOID function(DWORD dwSize, HANDLE hProcess) AllocMemEx;

    ///
    BOOL function(PVOID pMem, HANDLE hProcess) FreeMemEx;

    ///
    PVOID function(PVOID pFunction, HANDLE hProcess, BOOL bAcceptUnknownTargets, PVOID* pBuffer) CopyFunction;

    ///
    HANDLE function(HANDLE hProcess, LPSECURITY_ATTRIBUTES lpThreadAttributes, DWORD dwStackSize, LPTHREAD_START_ROUTINE lpStartAddress, LPVOID lpParameter, DWORD dwCreationFlags, LPDWORD lpThreadId) CreateRemoteThreadEx;

    ///
    BOOL function(HANDLE hProcess, PREMOTE_EXECUTE_ROUTINE pFunc, DWORD* dwFuncResult, PVOID pParams, DWORD dwSize) RemoteExecute;

    ///
    BOOL function(DWORD dwProcessHandleOrSpecialFlags, LPCSTR pLibFileName, DWORD dwTimeOut) InjectLibraryA;

    ///
    BOOL function(DWORD dwProcessHandleOrSpecialFlags, LPCWSTR pLibFileName, DWORD dwTimeOut) InjectLibraryW;

    ///
    BOOL function(DWORD dwSession, BOOL bSystemProcesses, LPCSTR pLibFileName, DWORD dwTimeOut) InjectLibrarySessionA;

    ///
    BOOL function(DWORD dwSession, BOOL bSystemProcesses, LPCWSTR pLibFileName, DWORD dwTimeOut) InjectLibrarySessionW;

    ///
    BOOL function(DWORD dwProcessHandleOrSpecialFlags, LPCSTR pLibFileName, DWORD dwTimeOut) UninjectLibraryA;

    ///
    BOOL function(DWORD dwProcessHandleOrSpecialFlags, LPCWSTR pLibFileName, DWORD dwTimeOut) UninjectLibraryW;

    ///
    BOOL function(DWORD dwSession, BOOL bSystemProcesses, LPCSTR pLibFileName, DWORD dwTimeOut) UninjectLibrarySessionA;

    ///
    BOOL function(DWORD dwSession, BOOL bSystemProcesses, LPCWSTR pLibFileName, DWORD dwTimeOut) UninjectLibrarySessionW;

    ///
    DWORD function(HANDLE dwProcessHandle) ProcessHandleToId;

    ///
    DWORD function(HANDLE dwThreadHandle) ThreadHandleToId;

    ///
    BOOL function(DWORD dwProcessId, LPSTR pFileName) ProcessIdToFileName;

    ///
    BOOL function() AmSystemProcess;

    ///
    BOOL function() AmUsingInputDesktop;

    ///
    DWORD function() GetCurrentSessionId;

    ///
    DWORD function() GetInputSessionId;

    ///
    HMODULE function() GetCallingModule;

    ///
    HANDLE function(LPCSTR pName) CreateGlobalMutex;

    ///
    HANDLE function(LPCSTR pName) OpenGlobalMutex;

    ///
    HANDLE function(LPCSTR pName, BOOL bManual, BOOL bInitialState) CreateGlobalEvent;

    ///
    HANDLE function(LPCSTR pName) OpenGlobalEvent;

    ///
    HANDLE function(LPCSTR pName, DWORD dwSize) CreateGlobalFileMapping;

    ///
    HANDLE function(LPCSTR pName, BOOL bWrite) OpenGlobalFileMapping;

    ///
    VOID function(LPCSTR pAnsi, LPWSTR pWide) AnsiToWide;

    ///
    VOID function(LPCWSTR pWide, LPSTR pAnsi) WideToAnsi;

    ///
    BOOL function(LPCSTR pIpc, PIPC_CALLBACK_ROUTINE pCallback, DWORD dwMaxThreadCount, DWORD dwMaxQueueLen) CreateIpcQueueEx;

    ///
    BOOL function(LPCSTR pIpc, PIPC_CALLBACK_ROUTINE pCallback) CreateIpcQueue;

    ///
    BOOL function(LPCSTR pIpc, PVOID pMessageBuf, DWORD dwMessageLen, PVOID pAnswerBuf, DWORD dwAnswerLen, DWORD dwAnswerTimeOut, BOOL bHandleMessage) SendIpcMessage;

    ///
    BOOL function(LPCSTR pIpc) DestroyIpcQueue;

    ///
    BOOL function(HANDLE hProcessOrService, DWORD dwAccess) AddAccessForEveryone;

    ///
    VOID function(HINSTANCE hinstDLL) AutoUnhook;
}

/// All functions are available in module scope.
mixin ExportMembers!MadHook;

/// All function pointers are loaded in this shared module constructor.
shared static this()
{
    enum madDLLs = ["madCHook-2.2.8.0.dll", "madCHook.dll"];

    HMODULE madHandle;
    foreach (madDLL; madDLLs)
    {
        madHandle = LoadLibraryA(madDLL.ptr);
        if (madHandle !is null)
            break;
    }

    enforce(madHandle !is null,
        format("madCHook shared library not found in PATH."
               "Attempted to load DLLs in this order: %s.", madDLLs.join(", ")));

    foreach (string member; __traits(allMembers, MadHook))
        madHandle.loadSymbol!(__traits(getMember, MadHook, member));
}

private void loadSymbol(alias field)(HANDLE handle)
{
    enum string symbolName = __traits(identifier, field);
    field = cast(typeof(field))enforce(GetProcAddress(handle, symbolName.toStringz),
                                       format("Failed to load function pointer: '%s'.", symbolName));
}

/**
    Extract aggregate or enum $(D T)'s members by making aliases to each member,
    effectively making the members accessible from module scope without qualifications.
*/
private mixin template ExportMembers(T)
    if (is(T == struct) || is(T == enum))
{
    mixin(_makeAggregateAliases!(T)());
}

private string _makeAggregateAliases(T)()
{
    enum enumName = __traits(identifier, T);
    string[] result;

    foreach (string member; __traits(allMembers, T))
        result ~= format("alias %s = %s.%s;", member, enumName, member);

    return result.join("\n");
}
