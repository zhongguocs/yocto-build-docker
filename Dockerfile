FROM ubuntu:16.04

MAINTAINER Xiaofeng Wei <xiaofeng.wei@nxp.com>

ARG http_proxy
ENV http_proxy $http_proxy
ARG https_proxy
ENV https_proxy $https_proxy
ARG no_proxy
ENV no_proxy $no_proxy
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
#RUN echo "Acquire::http::proxy \"$http_proxy\";" | tee -a /etc/apt/apt.conf
#RUN echo "Acquire::https::proxy \"$https_proxy\";" | tee -a /etc/apt/apt.conf

RUN apt-get update && apt-get -y upgrade

# Required Packages for the Host Development System
# http://www.yoctoproject.org/docs/latest/mega-manual/mega-manual.html#required-packages-for-the-host-development-system
RUN apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib g++-multilib \
     build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
     apt-utils tmux xz-utils debianutils iputils-ping libncurses5-dev

# Additional host packages required by poky/scripts/wic
RUN apt-get install -y curl dosfstools mtools parted syslinux tree zip

# Additional host packages required by i.MX layers
RUN apt-get install -y curl repo u-boot-tools

# Add "repo" tool (used by many Yocto-based projects)
#RUN curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
#RUN chmod a+x /usr/local/bin/repo

# Create a non-root user that will perform the actual build
RUN id build 2>/dev/null || useradd --uid 1000 --create-home build
RUN apt-get install -y sudo
RUN echo "build ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

# Fix error "Please use a locale setting which supports utf-8."
# See https://wiki.yoctoproject.org/wiki/TipsAndTricks/ResolvingLocaleIssues
RUN apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
        echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
        dpkg-reconfigure --frontend=noninteractive locales && \
        update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# install tzdata
#RUN apt-get install -y tzdata
# set timezone
#ENV TZ=Asia/Shanghai
#RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY apt.conf /etc/apt/apt.conf

COPY gitconfig /home/build/.gitconfig

USER build
WORKDIR /home/build
CMD "/bin/bash"

# EOF
