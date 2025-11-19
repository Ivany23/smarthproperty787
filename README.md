# 🏙️ **Smarth Property - Marketplace Imobiliário**

Sistema completo de marketplace imobiliário com App Flutter e API Spring Boot.

## 📋 **O QUE É ISSO?**

Este projeto contém:

### 🏠 **APP FLUTTER**
- Interface mobile para compradores e vendedores
- Maputo, Moçambique focado
- Sistema de anúncios de imóveis

### 🔧 **API SPRING BOOT**
- Backend RESTful
- Banco PostgreSQL
- Upload de imagens
- Autenticação e autorização

---

## 🚀 **COMO COMEÇAR**

### **Para a API (Backend):**
```bash
# 📖 Guia completo passo a passo
# Abra o arquivo: backend/GUIA_DE_EXECUCAO_API.md

# Ou execute rapidamente:
cd backend
./mvnw.cmd spring-boot:run
```

### **Para o App Flutter:**
```bash
# Instalar Flutter: https://flutter.dev/docs/get-started/install
flutter doctor
flutter pub get
flutter run
```

---

## 🗄️ **BANCO DE DADOS**

**Tabelas principais:**
- `visitante` - Usuários visitantes
- `anunciante` - Usuários anunciantes
- `imovel` - Propriedades anunciadas
- `imovel_imagem` - Galeria de fotos
- `pagamento` - Sistema de pagamentos

---

## 📊 **ENDPOINTS PRINCIPAIS**

### **Authentication:**
- `POST /api/registro` - Registrar novo usuário
- `POST /api/login` - Login

### **Imóveis:**
- `POST /api/imovel/criar` - Criar imóvel (com foto opcional)
- `GET /api/imovel/listar` - Listar imóveis disponíveis
- `PUT /api/imovel/atualizar/{id}` - Editar imóvel

### **Imagens:**
- `POST /api/imovel_imagem/adicionar` - Adicionar foto à galeria
- `GET /api/imovel_imagem/imovel/{id}` - Listar fotos do imóvel

### **Visitantes:**
- `GET /api/visitante/listar` - Listar todos visitantes
- `DELETE /api/visitante/deletar/{id}` - Remover visitante

---

## 🛠️ **TECNOLOGIAS**

### **Backend:**
- Java 17+
- Spring Boot 3.2
- PostgreSQL
- Maven
- JPA/Hibernate

### **Frontend:**
- Flutter
- Dart
- Material Design

---

## 📝 **DOCUMENTAÇÃO**

- **API Docs:** `http://localhost:8080/swagger-ui.html`
- **Guia de Execução:** `backend/GUIA_DE_EXECUCAO_API.md`

---

## 📱 **RECURSOS**

- ✅ Upload real de imagens
- ✅ Galeria de fotos por imóvel
- ✅ Autenticação completa
- ✅ Sistema de pagamentos
- ✅ Documentação Swagger automática
- ✅ CORS configurado
- ✅ Validações de dados

🎯 **Pronto para uso em produção ou desenvolvimento!**
