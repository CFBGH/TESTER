@echo off
color 0a
echo Select Bulid Mode
echo A - Windows release  B - Windows  C - HTML  D - Windows Debug
choice /c abcd /n /d b /t 10 /m Select: 
if %errorlevel%==1 echo Building Game to "Windows (32Bit)" Please Wait...
if %errorlevel%==2 echo Building Game to "Windows" Please Wait...
if %errorlevel%==3 echo Building Game to "HTML 5" Please Wait...
if %errorlevel%==4 echo Building Game to "Windows(Debug)" Please Wait...

if %errorlevel%==1 lime test windows -release
if %errorlevel%==2 lime test windows
if %errorlevel%==3 lime test html5
if %errorlevel%==4 lime test windows -debug
pause