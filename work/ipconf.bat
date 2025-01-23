@echo off

:: A script that displays `ipconfig /all` for only relevant interfaces. That is, non-virtual ones that are also up.

REM TODO: Is there a better way to know how many lines to display?

REM Check if Ethernet is plugged in, show powershell output if so
netsh interface show interface name="Ethernet" ^
 | find "Connect state" ^
 | find "Connected">nul ^
  && powershell.exe -NoLogo -NonInteractive -Command "ipconfig /all | Select-String -Pattern Ethernet: -Context 0,20" ^
  || echo Ethernet not connected


REM Check if Wi-Fi is connected, show powershell output if so
netsh interface show interface name="Wi-Fi" ^
 | find "Connect state" ^
 | find "Connected">nul ^
  && powershell.exe -NoLogo -NonInteractive -Command "ipconfig /all | Select-String -Pattern Wi-Fi: -Context 0,20" ^
  || echo Wi-Fi not connected

