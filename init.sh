#!/usr/bin/env bash
#/+++++++++++++++++ SHIKIGAMI SETUP v0.0.1 +++++\
#| This script will install all dependencies    |
#| required to run Shikigami. It will also      |
#| create the config directory and copy the     |
#| config files if they do not exist.           |
#\+++++++++++++++++++++++++++++++++++++++++++++/
RUBY_VERS="3.1.4"
NODE_VERS="16.20"
#===========================<[ RVM INSTALL...
if ! [ -d $HOME/.rvm ]; then
        echo "Installing RVM..."
        curl -sSL https://rvm.io/mpapis.asc | gpg --import -
        curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
        curl -sSL https://get.rvm.io | bash -s stable
        bash -c "source $HOME/.rvm/scripts/rvm && rvm get head && rvm install $RUBY_VERS"
fi

#===========================<[ NVM INSTALL...
if ! [ -d $HOME/.nvm ]; then
        echo "Installing NVM..."
        mkdir $HOME/.nvm
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
        bash -c "source $HOME/.nvm/nvm.sh && nvm install $NODE_VERS"
fi

#===========================<[ CONFIG DIR CREATION...
if ! [ -d $HOME/.config ]; then
        echo "Creating config directory..."
        mkdir $HOME/.config
fi
if ! [ -d $HOME/.config/shikigami ]; then
        echo "Creating shikigami config directory..."
        mkdir $HOME/.config/shikigami
fi

#===========================<[ CHECK FOR USER CONFIG...
if ! [ -f ./config.yml ] && ! [ -f $HOME/.config/shikigami/config.yml ]; then
        echo 'ERROR: config.yml does not exist, aborting!'
        exit 1;
fi #~WARNING~: the next line will ALWAYS overwrite with config.yml from the repo!
if [ -f ./config.yml ]; then
        echo "Copying shikigami config file..."
        cp ./config.yml $HOME/.config/shikigami/config.yml
fi

#===========================<[ CHECK FOR PM2 CONFIG...
if ! [ -f ./ecosystem.config.js ]; then
        echo 'WARNING: copying example ecosystem file to use...'
        cp ./example.ecosystem.config.js ./ecosystem.config.js
fi

#===========================<[ INSTALL DEPENDENCIES...
bash -c "source $HOME/.nvm/nvm.sh && npm install pm2 -g"
bash -c "source $HOME/.rvm/scripts/rvm && rvm gemset create shikigami"
bash -c "source $HOME/.rvm/environments/ruby-3.1.4@shikigami && gem install bundler"
bash -c "source $HOME/.rvm/environments/ruby-3.1.4@shikigami && bundle"
#===========================<[ PERSIST ENVIRONMENT...
bash -c "source $HOME/.rvm/environments/ruby-3.1.4@shikigami && rvm cron setup"
bash -c "source $HOME/.rvm/environments/ruby-3.1.4@shikigami && rvm --default use ruby-3.1.4@shikigami"

#===========================<[ INITIALIZE SUBMODULES...
git submodule update --init --recursive

#===========================<[ BUILD BEANSTALK...
cd beanstalkd/
make
