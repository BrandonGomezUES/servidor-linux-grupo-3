# Utilizar la imagen base nginx:latest
FROM nginx:latest

# Copiar el contenido del directorio web/ al directorio de Nginx
COPY web/ /usr/share/nginx/html/

# Exponer el puerto 80
EXPOSE 80

# Configurar el comando de inicio de Nginx
CMD ["nginx", "-g", "daemon off;"]
