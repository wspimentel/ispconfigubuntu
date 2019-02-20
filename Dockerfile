#
#                    ##        .
#              ## ## ##       ==
#           ## ## ## ##      ===
#       /""""""""""""""""\___/ ===
#  ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
#       \______ o          __/
#         \    \        __/
#          \____\______/
#
#          |          |
#       __ |  __   __ | _  __   _
#      /  \| /  \ /   |/  / _\ |
#      \__/| \__/ \__ |\_ \__  |
#
#
# Ubuntu 18.04, Apache, PHP, MySQL, PureFTPD, BIND, Postfix, Dovecot, Roundcube and ISPConfig 3.1
#
# Link Referência 
# https://www.howtoforge.com/tutorial/perfect-server-ubuntu-18.04-with-apache-php-myqsl-pureftpd-bind-postfix-doveot-and-ispconfig/3/
#

FROM ubuntu:18.04

MAINTAINER Weberson S Pimentel <weberson.pimentel@hotmail.com> version: 0.1

# --- 1 Inciando 
RUN apt-get -y update && apt-get -y upgrade
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --assume-yes apt-utils

# --- 2 Instalando o SSH server
RUN apt-get -y install ssh openssh-server rsync

# --- 3 Alterar o shell padrão
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN dpkg-reconfigure dash

# --- 4 Desabilitando AppArmor
#RUN service apparmor stop
#RUN update-rc.d -f apparmor remove 
#RUN apt-get remove apparmor apparmor-utils

# --- 5 Synchronize the System Clock
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get -y install ntp ntpdate

# --- 6 Removendo sendmail
#RUN service sendmail stop; update-rc.d -f sendmail remove
RUN echo -n "Removing Sendmail... "	service sendmail stop hide_output update-rc.d -f sendmail remove apt_remove sendmail

# --- 7 Install Postfix, Dovecot, MySQL, phpMyAdmin, rkhunter, binutils
RUN echo 'mysql-server mysql-server/root_password password pass' | debconf-set-selections \
&& echo 'mysql-server mysql-server/root_password_again password pass' | debconf-set-selections \
&& echo 'mariadb-server mariadb-server/root_password password pass' | debconf-set-selections \
&& echo 'mariadb-server mariadb-server/root_password_again password pass' | debconf-set-selections
RUN echo -n "Installing SMTP Mail server (Postfix)... " \
&& echo "postfix postfix/main_mailer_type select Internet Site" | debconf-set-selections \
&& echo "postfix postfix/mailname string contato@seusite.con.br" | debconf-set-selections
RUN apt-get -y install postfix postfix-mysql postfix-doc mariadb-client mariadb-server openssl getmail4 rkhunter binutils dovecot-imapd dovecot-pop3d dovecot-mysql dovecot-sieve dovecot-lmtpd sudo
ADD ./etc/postfix/master.cf /etc/postfix/master.cf
RUN mv /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf.backup
ADD ./etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
# RUN apt-get -y install expect
#RUN mv /etc/mysql/ubuntu.cnf /etc/mysql/ubuntu.cnf.backup
#ADD ./etc/mysql/ubuntu.cnf /etc/mysql/ubuntu.cnf
ADD ./etc/security/limits.conf /etc/security/limits.conf
RUN mkdir -p /etc/systemd/system/mysql.service.d/
ADD ./etc/systemd/system/mysql.service.d/limits.conf /etc/systemd/system/mysql.service.d/limits.conf

# --- 9 Install Amavisd-new, SpamAssassin And Clamav
RUN apt-get -y install amavisd-new spamassassin clamav clamav-daemon unzip bzip2 arj nomarch lzop cabextract apt-listchanges libnet-ldap-perl libauthen-sasl-perl clamav-docs daemon libio-string-perl libio-socket-ssl-perl libnet-ident-perl zip libnet-dns-perl postgrey
ADD ./etc/clamav/clamd.conf /etc/clamav/clamd.conf
RUN service spamassassin stop && systemctl disable spamassassin
RUN update-rc.d -f spamassassin remove
#RUN freshclam
#RUN service clamav-daemon start
# --- Erro amavisd-new
RUN wget https://git.ispconfig.org/ispconfig/ispconfig3/raw/stable-3.1/helper_scripts/ubuntu-amavisd-new-2.11.patch -P /tmp
RUN cd /usr/sbin
#RUN cp -pf amavisd-new amavisd-new_bak 
#RUN patch < /tmp/ubuntu-amavisd-new-2.11.patch

# -- 10 Install XMPP Server
RUN apt-get -qq update && apt-get -y -qq install git lua5.1 liblua5.1-0-dev lua-filesystem libidn11-dev libssl-dev lua-zlib lua-expat lua-event lua-bitop lua-socket lua-sec luarocks luarocks
RUN luarocks install lpc
RUN adduser --no-create-home --disabled-login --gecos 'Metronome' metronome
RUN cd /opt && git clone https://github.com/maranda/metronome.git metronome
RUN cd /opt/metronome && ./configure --ostype=debian --prefix=/usr && make && make install

# --- 11 Install Apache2, PHP5, phpMyAdmin, FCGI, suExec, Pear, And mcrypt
RUN echo 'phpmyadmin phpmyadmin/dbconfig-install boolean true' | debconf-set-selections \
&& echo 'phpmyadmin phpmyadmin/mysql/admin-pass password pass' | debconf-set-selections \
&& echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections
RUN service mysql start && apt-get -y install apache2 apache2-doc apache2-utils libapache2-mod-php php7.2 php7.2-common php7.2-gd php7.2-mysql php7.2-imap phpmyadmin php7.2-cli php7.2-cgi libapache2-mod-fcgid apache2-suexec-pristine php-pear mcrypt  imagemagick libruby libapache2-mod-python php7.2-curl php7.2-intl php7.2-pspell php7.2-recode php7.2-sqlite3 php7.2-tidy php7.2-xmlrpc php7.2-xsl memcached php-memcache php-imagick php-gettext php7.2-zip php7.2-mbstring php-soap php7.2-soap
RUN a2enmod suexec rewrite ssl actions include dav_fs dav auth_digest cgi
ADD ./etc/apache2/conf-available/httpoxy.conf /etc/apache2/conf-available/httpoxy.conf
RUN a2enconf httpoxy
RUN service apache2 restart

