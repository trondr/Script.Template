# Script.Template 1.0.16163.1
# 
# Copyright (C) 2016 github.com/trondr
#
# All rights reserved.
# 
# License: New BSD (https://github.com/trondr/Script.Template/blob/master/LICENSE.md)
#

param ($arg1, $arg2, $arg3, $arg4, $arg5, $arg6, $arg7, $arg8, $arg9)

$scriptVersion = "1.0.16163.0"

function Run
{    
	$exitCode = 0
	
    Try
    {
        Write-Host "Example. Your script code here."
        Write-Host "Example. Input arguments: arg1=$arg1, arg2=$arg2, arg3=$arg3, arg4=$arg4, arg5=$arg5, arg6=$arg6, arg7=$arg7, arg8=$arg8, arg9=$arg9"
        $logger.Info("Example. info message written to log file")
        $logger.Warn("Example. warning message written to log file")
        $logger.Error("Example. error message written to log file")
        SomeExampleUserFunctionThrowsError
    }
    Catch
    {
        
        $errorMessage = $_.Exception.Message        
        $exceptionName = $_.Exception.GetType().FullName
        $logger.Error("Powershell script failed. Exception: $exceptionName. Error message: $errorMessage")
        $exitCode = 1
    }
    
	return $exitCode
}

###############################################################################
#
#   Powershell logging preference
#
###############################################################################
$global:VerbosePreference = "SilentlyContinue"
$global:DebugPreference = "SilentlyContinue"
$global:WarningPreference = "Continue"
$global:ErrorActionPreference = "Continue"
$global:ProgressPreference = "Continue"

###############################################################################
#
#   Start: Main Script - DO NOT CHANGE
#
###############################################################################
$global:script = $MyInvocation.MyCommand.Definition
Write-Verbose "Script=$script"
$global:scriptFolder = Split-Path -Parent $script
Write-Verbose "ScriptFolder=$scriptFolder"
$global:scriptName = [System.IO.Path]::GetFileNameWithoutExtension($script)
Write-Verbose "ScriptName=$scriptName"

###############################################################################
#   Log file configuration
###############################################################################
$global:logFolder = [System.IO.Path]::Combine($env:PUBLIC, "Logs", $scriptName)
$userName = $env:USERNAME
$global:logFile = [System.IO.Path]::Combine($global:LogFolder, "$scriptName-$userName.log");

###############################################################################
#   Loading template script library
###############################################################################
$scriptLibrary = [System.IO.Path]::Combine($scriptFolder, "Libs", "Script.Template.Library.ps1")
if((Test-Path $scriptLibrary) -eq $false)
{
    Write-Host -ForegroundColor Red "Script library '$scriptLibrary' not found."
    EXIT 1
}
Write-Verbose "ScriptLibrary=$scriptLibrary"
Write-Verbose "Loading script library '$scriptLibrary'..."
. $scriptLibrary
If ($? -eq $false) 
{ 
    Write-Host -ForegroundColor Red "Failed to load library '$scriptLibrary'. Error: $($error[0])"; break 
    EXIT 1
};

###############################################################################
#   Loading user script library
###############################################################################
$scriptLibrary = [System.IO.Path]::Combine($scriptFolder ,"$($scriptName)Library.ps1")
if((Test-Path $scriptLibrary) -eq $false)
{
    Write-Host -ForegroundColor Red "Script library '$scriptLibrary' not found."
    EXIT 1
}
Write-Verbose "ScriptLibrary=$scriptLibrary"
Write-Verbose "Loading script library '$scriptLibrary'..."
. $scriptLibrary
If ($? -eq $false) 
{ 
    Write-Host -ForegroundColor Red "Failed to load library '$scriptLibrary'. Error: $($error[0])"; break 
    EXIT 1
};

###############################################################################
#   Run user script
###############################################################################
$global:commandLine = [System.Environment]::CommandLine
$logger.Info("Start: $scriptName $scriptVersion Command line: $commandLine");

$exitCode = ExecuteAction([scriptblock]$function:Run)

$logger.Info("Stop: $scriptName $scriptVersion Exit code: $exitCode");

exit $exitCode
###############################################################################
#
#   End: Main Script - DO NOT CHANGE
#
###############################################################################