Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Users\agung\Downloads\logo-purwa-digital.png"
$bmp = [System.Drawing.Bitmap]::FromFile($srcPath)

$width = $bmp.Width
$height = $bmp.Height

$minX = $width
$minY = $height
$maxX = 0
$maxY = 0

# Find bounding box of visible/non-white content
for ($y = 0; $y -lt $height; $y++) {
    for ($x = 0; $x -lt $width; $x++) {
        $pixel = $bmp.GetPixel($x, $y)
        # Check if pixel is not fully transparent and not pure white
        if ($pixel.A -gt 20 -and ($pixel.R -lt 245 -or $pixel.G -lt 245 -or $pixel.B -lt 245)) {
            if ($x -lt $minX) { $minX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}

# Fallback if bounding box not found
if ($minX -ge $maxX -or $minY -ge $maxY) {
    $minX = [int]($width * 0.1)
    $minY = [int]($height * 0.1)
    $maxX = [int]($width * 0.9)
    $maxY = [int]($height * 0.9)
}

# Add small 2% padding
$cropW = $maxX - $minX + 1
$cropH = $maxY - $minY + 1

$padX = [int]($cropW * 0.03)
$padY = [int]($cropH * 0.03)

$cropX = [Math]::Max(0, $minX - $padX)
$cropY = [Math]::Max(0, $minY - $padY)
$cropW = [Math]::Min($width - $cropX, $cropW + ($padX * 2))
$cropH = [Math]::Min($height - $cropY, $cropH + ($padY * 2))

# Create cropped bitmap
$rect = [System.Drawing.Rectangle]::new($cropX, $cropY, $cropW, $cropH)
$croppedBmp = $bmp.Clone($rect, $bmp.PixelFormat)
$bmp.Dispose()

# Create target square canvas (e.g. 512x512)
$canvasSize = 512
$targetBmp = [System.Drawing.Bitmap]::new($canvasSize, $canvasSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($targetBmp)

$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# Calculate scale to fit 92% of square canvas (Zoomed in!)
$targetSize = [int]($canvasSize * 0.92)
$scale = [Math]::Min($targetSize / $cropW, $targetSize / $cropH)

$drawW = [int]($cropW * $scale)
$drawH = [int]($cropH * $scale)

$drawX = [int](($canvasSize - $drawW) / 2)
$drawY = [int](($canvasSize - $drawH) / 2)

$g.Clear([System.Drawing.Color]::Transparent)
$g.DrawImage($croppedBmp, $drawX, $drawY, $drawW, $drawH)

$croppedBmp.Dispose()
$g.Dispose()

# Save cropped & zoomed image to assets/images/logo.png
$outPath = "e:\apps\purwa-digital\purwa-digital\assets\images\logo.png"
$targetBmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)

Write-Host "Cropped and zoomed logo saved to $outPath successfully!"

# Also update mipmap Android launcher icons with zoomed logo
$resDir = "e:\apps\purwa-digital\purwa-digital\android\app\src\main\res"
Get-ChildItem -Path $resDir -Filter "mipmap-*" | ForEach-Object {
    $dest = Join-Path $_.FullName "ic_launcher.png"
    Copy-Item -Path $outPath -Destination $dest -Force
    Write-Host "Updated $dest"
}

$targetBmp.Dispose()
