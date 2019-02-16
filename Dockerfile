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

# --- 2 Instalando o SSH server
RUN apt-get -y install ssh openssh-server rsync

# --- 3 Alterar o shell padrão
RUN echo "dash  dash/sh boolean no" | dpkg-reconfigure dash

# --- 4 Desabilitando AppArmor
RUN service apparmor stop
RUN update-rc.d -f apparmor remove 
RUN apt-get remove apparmor apparmor-utils

# --- 5 Synchronize the System Clock
RUN apt-get -y install ntp ntpdate

# --- 6 Removendo sendmail
RUN service sendmail stop; update-rc.d -f sendmail remove

# --- 7 Install Postfix, Dovecot, MySQL, phpMyAdmin, rkhunter, binutils
RUN echo 'mysql-server mysql-server/root_password password pass' | debconf-set-selections \
&& echo 'mysql-server mysql-server/root_password_again password pass' | debconf-set-selections \
&& echo 'mariadb-server mariadb-server/root_password password pass' | debconf-set-selections \
&& echo 'mariadb-server mariadb-server/root_password_again password pass' | debconf-set-selections
RUN apt-get -y install postfix postfix-mysql postfix-doc mariadb-client mariadb-server openssl getmail4 rkhunter binutils dovecot-imapd dovecot-pop3d dovecot-mysql dovecot-sieve dovecot-lmtpd sudo
ADD ./etc/postfix/master.cf /etc/postfix/master.cf
RUN mv /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf.backup
ADD ./etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
# RUN apt-get -y install expect
RUN mv /etc/mysql/ubuntu.cnf /etc/mysql/ubuntu.cnf.backup
ADD ./etc/mysql/ubuntu.cnf /etc/mysql/ubuntu.cnf
ADD ./etc/security/limits.conf /etc/security/limits.conf
RUN mkdir -p /etc/systemd/system/mysql.service.d/
ADD ./etc/systemd/system/mysql.service.d/limits.conf /etc/systemd/system/mysql.service.d/limits.conf

