$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
flutter create . --project-name nexasoft_incidencias --platforms android,web,windows
flutter pub get
Write-Host 'Preparación terminada. Ejecuta flutter devices y flutter run -d chrome'
