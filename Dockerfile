FROM maven

COPY target/*.jar /web.jar

ENTRYPOINT [ "java", "-jar", "/web.jar" ]
