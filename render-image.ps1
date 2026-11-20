Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'
$width = 1024
$height = 1024
$bitmap = [System.Drawing.Bitmap]::new($width, $height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

function Color([string]$hex) { [System.Drawing.ColorTranslator]::FromHtml($hex) }
function Brush([string]$hex) { [System.Drawing.SolidBrush]::new((Color $hex)) }
function Pen([string]$hex, [single]$size) { [System.Drawing.Pen]::new((Color $hex), $size) }
function Rounded([System.Drawing.Graphics]$g, [single]$x, [single]$y, [single]$w, [single]$h, [single]$r, [string]$fill) {
    $p = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $d = $r * 2
    $p.AddArc($x, $y, $d, $d, 180, 90)
    $p.AddArc(($x + $w - $d), $y, $d, $d, 270, 90)
    $p.AddArc(($x + $w - $d), ($y + $h - $d), $d, $d, 0, 90)
    $p.AddArc($x, ($y + $h - $d), $d, $d, 90, 90)
    $p.CloseFigure()
    $g.FillPath((Brush $fill), $p)
    $p.Dispose()
}
function Text([System.Drawing.Graphics]$g, [string]$value, [single]$x, [single]$y, [single]$size, [string]$hex, [bool]$bold = $false) {
    $style = if ($bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
    $font = [System.Drawing.Font]::new('Arial', $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
    $g.DrawString($value, $font, (Brush $hex), $x, $y)
    $font.Dispose()
}
function Line([System.Drawing.Graphics]$g, [string]$hex, [single]$size, [single]$x1, [single]$y1, [single]$x2, [single]$y2) {
    $p = Pen $hex $size
    $p.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $p.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawLine($p, $x1, $y1, $x2, $y2)
    $p.Dispose()
}
function Ellipse([System.Drawing.Graphics]$g, [string]$hex, [single]$x, [single]$y, [single]$w, [single]$h) {
    $g.FillEllipse((Brush $hex), $x, $y, $w, $h)
}

# Deep blue newspaper field and a hard-edged dateline.
$graphics.Clear((Color '#091522'))
$graphics.FillRectangle((Brush '#101F2E'), 0, 0, $width, 151)
$graphics.FillRectangle((Brush '#F5B84B'), 42, 34, 8, 82)
Text $graphics 'WORLD / DAILY FILE' 68 32 17 '#F5B84B' $true
Text $graphics 'THE DAY IN ONE IMAGE' 68 57 34 '#F7F3E9' $true
Rounded $graphics 758 41 222 70 18 '#F5B84B'
Text $graphics 'FRIDAY' 786 49 15 '#091522' $true
Text $graphics '20 NOV 2026' 786 72 23 '#091522' $true

$rows = @(
    @{ Y = 171; Tint = '#F0F4F2'; Accent = '#C84B3B'; Loc = 'KYIV  /  UKRAINE'; H1 = 'MISSILES HIT THREE BRIDGES'; H2 = '3 KILLED IN KYIV'; Note = 'Russian strikes hit crossings over the Dnipro.'; Art = 'city' },
    @{ Y = 373; Tint = '#EAF3F5'; Accent = '#147B98'; Loc = 'BAY OF BENGAL  /  INDIA'; H1 = 'CYCLONE AKVAN'; H2 = 'REACHES THE EAST COAST'; Note = 'Landfall near the Odisha-Andhra Pradesh coast.'; Art = 'storm' },
    @{ Y = 575; Tint = '#F7EFE0'; Accent = '#D26A33'; Loc = 'ANTALYA  /  COP31'; H1 = 'CLIMATE DRAFT'; H2 = 'DROPS FOSSIL-FUEL PHASE-OUT'; Note = 'Final-day talks open without phase-out language.'; Art = 'climate' },
    @{ Y = 777; Tint = '#F2EDF5'; Accent = '#6B5B91'; Loc = 'BANGLADESH  /  ROHINGYA CAMPS'; H1 = 'ROHINGYA REFUGEES'; H2 = 'WELCOME ICJ VERDICT'; Note = 'Many at the camps say they want to go home.'; Art = 'camp' }
)

foreach ($row in $rows) {
    $y = [single]$row.Y
    Rounded $graphics 40 $y 944 186 15 $row.Tint
    Rounded $graphics 40 $y 9 186 5 $row.Accent
    $graphics.FillRectangle((Brush '#DCE5E4'), 60, ($y + 17), 281, 152)
    $artX = 60; $artY = $y + 17

    if ($row.Art -eq 'city') {
        $graphics.FillRectangle((Brush '#B9D4DF'), $artX, $artY, 281, 82)
        $graphics.FillRectangle((Brush '#244559'), $artX, ($artY + 82), 281, 70)
        # Kyiv skyline above the Dnipro; the three scarlet lines mark damaged bridges.
        foreach ($building in @('76,58,31,24', '119,40,40,42', '177,52,37,30', '223,32,45,50', '274,61,28,21')) {
            $b = $building.Split(',') | ForEach-Object { [single]$_ }
            $graphics.FillRectangle((Brush '#486474'), $artX + $b[0] - 60, $artY + $b[1], $b[2], $b[3])
            $graphics.FillRectangle((Brush '#F0B85A'), $artX + $b[0] - 53, $artY + $b[1] + 8, 5, 5)
            $graphics.FillRectangle((Brush '#F0B85A'), $artX + $b[0] - 43, $artY + $b[1] + 8, 5, 5)
        }
        foreach ($bridgeY in @(101, 122, 143)) {
            Line $graphics '#E65A45' 5 67 ($artY + $bridgeY) 333 ($artY + $bridgeY)
            foreach ($px in @(93, 155, 217, 281)) { Line $graphics '#E65A45' 3 $px ($artY + $bridgeY) $px ($artY + 150) }
        }
        Line $graphics '#F7C765' 5 104 ($artY + 9) 177 ($artY + 56)
        Ellipse $graphics '#F27A51' 168 ($artY + 49) 14 14
    }
    elseif ($row.Art -eq 'storm') {
        $graphics.FillRectangle((Brush '#9ED3DE'), $artX, $artY, 281, 152)
        # Bay of Bengal spiral and the eastern Indian coastline.
        $coast = [System.Drawing.Point[]]@(
            [System.Drawing.Point]::new(278, $artY + 4), [System.Drawing.Point]::new(265, $artY + 26),
            [System.Drawing.Point]::new(269, $artY + 46), [System.Drawing.Point]::new(249, $artY + 62),
            [System.Drawing.Point]::new(258, $artY + 79), [System.Drawing.Point]::new(241, $artY + 96),
            [System.Drawing.Point]::new(251, $artY + 117), [System.Drawing.Point]::new(232, $artY + 151),
            [System.Drawing.Point]::new(281, $artY + 152), [System.Drawing.Point]::new(281, $artY + 4)
        )
        $graphics.FillPolygon((Brush '#53856E'), $coast)
        foreach ($w in @(82, 58, 34)) {
            $stormPen = Pen '#F8FBF8' 3
            $graphics.DrawArc($stormPen, (116 - $w / 2), ($artY + 66 - $w / 2), $w, $w, 35, 285)
            $stormPen.Dispose()
        }
        Ellipse $graphics '#F8FBF8' 111 ($artY + 61) 10 10
        Text $graphics 'AKVAN' 151 ($artY + 119) 12 '#F8FBF8' $true
    }
    elseif ($row.Art -eq 'climate') {
        $graphics.FillRectangle((Brush '#F3D6AE'), $artX, $artY, 281, 152)
        # COP venue, a small Earth, and the missing fossil-fuel line.
        $graphics.FillRectangle((Brush '#C98752'), $artX + 18, $artY + 70, 118, 72)
        $graphics.FillPolygon((Brush '#B87342'), [System.Drawing.Point[]]@(
            [System.Drawing.Point]::new($artX + 8, $artY + 73), [System.Drawing.Point]::new($artX + 77, $artY + 36),
            [System.Drawing.Point]::new($artX + 146, $artY + 73)
        ))
        Text $graphics 'COP31' ($artX + 43) ($artY + 93) 19 '#FFF8E9' $true
        Ellipse $graphics '#397D82' ($artX + 184) ($artY + 29) 68 68
        Line $graphics '#8EB99B' 6 ($artX + 198) ($artY + 51) ($artX + 232) ($artY + 44)
        Line $graphics '#8EB99B' 6 ($artX + 213) ($artY + 76) ($artX + 244) ($artY + 62)
        $graphics.FillRectangle((Brush '#565149'), $artX + 203, $artY + 105, 13, 38)
        $graphics.FillRectangle((Brush '#565149'), $artX + 231, $artY + 92, 13, 51)
        foreach ($dx in @(200, 226, 239)) {
            $sx = $artX + $dx
            Ellipse $graphics '#F8F4EA' $sx ($artY + 79) 18 14
        }
        Line $graphics '#C84B3B' 5 ($artX + 167) ($artY + 124) ($artX + 260) ($artY + 124)
    }
    else {
        $graphics.FillRectangle((Brush '#C9BDD9'), $artX, $artY, 281, 152)
        # A community watching a court verdict together; symbolic people, no portraits.
        Rounded $graphics ($artX + 87) ($artY + 13) 108 64 6 '#172B3A'
        $graphics.FillRectangle((Brush '#F0DFAF'), $artX + 94, $artY + 20, 94, 50)
        Text $graphics 'ICJ' ($artX + 118) ($artY + 26) 25 '#344E59' $true
        Line $graphics '#C84B3B' 3 ($artX + 105) ($artY + 58) ($artX + 178) ($artY + 58)
        foreach ($coordinate in @('43,105', '84,110', '131,103', '178,109', '229,104')) {
            $person = $coordinate.Split(',') | ForEach-Object { [single]$_ }
            Ellipse $graphics '#334958' ($artX + $person[0]) ($artY + $person[1]) 20 20
            Rounded $graphics ($artX + $person[0] - 4) ($artY + $person[1] + 18) 28 26 10 '#334958'
        }
        Text $graphics 'BANGLADESH' ($artX + 15) ($artY + 11) 11 '#334958' $true
    }

    Text $graphics $row.Loc 365 ($y + 20) 14 $row.Accent $true
    Text $graphics $row.H1 365 ($y + 46) 27 '#142435' $true
    Text $graphics $row.H2 365 ($y + 78) 27 '#142435' $true
    Text $graphics $row.Note 365 ($y + 132) 16 '#41505B' $false
}

Text $graphics 'CITY  /  COAST  /  CLIMATE  /  COURT' 44 980 13 '#F5B84B' $true
Text $graphics 'SOURCES: REUTERS  /  AP  /  IMD  /  INDIAN EXPRESS' 498 980 11 '#D6DEE2' $false

$graphics.Dispose()
$bitmap.Save((Join-Path (Get-Location) 'entry.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$bitmap.Dispose()
