$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

Push-Location $root
try {
    flutter pub get
    flutter analyze
    flutter test

    Push-Location (Join-Path $root 'example')
    try {
        # Platform runner generated inside the SAME repository checkout.
        flutter create . --platforms=windows
        flutter pub get
        flutter analyze
        Write-Host 'TERM-01G-C Windows Debug: two real ConPTY panes; toggle mirror; detach/reattach'
        flutter run -d windows
    } finally {
        Pop-Location
    }
} finally {
    Pop-Location
}
