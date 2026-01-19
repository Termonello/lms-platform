# Use the official PHP 8.4 image as a base
FROM php:8.4-apache

# Enable Apache mod_rewrite (needed by Moodle)
RUN a2enmod rewrite

# Install required packages and PHP extensions for Moodle + PostgreSQL
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      unzip git curl cron \
      libzip-dev \
      libjpeg-dev libpng-dev libfreetype6-dev \
      libicu-dev \
      libxml2-dev \
      libpq-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
      zip \
      gd \
      intl \
      soap \
      exif \
      pgsql \
      pdo_pgsql \
      opcache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Fetch Moodle and copy into Apache docroot
RUN git clone --depth 1 --branch MOODLE_500_STABLE git://git.moodle.org/moodle.git /tmp/moodle \
    && cp -a /tmp/moodle/. /var/www/html/ \
    && rm -rf /tmp/moodle

# New comment line
# Set PHP settings for Moodle: max_input_vars and OPcache
# Set max_input_vars to handle large forms in Moodle
RUN echo "max_input_vars=5000" >> /usr/local/etc/php/conf.d/docker-php-moodle.ini && \
    # Enable OPcache for performance optimization
    echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini && \
    # Enable OPcache for CLI scripts
    echo "opcache.enable_cli=1" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini && \
    # Allocate memory for OPcache
    echo "opcache.memory_consumption=128" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini && \
    # Set buffer size for interned strings
    echo "opcache.interned_strings_buffer=8" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini && \
    # Set the maximum number of cached files
    echo "opcache.max_accelerated_files=10000" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini && \
    # Set the frequency for OPcache to check for file changes
    echo "opcache.revalidate_freq=60" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini && \
    # Enable timestamp validation for OPcache
    echo "opcache.validate_timestamps=1" >> /usr/local/etc/php/conf.d/docker-php-opcache.ini

# Create moodledata directory
RUN mkdir -p /var/www/moodledata

# Set up cron job for Moodle
RUN echo "* * * * * www-data /usr/local/bin/php /var/www/html/admin/cli/cron.php > /dev/null 2>&1" > /etc/cron.d/moodle-cron && \
    chmod 0644 /etc/cron.d/moodle-cron

# Set working directory
WORKDIR /var/www/html

# Set the correct permissions
RUN chown -R www-data:www-data /var/www/ && chmod -R 755 /var/www

# Copy entrypoint script to start both Apache and cron
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh
RUN head -n 1 /entrypoint.sh | cat -A

# Copy Moodle config template (env-driven)
COPY moodle/config/moodle-config.php.tpl /usr/local/etc/moodle-config.php.tpl

# Expose port 80
EXPOSE 80

# Use entrypoint to start cron and Apache
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
