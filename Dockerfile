FROM php:7.2-apache

RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libncurses5-dev \
    libicu-dev \
    libmemcached-dev \
    libcurl4-openssl-dev \
    libpng-dev \
    libgmp-dev \
    libxml2-dev \
    libldap2-dev \
    curl \
    zlib1g-dev \
    msmtp \  
    antiword \
    poppler-utils \
    html2text \
    unrtf \
    git \
    unzip \
 && rm -rf /var/lib/apt/lists/* \
 && docker-php-ext-install soap 

RUN ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h 

RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
RUN docker-php-ext-install ldap && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install soap && \
    docker-php-ext-install intl && \
    docker-php-ext-install gd && \
    docker-php-ext-install gmp && \
    docker-php-ext-install zip

RUN docker-php-ext-install gd

WORKDIR /tmp
RUN git clone https://github.com/opencats/OpenCATS.git opencats && \
    git -C opencats checkout `git -C opencats describe --tags $(git -C opencats rev-list --tags --max-count=1)`

RUN cp -r /tmp/opencats/. /var/www/html/

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
