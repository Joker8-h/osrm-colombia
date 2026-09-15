# OSRM Colombia completa - no sobrescribe arlysv/osrm-popayan
# Etapa builder: procesa el PBF de Geofabrik (car.lua para domicilios moto/carro)
FROM osrm/osrm-backend:latest AS builder
WORKDIR /data
# Se espera colombia-latest.osm.pbf en ./data al hacer build (ver build.ps1)
# Se copian perfiles oficiales de la imagen base (/opt/*.lua)
RUN apt-get update && apt-get install -y --no-install-recommends osmium-tool && rm -rf /var/lib/apt/lists/*

COPY data/colombia-latest.osm.pbf /data/colombia-latest.osm.pbf

# 1. Extract (el paso más pesado: 1-2h para Colombia en PC normal, requiere 8GB+ RAM)
RUN osrm-extract -p /opt/car.lua /data/colombia-latest.osm.pbf
# 2. Partition + Customize (MCD, necesario para /route con alternatives=true)
RUN osrm-partition /data/colombia-latest.osrm && \
    osrm-customize /data/colombia-latest.osrm

# Etapa final: solo binario + datos procesados (liviana para Railway/VPS)
FROM osrm/osrm-backend:latest
WORKDIR /data
COPY --from=builder /data/colombia-latest.osrm* /data/
COPY --from=builder /data/colombia-latest.osm.pbf /data/colombia-latest.osm.pbf
EXPOSE 5000
# max-table-size alto para /segment-fares multi-parada de domicilios
CMD ["osrm-routed", "--max-table-size", "8000", "--max-trip-size", "500", "/data/colombia-latest.osrm"]
