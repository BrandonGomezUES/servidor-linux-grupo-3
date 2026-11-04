# Proyecto Final: Servidor Linux Automatizado - Grupo 3

Este repositorio contiene la solución e implementación del proyecto final para la asignatura *Introducción al Software Libre* (Ciclo II - 2026), de la Universidad de El Salvador, Facultad Multidisciplinaria de Occidente.

## 🛠️ Apartados del Proyecto Implementados
### Parte 1: Preparación del Entorno Servidor

**1.1 Administración básica del sistema**
- Se asignó el nombre de host `servidor-grupo3`.
- Se crearon los usuarios `adminsys`, `tecnico` y `visitante`, y los grupos `soporte` y `web`.
- `adminsys` tiene privilegios de `sudo`, `tecnico` pertenece al grupo `soporte` y `visitante` al grupo `web`.

```bash
sudo hostnamectl set-hostname servidor-grupo3
sudo groupadd soporte
sudo groupadd web
sudo useradd -m -s /bin/bash -G sudo adminsys
sudo useradd -m -s /bin/bash -G soporte tecnico
sudo useradd -m -s /bin/bash -G web visitante
```

* **Verificación:**
  ```bash
  hostnamectl
  id adminsys; id tecnico; id visitante
  ```

**1.2 Estructura de directorios y permisos**
Se creó la estructura en `/proyecto/` y se asignaron los grupos. Con el bit setgid (`2775`), los archivos nuevos heredan el grupo del directorio.

```bash
sudo mkdir -p /proyecto/{datos,web,scripts,capturas}
sudo chgrp soporte /proyecto/datos
sudo chgrp web /proyecto/web
sudo chmod 2775 /proyecto/datos /proyecto/web
ls -l /proyecto
```

---

### Parte 2: Automatización y Monitoreo

**2.1 Script de monitoreo del sistema**
Se creó `/proyecto/scripts/reporte_sistema.sh` con permisos de ejecución. Muestra la fecha y hora, el nombre del host, los usuarios conectados, el espacio libre en disco, la RAM disponible y el número de contenedores Docker activos.

```bash
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
```

```bash
chmod +x /proyecto/scripts/reporte_sistema.sh
/proyecto/scripts/reporte_sistema.sh
```

**2.2 Automatización con Cron**
Se programó la ejecución cada 30 minutos y se guarda la salida en `/var/log/proyecto/reporte_sistema.log`.

```bash
sudo mkdir -p /var/log/proyecto
sudo chown adminsys:adminsys /var/log/proyecto
sudo systemctl enable --now cron
crontab -e
```
Línea agregada al crontab de `adminsys`:
```text
*/30 * * * * /proyecto/scripts/reporte_sistema.sh >> /var/log/proyecto/reporte_sistema.log 2>&1
```

* **Verificación de que el registro se actualiza:**
  ```bash
  crontab -l
  systemctl status cron --no-pager
  grep "Fecha y hora" /var/log/proyecto/reporte_sistema.log
  ```
  Los logs de las sesiones de estos apartados están en `capturas/` (`apartado1-sesion.log` y `apartado2-sesion.log`).

---

### Parte 3: Control de Versiones (Git & GitHub)
- Inicialización del repositorio Git local en el directorio /proyecto/.
- Gestión de ramas y flujo de trabajo para el desarrollo colaborativo del equipo.
- Creación de este archivo de documentación README.md.

### Parte 4: Configuración del Entorno Docker
- Instalación del motor oficial de Docker Engine en su versión estable.
- Configuración de permisos para los usuarios administradores y técnicos (adminsys y tecnico) para la ejecución de comandos de contenedores sin el uso de privilegios sudo.
- Verificación exitosa del entorno mediante el despliegue del contenedor de prueba hello-world.


### Parte 5: Servidor Web Containerizado
Se creó el directorio de trabajo del servidor y se configuró la página web:

```bash
cd /proyecto/
cd web/
nano index.html
```
---

Se desplegó un contenedor Nginx oficial utilizando un volumen para vincular la carpeta local del proyecto en tiempo real:

* **Comando de ejecución:**
  ```bash
  docker run -d --name nginx-proyecto -p 8080:80 -v /proyecto/web:/usr/share/nginx/html/ nginx:latest
  ```

* **Verificación del servicio web y registros:**
  Se confirmó que el servidor respondiera correctamente y se revisaron los logs para descartar errores:
  ```bash
  curl http://localhost:8080
  docker logs nginx-proyecto
  ```

---

### Parte 6: Docker Avanzado
Para empaquetar de forma estática la aplicación web directamente dentro de una imagen propia, se creó un `Dockerfile` en la raíz del proyecto.

* **Creación y edición del Dockerfile:**
  ```bash
  cd ..
  nano Dockerfile
  ```
  Contenido implementado:
  ```dockerfile
  # Utilizar la imagen base nginx:latest
  FROM nginx:latest

  # Copiar el contenido del directorio web/ al directorio de Nginx
  COPY web/ /usr/share/nginx/html/

  # Exponer el puerto 80
  EXPOSE 80

  # Configurar el comando de inicio de Nginx
  CMD ["nginx", "-g", "daemon off;"]
  ```

* **Construcción de la imagen personalizada:**
  ```bash
  docker build -t servidor-grupo3 .
  ```

* **Despliegue del contenedor con la imagen propia:**
  ```bash
  docker run -d --name nginx-grupo-3 -p 8081:80 servidor-grupo3
  ```

* **Verificación final del servicio personalizado:**
  ```bash
  curl http://localhost:8081
  ```

---

### Parte 7: Redes y Volúmenes Persistentes

**7.1 Red personalizada (`red-proyecto`)**
Se creó una red personalizada de tipo *bridge* para permitir la comunicación aislada entre contenedores mediante resolución de nombres DNS. Se ejecutó un contenedor Nginx asignado a dicha red exponiendo el puerto 8082.

```bash
docker network create red-proyecto
docker run -d --name nginx-red --network red-proyecto -p 8082:80 nginx:latest
```

- **Verificación de red:**
  ```bash
  docker network inspect red-proyecto
  ```

**7.2 Volumen persistente (`volumen-web`)**
Se creó un volumen persistente para asegurar la conservación de datos independientemente del ciclo de vida del contenedor, asociándolo al servicio en el puerto 8083.

```bash
docker volume create volumen-web
docker run -d --name nginx-volumen -p 8083:80 -v volumen-web:/usr/share/nginx/html/ nginx:latest
```

- **Verificación del montaje:**
  ```bash
  docker inspect nginx-volumen
  ```

---

### Parte 8: Pruebas y Verificación Final

**8.1 Pruebas de conectividad en red**
Se comprobó la resolución de nombres DNS interna y la conectividad entre contenedores de `red-proyecto` mediante un contenedor temporal de Alpine Linux.

```bash
docker run --rm -it --network red-proyecto alpine ping -c 4 nginx-red
```

**8.2 Verificación integral del sistema**
Se confirmó el funcionamiento concurrente de todos los contenedores web del grupo en sus respectivos puertos (8080, 8081, 8082 y 8083) y la actualización constante de los registros del script de monitoreo en `cron`.

```bash
docker ps
curl -I http://localhost:8080
curl -I http://localhost:8081
curl -I http://localhost:8082
curl -I http://localhost:8083
tail -n 15 /var/log/proyecto/reporte_sistema.log
```

---

Desarrollado de forma equitativa por los integrantes del Grupo 3.

