FROM eclipse-temurin:25-jre-jammy

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

ADD https://github.com/aws-observability/aws-otel-java-instrumentation/releases/latest/download/aws-opentelemetry-agent.jar /app/aws-opentelemetry-agent.jar
COPY build/libs/workout-*-SNAPSHOT.jar /app/workout.jar
COPY entrypoint.sh /app/entrypoint.sh

# Inform Docker that the container listens on port 8092 at runtime
EXPOSE 8092

# Configure JVM flags optimized for container environments
# ENTRYPOINT ["java", "-XX:+UseG1GC", "-jar", "app.jar"]

RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]