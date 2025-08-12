# Sysprep'i engelleyen bilinen UWP uygulamalar listesi
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
    "Microsoft.ScreenSketch",
    "Microsoft.WindowsCalculator"   # Log'da geçen problemli uygulama
)

foreach ($app in $apps) {
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like "*$app*" } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# Tüm kullanıcılar için tüm AppX paketlerini kaldır
Get-AppxPackage -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

# Provisioned paketleri kaldır
Get-AppxProvisionedPackage -Online | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

# Staged paketleri kaldır
Get-AppxPackage -AllUsers | Where-Object {$_.InstallLocation -like "*WindowsApps*"} | ForEach-Object {
    Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue
}

# AppRepository klasörünü temizle
Stop-Service StateRepository -Force
Stop-Service AppXSvc -Force

$repo = "C:\ProgramData\Microsoft\Windows\AppRepository"
takeown /f $repo /r /d y
icacls $repo /grant administrators:F /t

Remove-Item "$repo\*" -Recurse -Force -ErrorAction SilentlyContinue

# Servisleri yeniden başlat
Start-Service StateRepository
Start-Service AppXSvc

Write-Host "Tüm AppX paketleri ve AppRepository temizlendi. Sysprep tekrar denenebilir."
