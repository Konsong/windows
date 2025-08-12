# Sysprep'i engelleyen varsayılan UWP uygulamalarını kaldır
$apps = @(
    "Microsoft.BingNews",
    "Microsoft.BingWeather",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.MixedReality.Portal",
    "Microsoft.Office.OneNote",
    "Microsoft.People",
    "Microsoft.SkypeApp",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsCamera",
    "Microsoft.WindowsMaps",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.YourPhone",
    "Microsoft.MSPaint",
    "Microsoft.ScreenSketch"
)

foreach ($app in $apps) {
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -EQ $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# Sysprep'in takılmasına neden olabilecek tüm Appx paketlerini kaldır

# 1. Mevcut kullanıcılar için kaldır
Get-AppxPackage -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

# 2. Provisioned paketleri kaldır
Get-AppxProvisionedPackage -Online | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

# 3. Staged (yarım yüklenmiş) paketleri kaldır
Get-AppxPackage -AllUsers | Where-Object {$_.InstallLocation -like "*WindowsApps*"} | ForEach-Object {
    Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue
}

# 4. Kısmi Appx kayıtlarını silmek için AppRepository klasörünü temizle
Stop-Service StateRepository -Force
Stop-Service AppXSvc -Force

$repo = "C:\ProgramData\Microsoft\Windows\AppRepository"
takeown /f $repo /r /d y
icacls $repo /grant administrators:F /t

Remove-Item "$repo\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\ProgramData\Microsoft\Windows\AppRepository\*" -Recurse -Force
Write-Host "Tüm AppX paketleri ve AppRepository temizlendi. Sysprep tekrar denenebilir."

