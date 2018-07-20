# === START: INTERMEDIATE BUILD IMAGE ===
# Since Stardog only offers rpm/deb repositories
# we need an intermediate image to pull the latest
# release and later on copy it to the alpine image
FROM centos:7 AS INSTALL_IMAGE

# VERSION can be specified to download a specific
# version of Stardog
ARG VERSION=0

# Install stardog from its repo
RUN curl http://packages.stardog.com/rpms/stardog.repo > /etc/yum.repos.d/stardog.repo && \
	if [ $VERSION -eq 0 ]; then yum install -y stardog; else yum install -y stardog-$VERSION-1; fi

# === END: INTERMEDIATE BUILD IMAGE ===

FROM openjdk:8-alpine

# Install bash since Stardog init scripts need it
RUN apk add --update \
	bash \
	&& rm -rf /var/cache/apk/*

# Stardog needs this environment variable to
# locate its data
ENV STARDOG_HOME /stardog

# Add Stardog bin directory to the PATH env so
# Stardog binaries can be executed directly
ENV PATH /opt/stardog/bin:${PATH}

RUN mkdir -p ${STARDOG_HOME}
RUN mkdir -p /opt/stardog/bin

# Copy the previously installed binaries (from the
# intermediate image)
COPY --from=INSTALL_IMAGE /opt/stardog /opt/stardog

WORKDIR /opt/stardog/bin

VOLUME [ "/stardog" ]

EXPOSE 5820

ENTRYPOINT [ "/bin/bash" ]