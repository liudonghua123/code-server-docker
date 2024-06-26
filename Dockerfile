FROM codercom/code-server

# https://docs.docker.com/reference/dockerfile/#maintainer-deprecated
LABEL org.opencontainers.image.authors="liudonghua@ynu.edu.cn"

# use .bash_profile instead of .bashrc
# see also https://unix.stackexchange.com/questions/257571/why-does-bashrc-check-whether-the-current-shell-is-interactive
# and https://askubuntu.com/questions/40287/why-is-etc-profile-not-being-loaded-during-non-login-bash-shell-sessions
ENV PROFILE=/home/coder/.bash_profile
# create if not exists
RUN touch $PROFILE

# install node and python (multi-versions) 
# node
# installs NVM (Node Version Manager)
ENV NVM_DIR /home/coder/.nvm
RUN curl https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
# download and install Node.js
RUN . $PROFILE && nvm install 16
RUN . $PROFILE && nvm install 18
RUN . $PROFILE && nvm install 20

# python
# https://github.com/pyenv/pyenv?tab=readme-ov-file#usage
# install pyenv in /opt rather then /root or /home/coder
ENV PYENV_ROOT=/home/coder/.pyenv
RUN curl https://pyenv.run | bash
# setup pyenv
RUN echo "export PYENV_ROOT=$PYENV_ROOT" >> $PROFILE
RUN echo "command -v pyenv >/dev/null || export PATH=$PYENV_ROOT/bin:$PATH" >> $PROFILE
RUN echo 'eval "$(pyenv init -)"' >> $PROFILE
# install build-essential for python build from source
RUN sudo apt update -y 
RUN sudo apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev libbz2-dev liblzma-dev wget
# install python3 from official python3-dev package which is python3.11
RUN sudo apt install -y python3-dev
RUN . $PROFILE && pyenv install 3.10
RUN . $PROFILE && pyenv install 3.11
RUN . $PROFILE && pyenv install 3.12

# install other packages
RUN sudo apt install -y vim python-is-python3

# other config
RUN echo >> $HOME/.bashrc
RUN echo "[ -s \"$PROFILE\" ] && . $PROFILE # load $PROFILE" >> $HOME/.bashrc
RUN echo 'nvm use 20 1>/dev/null' >> $HOME/.bashrc
RUN echo 'pyenv global 3.12' >> $HOME/.bashrc

# install cnpm
RUN . $PROFILE && nvm use 20 && npm install cnpm -g --registry=https://registry.npmmirror.com

# cleanup
RUN sudo rm -rf /var/lib/apt/lists/*
