FROM openjdk:8-alpine

RUN apk add --update \
	bash \
	&& rm -rf /var/cache/apk/*

# Argument to provide stardog zip file to the build process
ARG file

ENV STARDOG_HOME /data
ENV STARDOG_INSTALL_DIR /opt/stardog
ENV PATH ${STARDOG_INSTALL_DIR}/bin:${PATH}

RUN mkdir -p ${STARDOG_HOME}
RUN mkdir -p ${STARDOG_INSTALL_DIR}/bin

# Unzip and install stardog from provided zip file
ADD $file /tmp
RUN apk add --update unzip && \
	rm -rf /var/cache/apk/* && \
	mkdir /tmp/stardog && \
	unzip -qq -d /tmp/stardog /tmp/$file && \
	rm -f /tmp/$file && \
	cp -r /tmp/stardog/$(ls /tmp/stardog)/* ${STARDOG_INSTALL_DIR}/ && \
	rm -rf /tmp/stardog && \
	apk del unzip

WORKDIR ${STARDOG_INSTALL_DIR}/bin

EXPOSE 5820

ENTRYPOINT [ "/bin/bash" ]