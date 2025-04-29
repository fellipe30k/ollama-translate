# 🌐 Ollama Translator Service

Serviço de tradução que utiliza o modelo Mistral do Ollama para traduzir textos entre Português e Inglês.

## 📋 Índice

- [🚀 Começando](#-começando)
- [🔧 Configuração](#-configuração)
- [🛣️ API Endpoints](#️-api-endpoints)
- [📝 Exemplos de Uso](#-exemplos-de-uso)
- [🔍 Monitoramento](#-monitoramento)
- [❓ Troubleshooting](#-troubleshooting)

## 🚀 Começando

Este serviço oferece uma API simples para tradução de textos utilizando o modelo Mistral do Ollama, executando tudo em Docker para facilitar o deploy e a manutenção.

### 🧰 Pré-requisitos

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Make](https://www.gnu.org/software/make/) (opcional, mas recomendado)

## 🔧 Configuração

1. **Clone o repositório**

```bash
git clone <repository-url>
cd ollama-translator
```

2. **Construa e inicie os serviços**

```bash
# Iniciar tudo com apenas um comando
make all

# Ou passo a passo
make build  # Constrói as imagens
make up     # Inicia os containers
```

3. **Verificar se tudo está funcionando**

```bash
make status
make check-model  # Verifica se o modelo Mistral foi baixado corretamente
```

## 🛣️ API Endpoints

| Método | Endpoint | Descrição | Parâmetros | Formato de Resposta |
|--------|----------|-----------|------------|---------------------|
| `POST` | `/pt-to-en` | 🇧🇷➡️🇺🇸 Traduz de Português para Inglês | JSON: `{"inputs": "texto em português"}` | `[{"translation_text": "translated text"}]` |
| `POST` | `/en-to-pt` | 🇺🇸➡️🇧🇷 Traduz de Inglês para Português | JSON: `{"inputs": "text in english"}` | `[{"translation_text": "texto traduzido"}]` |
| `GET`  | `/status` | ℹ️ Verifica o status do serviço | Nenhum | `{"status": "online", "model": "mistral", "endpoints": ["/pt-to-en", "/en-to-pt"]}` |

## 📝 Exemplos de Uso

### 🇧🇷➡️🇺🇸 Traduzindo de Português para Inglês

```bash
curl -X POST http://localhost:3008/pt-to-en \
  -H "Content-Type: application/json" \
  -d '{"inputs": "Olá mundo! Como você está hoje?"}'
```

**Resposta esperada:**
```json
[
  {
    "translation_text": "Hello world! How are you today?"
  }
]
```

### 🇺🇸➡️🇧🇷 Traduzindo de Inglês para Português

```bash
curl -X POST http://localhost:3008/en-to-pt \
  -H "Content-Type: application/json" \
  -d '{"inputs": "Hello world! How are you today?"}'
```

**Resposta esperada:**
```json
[
  {
    "translation_text": "Olá mundo! Como você está hoje?"
  }
]
```

### ℹ️ Verificando o status do serviço

```bash
curl http://localhost:3008/status
```

**Resposta esperada:**
```json
{
  "status": "online",
  "model": "mistral",
  "endpoints": ["/pt-to-en", "/en-to-pt"]
}
```

## 🔍 Monitoramento

Você pode monitorar o serviço através dos logs:

```bash
# Logs de todos os serviços
make logs

# Apenas logs do serviço de tradução
make logs-translator

# Apenas logs do Ollama
make logs-ollama
```

## 🛠️ Comandos Úteis do Makefile

| Comando | Descrição |
|---------|-----------|
| `make all` | 🚀 Constrói, inicia e configura tudo |
| `make build` | 🏗️ Constrói as imagens Docker |
| `make up` | ⬆️ Inicia os containers |
| `make down` | ⬇️ Para os containers |
| `make restart` | 🔄 Reinicia todos os serviços |
| `make logs` | 📋 Mostra logs de todos os serviços |
| `make logs-translator` | 📋 Mostra logs do tradutor |
| `make logs-ollama` | 📋 Mostra logs do Ollama |
| `make status` | ℹ️ Verifica o status dos containers |
| `make check-model` | 🔍 Lista os modelos instalados no Ollama |
| `make download-model` | ⬇️ Força o download do modelo Mistral |
| `make clean` | 🧹 Remove containers, volumes e imagens |

## ❓ Troubleshooting

**O serviço de tradução não está funcionando:**

1. Verifique se o Ollama está em execução:
   ```bash
   make logs-ollama
   ```

2. Verifique se o modelo Mistral foi baixado corretamente:
   ```bash
   make check-model
   ```

3. Reinicie os serviços:
   ```bash
   make restart
   ```

4. Se o problema persistir, tente limpar e reconstruir tudo:
   ```bash
   make clean
   make all
   ```

---

📝 **Nota:** O serviço mantém um cache de traduções para melhorar o desempenho. As traduções frequentes serão respondidas mais rapidamente.

🛡️ **Segurança:** Este serviço está configurado para aceitar conexões de qualquer origem (CORS habilitado). Em ambientes de produção, considere restringir os cabeçalhos CORS para origens específicas.

🔧 **Configuração Avançada:** Para personalizar a URL do Ollama ou o modelo utilizado, edite as variáveis de ambiente no arquivo `docker-compose.yml`.