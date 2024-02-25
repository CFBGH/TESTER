@echo off
color 0a
echo Select Bulid Mode
echo A -> Windows 32Bit | B -> Windows | C -> Windows 32Bit Debug |D -> Windows Debug | E -> 
choice /c abcde /n /d b /t 10 /m Select: 
if %errorlevel%==1 echo Building Game to "Windows (32Bit)" Please Wait...
if %errorlevel%==2 echo Building Game to "Windows" Please Wait...
if %errorlevel%==3 echo Building Game to "Windows(Debug, 32Bit)" Please Wait...
if %errorlevel%==4 echo Building Game to "Windows(Debug)" Please Wait...

if %errorlevel%==1 lime build windows -release -D 32bits -D HXCPP_M32
if %errorlevel%==2 lime build windows -release
if %errorlevel%==3 lime build windows -debug -D 32bits -D HXCPP_M32
if %errorlevel%==4 lime build windows -debug
pause