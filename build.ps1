#Requires -Version 5.1
# Build de arlysv/osrm-colombia:2026.09 (Colombia completa, no toca osrm-popayan)
$ErrorActionPreference = "Stop"
$ProjectDir = "C:\Users\usuario\osrm-colombia"
$DataDir = Join-Path $ProjectDir "data"
$Pbf = Join-Path $DataDir "colombia-latest.osm.pbf"
$GeofabrikUrl = "https://download.geofabrik.de/south-america/colombia-latest.osm.pbf"

Write-Host "=== 1. Descargar PBF Colombia ==="
if (-not (Test-Path -LiteralPath $Pbf)) {
    Write-Host "Descargando $GeofabrikUrl ..."
    Invoke-WebRequest -Uri $GeofabrikUrl -OutFile $Pbf -UseBasicParsing
} else {
    Write-Host "PBF ya existe, se reutiliza: $Pbf"
}
Write-Host ("Tamano PBF: {0:N2} MB" -f ((Get-Item $Pbf).Length / 1MB))

Write-Host "`n=== 2. Build Docker (extract+partition+customize, 2-3h) ==="
docker build -t arlysv/osrm-colombia:2026.09 -t arlysv/osrm-colombia:latest $ProjectDir

Write-Host "`n=== 3. Push (requiere docker login) ==="
docker push arlysv/osrm-colombia:2026.09
docker push arlysv/osrm-colombia:latest

Write-Host "`nListo. Rollback seguro: arlysv/osrm-popayan:latest queda intacto."
