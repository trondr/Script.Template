# Script.Template 1.0.17060.3
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

$global:scriptVersion = "1.0.17060.3"

function Run
{    
	$exitCode = 0
	
    Try
    {        
        LogInfo "Example. Your script code here."
        LogInfo "Example. Input arguments: arg1=$arg1, arg2=$arg2, arg3=$arg3, arg4=$arg4, arg5=$arg5, arg6=$arg6, arg7=$arg7, arg8=$arg8, arg9=$arg9"
        $dayOfYear = [System.DateTime]::Now.DayOfYear
        LogInfo "Example. info message written to log file. Day of year: $dayOfYear"
        LogWarning "Example. warning message written to log file"
        LogError "Example. error message written to log file"
        LogDebug "Example. debug message written to log file"        
        LogFatal "Example. fatal message written to log file"
        
        #Get localized message for en-US
        $culture = [System.Globalization.CultureInfo]::GetCultureInfo('en-US')
        $helloMessage = (GetMessage $culture "Hello_F1" "Default Hello {0}") -f "Ola"        
        LogInfo $helloMessage
        $byeMessage = (GetMessage $culture "Goodbye" "Default Goodbye")
        LogInfo $byeMessage

        #Get localized message for nb-NO
        $culture = [System.Globalization.CultureInfo]::GetCultureInfo('nb-NO')
        $helloMessage = (GetMessage $culture "Hello_F1" "Default Hello {0}") -f "Ola"        
        LogInfo $helloMessage
        $byeMessage = (GetMessage $culture "Goodbye" "Default Goodbye")
        LogInfo $byeMessage

        #Get localized message for sv-SE 
        #Localized message file does not exist for sv-SE, so default message file will be used
        $culture = [System.Globalization.CultureInfo]::GetCultureInfo('sv-SE')
        $helloMessage = (GetMessage $culture "Hello_F1" "Default Hello {0}") -f "Ola"        
        LogInfo $helloMessage
        $byeMessage = (GetMessage $culture "Goodbye" "Default Goodbye")
        LogInfo $byeMessage
        
        SomeExampleUserFunctionThrowsError
    }
    Catch
    {        
        $errorMessage = $_.Exception.Message        
        $exceptionName = $_.Exception.GetType().FullName
        LogError "Example. Powershell script failed. Exception: $exceptionName. Error message: $errorMessage Line: $($_.InvocationInfo.ScriptLineNumber) Script: $($_.InvocationInfo.ScriptName)"
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