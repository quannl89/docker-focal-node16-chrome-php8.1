FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y 

# add Node.js, Yarn and PHP repos
RUN apt-get -y update \
    && apt-get install -y --no-install-recommends gnupg \
    && echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu focal main" > /etc/apt/sources.list.d/ondrej-php.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
        ca-certificates \
		curl \
		git \
		zip \
		unzip \
		xvfb \
		wget \
		python3-pip \
		cron \ 
		openssh-server

# install PHP
RUN apt-get -y install \
  php8.1-cli \
  php8.1-mbstring \
  php8.1-dom \
  php8.1-curl \
  php8.1-simplexml \
  php8.1-gd \
  php8.1-zip \
  php8.1-bcmath \
  php8.1-intl \
  php8.1-mysql \
  php8.1-mongodb \
  php8.1-soap \
  
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Quannl Script  

#RUN apt -y install \
#	git \
#	python3-pip 
	
RUN pip install boto3 \
    && pip install awscli 

RUN echo 'max_execution_time = 600' >> /etc/php/8.1/cli/conf.d/docker-php-quannl.ini &&\
	echo "upload_max_filesize = 100M"  >> /etc/php/8.1/cli/conf.d/docker-php-quannl.ini &&\
    echo "post_max_size = 100M"  >> /etc/php/8.1/cli/conf.d/docker-php-quannl.ini &&\
    echo "memory_limit = 4096M"  >> /etc/php/8.1/cli/conf.d/docker-php-quannl.ini
	

#RUN apt-get -y install vim 


#INSTALL OpenSSH
#RUN apt-get -y install openssh-server
RUN mkdir /var/run/sshd

#Set Root password SSH
RUN echo 'root:hellossh' | chpasswd

#Allow Root login
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' \
    /etc/ssh/sshd_config

#SSH login fix
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional \
    pam_loginuid.so@g' -i /etc/pam.d/sshd

EXPOSE 22	

#Commands to be executed by default
CMD ["/usr/sbin/sshd","-D"]

RUN mkdir /var/www 
WORKDIR "/var/www"


