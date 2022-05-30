FROM openjdk:11.0.15-jre

COPY target/*.jar /web.jar

CMD java -jar spring-petclinic-*.jar
