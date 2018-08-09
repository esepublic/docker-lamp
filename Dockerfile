FROM phusion/baseimage:0.9.22
MAINTAINER Keith Bentrup <kbentrup@magento.com>

RUN curl -S https://packagecloud.io/gpg.key | apt-key add - && \
  echo "deb http://packages.blackfire.io/debian any main" | tee /etc/apt/sources.list.d/blackfire.list && \
  add-apt-repository ppa:ondrej/php && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    --force-yes \
    redis-tools \
    git \
    npm \
    ruby \
    ruby-dev \
    php7.0 \
    php7.0-common \
    php7.0-gd \
    php7.0-mysql \
    php7.0-mcrypt \
    php7.0-curl \
    php7.0-intl \
    php7.0-xsl \
    php7.0-mbstring \
    php7.0-zip \
    php7.0-bcmath \
    php7.0-xdebug \
    php7.0-soap \
    unzip \
    mysql-client \
    libxml2-utils \
    ssmtp \
    vim \
    blackfire-agent \
    blackfire-php \
    strace \
    python-yaml \
    wget && \
  `# prevent extraneous logging from cron` && \  
  `# find correct xdebug.so path` && \
  (find /usr/lib/php -name "xdebug.so" | sort | tail -1 | sed 's/^/zend_extension=/' > /etc/php/7.0/mods-available/xdebug.ini) && \
  phpdismod xdebug && \
  phpenmod opcache && \
  printf "#!/bin/sh\n/etc/init.d/blackfire-agent start\n" > /etc/my_init.d/blackfire.sh && \
  chmod +x /etc/my_init.d/blackfire.sh && \
  apt-get --purge autoremove -y && \
  apt-get clean && \
  rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*

# add amqp-utils
RUN gem install amqp-utils && \
  echo 'export PATH="${PATH}:/var/lib/gems/1.9.1/gems/amqp-utils-0.5.1/bin/"' >> /root/.bashrc

# disable ssmtop
RUN mv /usr/sbin/ssmtp /usr/sbin/ssmtp.disabled

# add composer
#RUN curl -sS https://getcomposer.org/installer | php && \
#  mv composer.phar /usr/local/bin/composer

#COPY apache2.sh /etc/service/apache2/run
#COPY randomize-cron-start.sh /etc/my_init.d/
# built this version of xdebug for latest debian updates based on these instructions
# 1) copy output of php -i to https://xdebug.org/wizard.php
# 2) download and build xdebug module using displayed results
COPY xdebug.so /usr/lib/php/20160303/

EXPOSE 80 443

ADD etc /etc
