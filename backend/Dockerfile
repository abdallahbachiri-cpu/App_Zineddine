# Stage 1: PHP-FPM with Symfony
FROM php:8.2-fpm-alpine AS php

# Install system dependencies and PHP extensions
RUN apk add --no-cache \
    icu-dev \
    libzip-dev \
    zlib-dev \
    libintl \
    libzip \
    git \
    unzip \
    curl \
    postgresql-dev \
    postgresql-client \
    nginx \
    supervisor \
    bash \
    && docker-php-ext-install -j$(nproc) \
        intl \
        pdo_pgsql \
        zip \
        opcache \
    && docker-php-ext-enable opcache

# Copy custom php.ini configuration
COPY docker/php/php.ini /usr/local/etc/php/conf.d/custom.ini

# Allow PHP-FPM to inherit Docker environment variables
COPY docker/php/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create working directory
WORKDIR /var/www/cuiz

# Copy composer files
COPY composer.json composer.lock symfony.lock ./

# Copy all project files
COPY . .

# Install PHP dependencies
RUN composer install --prefer-dist --no-progress --no-interaction --no-scripts

# Set permissions
RUN mkdir -p /var/www/cuiz/var/cache /var/www/cuiz/var/log \
    && chown -R www-data:www-data /var/www/cuiz/var \
    && chmod -R 775 /var/www/cuiz/var

# Stage 2: Final image with Nginx + PHP-FPM
FROM php:8.2-fpm-alpine

# Install runtime dependencies for PHP and Nginx
RUN apk add --no-cache \
    nginx \
    supervisor \
    bash \
    curl \
    icu \
    libzip \
    libintl \
    zlib \
    postgresql-libs

# Create nginx log directories
RUN mkdir -p /var/log/nginx /var/cache/nginx \
    && touch /var/log/nginx/access.log /var/log/nginx/error.log \
    && chmod -R 755 /var/log/nginx /var/cache/nginx

# Copy PHP from the first stage
COPY --from=php /usr/local/bin /usr/local/bin
COPY --from=php /usr/local/etc /usr/local/etc
COPY --from=php /usr/local/lib /usr/local/lib
COPY --from=php /usr/bin/composer /usr/bin/composer
COPY --from=php /var/www/cuiz /var/www/cuiz

# Copy Nginx config
COPY docker/nginx.conf /etc/nginx/http.d/default.conf


# Copy Supervisor config (to run both php-fpm and nginx)
COPY docker/supervisord.conf /etc/supervisord.conf

RUN chown -R www-data:www-data /var/www/cuiz \
 && chmod -R 775 /var/www/cuiz/var

# # Create and set permissions for secure and public media folders
# RUN mkdir -p /mnt/data/uploads/secure && chown www-data:www-data /mnt/data/uploads/secure
# RUN mkdir -p /mnt/data/uploads/public && chown www-data:www-data /mnt/data/uploads/public

WORKDIR /var/www/cuiz


EXPOSE 80

# Copy custom entrypoint script
COPY docker/entrypoint /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

# Use it as the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
