# 🚀 **GUÍA COMPLETO: Como Baixar e Rodar a API Smarth Property**

Este guia ensinará **passo a passo** como baixar o projeto e executar a API.

---

## 📋 **PRÉ-REQUISITOS**

### **1. Instalar Java JDK 17+**
```bash
# Verificar se já tem Java
java --version

# Se não tiver, baixe em:
# https://adoptium.net/temurin/releases/?version=17
```

### **2. Instalar PostgreSQL** (Banco de dados)
```bash
# Baixe PostgreSQL do site oficial:
# https://www.postgresql.org/download/
```

---

## 📥 **PASSO 1: BAIXAR O PROJETO**

### **Opção 1: Via Git (Recomendado)**
```bash
# Instalar Git primeiro se não tiver
# Site: https://git-scm.com/downloads

# Baixar o projeto
git clone https://github.com/Ivany23/SmarthProperty-Marketplace.git

# Entrar na pasta
cd SmarthProperty-Marketplace
```

### **Opção 2: Download ZIP**
```
1. Acesse: https://github.com/Ivany23/SmarthProperty-Marketplace
2. Clique em "Code"
3. Clique em "Download ZIP"
4. Extraia o arquivo ZIP
5. Abra a pasta extraída no VS Code ou editor de sua preferência
```

---

## 🗄️ **PASSO 2: CONFIGURAR O BANCO DE DADOS**

### **1. Criar Base de Dados no PostgreSQL**
```sql
-- Abrir pgAdmin (instalado junto com PostgreSQL)
-- Criar nova database chamada 'smart_property'

CREATE DATABASE smart_property;
```

### **2. Abrir arquivo de configuração**
- Vá para a pasta `backend/`
- Abra o arquivo `src/main/resources/application.properties`
- Configure sua conexão:

```properties
# Configurações do Banco de Dados
spring.datasource.url=jdbc:postgresql://localhost:5432/smart_property
spring.datasource.username=postgres
spring.datasource.password=sua_senha_aqui

# Outras configurações (mantenha assim)
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.datasource.driver-class-name=org.postgresql.Driver
spring.sql.init.platform=postgres

# Porta da aplicação
server.port=8080
```

---

## 🏃‍♂️ **PASSO 3: EXECUTAR A API**

### **Opção 1: Via VS Code (Recomendado)**
```bash
# Abrir o projeto no VS Code
code .

# Abrir terminal integrado (Ctrl + Shift + ')
# Entrar na pasta backend
cd backend

# Executar a API
./mvnw.cmd spring-boot:run
```
**Nota:** Arquivo `mvnw.cmd` é para Windows. Use `./mvnw` no Linux/Mac.

### **Opção 2: Via Terminal**
```bash
# Abra um terminal (Command Prompt, PowerShell, ou Git Bash)
# Navegue até a pasta do projeto
cd desktop/SmarthProperty-Marketplace

# Entre na pasta backend
cd backend

# Execute a API
mvnw.cmd spring-boot:run
```

---

## 📊 **PASSO 4: VERIFICAR SE ESTÁ FUNCIONANDO**

### **1. Verificar Logs no Terminal**
Você deve ver algo como:
```
Tomcat started on port 8080 (http) with context path ''
Started ApiApplication in 12.814 seconds
HikariPool-1 - Start completed.
```

### **2. Acessar o Swagger (Documentação da API)**
Abra seu navegador e vá para:
```
http://localhost:8080/swagger-ui.html
```

### **3. Testar API**
- Vá para: `http://localhost:8080/api/visitante/listar`
- Deve retornar uma lista vazia de visitantes

### **4. Verificar Banco de Dados**
- Abra pgAdmin
- Verifique se tabelas foram criadas automaticamente:
  - `anunciante`
  - `credito`
  - `documento_verificacao`
  - `imovel`
  - `imovel_imagem`
  - `pagamento`
  - `visitante`

---

## 📁 **ESTRUTURA DO PROJETO**

```
backend/
├── src/main/java/com/example/api/
│   ├── controllers/          # Endpoints da API
│   ├── entities/            # Entidades do banco
│   ├── repositories/        # Acesso ao banco
│   └── services/            # Lógica de negócio
├── src/main/resources/
│   └── application.properties # Configurações
└── uploads/                 # Imagens serão salvas aqui
```

---

## 🛠️ **RESOLUÇÃO DE PROBLEMAS**

### **Problema 1: Porta 8080 já está ocupada**
```bash
# No application.properties, mude:
server.port=8081

# Depois reinicie a aplicação
```

### **Problema 2: Erro de conexão com PostgreSQL**
```
1. Verifique se PostgreSQL está rodando
2. Confirme usuário/senha no application.properties
3. Certifique-se que o banco 'smart_property' existe
```

### **Problema 3: Java não encontrado**
```
1. Instale Java JDK 17 ou superior
2. Configure variável JAVA_HOME
3. Confirme: java --version
```

### **Problema 4: Maven não encontrado**
```
1. Use o Maven Wrapper (mvnw.cmd) que vem com o projeto
2. Ou instale Maven: https://maven.apache.org/download.cgi
```

---

## 🧪 **TESTANDO OS ENDPOINTS**

### **Testar Visitantes:**
```bash
# Listar todos visitantes
GET http://localhost:8080/api/visitante/listar

# Buscar específico
GET http://localhost:8080/api/visitante/buscar/1

# Criar visitante via autenticação:
POST http://localhost:8080/api/registro
```

### **Testar Imóveis:**
```bash
# Criar imóvel (com imagem opcional)
POST http://localhost:8080/api/imovel/criar

# Listar imóveis disponíveis
GET http://localhost:8080/api/imovel/listar
```

### **Testar Imagens:**
```bash
# Listar imagens de um imóvel
GET http://localhost:8080/api/imovel_imagem/imovel/1

# Adicionar imagem à galeria
POST http://localhost:8080/api/imovel_imagem/adicionar
```

---

## 📝 **DICAS IMPORTANTES**

### **1. Sempre rode na pasta `backend/`:**
```bash
cd backend
./mvnw.cmd spring-boot:run
```

### **2. Para desenvolvimento:**
- Use **VS Code** com extensão Java
- API roda em **porta 8080** por padrão
- Swagger está em: `http://localhost:8080/swagger-ui.html`

### **3. Para produção:**
- Configure variáveis de ambiente
- Use senha forte no banco
- Configure CORS adequadamente

### **4. Arquivos de imagem serão salvos em:**
```
backend/uploads/properties/
├── main/     # Imagens principais dos imóveis
└── gallery/  # Imagens da galeria
```

---

## ✅ **VERIFICAÇÃO FINAL**

Depois de seguir todos os passos, você deve ter:

✅ **API rodando** em `http://localhost:8080`
✅ **Banco de dados** configurado com PostgreSQL
✅ **Swagger UI** acessível
✅ **Tabelas criadas** automaticamente
✅ **Uploads funcionando** para imagens

🎉 **Agora você pode começar a desenvolver ou testar as funcionalidades da API!**

---

## 🤔 **PRECISA DE AJUDA?**

Se tiver problemas:
1. Verifique os logs no terminal
2. Confirme versões do Java (17+)
3. Teste conexão com PostgreSQL
4. Compartilhe erros específicos
