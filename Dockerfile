FROM maven:3.9.6-eclipse-temurin-17-alpine AS build
WORKDIR /app

COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/myapp.jar ./Kitchen-control-backend.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "Kitchen-control-backend.jar"]