# syntax=docker/dockerfile:1
ARG OS_TYPE=ubuntu
ARG OS_VERSION=22.04
FROM ${OS_TYPE}:${OS_VERSION}

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install tzdata apt-utils \
    gcc make \
    debhelper dpkg-dev quilt lsb-release libssl-dev pkg-config help2man

ARG LUAJIT_DEB_VERSION
ARG LUAJIT_DEB_OS_ID
RUN mkdir -p /depends
RUN curl -sSL https://github.com/hnakamur/openresty-luajit-deb-docker/releases/download/${LUAJIT_DEB_VERSION}${LUAJIT_DEB_OS_ID}/openresty-luajit-${LUAJIT_DEB_VERSION}${LUAJIT_DEB_OS_ID}.tar.gz | tar zxf - -C /depends --strip-components=2
RUN dpkg -i /depends/*.deb

ARG SRC_DIR=/src
ARG BUILD_USER=wrk
RUN adduser --system --group ${BUILD_USER}

COPY --chown=${BUILD_USER}:${BUILD_USER} ./wrk/ ${SRC_DIR}/wrk/

USER ${BUILD_USER}
WORKDIR ${SRC_DIR}
ARG PKG_VERSION
RUN tar cf - wrk | xz > wrk_${PKG_VERSION}.orig.tar.xz

COPY --chown=${BUILD_USER}:${BUILD_USER} ./debian ${SRC_DIR}/wrk/debian/
WORKDIR ${SRC_DIR}/wrk
ARG PKG_REL_DISTRIB
RUN sed -i "s/DebRelDistrib/${PKG_REL_DISTRIB}/;s/UNRELEASED/$(lsb_release -cs)/" ${SRC_DIR}/wrk/debian/changelog
RUN dpkg-buildpackage -us -uc

USER root
