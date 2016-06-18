# Script.Template 1.0.16171.0
# 
# Copyright (C) 2016 github.com/trondr
#
# All rights reserved.
# 
# License: New BSD (https://github.com/trondr/Script.Template/blob/master/LICENSE.md)
#

param ($arg1, $arg2, $arg3, $arg4, $arg5, $arg6, $arg7, $arg8, $arg9)

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
#   Your code below this line
#
###############################################################################

$global:scriptVersion = "1.0.16171.0"

function Run
{    
	$exitCode = 0
	
    Try
    {
        Write-Host "Example. Your script code here."
        Write-Host "Example. Input arguments: arg1=$arg1, arg2=$arg2, arg3=$arg3, arg4=$arg4, arg5=$arg5, arg6=$arg6, arg7=$arg7, arg8=$arg8, arg9=$arg9"
        $dayOfYear = [System.DateTime]::Now.DayOfYear
        $logger.Info("Example. info message written to log file. Day of year: $dayOfYear")
        $logger.Warn("Example. warning message written to log file")
        $logger.Error("Example. error message written to log file")        
        SomeExampleUserFunctionThrowsError
    }
    Catch
    {
        
        $errorMessage = $_.Exception.Message        
        $exceptionName = $_.Exception.GetType().FullName
        $logger.Error("Example. Powershell script failed. Exception: $exceptionName. Error message: $errorMessage")
        $exitCode = 2
    }
    
	return $exitCode
}
###############################################################################
#
#   Your code above this line
#
###############################################################################


###############################################################################
#
#   Start: Main Script - DO NOT CHANGE
#
###############################################################################

###############################################################################
#
#   Loading template script library, that:
#
#      1. Configures logging
#      2. Loads user script library
#      3. Executes Run function
#
###############################################################################

$global:script = $MyInvocation.MyCommand.Definition
$global:scriptFolder = Split-Path -Parent $script
$scriptLibrary = [System.IO.Path]::Combine($scriptFolder, "Libs", "Script.Template.Library.ps1")
if((Test-Path $scriptLibrary) -eq $false)
{
    Write-Host -ForegroundColor Red "Script library '$scriptLibrary' not found."
    EXIT 1
}
Write-Verbose "Loading and running script library '$scriptLibrary'..."
. $scriptLibrary
If ($? -eq $false) 
{ 
    Write-Host -ForegroundColor Red "Failed to load library '$scriptLibrary'. Error: $($error[0])"; break 
    EXIT 1
};
exit $global:scriptExitCode

###############################################################################
#
#   End: Main Script - DO NOT CHANGE
#
###############################################################################