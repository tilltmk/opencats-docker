# Verwende das Basis-Image mit PHP 7.2 auf Debian Stretch
FROM php:7.2-apache-stretch

# Archivierte Debian Stretch-Repositories hinzufügen
RUN echo "deb http://archive.debian.org/debian/ stretch main contrib non-free\n\
deb http://archive.debian.org/debian-security stretch/updates main contrib non-free" > /etc/apt/sources.list && \
    apt-get -o Acquire::Check-Valid-Until=false update && \
    apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libxml2-dev \
    libldap2-dev \
    libgmp-dev \
    libicu-dev \
    sudo \
    libncurses5-dev \
    libmemcached-dev \
    libcurl4-openssl-dev \
    libmcrypt-dev \
    curl \
    zlib1g-dev \
    msmtp \
    antiword \
    poppler-utils \
    html2text \
    unrtf \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# GD-Erweiterung ohne spezifische Optionen installieren
RUN docker-php-ext-install -j$(nproc) gd

# Zusätzliche PHP-Erweiterungen installieren
RUN docker-php-ext-install -j$(nproc) soap ldap mysqli pdo_mysql intl gmp zip

# GMP-Bibliothek verlinken
RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h

# LDAP konfigurieren
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/

# OpenCATS Repository klonen und Dateien kopieren
WORKDIR /tmp
RUN git clone https://github.com/opencats/OpenCATS.git opencats && \
    cp -r /tmp/opencats/. /var/www/html/

# Composer installieren
WORKDIR /var/www/html
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer install

# Berechtigungen setzen
RUN chown -R www-data:www-data /var/www/html/

# Apache Konfiguration anpassen
RUN rm -rf /etc/apache2/sites-available/000-default.conf
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html\n\
    <Directory /var/www/html>\n\
        AllowOverride All\n\
        Require all granted\n\
        DirectoryIndex index.php index.html\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Apache Rewrite-Modul aktivieren
RUN a2enmod rewrite

# Startbefehl für den Apache-Server
CMD ["apache2-foreground"]
