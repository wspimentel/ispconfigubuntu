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
#


FROM ubuntu:latest

MAINTAINER Weberson S Pimentel <weberson.pimentel@hotmail.com> version: 0.1


# ---------------- Inciando ----------------
<<<<<<< HEAD

RUN apt-get update
RUN apt-get -y dist-upgrade

# ---------------- Install Roundcube Webmail ----------------

RUN apt-get -y install roundcube roundcube-core roundcube-mysql roundcube-plugins javascript-common libjs-jquery-mousewheel php-net-sieve tinymce
=======
RUN apt-get update
RUN apt-get -y dist-upgrade
>>>>>>> cc44fa34bd1e7c3e0de5a3b93aad53d3b9f46d3a
