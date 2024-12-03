FROM alpine:latest

WORKDIR /app

# avoid errors/configuration issues while installing other packages
ARG TZ=Europe/Paris
ENV LANG=fr_FR.UTF-8
ENV DEVKITPRO=/opt/devkitpro
ENV DEVKITARM=/opt/devkitpro/devkitARM
ENV PATH=/opt/devkitpro/tools/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN apk update
RUN apk upgrade
RUN apk add --no-cache tzdata pacman wget make cmake

RUN echo -e "[dkp-libs]\nSigLevel = Optional TrustAll\nServer = https://pkg.devkitpro.org/packages" >> /etc/pacman.conf
RUN echo -e "[dkp-linux-musl]\nSigLevel = Optional TrustAll\nServer = https://pkg.devkitpro.org/packages/linux-musl/\$arch/" >> /etc/pacman.conf

RUN pacman-key --init
RUN pacman-key --recv BC26F752D25B92CE272E0F44F7FD5492264BB9D0 --keyserver keyserver.ubuntu.com
RUN pacman-key --lsign BC26F752D25B92CE272E0F44F7FD5492264BB9D0
RUN wget -S https://pkg.devkitpro.org/devkitpro-keyring.pkg.tar.xz
RUN pacman -U --noconfirm devkitpro-keyring.pkg.tar.xz
RUN pacman-key --populate devkitpro
RUN rm devkitpro-keyring.pkg.tar.xz

RUN pacman -Syu --noconfirm
RUN pacman -Sy --noconfirm switch-dev

ENTRYPOINT ["sh"]
