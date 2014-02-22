@echo off
setlocal EnableDelayedExpansion

set this_path=%~dp0
set home_path=%this_path%\..
set bin_path=%home_path%\bin
cd %this_path%\..\src

set output_path="%bin_path%\wkBindKeys.dll"
rem set output_path="C:\Worms Armageddon\wkBindKeys.dll"

set "build_flags=-w -g"
rem set "build_flags=-release -inline -O -noboundscheck"

rdmd --build-only -shared %build_flags% -I%home_path% -I%home_path%\src -od%bin_path% -of%output_path% -L/map -version=WindowsXP wkBindKeys\wkBindKeys.def wkBindKeys\main.d
