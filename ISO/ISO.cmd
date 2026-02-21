@echo off

rem script:		@rgadguard
rem version:	v1.03.2

setlocal EnableExtensions
setlocal EnableDelayedExpansion

color 0a

:BIN
cd /d "%~dp0"
if exist "%~dp0bin\7z.exe" (set "x7z=%~dp0bin\7z.exe") else (goto :DLBin)
if not exist "%~dp0bin\7z.cmd" goto :DLBin
if not exist "%~dp0bin\7z.dll" goto :DLBin
if exist "%~dp0bin\aria2c.exe" (set "aria2=%~dp0bin\aria2c.exe") else (goto :DLBin)
if not exist "%~dp0bin\smv.cmd" goto :DLBin
if exist "%~dp0bin\smv.exe" (set "smv=%~dp0bin\smv.exe") else (goto :DLBin)

call :sup
call :tr

set "uuid=e425afa0-8d3c-e13d-a78a-1875c7c36ad6"
set "key=free"

if /i !key! EQU free call :free
color 0a
title Select list files...

"%aria2%" -x1 -s1 -d"%dir_temp%" -o"list.txt" "https://files.rg-adguard.net/file/%uuid%/list" --disable-ipv6
for /f "tokens=1 delims=" %%a in ('type "%dir_temp%\list.txt"') do set /a count+=1

:ListFiles
cls
set ListSel=
echo.
echo %r%
echo The list of files that will be uploaded during operation...
echo %r%
echo.
for /f "tokens=2,3 delims=^|" %%a in ('type "%dir_temp%\list.txt"') do (
	echo %%a   ^(%%b^)
)
echo.
echo %r%
if /i %count% NEQ 1 (
	echo 	Save all files				- press key S
	echo 	Save only the requested file		- press key F
) else (
	echo	Enter F or S to continue downloading files
)
echo %r%
echo.
rem === AUTO SELECT F (Save requested file only) ===
set ListSel=F
goto :working

:working
title Download files...
cls
"%aria2%" -x1 -s1 -d"%dir_temp%" -o"dl.txt" "https://files.rg-adguard.net/dl/%key%/%uuid%" --disable-ipv6
"%aria2%" -x1 -s1 -j1 -c -R -d"%cd%" -i"%dir_temp%\dl.txt" --disable-ipv6
if exist "%~dp0tmp\*.aria2" (
    erase /q "%dir_temp%\dl.txt"
    echo Re-download, after 10 seconds...
    timeout /t 10 /NOBREAK
	goto :working
)
call bin\7z.cmd
call bin\smv.cmd
goto :exit

:DLBin
for /f "tokens=3 delims=:. " %%f in ('bitsadmin.exe /CREATE /DOWNLOAD "Download Tools" ^| findstr "Created job"') do set GUID=%%f
title Download tools...
bitsadmin /transfer %GUID% /download /priority foreground https://files.rg-adguard.net/tools "%cd%\tools.cab"
if NOT EXIST tools.cab goto :Error 4
expand "tools.cab" -f:* .\ >nul
del /f /q tools.cab >nul 2>&1
goto :BIN

:sup
set "dir_temp=%~dp0%random%"
set xOS=x86
if exist "%WINDIR%\SysWOW64" Set xOS=x64
if exist "%WINDIR%\SysArm32" Set xOS=a64

for /f "tokens=6 delims=[]. " %%# in ('ver') do set xBuild=%%#
if %xOS% NEQ x64 goto :Error 1
if %xBuild% LSS 6000 goto :Error 2
exit /b

:Error
cls
color 4f
echo.
echo %r%
echo.
echo.
if %1==1 echo                      Attention, the script only works with a 64-bit system.
if %1==2 echo           For the script to work, the operating system Windows Vista or higher is required.
if %1==3 echo                            There are not enough files in the bin folder.
if %1==4 echo                               Failed to download the software package.
echo.
echo.
echo %r%
echo.
echo.
pause
exit

:limit
title LIMIT DOWNLOAD
cls
color 4f
echo.
echo %r%
echo.
echo                                                LIMIT DOWNLOAD
echo.
echo                           You have exceeded the limit of simultaneous connections.
echo                      During the free download, no more than 1 connection is available.
echo.
echo %r%
echo.
pause
echo.
exit

:free
title THIS BANNER IS A WARNING
cls
color 4f
echo.
echo %r%
echo.
echo                                           THIS BANNER IS A WARNING
echo.
echo                                      You have used the free download.
echo                                    The download speed will be limited. 
echo            If you want to download multiple files at maximum speed and with the possibility
echo                  of downloading them at once, you need to purchase a subscription.
echo.
echo %r%
echo.
echo                              This message is available within a few seconds.
echo.
timeout /t 10 /NOBREAK
echo.
exit /b

:exit
set fnd=n
title Finish...
cls
echo.
echo %r%
echo.
echo                                        The script is finished.
echo                All the files you received are files, you will find them next to the script.
echo.
echo                                      Here is the list of files:
echo %t%
echo.
exit

:tr
set "r=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^=^="
set "t=----------------------------------------------------------------------------------------------------"
goto :eof

