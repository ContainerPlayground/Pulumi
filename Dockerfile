FROM  ubuntu:20.04
LABEL Maintainer="Mauricio Araya"

ENV PATH="/usr/local/pulumi/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV LANGUAGE=en_US
ENV LANG=en_US.UTF-8
RUN export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE='true'

WORKDIR /tmp

RUN export DEBIAN_FRONTEND='noninteractive' APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE='true' \
    && apt-get --yes update && apt-get upgrade -y \
    && apt-get install --yes \
        apt-transport-https \
        curl \
        git \
        gnupg2 \
        openssh-client \
        python3.8 \
        python3-pip \
        unzip \
    && pip3 install --upgrade pip

RUN curl -sSL https://golang.org/dl/go1.15.6.linux-amd64.tar.gz -o /tmp/go-linux-amd64.tar.gz \
    && tar -C /usr/local -xvzf go-linux-amd64.tar.gz

RUN curl -sSL https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -o packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install --yes dotnet-sdk-5.0 \
    && apt-get install --yes aspnetcore-runtime-5.0

RUN curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
COPY files/nodesource.list /etc/apt/sources.list.d/nodesource.list
RUN export DEBIAN_FRONTEND='noninteractive' APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE='true' \
    && apt-get --yes update \
    && apt-get install --yes nodejs \
    && npm install -g gulp-cli

RUN export DEBIAN_FRONTEND='noninteractive' \
    && curl -fsSL https://get.pulumi.com \
     | sed -e 's,${HOME}/.pulumi,/usr/local/pulumi,g' \
           -e 's,$HOME/.pulumi,/usr/local/pulumi,g' \
     | sh

RUN curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

RUN useradd -m -d /home/playground \
               -s /bin/bash \
               -c "Pulumi Playground" playground \
    && mkdir -p /home/playground/.ssh \
                /home/playground/.config \
                /home/playground/bin \
                /home/playground/workdir \
    && chown -R playground:playground /home/playground

RUN rm -rf /tmp/* \
    && apt-get --yes clean

WORKDIR /home/playground/workdir
