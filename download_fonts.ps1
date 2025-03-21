$fonts = @{
    "PressStart2P-Regular.ttf" = "https://github.com/google/fonts/raw/main/ofl/pressstart2p/PressStart2P-Regular.ttf"
    "VT323-Regular.ttf" = "https://github.com/google/fonts/raw/main/ofl/vt323/VT323-Regular.ttf"
}

foreach ($font in $fonts.GetEnumerator()) {
    $outputPath = "assets/fonts/$($font.Key)"
    Write-Host "Downloading $($font.Key)..."
    Invoke-WebRequest -Uri $font.Value -OutFile $outputPath
}
