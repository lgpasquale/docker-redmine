FROM debian:latest

MAINTAINER Luca Pasquale

RUN apt-get update

RUN apt-get -y install sudo
RUN apt-get -y install openssh-server
RUN apt-get -y install libnss-ldap
RUN apt-get -y install debconf-utils
RUN export DEBIAN_FRONTEND=noninteractive; echo "redmine redmine/instances/default/dbconfig-install  boolean false" | debconf-set-selections; \
    apt-get -y install redmine
RUN apt-get -y install redmine-mysql
RUN apt-get -y install apache2 libapache2-mod-passenger
RUN apt-get -y install git

ADD ./passenger.conf /etc/apache2/mods-available/passenger.conf
ADD ./sites-available/redmine.conf /etc/apache2/sites-available/redmine.conf
ADD ./sites-available/redmine-ssl.conf /etc/apache2/sites-available/redmine-ssl.conf

RUN ln -s /usr/share/redmine/public /var/www/html/redmine

RUN a2enmod passenger
RUN for f in /etc/apache2/sites-available/*default*; do a2dissite $(echo ${f##/etc/apache2/sites-available/} | sed 's/.conf//g'); done
RUN a2ensite redmine
RUN a2ensite redmine-ssl

# To avoid annoying "perl: warning: Setting locale failed." errors,
# do not allow the client to pass custom locals, see:
# http://stackoverflow.com/a/2510548/15677
RUN sed -i 's/^AcceptEnv LANG LC_\*$//g' /etc/ssh/sshd_config

RUN sed -i 's/^[[:space:]]*passwd.*/passwd:         files ldap/g' /etc/nsswitch.conf
RUN sed -i 's/^[[:space:]]*group.*/group:         files ldap/g' /etc/nsswitch.conf
RUN sed -i 's/^[[:space:]]*shadow.*/shadow:         files ldap/g' /etc/nsswitch.conf

RUN mkdir -p /home/gitolite/repositories
RUN mkdir /var/run/sshd

ADD ./init.sh /init

RUN chmod +x /init
ENTRYPOINT ["/init", "/usr/sbin/sshd", "-D"]

EXPOSE 22
EXPOSE 80
EXPOSE 443
