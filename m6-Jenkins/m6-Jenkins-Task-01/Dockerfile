FROM maven:3.8.1-adoptopenjdk-11 as mvn-package
ENV HOME=/usr/app
RUN mkdir -p $HOME
WORKDIR $HOME
COPY pom.xml $HOME
RUN mvn verify --fail-never
COPY . $HOME
RUN mvn package

FROM openjdk:11-jre-slim
ARG TOMCAT_PORT
COPY --from=mvn-package /usr/app/target/*.jar /app/app.jar
RUN ls -lah \
    && ls -lah /app
EXPOSE ${TOMCAT_PORT}
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
