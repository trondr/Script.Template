# SetWallPaperWithTextLibrary.ps1 1.0.16212.1
# 
# Copyright (C) 2016 github.com/trondr
#
# All rights reserved.
# 
# License: New BSD (https://github.com/trondr/Script.Template/blob/master/LICENSE.md)
#
Set-StrictMode -Version Latest
# User specified functions for use in the main script can be defined in this file.


function GetMagickNETDll
{
    $magickNETDll = [System.IO.Path]::Combine($global:scriptFolder,"Libs","Magick.NET-Q16-AnyCPU.dll")
    Write-Verbose "magickNETDll: $magickNETDll"
    return $magickNETDll
}
###############################################################################
#
#   Inline C#.NET class for writing text to image and setting wallpaper
#
###############################################################################
$desktopOperationsClass = @'
using System;
using System.IO;
using System.Runtime.InteropServices;
using ImageMagick;
using Microsoft.Win32;
using log4net;

namespace Desktop
{
    public class DesktopOperations
    {

        public static ILog Logger
        {
            get
            {
                if(_logger == null)
                {
                    _logger = LogManager.GetLogger("DesktopOperations"); 
                }   
                return _logger;
            }
        }
        private static ILog _logger;

        private const int SetDesktopWallpaper = 20;
        private const int UpdateIniFile = 0x01;
        private const int SendWinIniChange = 0x02;
        [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        private static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
        public static void SetWallpaper(string path, WallPaperStyle wallPaperStyle)
        {            
            Logger.InfoFormat("Setting wallpaper '{0}' ({1})...", path, wallPaperStyle);
            var subKeyPath = "Control Panel\\Desktop";
            using (var key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true))
            {
                if (key != null)
                {
                    key.SetValue(@"WallpaperStyle", Convert.ToString((int)wallPaperStyle));
                    key.SetValue(@"TileWallpaper", "0");                    
                    key.Close();
                }
                else
                {
                    Console.WriteLine("Failed to set wall paper. Registry key not found: HKCU\\" + subKeyPath);
                }
            }
            SystemParametersInfo(SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange);
            Logger.InfoFormat("Finisihed setting wallpaper '{0}' ({1})!", path, wallPaperStyle);
        }

        public static void WriteTextOnImage(string targetFile, string text, string fontFamily, double fontSize, FontStyleType fontStyle, FontWeight fontWeight, FontStretch fontStretch,  MagickColor borderColor, MagickColor fillColor, double positionX, double positionY)
        {            
            Logger.InfoFormat("Writing text '{0}' to wallpaper '{1}'...", text, targetFile);
            using (var image = new MagickImage(new FileInfo(targetFile)))
            {
                var drawables = new Drawables();
                drawables.Font(fontFamily, fontStyle, fontWeight, fontStretch);
                drawables.BorderColor(borderColor);
                drawables.FillColor(fillColor);
                drawables.FontPointSize(fontSize);
                drawables.Text(positionX, positionY, text);
                image.Draw(drawables);
                image.Write(targetFile);
            }
            Logger.InfoFormat("Finished writing text '{0}' to wallpaper '{1}'!", text, targetFile);
        }
    }

    public enum WallPaperStyle : int
    {
        Center = 1,
        Stretch = 2
    }
}
'@
$log4NetDll = GetLog4NetDll
$magickNETDll = GetMagickNETDll
$SystemDrawingDll = "System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"

$referencedAssemblies = "$log4NetDll", "$magickNETDll", $SystemDrawingDll

Write-Host "RreferencedAssemblies: $referencedAssemblies"
Add-Type -TypeDefinition $desktopOperationsClass -Language CSharp -ReferencedAssemblies $referencedAssemblies
$assembly = LoadLibrary $magickNETDll

###############################################################################
#
#   Functions using the inline C# class
#
###############################################################################

function WriteTextOnImage
{
     param(
            [Parameter(Mandatory=$true)]
            $targetFile,
            [Parameter(Mandatory=$true)]
            $text,
            
            $fontFamily = 'Arial',
                        
            $fontSize = 40,
            
            [ValidateSet('Undefined','Normal','Italic','Oblique','Any')]
            $fontStyle = 'Normal',

            [ValidateSet('Black','Bold','DemiBold','ExtraBold','ExtraLight','Heavy','Light','Medium','Normal','Regular','SemiBold','Thin','UltraBold','UltraLight','Undefined')]
            $fontWeight = 'Bold',
            
            [ValidateSet('Undefined', 'Normal', 'UltraCondensed', 'ExtraCondensed', 'Condensed', 'SemiCondensed', 'SemiExpanded', 'Expanded', 'ExtraExpanded', 'UltraExpanded', 'Any' )]
            $fontStretch = 'Normal',
            
            $borderColor = 'Black',
            
            $fillColor = 'White',
            
            $positionX = 100,
            
            $positionY = 100
        )    
    [Desktop.DesktopOperations]::WriteTextOnImage($targetFile, $text, $fontFamily, $fontSize, $fontStyle, $fontWeight, $fontStretch, $borderColor, $fillColor, $positionX, $positionY)
}

function SetWallPaper
{
    param(
            [Parameter(Mandatory=$true)]
            $path,
        
            [ValidateSet('Center', 'Stretch')]
            $style = 'Stretch'
        )
    [Desktop.DesktopOperations]::SetWallpaper($path, $style)
}