# Script.Template 1.0.17061.4
# 
# Copyright (C) 2016-2017 github.com/trondr
#
# All rights reserved.
# 
# License: New BSD (https://github.com/trondr/Script.Template/blob/master/LICENSE.md)

param ($arg1, $arg2, $arg3, $arg4, $arg5, $arg6, $arg7, $arg8, $arg9)

Set-StrictMode -Version Latest

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
#   Log folder preference
#
#      $false : Store logs in "<scriptfolder>\Logs"
#      $true  : Store logs in "%Public%\Logs\<script name>"
#
###############################################################################
$global:storeLogFilesInPublicLogsFolder = $false

###############################################################################
#
#   Your code below this line
#
###############################################################################
#[System.DateTime]::Now.DayOfYear
$global:scriptVersion = "1.0.17080.1"

function Run
{    
	$exitCode = 0
	
    Try
    {        
        $scriptFolder = GetRemoteScriptFolder
        $rootFolder = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($scriptFolder, ".."))
        $templateScriptFolder = [System.IO.Path]::Combine($rootFolder, "Script.Template")
        LogInfo "Creating new script from template '$templateScriptFolder'..."
        LogInfo "Getting script name"
        $newScriptName = GetScriptNameFromUser
        if([System.String]::IsNullOrEmpty($newScriptName) -eq $true)
        {
            LogWarning "User canceled or specified script name is empty"
            $exitCode = 1223
            return $exitCode
        }

        $newScriptFolder = [System.IO.Path]::Combine($rootFolder, $newScriptName)
                            
        $exitCode = ResolveScriptTemplate $templateScriptFolder $newScriptFolder $newScriptName
    }
    Catch
    {        
        $errorMessage = $_.Exception.Message        
        $exceptionName = $_.Exception.GetType().FullName
        LogError "Powershell script failed. Exception: $exceptionName. Error message: $errorMessage Line: $($_.InvocationInfo.ScriptLineNumber) Script: $($_.InvocationInfo.ScriptName)"
        $exitCode = 1
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
$scriptTemplateLibrary = [System.IO.Path]::Combine([System.IO.Path]::Combine($scriptFolder, "Libs"), "Script.Template.Library.ps1")
if((Test-Path $scriptTemplateLibrary) -eq $false)
{
    Write-Host -ForegroundColor Red "Script template library '$scriptTemplateLibrary' not found."
    EXIT 1
}
Write-Verbose "Loading and running script template library '$scriptTemplateLibrary'..."
. $scriptTemplateLibrary
If ($? -eq $false) 
{ 
    Write-Host -ForegroundColor Red "Failed to load script template library '$scriptTemplateLibrary'. Error: $($error[0])"; break 
    EXIT 1
};
exit $global:scriptExitCode

###############################################################################
#
#   End: Main Script - DO NOT CHANGE
#
###############################################################################