#!/bin/bash
echo "===== Reporte del sistema ====="
echo "Fecha y hora:         $(date '+%Y-%m-%d %H:%M:%S')"
echo "Host:                 $(hostname)"
echo "Usuarios conectados:  $(who | wc -l)"
echo "Espacio libre en /:   $(df -h / | awk 'NR==2 {print $4}')"
echo "RAM disponible:       $(free -h | awk '/^Mem:/ {print $7}')"
if command -v docker >/dev/null 2>&1; then
  echo "Contenedores activos: $(docker ps -q 2>/dev/null | wc -l)"
else
  echo "Contenedores activos: 0 (Docker no instalado)"
fi
echo
