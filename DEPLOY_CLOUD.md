# Deploy en la nube — OSRM Colombia (sin usar tu PC)

Tu PC tiene 956MB RAM libre y el daemon ni arranca: Colombia necesita 16GB.
Por eso el build corre en **GitHub Actions** y publica en DockerHub.

## Lo que debes hacer tú (15 min, solo esto)

1. **Crear token DockerHub**: https://hub.docker.com/settings/security
   → `New Access Token` → permisos `Read, Write, Delete` → cópialo.
2. **Crear repo GitHub** (ej: `arlysv/osrm-colombia`) y subir esta carpeta:
   ```
   git init && git add . && git commit -m "osrm colombia" && git push
   ```
3. **Agregar secrets** en el repo → `Settings → Secrets → Actions`:
   - `DOCKERHUB_USERNAME` = `arlysv`
   - `DOCKERHUB_TOKEN` = el token del paso 1
4. **Correr el workflow**: pestaña `Actions` → `Build OSRM Colombia` → `Run workflow`
   → tarda 2-3h, puedes cerrar el PC tranquilo.
5. **Verificar**: al terminar tendrás `arlysv/osrm-colombia:2026.09` + `latest` en DockerHub.

## Después (lo hago yo cuando me avises)
- Desplegar `osrm-colombia` en Railway/Render con el `docker-compose.yml`.
- Cambiar `OSRM_BASE_URL` en `Optimizacion_Of_Rutas` a la nueva URL.
- Correr `validate.ps1` contra la nube (regresión Popayán + Bogotá→Medellín + `/route-options`).
- Apuntar el futuro `DOMIFLEX-backend` a este optimizer.

## Costo
- GitHub Actions: gratis (2000 min/mes, el build consume ~180 min).
- `arlysv/osrm-popayan:latest` queda intacto como rollback de Moviflexx actual.
