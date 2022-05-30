FROM openjdk:11.0.15-jre

COPY target/*.jar /web.jar

ENTRYPOINT [ "java", "-jar", "/web.jar" ]
