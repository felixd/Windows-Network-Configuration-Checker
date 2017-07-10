:: (c) Outsourcing IT - Konopnickiej.Com - 07/12/2012 - Pawel Wojciechowski
:: "Windows Network Configuration Checker" script
:: =========================
:: Changes: 12/12/2012 v0.2
:: 	1. Mail sending function has been added.
:: =========================
:: Changes: 07/03/2013 v0.3
::  1. Script is now collecting all WLAN information (netsh wlan show all)
::  2. Changed mail subject - added Date and Time + Version
::		Example: [07/03/2013  9:36:11.23] - Network Configuration v0.3 - U: Pawel.Wojciechowski C: PLLPAWWOJ 
::  3. Removed "=" sign from Window title
::  4. Mail Body changed: 
::		* "on %DATE% %TIME%"  					-->> 	"on %DATE% at %TIME%"
:: =========================
:: Changes: 07/03/2013 - VERTU v0.4
:: 	1. Added new servers from VERTU network to be checked. (tracert/ping)
::		* SAP: ********.*******.nokia.com [***.***.***.***]
::		* NAS: *************.vertuint.com [***.***.***.***]
::	2. Cosmetic view changes
:: =========================
:: Changes: 21/03/2013 - VERTU v0.5
::  1. Script run DATE and TIME added to FILE NAME  
::    Time format: HHMM 
::    Example: NETCONF-2013-03-21_1145-Pawel.Wojciechowski-PLLPAWWOJ-v0.5
::  2. More Copyright information in E-mail/Results 
:: =========================
:: Changes: 21/03/2013 - VERTU v0.6
::  1. Script is grabbing PROXY configuration with Automatic Configuration Script Address (AutoConfURL), if set
:: =========================
:: Changes: 21/03/2013 - VERTU v0.7
::  1. gpresults /v - Displays the Resultant Set of Policy (RSoP) information for a User and Computer. 
:: =========================
:: Changes: 21/03/2013 - VERTU v0.8
::  1. arp -a - Displays cached ARP entries on user machine. (added after Macau network issue)
:: =========================
@echo off
color 1A

:: Convert date and time to format that can be used in File Name
:: Two variables:
::  - FILE_DATE - YYYY-MM-DD
::  - FILE_TIME - HH-MM
For /f "tokens=1-3 delims=/ " %%a in ('date /t') do (set FILE_DATE=%%c-%%b-%%a) 
For /f "tokens=1-2 delims=/:" %%a in ('time /t') do (set FILE_TIME=%%a%%b)

set VER=v1.0
set TOOL=Network Configuration Checker
set AUTHOR=Pawel Wojciechowski
set COPYRIGHT=Copyright (c) Outsourcing IT - Konopnickiej.Com

set FILE=NETCONF-%FILE_DATE%_%FILE_TIME%-%USERNAME%-%COMPUTERNAME%-%VER%.TXT
set FILEPATH=%~dp0%FILE%

set MAIL-TO=***YOUR_EMIAL@TEST.COM***
set MAIL-SUBJECT=%TOOL% %VER% - [%Date% %time%] - U: %USERNAME% C: %COMPUTERNAME% 
set MAIL-BODY=Dear Service Desk %%0D%%0A %%0D%%0A Those are my results from %TOOL% %VER% script. Please note that attached file is also saved on my computer:%%0D%%0A * %FILEPATH% %%0D%%0A Regards, %USERNAME% %%0D%%0A %%0D%%0A -- %%0D%%0A Created by %TOOL% %VER% on %DATE% at %TIME% %%0D%%0A Copyright: %COPYRIGHT% %%0D%%0A Author: %AUTHOR% %%0D%%0A --

title %COPYRIGHT% - %TOOL% %VER% 

 echo Copyright: %COPYRIGHT%
 echo Author: %AUTHOR%
 echo Tool: %TOOL% %VER%
 echo Script started: %date% %time%
echo[
 echo Hello %USERNAME%
 echo This tool will collect all network configuration needed by Service Desk
echo[
 echo All results will be saved under below location:
echo[
 echo Folder: %~dp0
 echo File:   %FILE%
echo[
 echo Checking network configuration. This can take some minutes...

::# Default Gateway variable
@For /f "tokens=3" %%* in (
   'route.exe print ^|findstr "\<0.0.0.0\>"'
   ) Do @Set "DefaultGateway=%%*"
   
:: #AutoConfURL - collecting information @> "%FILE%" 

@FOR /f "tokens=*" %%a in ('"reg query "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" | find /i "AutoConfigURL" "'
 ) DO ( 
set AutoConfigURL=%%a
 ) 

::# Redirect output to a textfile

@> "%FILE%" (
  echo Copyright: "%COPYRIGHT%"
  echo Author: %AUTHOR%
  echo Tool: %TOOL% %VER%
 echo[
  echo User name: %username%
  echo Computer name: %computername%
  echo Results: %FILEPATH%
 echo[
  echo [%Date% %time%] - IPCONFIG /all
   ipconfig /all
  echo [%Date% %time%] - ROUTING
   route print
 echo[
  echo [%DATE% %TIME%] - PROXY settings 
 echo[
  IF ["%AutoConfigURL%"]==[""] ( echo AutoConfigURL is not set. 
   ) ELSE ( 
  echo I've found %AutoConfigURL%
  )
 echo[
   reg query "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" | find /i "Proxy"
 echo[
  echo [%Date% %time%] - PING DefaultGateway
  ping %DefaultGateway%
  echo [%Date% %time%] - PING GOOGLE
  ping google.com
  echo [%Date% %time%] - TRACERT GOOGLE [8.8.8.8]
  tracert -w 100 -4 -h 15 8.8.8.8
 echo[
  echo [%Date% %time%] - =========== Checking COMPANY specific servers ============
 echo[ 
  echo [%Date% %time%] - SAP: 
 echo[ 
   ping **********.*******.nokia.com 
   ping ***.***.***.***.***
   tracert -w 100 -4 -h 15 ***.***.***.***.***
 echo[ 
   echo [%Date% %time%] - NAS: 
 echo[ 
   ping *********.******.nokia.com
   ping ***.***.***.***.***
   tracert -w 100 -4 -h 15 ***.***.***.***.***
 echo[
   echo [%Date% %time%] - =========== ARP - Start ============ 
 echo[
   arp -a
 echo[
   echo [%Date% %time%] - =========== ARP - End ===========
 echo[ 
   echo [%Date% %time%] - =========== GP Result ============
   gpresult /v
   echo [%Date% %time%] - =========== GP Result ============
 echo[ 
  echo [%Date% %time%] - =========== WLAN Information ============
 echo[ 
   netsh wlan show all
 echo[ 
  echo [%Date% %time%] - =========== WLAN Information ============
 echo[ 
  echo Script stopped: %Date% %time%
)

echo[
echo Finished. [ %date% %time% ]
echo[

echo Please send results to Service Desk - %MAIL-TO%
echo[
echo Results saved: %FILEPATH%
echo Press any key to create new e-mail (Outlook) with attached results.
pause
start outlook /c ipm.note /m "mailto:%MAIL-TO%?body=%MAIL-BODY%&subject=%MAIL-SUBJECT%" /a "%FILEPATH%"
exit
