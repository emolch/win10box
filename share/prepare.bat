call schtasks /delete /f /tn "OneDrive Standalone Update Task-S-1-5-21-3461203602-4096304019-2269080069-1000"
call copy "z:\fixpolicy.bat" "c:\fixpolicy.bat"
REM call schtasks /create /sc MINUTE /rl HIGHEST /tn "fixpolicy_h" /tr "c:\fixpolicy.bat"
REM call schtasks /create /sc ONSTART /delay 0000:15 /rl HIGHEST /tn "fixpolicy_s" /tr "c:\fixpolicy.bat"
call powershell -File z:\prepare.ps1
call wmic useraccount where name='IEUser' rename 'vagrant'
call net user vagrant vagrant
pause

