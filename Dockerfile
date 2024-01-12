FROM php:8.1-fpm

# Instala las dependencias de PHP y extensiones necesarias para Laravel
RUN apt-get update && apt-get install -y \
    libonig-dev \
    libpng-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl

# Instala las extensiones de PHP
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Establece el directorio de trabajo en /var/www
WORKDIR /var/www

# Copia los archivos de Laravel al directorio de trabajo
COPY . /var/www

# Instala las dependencias de Laravel
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Establece permisos para el directorio de almacenamiento y bootstrap/cache
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage \
    && chmod -R 755 /var/www/bootstrap/cache

# Expone el puerto 8000, que es el puerto por defecto de 'artisan serve'
EXPOSE 8000

# Usa el usuario www-data
USER www-data

# Inicia Laravel con 'artisan serve' y escucha en todas las interfaces de red
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
