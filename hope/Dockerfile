FROM maven:3-jdk-11 AS dataturks-be-builder
RUN mkdir /usr/src/dataturks-be
COPY . /usr/src/dataturks-be
WORKDIR /usr/src/dataturks-be
RUN mvn clean install -DskipTests


FROM openjdk:11-jre
RUN mkdir /dataturks-be
COPY --from=dataturks-be-builder /usr/src/dataturks-be/target/dataturks-1.0-SNAPSHOT.jar /dataturks-be/
COPY --from=dataturks-be-builder /usr/src/dataturks-be/onprem.yml /dataturks-be/onprem.yml
EXPOSE 9090
WORKDIR /dataturks-be
CMD java -Djava.net.useSystemProxies=true -server -jar dataturks-1.0-SNAPSHOT.jar server onprem.yml
