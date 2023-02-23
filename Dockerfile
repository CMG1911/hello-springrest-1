FROM gradle:8.0.1-jdk17-alpine as Builder
WORKDIR /tmp/app
COPY . .
RUN ./gradlew assemble

FROM amazoncorretto:11-alpine3.17 as Runner
WORKDIR /opt/hello-springrest-1
COPY --from=builder /tmp/app/build/libs/rest-service-0.0.1-SNAPSHOT.jar .
CMD ["java","-jar","/opt/hello-springrest-1/rest-service-0.0.1-SNAPSHOT.jar"]
LABEL org.opencontainers.image.source https://github.com/CMG1911/hello-springrest-1
