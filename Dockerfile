FROM ubuntu:18.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y software-properties-common locales

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8

RUN apt-add-repository ppa:git-core/ppa -y && \
    apt-get update && \
    apt-get install -y --force-yes \
	    nano \
	    git \
	    curl \
	    mysql-client \
	    vim \
	    wget \
        zsh \
        iputils-ping \
        gnupg-agent

# nodejs
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
	apt-get update && apt-get install nodejs -y && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
	apt-get update && apt-get install yarn -y

RUN useradd -ms /bin/zsh bronek

WORKDIR /home/bronek

RUN apt-add-repository -y ppa:ondrej/php && apt-get update && apt-get install -y --force-yes \
	php7.3-curl \
	php7.3-gd \
	php7.3-intl \
	php7.3-mysql \
	php7.3-xml \
	php7.3-mbstring \
	php7.3-bcmath \
    php7.3-mongo \
	php7.3-zip \
	php7.3-opcache \
	php7.3-bz2 \
	php7.3-gmp \
	php7.3-redis \
    php7.3-cli \
    php-xdebug

RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

ADD php-conf.ini /etc/php/7.3/cli/conf.d/29-conf.ini

RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > /etc/php/7.3/cli/conf.d/blackfire.ini \
    && curl -o /bin/blackfire https://packages.blackfire.io/binaries/blackfire-agent/1.11.2/blackfire-cli-linux_amd64 \
    && chmod +x /bin/blackfire

RUN rm /etc/php/7.3/cli/conf.d/20-xdebug.ini

RUN wget https://github.com/sharkdp/bat/releases/download/v0.3.0/bat_0.3.0_amd64.deb \
    && dpkg -i bat_0.3.0_amd64.deb \
    && rm bat_0.3.0_amd64.deb

USER bronek

RUN git clone git://github.com/robbyrussell/oh-my-zsh.git /home/bronek/.oh-my-zsh \
      && cp /home/bronek/.oh-my-zsh/templates/zshrc.zsh-template /home/bronek/.zshrc \
      && sed -i.bak 's/robbyrussell/nebirhos/' /home/bronek/.zshrc

RUN echo "plugins=(git docker docker-compose symfony symfony2 composer yarn)" >> /home/bronek/.zshrc

# from https://hub.docker.com/r/themattrix/develop/~/dockerfile/
RUN git clone https://github.com/junegunn/fzf.git /home/bronek/.fzf \
    && (cd /home/bronek/.fzf) \
    && (yes | /home/bronek/.fzf/install)

RUN echo "export FZF_DEFAULT_OPTS='--no-height --no-reverse'" >> /home/bronek/.zshrc

RUN mkdir /home/bronek/current
WORKDIR /home/bronek/current
