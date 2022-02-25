#!/bin/bash

set -e

# PATH
echo -e "\n" >> ~/.zshrc
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Ruby
curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
echo 409B6B1796C275462A1703113804BB82D39DC0E3:6: | gpg --import-ownertrust
echo 7D2BAF1CF37B13E2069D6956105BD0E739499BDB:6: | gpg --import-ownertrust
curl -sSL https://get.rvm.io | bash
source ~/.rvm/scripts/rvm
rvm install $RUBY_VERSION
rvm use $RUBY_VERSION --default
ruby --version

# Xcode
echo 'ec2-user ALL=(ALL) NOPASSWD: ALL' | sudo EDITOR='tee -a' visudo
gem install xcode-install
xcversion install $XCODE_VERSION
xcversion select $XCODE_VERSION
