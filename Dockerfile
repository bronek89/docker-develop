FROM ubuntu:latest
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-add-repository -y ppa:ondrej/php5-5.6

RUN apt-get update && apt-get install -y --force-yes \
	nano \
	tmux \
	byobu \
	git \
	curl \
	php5-cli \
	php5-json \
	php5-redis \
	php5-mcrypt \
	php5-curl \
	php5-gd \
	php5-memcached \
	php5-mysql \
	php5-sqlite \
	php5-xdebug \
	php5-intl \
	zsh

RUN apt-get install -y --force-yes rubygems-integration && gem install tmuxinator

RUN apt-get install -y --force-yes python-pip python-dev && pip install \
    percol \
    eg \
    thefuck

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# nodejs
RUN apt-get update && apt-get install nodejs npm -y --force-yes
RUN npm install -g bower
RUN npm install -g grunt
RUN npm install -g grunt-cli
RUN chmod +x /usr/local/bin/grunt
RUN ln -s /usr/bin/nodejs /usr/bin/node

RUN useradd -ms /bin/zsh bronek
RUN apt-get install -y --force-yes php5-imagick

# Install jq
#RUN cd /opt \
#      && mkdir jq \
#      && wget -O ./jq/jq http://stedolan.github.io/jq/download/linux64/jq \
#      && chmod +x ./jq/jq \
#      && ln -s /opt/jq/jq /usr/local/bin

WORKDIR /home/bronek

RUN git clone git://github.com/robbyrussell/oh-my-zsh.git /home/bronek/.oh-my-zsh \
      && cp /home/bronek/.oh-my-zsh/templates/zshrc.zsh-template /home/bronek/.zshrc \
      && sed -i.bak 's/robbyrussell/nebirhos/' /home/bronek/.zshrc \
      && chown bronek:bronek /home/bronek/.zshrc

USER bronek

# from https://hub.docker.com/r/themattrix/develop/~/dockerfile/
RUN git clone https://github.com/junegunn/fzf.git /home/bronek/.fzf \
    && (cd /home/bronek/.fzf) \
    && (yes | /home/bronek/.fzf/install)

RUN mkdir /home/bronek/.byobu
RUN mkdir /home/bronek/.ssh


