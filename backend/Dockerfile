FROM eclipse-temurin:21-jdk


WORKDIR /home/app

COPY . /home/app

RUN chmod +x ./mvnw

EXPOSE 8080


CMD ["./mvnw", "spring-boot:run"]

