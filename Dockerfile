FROM centos:7 
ADD ./composer /usr/bin/composer
#RUN git clone https://github.com/meolu/walle-web.git /data/walle-web
ADD lib/v1.2.0.tar.gz /data
ADD ./src/entrypoint.sh  /entrypoint.sh
RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    && yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm \
    && yum -y install yum-utils \
    && yum-config-manager --enable remi-php71 \
    && yum -y install git openssh php php-fpm nginx php-xml php-mbstring php-common \
    php-mcrypt php-cli php-gd php-curl php-mysql rsync openssh-clients php-ldap php-zip php-fileinfo \
    && yum -y install kde-l10n-Chinese glibc-common \ 
    && yum clean all && rm -rf /var/cache/yum \
    && rm -f /etc/localtime && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && localedef -c -f UTF-8 -i zh_CN zh_CN.utf8 \
    && echo "* soft nofile 32768" >>/etc/security/limits.conf \
    && echo "* hard nofile 32768" >>/etc/security/limits.conf \
    && mv /data/walle-web-1.2.0 /data/walle-web && cd /data/walle-web \
    && chmod +x /usr/bin/composer \
#    && composer install --prefer-dist --no-dev --dataimize-autoloader -vvvv \
    && composer install \
    && groupadd -g 1111 ops \
    && useradd -g ops ops -u 1111 \
    && echo "W9II6wOPIsXXG7km"| passwd --stdin ops \
    && sed -i 's/user = apache/user = ops/g' /etc/php-fpm.d/www.conf \
    && sed -i 's/group = apache/group = ops/g' /etc/php-fpm.d/www.conf \
    && cp -raf /data/walle-web/vendor/bower-asset /data/walle-web/vendor/bower \
    && chown -R 775 /data/walle-web  && chown -R ops.ops /data/walle-web \
    && mkdir -p /data/nginx/{logs,cache/tmp,cache/cache,error} \
    && mkdir -p /run/php-fpm \ 
    && chown -R ops:ops /data/walle-web \
    && chmod +x /entrypoint.sh
ADD ./src/config/local.php  /data/walle-web/config/local.php
ADD ./src/config/params.php  /data/walle-web/config/params.php
ADD ./src/php.ini  /etc/php.ini.bak 
COPY ./src/walle.conf /etc/nginx/conf.d/walle.conf
COPY ./src/nginx.conf /etc/nginx/nginx.conf
WORKDIR /data/walle-web
RUN mkdir /home/ops/.ssh \
    && echo -e "\n" |ssh-keygen -t rsa -C 'walle' -b 4096 -f ~/.ssh/id_rsa \
    && echo -e "IdentityFile ~/.ssh/id_rsa\n" >> ~/.ssh/config \
    && echo -e "StrictHostKeyChecking no\nUserKnownHostsFile /dev/null" >> ~/.ssh/config \
    && chown -R ops:ops /home/ops/.ssh \
    && chmod -R 600 /home/ops/.ssh/*
USER root
ENV LANG zh_CN.UTF-8  
ENV LANGUAGE zh_CN:zh 
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx"]
