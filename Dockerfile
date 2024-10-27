FROM php:7.2-apache-stretch

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

RUN docker-php-ext-install -j$(nproc) gd

RUN docker-php-ext-install -j$(nproc) soap ldap mysqli pdo_mysql intl gmp zip

RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h

RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/

WORKDIR /tmp
RUN git clone https://github.com/opencats/OpenCATS.git opencats && \
    cp -r /tmp/opencats/. /var/www/html/

WORKDIR /var/www/html
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer install

RUN chown -R www-data:www-data /var/www/html/

RUN rm -rf /etc/apache2/sites-available/000-default.conf
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html\n\
    <Directory /var/www/html>\n\
        AllowOverride All\n\
        Require all granted\n\
        DirectoryIndex index.php index.html\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

RUN a2enmod rewrite

CMD ["apache2-foreground"]
