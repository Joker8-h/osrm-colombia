# osrm-colombia — Imagen OSRM Colombia completa para domicilios

No sobrescribe `arlysv/osrm-popayan:latest` (queda como rollback de Moviflexx).
Nueva imagen: `arlysv/osrm-colombia:2026.09` + `latest`.

## Contenido
- `Dockerfile` — multi-stage: extract + partition + customize con `car.lua`, sirve con `osrm-routed --max-table-size 8000`
- `docker-compose.yml` — `osrm-colombia:5000` + `route-optimizer:8000` (repo `Joker8-h/Optimizacion_Of_Rutas` con `OSRM_BASE_URL=http://osrm-colombia:5000`)
- `build.ps1` — descarga `colombia-latest.osm.pbf` de Geofabrik y hace build+push
- `validate.ps1` — regresión Popayán + prueba nacional Bogotá→Medellín + `/route-options CHEAPEST`
- `data/` — pon aquí `colombia-latest.osm.pbf` (no se versiona, ver `.gitignore`)

## Uso
1. `docker login` (cuenta arlysv)
2. `powershell -ExecutionPolicy Bypass -File build.ps1` (2-3h, 8GB RAM, 30GB disco)
3. `docker compose up -d` y luego `validate.ps1`
4. En Railway/Render del optimizer cambiar `OSRM_BASE_URL` a la URL de esta imagen desplegada.
5. El futuro `DOMIFLEX-backend` usará este optimizer, no el de Popayán.

## Integración domicilios
- `/route-options FASTEST/CHEAPEST` → asignación de repartidor
- `/segment-fares` → prorrateo multi-pedido por distancia OSRM
- `reconocimiento-placa/facial` se reutilizan sin cambios para verificar repartidor + moto
