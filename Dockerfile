# Reference https://github.com/slamont/DataTurks

# Build dataturks backend; dataturks-be (hope)
FROM maven:3-jdk-11 AS dataturks-be-builder
COPY ./hope /tmp/hope
WORKDIR /tmp/hope
RUN ls -la && mvn clean install -DskipTests


# Build dataturks frontend; dataturks-fe (bazaar)
FROM node:carbon-alpine AS dataturks-fe-builder
RUN apk update && \
    apk add python make g++ && \
    npm i -g nodemon && nodemon -v
COPY ./bazaar /tmp/bazaar
WORKDIR /tmp/bazaar
RUN npm install && \
    npm run build-onprem && \
    npm prune && \
    rm -rf src/components && \
    rm -rf src/containers && \
    rm -rf src/theme && \
    rm -rf src/utils


# Create Runtime Container; Common OS is Debian Buster
# Starting with NodeJS installing oracle JRE
FROM  node:12-buster

# installing JRE 11
ENV LANG='en_US.UTF-8' \
    LANGUAGE='en_US:en' \
    LC_ALL='en_US.UTF-8' \
    JAVA_HOME='/opt/java/openjdk' \
    PATH="/opt/java/openjdk/bin:$PATH"

RUN apt-get update && \
    apt-get install -y apache2 && \
    apt-get install -y --no-install-recommends curl ca-certificates fontconfig locales && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

RUN curl -LfsSo /tmp/openjdk.tar.gz 'https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.7%2B10/OpenJDK11U-jre_x64_linux_hotspot_11.0.7_10.tar.gz'; \
    mkdir -p /opt/java/openjdk; \
    cd /opt/java/openjdk; \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1; \
    rm -rf /tmp/openjdk.tar.gz;

# Copy Dataturks artifacts
RUN mkdir -p /home/dataturks /home/dataturks/dataturks-be /home/dataturks/dataturks-fe
COPY --from=dataturks-be-builder /tmp/hope/target/dataturks-1.0-SNAPSHOT.jar /home/dataturks/dataturks-be/
COPY --from=dataturks-fe-builder /tmp/bazaar /home/dataturks/dataturks-fe
COPY --from=dataturks-fe-builder /tmp/bazaar/proxy/onprem-dataturks.com.conf /etc/apache2/sites-available/
COPY --from=dataturks-fe-builder /tmp/bazaar/proxy/onprem-dataturks.com.conf /etc/apache2/sites-available/000-default.conf
COPY startup.sh /home/dataturks

RUN a2enmod proxy_http && \
    a2ensite onprem-dataturks.com.conf

EXPOSE 9090
EXPOSE 3000
EXPOSE 3001
EXPOSE 3030
EXPOSE 80

WORKDIR /home/dataturks
CMD ./startup.sh > ./startup.log
