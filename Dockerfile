# --- Étape 1 : build de l'application avec Maven ---
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
# Télécharge les dépendances en cache (accélère les builds suivants)
RUN mvn dependency:go-offline -B
COPY src ./src
RUN mvn clean package -DskipTests

# --- Étape 2 : image finale, légère, sans Maven ni sources ---
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Bonnes pratiques sécurité : ne pas rouler en root
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
