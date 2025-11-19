# API Spring Boot - Smarth Property

Esta é a API backend para o aplicativo Flutter Smarth Property.

## 🚀 Como executar

### Pré-requisitos
- Java 22 ou superior
- Maven (ou use o Maven Wrapper incluído)

### Executar a aplicação

#### Opção 1: Usando Maven Wrapper (Recomendado)
```bash
# No Windows
.\mvnw.cmd spring-boot:run

# No Linux/Mac
./mvnw spring-boot:run
```

#### Opção 2: Usando Maven instalado
```bash
mvn spring-boot:run
```

A aplicação será executada na porta 8080.

## 📡 Endpoints da API

### Teste de conexão
```
GET /api/test
```
Retorna status da API.

### Listar propriedades
```
GET /api/properties
```
Retorna lista de propriedades disponíveis.

### Login
```
POST /api/login
Content-Type: application/json

{
  "email": "ivanymassinga@gmail.com",
  "password": "1234"
}
```

## 🗄️ Banco de Dados

Por enquanto, a API usa dados mockados. Para conectar ao PostgreSQL, descomente as configurações no `application.properties`:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/nopin_db
spring.datasource.username=postgres
spring.datasource.password=password
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
```

## 🛠️ Tecnologias utilizadas

- Spring Boot 3.2.0
- Java 22
- Maven
- Spring Web
- Spring Data JPA (configurado mas não usado ainda)
- PostgreSQL Driver

## 📁 Estrutura do projeto

```
src/
├── main/
│   ├── java/com/example/api/
│   │   ├── ApiApplication.java          # Classe principal
│   │   └── PropertyController.java      # Controlador REST
│   └── resources/
│       └── application.properties       # Configurações
└── test/
    └── java/com/example/api/
        └── ApiApplicationTests.java     # Testes
```

## 🔧 Desenvolvimento

Para adicionar novos endpoints, edite a classe `PropertyController.java`.

Para modificar configurações, edite o arquivo `application.properties`.
