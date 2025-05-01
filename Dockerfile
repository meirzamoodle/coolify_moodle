# Start with an official PHP + FPM base image
ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-fpm

# Install required dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    mariadb-client \
    default-libmysqlclient-dev \
    libicu-dev \
    libpq-dev \
    libpng-dev \
    pkg-config \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libzip-dev \
    libxml2-dev \
    wget \
    unzip \
    curl \
    nginx \
    supervisor \
    exiftool \
    ghostscript \
    graphviz \
    aspell \
    aspell-en \
    python3-full \
    python3-venv \
    poppler-utils \
    && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions (including GD)
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install \
    gd \
    intl \
    pdo_pgsql \
    pgsql \
    pdo_mysql \
    mysqli \
    zip \
    xml \
    dom \
    soap \
    exif \
    opcache

# Set up Python virtual environment for pip packages
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python packages in virtual environment
RUN /opt/venv/bin/pip install --no-cache-dir \
    pylint \
    numpy

# Copy application files
WORKDIR /var/www/html

ARG MOODLE_VERSION
RUN wget -O /tmp/moodle.tgz "https://download.moodle.org/download.php/direct/stable${MOODLE_VERSION}/moodle-latest-${MOODLE_VERSION}.tgz" \
    && tar -xzf /tmp/moodle.tgz --strip-components=1 -C /var/www/html \
    && chown -R www-data:www-data /var/www/html \
    && rm /tmp/moodle.tgz

# Create moodledata directory inside /var/www/html/ so it can be volume-mounted
RUN mkdir -p /var/www/html/moodledata && chown -R www-data:www-data /var/www/html/moodledata

COPY config.php /var/www/html/config.php
RUN chown www-data:www-data /var/www/html/config.php && chmod 640 /var/www/html/config.php

# Copy custom php.ini
COPY php.ini /usr/local/etc/php/conf.d/custom.ini

# Configure Nginx
RUN rm -f /etc/nginx/sites-enabled/default
COPY nginx.conf /etc/nginx/nginx.conf

# Configure Supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ports for Nginx
EXPOSE 80

# Copy the extra script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Health check (optional)
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

# Modify the CMD to execute the script before Supervisor starts
CMD ["/usr/local/bin/entrypoint.sh"]
