# Build stage
FROM maven:3.9.6-eclipse-temurin-11 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Run stage
FROM tomcat:10.1-jdk11
# Delete existing ROOT app
RUN rm -rf /usr/local/tomcat/webapps/ROOT
# Copy WAR file and rename to ROOT.war to serve at /
COPY --from=build /app/target/Precipation_Assigment-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
