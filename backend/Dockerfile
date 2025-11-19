
# Use uma imagem base oficial do Maven para construir o artefato
FROM maven:3.8.5-openjdk-17 AS build

# Defina o diretório de trabalho
WORKDIR /app

# Copie o arquivo pom.xml e baixe as dependências
COPY pom.xml .
RUN mvn dependency:go-offline

# Copie o resto do código fonte da aplicação
COPY src ./src

# Compile a aplicação e empacote em um JAR, pulando os testes para acelerar
RUN mvn clean package -DskipTests


# Use uma imagem base oficial do OpenJDK para a execução
FROM openjdk:17-jdk-slim

# Defina o diretório de trabalho
WORKDIR /app

# Copie o JAR construído da fase de 'build' para a imagem final
COPY --from=build /app/target/*.jar app.jar

# Exponha a porta que a aplicação vai rodar
EXPOSE 8080

# Comando para executar a aplicação quando o contêiner iniciar
ENTRYPOINT ["java","-jar","app.jar"]
