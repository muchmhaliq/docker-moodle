FROM ubuntu:16.04

VOLUME ["/var/moodledata"]

EXPOSE 80 443 
COPY moodle-config.php /var/www/html/config.php

# Keep upstart from complaining 
# RUN dpkg-divert --local --rename --add /sbin/initctl 
# RUN ln -sf /bin/true /sbin/initctl 

# Let the container know that there is no tty 
ENV DEBIAN_FRONTEND noninteractive

# Database info 
#ENV MYSQL_HOST 127.0.0.1 
#ENV MYSQL_USER moodle 
#ENV MYSQL_PASSWORD moodle 
#ENV MYSQL_DB moodle 
ENV MOODLE_URL http://example.com 
ADD ./foreground.sh /etc/apache2/foreground.sh

RUN apt-get update && \
	apt-get -y install mysql-client pwgen python-setuptools curl git unzip apache2 php \
		php-gd libapache2-mod-php postfix wget supervisor php-pgsql curl libcurl3 \
		libcurl3-dev php-curl php-xmlrpc php-intl php-mysql git-core php-xml php-mbstring php-zip php-soap && \
	cd /tmp && \
	git clone -b MOODLE_32_STABLE git://git.moodle.org/moodle.git --depth=1 && \
	mv /tmp/moodle/* /var/www/html/ && \
	rm /var/www/html/index.html && \
	chown -R www-data:www-data /var/www/html && \
	chmod +x /etc/apache2/foreground.sh
# Enable SSL, moodle requires it 
RUN a2enmod ssl && a2ensite default-ssl # if using proxy, don't need actually secure connection
# Cleanup 
RUN apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/dpkg/* /var/lib/cache/* /var/lib/log/*
CMD ["/etc/apache2/foreground.sh"]
