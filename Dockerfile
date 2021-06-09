FROM lsiobase/nginx:3.11

# set version label
ARG BUILD_DATE
ARG VERSION
ARG EOC_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	curl && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	mariadb-client \
	php7 \
	php7-mysqli && \
 echo "**** install EQEmuEOC ****" && \
 mkdir -p /app/eoc && \
 if [ -z ${EOC_RELEASE+x} ]; then \
	EOC_RELEASE=$(curl -sX GET "https://api.github.com/repos/Akkadius/EQEmuEOC/commits/master" \
	| awk '/sha/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 	/tmp/server.tar.gz -L \
	"https://github.com/Akkadius/EQEmuEOC/archive/${EOC_RELEASE}.tar.gz" && \
 tar xf \
 	/tmp/server.tar.gz -C \
	/app/eoc/ --strip-components=1 && \
 cd /app/eoc && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache \
	/tmp/*

# copy local files
COPY root/ /
