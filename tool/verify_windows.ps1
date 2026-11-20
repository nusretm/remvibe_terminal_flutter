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
        # Generate only when missing. Never create a second checkout.
        if (-not (Test-Path '.\windows\CMakeLists.txt')) {
            flutter create . --platforms=windows
        }
        flutter pub get
        flutter analyze
        flutter test
        Write-Host 'TERM-01G-C Windows Debug: two real ConPTY panes; toggle mirror; detach/reattach'
        flutter run -d windows
    } finally {
        Pop-Location
    }
} finally {
    Pop-Location
}
