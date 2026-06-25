#!/bin/sh
# Download the certificate dynamically into a temporary space
curl -sS "https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem" -o /app/global-bundle.pem

# Start your Java application
exec java -Dspring.profiles.active="$profile" -Dotel.instrumentation.mongo.enabled=true -XX:+UseG1GC -javaagent:/app/aws-opentelemetry-agent.jar -jar /app/workout.jar