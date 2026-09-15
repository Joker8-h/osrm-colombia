#Requires -Version 5.1
# Valida OSRM Colombia + Optimizacion_Of_Rutas antes de conectar BACKENDMOVI/DOMIFLEX
$ErrorActionPreference = "Continue"
$OSRM = $env:OSRM_BASE_URL
if (-not $OSRM) { $OSRM = "http://localhost:5000" }
$OPT = $env:OPTIMIZER_URL
if (-not $OPT) { $OPT = "http://localhost:8000" }

Write-Host "OSRM: $OSRM | Optimizer: $OPT"

Write-Host "`n[1] OSRM health..."
try { Invoke-RestMethod "$OSRM/health" -TimeoutSec 10 | ConvertTo-Json -Depth 3 } catch { Write-Host "FALLO OSRM: $_" }

Write-Host "`n[2] Ruta Popayan (regresion vs osrm-popayan)..."
try {
    $r = Invoke-RestMethod "$OSRM/route/v1/driving/-76.6147,2.4448;-76.5980,2.4550?overview=false" -TimeoutSec 20
    Write-Host ("OK rutas: {0} dist: {1:N2} km" -f $r.routes.Count, ($r.routes[0].distance/1000))
} catch { Write-Host "FALLO ruta Popayan: $_" }

Write-Host "`n[3] Ruta Bogota->Medellin (nueva capacidad Colombia)..."
try {
    $r = Invoke-RestMethod "$OSRM/route/v1/driving/-74.0721,4.7110;-75.5636,6.2518;?overview=false" -TimeoutSec 30
    # Nota: URL con ; final intencional para tolerar slash, reintento sin el:
} catch {
    try {
        $r = Invoke-RestMethod "$OSRM/route/v1/driving/-74.0721,4.7110;-75.5636,6.2518?overview=false" -TimeoutSec 30
        Write-Host ("OK rutas: {0} dist: {1:N2} km dur: {2:N1} min" -f $r.routes.Count, ($r.routes[0].distance/1000), ($r.routes[0].duration/60))
    } catch { Write-Host "FALLO ruta nacional: $_" }
}

Write-Host "`n[4] Optimizer /health y /route-options..."
try { Invoke-RestMethod "$OPT/health" -TimeoutSec 10 | ConvertTo-Json } catch { Write-Host "FALLO optimizer health: $_" }
try {
    $body = @{ origin=@{lat=2.4448; lng=-76.6147}; destination=@{lat=2.4550; lng=-76.5980}; preference="CHEAPEST"; k=3 } | ConvertTo-Json -Depth 4
    $o = Invoke-RestMethod -Method Post -Uri "$OPT/route-options" -Body $body -ContentType "application/json" -TimeoutSec 30
    Write-Host ("OK optimizer: {0} rutas, pref {1}" -f $o.returned, $o.preference)
} catch { Write-Host "FALLO route-options: $_" }
