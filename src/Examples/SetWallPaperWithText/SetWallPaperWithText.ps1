# SetWallPaperWithText.ps1 1.0.16212.1
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
$global:VerbosePreference = "Continue"
$global:DebugPreference = "SilentlyContinue"
$global:WarningPreference = "Continue"
$global:ErrorActionPreference = "Continue"
$global:ProgressPreference = "Continue"

###############################################################################
#
#   Your code below this line
#
###############################################################################

$scriptVersion = "1.0.16212.1"

function Run
{
	$exitCode = 0    
    Try
    {
        $wallPaperImageFile = [System.IO.Path]::GetFullPath($arg1)
        Write-Host "WallPaper image file: $wallPaperImageFile"

        $fileWithText = [System.IO.Path]::GetFullPath($arg2)
        Write-Host "File with text: $fileWithText"
                
        $baseImageName = [System.IO.Path]::GetFileName($wallPaperImageFile)
        $tempWallPaperFolder = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyPictures),"Temp")
        $directory = [System.IO.Directory]::CreateDirectory($tempWallPaperFolder)
        $wallPaperImageEditedFile = [System.IO.Path]::Combine($tempWallPaperFolder, $baseImageName)
                
        $text = Get-Content $fileWithText | out-string
        Write-Host "$text"
        [System.IO.File]::Copy($wallPaperImageFile, $wallPaperImageEditedFile, $true);

        WriteTextOnImage $wallPaperImageEditedFile "$text"
        SetWallPaper $wallPaperImageEditedFile Stretch
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