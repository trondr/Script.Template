@REM 
@REM Copyright (C) 2016 github.com/trondr
@REM
@REM All rights reserved.
@REM 
@REM License: New BSD (https://github.com/trondr/Script.Template/blob/master/LICENSE.md)
@REM
@REM ###############################################################################
@REM #
@REM #   START: Shell script - DO NOT CHANGE
@REM #
@REM ###############################################################################
@Echo Off
@Echo ------------------------------------------------------------------------
@Echo Start: Preparing to run powershell script
@Echo ------------------------------------------------------------------------
Set ScriptFolder=%~dp0
Set ScriptName=%~n0
Set PowerShellScript=%ScriptFolder%%ScriptName%.ps1
@Echo PowerShellScript=%PowerShellScript%
REM @Echo Verifying that powershell script "%PowerShellScript%" exists
IF EXIST "%PowerShellScript%" ( 
		REM @Echo Powershell script was found
	) ELSE (
		@Echo Powershell script was not found
		Goto MISSINGPOWERSHELLSCRIPT
	)
@Set LocalScriptFolder=%TEMP%\Script.Template.%ScriptName%
@Echo Copy Powershell script and libraries to local folder: %LocalScriptFolder%
REM @Echo XCOPY "%ScriptFolder%" "%LocalScriptFolder%" /S /I /Q /Y
XCOPY "%ScriptFolder%*.*" "%LocalScriptFolder%" /S /I /Q /Y

@Echo ------------------------------------------------------------------------
@Echo Run Powershell script from local directory
@Echo ------------------------------------------------------------------------
@Set LocalPowershellScript=%LocalScriptFolder%\%ScriptName%.ps1
REM @Echo Verifying that local powershell script "%LocalPowershellScript%" exists
IF EXIST "%LocalPowershellScript%" ( 
		REM @Echo Powershell script was found
	) ELSE (
		@Echo Powershell '%LocalPowershellScript%' script was not found
		Goto MISSINGPOWERSHELLSCRIPT
	)
REM @Echo Powershell.exe -ExecutionPolicy Unrestricted -NonInteractive -NoProfile -Command "& { "%LocalPowershellScript%" -arg1 \"%1\" -arg2 \"%2\" -arg3 \"%3\" -arg4 \"%4\" -arg5 \"%5\" -arg6 \"%6\" -arg7 \"%7\" -arg8 \"%8\" -arg9 \"%9\"; exit $LastExitCode; }"
Powershell.exe -ExecutionPolicy Unrestricted -NonInteractive -NoProfile -Command "& { "%LocalPowershellScript%" -arg1 \"%1\" -arg2 \"%2\" -arg3 \"%3\" -arg4 \"%4\" -arg5 \"%5\" -arg6 \"%6\" -arg7 \"%7\" -arg8 \"%8\" -arg9 \"%9\"; exit $LastExitCode; }"
@Set EXITCODE=%ERRORLEVEL%
@Echo Powershell script exited with exitcode %EXITCODE%

:CLEANUP
IF "%LocalScriptFolder%" NEQ "" (
		@Echo Cleaning up local directory: %LocalScriptFolder%
		REM @Echo RD "%LocalScriptFolder%" /S /Q
		RD "%LocalScriptFolder%" /S /Q
	) ELSE (
		@Echo Failed to cleanup local directory
	)
IF %EXITCODE% GTR 0 GOTO  FAILED
IF %EXITCODE% EQU 0 GOTO  SUCCESS
	
:MISSINGPOWERSHELLSCRIPT
@Echo Powershell script must exist in the same folder and have the same base name '%ScriptName%.ps1' as this batch script '%ScriptName%.cmd'
@Set EXITCODE=1
goto FAILED

:FAILED
@Echo ------------------------------------------------------------------------
@Echo Stop: Script returned with exit code %EXITCODE%
@Echo ------------------------------------------------------------------------
EXIT /B %EXITCODE%

:SUCCESS
@Echo ------------------------------------------------------------------------
@Echo Stop: Script returned with exit code %EXITCODE%
@Echo ------------------------------------------------------------------------
EXIT /B %EXITCODE%
@REM ###############################################################################
@REM #
@REM #   STOP: Shell script - DO NOT CHANGE
@REM #
@REM ###############################################################################
