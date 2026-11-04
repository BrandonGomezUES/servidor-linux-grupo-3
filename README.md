# Proyecto Final: Servidor Linux Automatizado - Grupo 3

Este repositorio contiene la solución e implementación del proyecto final para la asignatura *Introducción al Software Libre* (Ciclo II - 2026), de la Universidad de El Salvador, Facultad Multidisciplinaria de Occidente.

## 🛠️ Apartados del Proyecto Implementados

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
Desarrollado de forma equitativa por los integrantes del Grupo 3.

